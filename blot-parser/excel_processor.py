"""
Excel Processor - Handles Excel file reading and data cleaning
"""

import pandas as pd
from pathlib import Path
from typing import Dict, Any
import logging

logger = logging.getLogger(__name__)


class ExcelProcessor:
    """Handles Excel file reading and data processing"""
    
    def __init__(self):
        """Initialize the Excel processor"""
        self.supported_formats = ['.xlsx', '.xls']
    
    def read_excel_file(self, file_path: Path) -> Dict[str, pd.DataFrame]:
        """
        Read Excel file and return all sheets as DataFrames
        
        Args:
            file_path: Path to Excel file
            
        Returns:
            Dictionary with sheet names as keys and DataFrames as values
        """
        try:
            logger.info(f"Reading Excel file: {file_path.name}")
            
            # First, try to detect the header row by reading a small sample
            sample_df = pd.read_excel(file_path, sheet_name=0, nrows=5, engine='openpyxl')
            
            # Find the header row (first row with non-null values)
            header_row = 0
            for i, row in sample_df.iterrows():
                if not row.isna().all():
                    header_row = i
                    break
            
            logger.info(f"Detected header row at index: {header_row}")
            
            # Read all sheets with the detected header row
            excel_data = pd.read_excel(file_path, sheet_name=None, header=header_row, engine='openpyxl')
            
            # If we still have unnamed columns, try to use the first data row as headers
            for sheet_name, df in excel_data.items():
                if any('Unnamed' in str(col) for col in df.columns):
                    logger.info(f"Detected unnamed columns in {sheet_name}, using first row as headers")
                    # Use the first row as column names
                    new_columns = df.iloc[0].tolist()
                    df.columns = new_columns
                    # Remove the first row since it's now the header
                    df = df.iloc[1:].reset_index(drop=True)
                    excel_data[sheet_name] = df
            
            logger.info(f"Successfully read {len(excel_data)} sheets from {file_path.name}")
            return excel_data
            
        except Exception as e:
            logger.error(f"Error reading Excel file {file_path.name}: {str(e)}")
            return {}
    
    def clean_dataframe(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Clean and prepare DataFrame for processing
        
        Args:
            df: Raw DataFrame
            
        Returns:
            Cleaned DataFrame
        """
        # Remove completely empty rows and columns
        df = df.dropna(how='all').dropna(axis=1, how='all')
        
        # Reset index
        df = df.reset_index(drop=True)
        
        # Convert data types where possible
        df = df.convert_dtypes()
        
        # Fill NaN values with empty string
        df = df.fillna('')
        
        return df
    
    def process_sheet(self, sheet_name: str, df: pd.DataFrame, file_name: str) -> Dict[str, Any]:
        """
        Process individual sheet data
        
        Args:
            sheet_name: Name of the sheet
            df: DataFrame containing sheet data
            file_name: Name of the source file
            
        Returns:
            Dictionary with processed sheet data
        """
        # Clean the data
        cleaned_df = self.clean_dataframe(df)
        
        # Convert to records (list of dictionaries)
        records = cleaned_df.to_dict('records')
        
        # Add file_name to each record
        for record in records:
            record['file_name'] = file_name
        
        return {
            'sheet_name': sheet_name,
            'row_count': len(cleaned_df),
            'column_count': len(cleaned_df.columns),
            'data': records
        }
