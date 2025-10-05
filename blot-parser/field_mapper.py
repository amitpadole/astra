"""
Field Mapper - Maps vendor-specific field names to generic system field names
"""

import csv
from pathlib import Path
from typing import Dict, Any, List
import logging

logger = logging.getLogger(__name__)


class FieldMapper:
    """Maps vendor-specific field names to generic system field names using CSV configuration"""
    
    def __init__(self, mappings_dir: str = "mappings"):
        """
        Initialize the field mapper
        
        Args:
            mappings_dir: Directory containing CSV mapping files
        """
        self.mappings_dir = Path(mappings_dir)
        self.mappings = {}
    
    def load_vendor_mapping(self, vendor: str) -> None:
        """
        Load field mappings for a specific vendor from CSV file
        
        Args:
            vendor: Vendor name (e.g., 'bloomberg')
        """
        csv_file = self.mappings_dir / f"{vendor}.csv"
        
        if not csv_file.exists():
            logger.error(f"Mapping file not found: {csv_file}")
            return
        
        try:
            with open(csv_file, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                
                self.mappings[vendor] = {}
                
                for row in reader:
                    vendor_field = row['vendor_field']
                    system_field = row['system_field']
                    self.mappings[vendor][vendor_field] = system_field
                
            logger.info(f"Loaded mappings for vendor '{vendor}' from {csv_file.name}")
            
        except Exception as e:
            logger.error(f"Error loading mappings from {csv_file}: {e}")
    
    def map_records(self, records: List[Dict[str, Any]], vendor: str) -> List[Dict[str, Any]]:
        """
        Map multiple records from vendor format to system format
        
        Args:
            records: List of dictionaries containing field names and values
            vendor: Vendor name (e.g., 'bloomberg')
            
        Returns:
            List of mapped records with system field names
        """
        if vendor not in self.mappings:
            self.load_vendor_mapping(vendor)
        
        if vendor not in self.mappings:
            logger.error(f"No mappings found for vendor: {vendor}")
            return records
        
        vendor_mapping = self.mappings[vendor]
        mapped_records = []
        
        for record in records:
            try:
                mapped_record = {}
                for field_name, value in record.items():
                    if field_name in vendor_mapping:
                        mapped_field = vendor_mapping[field_name]
                        mapped_record[mapped_field] = value
                    else:
                        # Keep unmapped fields as-is
                        mapped_record[field_name] = value
                mapped_records.append(mapped_record)
            except Exception as e:
                logger.error(f"Error mapping record: {e}")
                # Keep original record if mapping fails
                mapped_records.append(record)
        
        return mapped_records