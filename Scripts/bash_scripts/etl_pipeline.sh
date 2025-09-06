#!/bin/bash

# This script downloads, transforms, and loads CSV data

# Sets the CSV download URL as environment variable
export CSV_URL="https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv"

echo "Starting ETL Pipeline..."
echo "Date: $(date)"

# EXTRACT - Downloads CSV file
echo "=== EXTRACT PHASE ==="

# Creates raw folder
mkdir -p raw
echo "Created raw folder"

# Downloads the CSV file
echo "Downloading CSV file..."
curl -o raw/data.csv "$CSV_URL"

# Checks if file was downloaded
if [ -f "raw/data.csv" ]; then
    echo "✓ File downloaded successfully to raw folder"
    echo "File size: $(du -h raw/data.csv | cut -f1)"
else
    echo "✗ Download failed"
    exit 1
fi

# TRANSFORM - Processes the data
echo ""
echo "=== TRANSFORM PHASE ==="

# Creates Transformed folder
mkdir -p Transformed
echo "Created Transformed folder"

# Transforms the data to rename Variable_code to variable_code and selected columns
echo "Processing data..."

# Uses head to get header and sed to transform it
head -n 1 raw/data.csv | sed 's/Variable_code/variable_code/g' > Transformed/2023_year_finance.csv

echo "year,Value,Units,variable_code" > Transformed/2023_year_finance.csv

# Processes the data (skip header, select required columns)
# Append rows: Year(1), Value(9), Units(5), Variable_code(6)
tail -n +2 raw/data.csv | cut -d',' -f1,9,5,6 >> Transformed/2023_year_finance.csv


# Checks if transformation worked
if [ -f "Transformed/2023_year_finance.csv" ]; then
    echo "✓ Data transformed successfully"
    echo "Lines in transformed file: $(wc -l < Transformed/2023_year_finance.csv)"
    echo "✓ File saved in Transformed folder"
else
    echo "✗ Transformation failed"
    exit 1
fi

# LOAD - Copies to Gold folder
echo ""
echo "=== LOAD PHASE ==="

# Creates Gold folder
mkdir -p Gold
echo "Created Gold folder"

# Copies transformed file to Gold folder
cp Transformed/2023_year_finance.csv Gold/2023_year_finance.csv

# Checks if file was copied
if [ -f "Gold/2023_year_finance.csv" ]; then
    echo "✓ Data loaded successfully to Gold folder"
    echo "✓ File confirmed in Gold folder"
else
    echo "✗ Load failed"
    exit 1
fi

echo ""
echo "=== ETL PIPELINE COMPLETED ==="
echo "Summary:"
echo "- Raw file: $(ls -la raw/)"
echo "- Transformed file: $(ls -la Transformed/)"
echo "- Gold file: $(ls -la Gold/)"
echo "ETL Pipeline finished successfully!"