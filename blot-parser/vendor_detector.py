"""
Vendor Detector - Extracts vendor name from filename
"""

from pathlib import Path
import logging
from config import VENDOR_SEPARATORS

logger = logging.getLogger(__name__)


class VendorDetector:
    """Extracts vendor name from filename"""
    
    @staticmethod
    def extract_vendor_from_filename(filename: str) -> str:
        """
        Extract vendor name from filename (first word before any separator)
        
        Args:
            filename: Name of the file
            
        Returns:
            Vendor name extracted from filename
        """
        # Remove file extension
        name_without_ext = Path(filename).stem
        
        # Split by common separators and take first word
        vendor = name_without_ext
        
        for sep in VENDOR_SEPARATORS:
            if sep in name_without_ext:
                vendor = name_without_ext.split(sep)[0]
                break
        
        # Convert to lowercase for consistency
        vendor = vendor.lower()
        
        logger.info(f"Extracted vendor '{vendor}' from filename '{filename}'")
        return vendor