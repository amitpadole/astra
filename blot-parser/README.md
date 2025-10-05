# Blot Parser - AWS Lambda Implementation

A serverless Python utility for parsing Excel files with automatic vendor detection and field mapping, deployed as an AWS Lambda function.

## Architecture

The code follows clean code principles with single responsibility modules:

```
blot-parser/
├── lambda_function.py      # Lambda entry point
├── lambda_handler.py       # S3 event handler
├── blot_parser.py          # Main orchestrator
├── field_mapper.py         # Field mapping logic
├── excel_processor.py     # Excel file processing
├── vendor_detector.py      # Vendor name extraction
├── file_manager.py         # File operations
├── config.py             # Configuration settings
├── mappings/             # Field mapping CSV files
│   ├── bloomberg.csv     # Bloomberg field mappings
│   ├── platform.csv      # Platform field mappings
│   └── generic.csv       # Generic field mappings
├── requirements-lambda.txt # Lambda dependencies
├── deploy-lambda.sh       # Lambda deployment script
└── README.md             # This file
```

## AWS Integration

### 🚀 Serverless Architecture

| Component | Purpose | AWS Service |
|-----------|---------|-------------|
| **File Upload** | Excel files uploaded to S3 | S3 Bucket |
| **Event Trigger** | S3 upload triggers processing | S3 Event Notification |
| **Processing** | Excel parsing and field mapping | Lambda Function |
| **Data Storage** | Processed JSON data storage | DynamoDB Table |
| **Monitoring** | Logs and metrics | CloudWatch |

### 📊 Processing Flow

1. **Excel file** uploaded to S3 Input Bucket
2. **S3 event** triggers Lambda function
3. **Lambda downloads** file from S3
4. **Vendor detection** from filename
5. **Excel processing** and data cleaning
6. **Field mapping** using vendor-specific CSV
7. **Data storage** in DynamoDB table
8. **Results** available for querying

## Features

- **Serverless Processing**: Automatic scaling with AWS Lambda
- **S3 Integration**: Direct processing from S3 uploads
- **DynamoDB Storage**: NoSQL database for processed data
- **Automatic Vendor Detection**: Extracts vendor from filename
- **CSV-based Field Mapping**: Vendor-specific field mappings
- **Error Handling**: Comprehensive error recovery
- **CloudWatch Logging**: Full observability

## Deployment

### Prerequisites

1. **AWS Infrastructure** deployed (see `../aws-infra/`)
2. **AWS CLI** configured with appropriate permissions
3. **Python 3.11+** installed
4. **Environment file** (`.env`) created by infrastructure deployment

### Step 1: Deploy Infrastructure

```bash
# Deploy shared AWS infrastructure first
cd ../aws-infra
./deploy-infrastructure.sh dev us-east-1
```

### Step 2: Deploy Lambda Function

```bash
# Deploy the blot-parser Lambda function
./deploy-lambda.sh
```

## Usage

### File Upload

Upload Excel files to the S3 Input Bucket:

```bash
# Upload file to S3
aws s3 cp bloomberg-trade-data.xlsx s3://blot-parser-input-dev-123456789/

# File will be automatically processed by Lambda
```

### File Naming Convention

The parser extracts vendor name from filename:

```
bloomberg-trade-data.xlsx     → vendor: "bloomberg"
reuters_market_data.xlsx     → vendor: "reuters"  
refinitiv.fixed.income.xlsx   → vendor: "refinitiv"
```

### CSV Mapping Format

Field mappings are stored in the `mappings/` directory:

```
mappings/
├── bloomberg.csv    # Bloomberg field mappings
├── reuters.csv      # Reuters field mappings
└── [vendor].csv     # Other vendor mappings
```

Each CSV file structure:

```csv
vendor_field,system_field,description
Status,trade_status,Trade status
Security,security_name,Security name
BrkrName,broker_name,Broker name
```

## Data Output

### DynamoDB Schema

Processed data is stored in DynamoDB with the following structure:

```json
{
  "id": "bloomberg_trade-data.xlsx_0",
  "source_file": "bloomberg-trade-data.xlsx",
  "vendor": "bloomberg",
  "processed_at": "2025-10-05T10:30:00Z",
  "trade_status": "Accepted",
  "security_name": "Bond Name",
  "broker_name": "Broker Ltd",
  "quantity": 500,
  "price": 99.35,
  "file_name": "bloomberg-trade-data.xlsx"
}
```

### Querying Data

```bash
# Query by vendor
aws dynamodb query \
  --table-name blot-parser-data-dev \
  --index-name VendorIndex \
  --key-condition-expression "vendor = :v" \
  --expression-attribute-values '{":v": {"S": "bloomberg"}}'

# Scan all records
aws dynamodb scan \
  --table-name blot-parser-data-dev
```

## Monitoring

### CloudWatch Logs

```bash
# View Lambda logs
aws logs tail /aws/lambda/blot-parser-dev --follow

# Filter for errors
aws logs filter-log-events \
  --log-group-name /aws/lambda/blot-parser-dev \
  --filter-pattern "ERROR"
```

### Metrics

- **Invocation Count**: Number of Lambda invocations
- **Duration**: Processing time per file
- **Error Rate**: Failed processing percentage
- **DynamoDB Metrics**: Read/Write capacity usage

## Configuration

### Environment Variables

Set by infrastructure deployment:

```bash
DYNAMODB_TABLE_NAME=blot-parser-data-dev
S3_BUCKET=blot-parser-input-dev-123456789
AWS_REGION=us-east-1
```

### Lambda Settings

- **Runtime**: Python 3.11
- **Memory**: 512 MB
- **Timeout**: 5 minutes
- **Handler**: `lambda_function.lambda_handler`

## Error Handling

### Common Issues

1. **Lambda Timeout**: Increase timeout for large files
2. **Memory Issues**: Increase memory allocation
3. **Permission Errors**: Check IAM role permissions
4. **S3 Trigger Not Working**: Verify bucket notification

### Debugging

```bash
# Test Lambda function directly
aws lambda invoke \
  --function-name blot-parser-dev \
  --payload '{"Records":[{"s3":{"bucket":{"name":"test-bucket"},"object":{"key":"test.xlsx"}}}]}' \
  response.json

# Check DynamoDB for processed data
aws dynamodb scan --table-name blot-parser-data-dev --max-items 10
```

## Adding New Vendors

1. **Create CSV mapping**: `mappings/[vendor].csv`
2. **Use standard format**: `vendor_field,system_field,description`
3. **Name files with vendor prefix**: `[vendor]-data.xlsx`
4. **Upload to S3**: File will be automatically processed

## Cost Optimization

### Lambda Optimization

- **Memory**: Right-size based on file size
- **Timeout**: Set appropriate timeout
- **Concurrency**: Control concurrent executions

### DynamoDB Optimization

- **On-Demand Billing**: Pay per request
- **TTL**: Automatic cleanup of old records
- **Indexes**: Optimize for query patterns

## Security

### IAM Permissions

- **S3 Access**: Read from input bucket only
- **DynamoDB Access**: Write to data table only
- **CloudWatch Logs**: Write logs
- **Least Privilege**: Minimal required permissions

### Data Protection

- **Encryption**: All data encrypted at rest
- **VPC**: Can be configured for private access
- **Access Logs**: All access logged

## Cleanup

To remove the Lambda function:

```bash
# Delete Lambda function
aws lambda delete-function --function-name blot-parser-dev

# Remove S3 trigger
aws s3api put-bucket-notification-configuration \
  --bucket blot-parser-input-dev-123456789 \
  --notification-configuration '{}'
```