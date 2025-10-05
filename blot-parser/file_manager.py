"""
File Manager - Handles file operations and directory management
"""

import json
from pathlib import Path
from typing import List, Dict, Any
import logging
from config import SUPPORTED_FORMATS

logger = logging.getLogger(__name__)


class FileManager:
    """Handles file operations and directory management"""
    
    def __init__(self, input_dir: str = "../Input-files", output_dir: str = "Output-files"):
        """
        Initialize the file manager
        
        Args:
            input_dir: Directory containing input Excel files
            output_dir: Directory for output JSON files
        """
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir)
        self.supported_formats = SUPPORTED_FORMATS
    
    def get_excel_files(self) -> List[Path]:
        """
        Get all Excel files from input directory
        
        Returns:
            List of Excel file paths
        """
        if not self.input_dir.exists():
            logger.error(f"Input directory {self.input_dir} does not exist")
            return []
        
        excel_files = []
        for file_path in self.input_dir.iterdir():
            if file_path.suffix.lower() in self.supported_formats:
                excel_files.append(file_path)
                logger.info(f"Found Excel file: {file_path.name}")
        
        return excel_files
    
    def save_json_data(self, file_data: Dict[str, Any], mapped_records: List[Dict[str, Any]]) -> None:
        """
        Save mapped JSON data to output directory
        
        Args:
            file_data: File metadata
            mapped_records: Mapped records to save
        """
        self.output_dir.mkdir(exist_ok=True)
        
        # Create JSON file
        json_file = self.output_dir / f"{file_data['file_name']}_data.json"
        
        # Save mapped data
        with open(json_file, 'w') as f:
            json.dump(mapped_records, f, indent=2, default=str)
        
        logger.info(f"Saved mapped JSON data for {file_data['file_name']} to {json_file}")