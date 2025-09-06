#!/bin/bash

# Script to move CSV and JSON files to a specific folder


echo "CSV and JSON File Mover Script"
echo "=============================="

# Set default folders if not provided
SOURCE_FOLDER="${1:-.}"  # Defaults to current folder
DEST_FOLDER="${2:-json_and_CSV}"  # Defaults to json_and_CSV folder

echo "Source folder: $SOURCE_FOLDER"
echo "Destination folder: $DEST_FOLDER"

# Creates destination folder if it doesn't exist
mkdir -p "$DEST_FOLDER"
echo "Created destination folder: $DEST_FOLDER"

# Counts files
csv_count=0
json_count=0

echo ""
echo "Looking for CSV files..."
# Finds and move CSV files
for file in "$SOURCE_FOLDER"/*.csv; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Moving CSV file: $filename"
        mv "$file" "$DEST_FOLDER/"
        csv_count=$((csv_count + 1))
    fi
done

echo ""
echo "Looking for JSON files..."
# Finds and move JSON files  
for file in "$SOURCE_FOLDER"/*.json; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Moving JSON file: $filename"
        mv "$file" "$DEST_FOLDER/"
        json_count=$((json_count + 1))
    fi
done

echo ""
echo "=== SUMMARY ==="
echo "CSV files moved: $csv_count"
echo "JSON files moved: $json_count"
echo "Total files moved: $((csv_count + json_count))"

if [ $((csv_count + json_count)) -eq 0 ]; then
    echo "No CSV or JSON files found in $SOURCE_FOLDER"
else
    echo "All files moved to: $DEST_FOLDER"
    echo ""
    echo "Contents of destination folder:"
    ls -la "$DEST_FOLDER"
fi

echo "Script completed!"