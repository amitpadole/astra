"""
Configuration settings for Blot Parser
"""

from pathlib import Path

# Default directories
DEFAULT_INPUT_DIR = "../Input-files"
DEFAULT_OUTPUT_DIR = "Output-files"

# Supported file formats
SUPPORTED_FORMATS = ['.xlsx', '.xls']

# Vendor detection separators
VENDOR_SEPARATORS = ['-', '_', ' ', '.']

# Logging configuration
LOG_FORMAT = '%(asctime)s - %(levelname)s - %(message)s'
LOG_LEVEL = 'INFO'
