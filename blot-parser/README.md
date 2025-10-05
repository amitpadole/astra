# Blot Parser - Clean Architecture Implementation

A modular Python utility for parsing Excel files with automatic vendor detection and field mapping.

## Architecture

The code follows clean code principles with single responsibility modules:

```
blot-parser/
├── blot_parser.py          # Main orchestrator
├── field_mapper.py         # Field mapping logic
├── excel_processor.py     # Excel file processing
├── vendor_detector.py     # Vendor name extraction
├── file_manager.py        # File operations
├── config.py             # Configuration settings
├── mappings/             # Field mapping CSV files
│   ├── bloomberg.csv     # Bloomberg field mappings
│   ├── platform.csv      # Platform field mappings
│   └── generic.csv       # Generic field mappings
├── requirements.txt      # Dependencies
├── run_parser.sh        # Execution script
├── Input-files/         # Excel input files
└── Output-files/        # Generated JSON files
```

## Module Responsibilities

### 🎯 Single Responsibility Principle

| Module | Responsibility |
|--------|---------------|
| `blot_parser.py` | **Orchestration** - Coordinates all components |
| `field_mapper.py` | **Field Mapping** - Maps vendor fields to system fields |
| `excel_processor.py` | **Excel Processing** - Reads and cleans Excel data |
| `vendor_detector.py` | **Vendor Detection** - Extracts vendor from filename |
| `file_manager.py` | **File Operations** - Handles file I/O operations |
| `config.py` | **Configuration** - Centralized settings |

## Features

- **Clean Architecture**: Modular design with single responsibilities
- **Automatic Vendor Detection**: Extracts vendor from filename
- **CSV-based Field Mapping**: Vendor-specific field mappings in `mappings/` folder
- **Generic JSON Output**: Standardized field names
- **Error Handling**: Graceful error recovery
- **Logging**: Comprehensive logging throughout

## Usage

### Command Line
```bash
./run_parser.sh
```

### Python API
```python
from blot_parser import BlotParser

# Initialize parser
parser = BlotParser()

# Process all files
parser.run()
```

## File Naming Convention

The parser extracts vendor name from filename:

```
bloomberg-trade-data.xlsx     → vendor: "bloomberg"
reuters_market_data.xlsx     → vendor: "reuters"  
refinitiv.fixed.income.xlsx   → vendor: "refinitiv"
```

## CSV Mapping Format

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

## Example Output

### Input Excel (Bloomberg format)
| Status | Security | BrkrName | Qty_M | Price |
|--------|----------|----------|-------|-------|
| Accepted | Bond Name | Broker Ltd | 500 | 99.35 |

### Output JSON (Generic format)
```json
[
  {
    "trade_status": "Accepted",
    "security_name": "Bond Name", 
    "broker_name": "Broker Ltd",
    "quantity": 500,
    "price": 99.35,
    "file_name": "bloomberg-trade-data.xlsx"
  }
]
```

## Adding New Vendors

1. **Create CSV mapping file**: `mappings/[vendor].csv`
2. **Use standard format**: `vendor_field,system_field,description`
3. **Name files with vendor prefix**: `[vendor]-data.xlsx`

The parser will automatically:
- Detect vendor from filename
- Load appropriate CSV mapping from `mappings/` folder
- Apply field transformations
- Generate generic JSON output

## Error Handling

- **Missing CSV**: Logs error, keeps original field names
- **Invalid Excel**: Skips file, reports error
- **No vendor detected**: Uses filename as vendor name

## Setup

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run parser
./run_parser.sh
```

## Code Quality

- **Single Responsibility**: Each module has one clear purpose
- **Clean Code**: Readable, maintainable, and efficient
- **Error Handling**: Comprehensive error recovery
- **Logging**: Detailed logging for debugging
- **Type Hints**: Full type annotation support
- **Documentation**: Clear docstrings and comments