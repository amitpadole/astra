# Blot Parser - Clean Architecture

## Overview

The Blot Parser has been refactored following clean code principles and single responsibility principle. The code is now modular, maintainable, and easy to understand.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    BlotParser (Orchestrator)               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │FieldMapper  │  │ExcelProcessor│  │VendorDetector│        │
│  │             │  │             │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│  ┌─────────────┐  ┌─────────────┐                        │
│  │FileManager  │  │Config       │                        │
│  │             │  │             │                        │
│  └─────────────┘  └─────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

## File Structure

```
blot-parser/
├── blot_parser.py          # 🎯 Main orchestrator
├── field_mapper.py         # 🎯 Field mapping logic
├── excel_processor.py      # 🎯 Excel file processing
├── vendor_detector.py      # 🎯 Vendor name extraction
├── file_manager.py         # 🎯 File operations
├── config.py              # 🎯 Configuration settings
├── mappings/              # 📊 Field mapping CSV files
│   ├── bloomberg.csv      # Bloomberg field mappings
│   ├── platform.csv       # Platform field mappings
│   └── generic.csv        # Generic field mappings
├── requirements.txt       # 📦 Python dependencies
├── run_parser.sh          # 🚀 Execution script
├── README.md             # 📖 Usage documentation
├── ARCHITECTURE.md        # 🏗️ Architecture documentation
├── Input-files/           # 📁 Excel input files
└── Output-files/          # 📁 Generated JSON files
```

## Module Responsibilities

### 1. **BlotParser** (`blot_parser.py`)
- **Single Responsibility**: Orchestration and coordination
- **Responsibilities**:
  - Coordinates all components
  - Manages the processing workflow
  - Handles error aggregation
  - Provides main execution interface

### 2. **FieldMapper** (`field_mapper.py`)
- **Single Responsibility**: Field mapping logic
- **Responsibilities**:
  - Loads vendor-specific CSV mappings from `mappings/` folder
  - Maps vendor fields to system fields
  - Handles mapping errors gracefully

### 3. **ExcelProcessor** (`excel_processor.py`)
- **Single Responsibility**: Excel file processing
- **Responsibilities**:
  - Reads Excel files with header detection
  - Cleans and prepares data
  - Processes individual sheets
  - Handles Excel-specific errors

### 4. **VendorDetector** (`vendor_detector.py`)
- **Single Responsibility**: Vendor name extraction
- **Responsibilities**:
  - Extracts vendor from filename
  - Handles different separator formats
  - Provides consistent vendor naming

### 5. **FileManager** (`file_manager.py`)
- **Single Responsibility**: File operations
- **Responsibilities**:
  - Manages input/output directories
  - Handles file discovery
  - Saves JSON output files
  - Manages file I/O errors

### 6. **Config** (`config.py`)
- **Single Responsibility**: Configuration management
- **Responsibilities**:
  - Centralizes all configuration
  - Provides default values
  - Manages constants and settings

## Clean Code Principles Applied

### ✅ **Single Responsibility Principle**
Each module has one clear, well-defined responsibility.

### ✅ **Open/Closed Principle**
Modules are open for extension but closed for modification.

### ✅ **Dependency Inversion**
High-level modules don't depend on low-level modules; both depend on abstractions.

### ✅ **Interface Segregation**
Each module has a focused, minimal interface.

### ✅ **DRY (Don't Repeat Yourself)**
Common functionality is centralized in appropriate modules.

### ✅ **SOLID Principles**
- **S** - Single Responsibility
- **O** - Open/Closed
- **L** - Liskov Substitution
- **I** - Interface Segregation
- **D** - Dependency Inversion

## Benefits of Refactored Architecture

### 🎯 **Maintainability**
- Each module is focused and easy to understand
- Changes are isolated to specific modules
- Clear separation of concerns

### 🎯 **Testability**
- Each module can be unit tested independently
- Dependencies are clearly defined
- Mock objects can be easily injected

### 🎯 **Extensibility**
- New vendors can be added by creating CSV files in `mappings/`
- New file formats can be added to ExcelProcessor
- New field mappings can be added to FieldMapper

### 🎯 **Reusability**
- Modules can be reused in other projects
- Clear interfaces make integration easy
- Configuration is centralized and flexible

## Code Quality Metrics

- **Lines per module**: 50-100 lines (optimal)
- **Cyclomatic complexity**: Low (simple logic)
- **Coupling**: Low (minimal dependencies)
- **Cohesion**: High (focused responsibilities)
- **Documentation**: Comprehensive (clear docstrings)

## Error Handling Strategy

Each module handles its own errors and provides meaningful error messages:

- **FieldMapper**: Handles missing CSV files gracefully
- **ExcelProcessor**: Handles Excel reading errors
- **VendorDetector**: Provides fallback vendor names
- **FileManager**: Handles file I/O errors
- **BlotParser**: Aggregates and reports errors

## Future Enhancements

The clean architecture makes it easy to add:

- **New file formats** (CSV, JSON, XML)
- **New vendors** (Reuters, Refinitiv, etc.)
- **New field mappings** (custom transformations)
- **New output formats** (XML, YAML, etc.)
- **Database integration** (DynamoDB, PostgreSQL)
- **API endpoints** (REST, GraphQL)
- **Web interface** (React, Vue.js)

## Conclusion

The refactored Blot Parser follows clean code principles and provides a solid foundation for future enhancements. Each module has a single responsibility, making the code maintainable, testable, and extensible.