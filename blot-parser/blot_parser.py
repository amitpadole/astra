"""
Blot Parser - Main orchestrator for Excel file processing with field mapping
"""

from pathlib import Path
from typing import List, Dict, Any
import logging

from field_mapper import FieldMapper
from excel_processor import ExcelProcessor
from vendor_detector import VendorDetector
from file_manager import FileManager

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class BlotParser:
    """Main class for parsing Excel blot files with automatic field mapping"""
    
    def __init__(self, input_dir: str = "../Input-files", output_dir: str = "Output-files"):
        """
        Initialize the blot parser
        
        Args:
            input_dir: Directory containing input Excel files
            output_dir: Directory for output JSON files
        """
        self.field_mapper = FieldMapper()
        self.excel_processor = ExcelProcessor()
        self.vendor_detector = VendorDetector()
        self.file_manager = FileManager(input_dir, output_dir)
    
    def process_file(self, file_path: Path) -> Dict[str, Any]:
        """
        Process entire Excel file
        
        Args:
            file_path: Path to Excel file
            
        Returns:
            Dictionary with processed file data
        """
        logger.info(f"Processing file: {file_path.name}")
        
        # Extract vendor from filename
        vendor = self.vendor_detector.extract_vendor_from_filename(file_path.name)
        
        # Read Excel file
        excel_data = self.excel_processor.read_excel_file(file_path)
        
        if not excel_data:
            return {'error': f'Failed to read file {file_path.name}'}
        
        # Process each sheet
        processed_sheets = {}
        total_records = 0
        
        for sheet_name, df in excel_data.items():
            sheet_data = self.excel_processor.process_sheet(sheet_name, df, file_path.name)
            processed_sheets[sheet_name] = sheet_data
            total_records += sheet_data['row_count']
        
        return {
            'file_name': file_path.name,
            'file_path': str(file_path),
            'vendor': vendor,
            'sheet_count': len(processed_sheets),
            'total_records': total_records,
            'sheets': processed_sheets
        }
    
    def process_all_files(self) -> List[Dict[str, Any]]:
        """
        Process all Excel files in input directory
        
        Returns:
            List of processed file data
        """
        excel_files = self.file_manager.get_excel_files()
        
        if not excel_files:
            logger.warning("No Excel files found in input directory")
            return []
        
        processed_files = []
        
        for file_path in excel_files:
            try:
                file_data = self.process_file(file_path)
                processed_files.append(file_data)
                
            except Exception as e:
                logger.error(f"Error processing file {file_path.name}: {str(e)}")
                processed_files.append({
                    'file_name': file_path.name,
                    'error': str(e)
                })
        
        return processed_files
    
    def save_processed_data(self, processed_data: List[Dict[str, Any]]) -> None:
        """
        Save processed data to output directory with field mapping
        
        Args:
            processed_data: List of processed file data
        """
        for file_data in processed_data:
            if 'error' in file_data:
                logger.warning(f"Skipping file {file_data.get('file_name', 'unknown')} due to error")
                continue
            
            # Collect all records from all sheets
            all_records = []
            for sheet_name, sheet_data in file_data['sheets'].items():
                all_records.extend(sheet_data['data'])
            
            # Get vendor from file data
            vendor = file_data.get('vendor', 'unknown')
            
            # Map vendor-specific fields to generic fields
            logger.info(f"Mapping {len(all_records)} records from {vendor} to system format")
            mapped_records = self.field_mapper.map_records(all_records, vendor)
            
            # Save mapped data
            self.file_manager.save_json_data(file_data, mapped_records)
    
    def run(self) -> None:
        """Main execution method"""
        logger.info("Starting Blot Parser with Automatic Vendor Detection")
        
        # Process all files
        processed_data = self.process_all_files()
        
        if not processed_data:
            logger.warning("No files were processed")
            return
        
        # Save processed data with field mapping
        self.save_processed_data(processed_data)
        
        # Print summary
        total_files = len(processed_data)
        successful_files = len([f for f in processed_data if 'error' not in f])
        
        logger.info(f"Processing complete: {successful_files}/{total_files} files processed successfully")
        
        for file_data in processed_data:
            if 'error' not in file_data:
                print(f"\nFile: {file_data['file_name']}")
                print(f"  Vendor: {file_data.get('vendor', 'unknown')}")
                print(f"  Sheets: {file_data['sheet_count']}")
                print(f"  Total Records: {file_data['total_records']}")
            else:
                print(f"\nFile: {file_data.get('file_name', 'unknown')} - ERROR: {file_data['error']}")


def main():
    """Main execution function"""
    parser = BlotParser()
    parser.run()


if __name__ == "__main__":
    main()