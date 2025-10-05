#!/bin/bash

# Blot Parser Runner Script
# This script activates the virtual environment and runs the blot parser

echo "Starting Blot Parser..."
echo "Activating virtual environment..."

# Change to the script directory
cd "$(dirname "$0")"

# Activate virtual environment
source venv/bin/activate

# Run the parser
python blot_parser.py

echo "Parser execution completed."
