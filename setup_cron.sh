#!/bin/bash


# This will run the ETL script every day at 12:00 AM midnight

echo "Setting up cron job for ETL pipeline..."

# Gets the full path to ETL script
SCRIPT_PATH="$(pwd)/etl_pipeline.sh"

echo "ETL script location: $SCRIPT_PATH"

# Makes the ETL script executable
chmod +x etl_pipeline.sh
echo "ETL script executable"

# Checks if cron job already exists
echo "Checking for existing cron jobs..."
crontab -l > current_cron.txt 2>/dev/null || touch current_cron.txt

# Adds new cron job to runs daily at midnight
echo "Adding cron job..."
echo "0 0 * * * $SCRIPT_PATH" >> current_cron.txt

# Installs the new crontab
crontab current_cron.txt

# Cleans up temp file
rm current_cron.txt

echo "Cron job added successfully!"
echo "The ETL script will now run every day at 12:00 AM"

# Shows current cron jobs
echo "Current cron jobs:"
crontab -l

echo ""
echo "Cron job format explanation:"
echo "0 0 * * * means:"
echo "- 0 = minute (0)"
echo "- 0 = hour (0 = midnight)" 
echo "- * = any day of month"
echo "- * = any month"
echo "- * = any day of week"