"""
AWS Lambda Handler for Blot Parser
Processes S3 upload events and saves data to DynamoDB
"""

import json
import boto3
import os
import pandas as pd
from typing import Dict, Any, List
import logging
from io import BytesIO

from blot_parser import BlotParser
from field_mapper import FieldMapper
from excel_processor import ExcelProcessor
from vendor_detector import VendorDetector

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# Environment variables
DYNAMODB_TABLE_NAME = os.environ.get('DYNAMODB_TABLE_NAME', 'blot-parser-data')
DYNAMODB_STATUS_TABLE_NAME = os.environ.get('DYNAMODB_STATUS_TABLE_NAME', 'blot-parser-status')
S3_BUCKET = os.environ.get('S3_BUCKET', 'blot-parser-input')


class LambdaBlotParser:
    """AWS Lambda version of Blot Parser with S3 and DynamoDB integration"""
    
    def __init__(self):
        """Initialize the Lambda blot parser"""
        self.field_mapper = FieldMapper()
        self.excel_processor = ExcelProcessor()
        self.vendor_detector = VendorDetector()
        self.dynamodb_table = dynamodb.Table(DYNAMODB_TABLE_NAME)
        self.status_table = dynamodb.Table(DYNAMODB_STATUS_TABLE_NAME)
    
    def process_s3_event(self, event: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process S3 upload event
        
        Args:
            event: S3 event from Lambda
            
        Returns:
            Processing result
        """
        try:
            # Extract S3 event details
            records = event.get('Records', [])
            results = []
            
            for record in records:
                try:
                    # Get S3 object details
                    bucket = record['s3']['bucket']['name']
                    key = record['s3']['object']['key']
                    
                    logger.info(f"Processing S3 object: s3://{bucket}/{key}")
                    
                    # Process the file
                    result = self.process_s3_file(bucket, key)
                    results.append(result)
                    
                except Exception as e:
                    logger.error(f"Error processing S3 record: {str(e)}")
                    results.append({
                        'status': 'error',
                        'error': str(e),
                        'record': record
                    })
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Processing completed',
                    'results': results
                })
            }
            
        except Exception as e:
            logger.error(f"Error processing S3 event: {str(e)}")
            return {
                'statusCode': 500,
                'body': json.dumps({
                    'error': str(e)
                })
            }
    
    def process_s3_file(self, bucket: str, key: str) -> Dict[str, Any]:
        """
        Process Excel file from S3
        
        Args:
            bucket: S3 bucket name
            key: S3 object key
            
        Returns:
            Processing result
        """
        try:
            # Extract vendor from filename
            filename = key.split('/')[-1]
            vendor = self.vendor_detector.extract_vendor_from_filename(filename)
            
            # Save processing status
            self.save_processing_status(filename, vendor, 'processing', 'Starting file processing')
            
            # Download file from S3
            response = s3_client.get_object(Bucket=bucket, Key=key)
            file_content = response['Body'].read()
            
            # Process Excel file
            excel_data = self.excel_processor.read_excel_file_from_bytes(file_content, filename)
            
            if not excel_data:
                return {
                    'status': 'error',
                    'message': f'Failed to read Excel file: {filename}',
                    'file': filename
                }
            
            # Process each sheet
            all_records = []
            for sheet_name, df in excel_data.items():
                sheet_data = self.excel_processor.process_sheet(sheet_name, df, filename)
                all_records.extend(sheet_data['data'])
            
            # Map vendor-specific fields to generic fields
            logger.info(f"Mapping {len(all_records)} records from {vendor} to system format")
            mapped_records = self.field_mapper.map_records(all_records, vendor)
            
            # Save to DynamoDB
            saved_count = self.save_to_dynamodb(mapped_records, filename, vendor)
            
            # Save completion status
            self.save_processing_status(filename, vendor, 'completed', f'Successfully processed {saved_count} records')
            
            return {
                'status': 'success',
                'file': filename,
                'vendor': vendor,
                'records_processed': len(mapped_records),
                'records_saved': saved_count
            }
            
        except Exception as e:
            logger.error(f"Error processing S3 file {key}: {str(e)}")
            
            # Save error status
            filename = key.split('/')[-1]
            vendor = self.vendor_detector.extract_vendor_from_filename(filename)
            self.save_processing_status(filename, vendor, 'error', f'Processing failed: {str(e)}')
            
            return {
                'status': 'error',
                'message': str(e),
                'file': key
            }
    
    def save_to_dynamodb(self, records: List[Dict[str, Any]], filename: str, vendor: str) -> int:
        """
        Save records to DynamoDB
        
        Args:
            records: List of records to save
            filename: Source filename
            vendor: Vendor name
            
        Returns:
            Number of records saved
        """
        saved_count = 0
        
        for i, record in enumerate(records):
            try:
                # Add metadata
                record['id'] = f"{vendor}_{filename}_{i}"
                record['source_file'] = filename
                record['vendor'] = vendor
                record['processed_at'] = str(pd.Timestamp.now())
                
                # Set TTL to 90 days from now (DynamoDB TTL expects Unix timestamp)
                import time
                ttl_timestamp = int(time.time()) + (90 * 24 * 60 * 60)  # 90 days in seconds
                record['ttl'] = ttl_timestamp
                
                # Save to DynamoDB
                self.dynamodb_table.put_item(Item=record)
                saved_count += 1
                
            except Exception as e:
                logger.error(f"Error saving record {i} to DynamoDB: {str(e)}")
        
        logger.info(f"Saved {saved_count}/{len(records)} records to DynamoDB")
        return saved_count
    
    def save_processing_status(self, filename: str, vendor: str, status: str, message: str = None) -> None:
        """
        Save file processing status to DynamoDB status table
        
        Args:
            filename: Source filename
            vendor: Vendor name
            status: Processing status (processing, completed, error)
            message: Optional status message
        """
        try:
            import time
            
            # Set TTL to 90 days from now (DynamoDB TTL expects Unix timestamp)
            ttl_timestamp = int(time.time()) + (90 * 24 * 60 * 60)  # 90 days in seconds
            
            status_record = {
                'file_name': filename,
                'processed_at': str(pd.Timestamp.now()),
                'vendor': vendor,
                'status': status,
                'ttl': ttl_timestamp
            }
            
            if message:
                status_record['message'] = message
                
            self.status_table.put_item(Item=status_record)
            logger.info(f"Saved processing status for {filename}: {status}")
            
        except Exception as e:
            logger.error(f"Error saving status for {filename}: {str(e)}")


def lambda_handler(event, context):
    """
    AWS Lambda handler function
    
    Args:
        event: Lambda event (S3 event)
        context: Lambda context
        
    Returns:
        Lambda response
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Initialize parser
    parser = LambdaBlotParser()
    
    # Process S3 event
    result = parser.process_s3_event(event)
    
    logger.info(f"Processing result: {json.dumps(result)}")
    return result
