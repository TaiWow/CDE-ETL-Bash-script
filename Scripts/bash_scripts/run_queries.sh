#!/bin/bash

# Sript to run the business questions SQL queries

echo "Running Business Questions SQL Queries"
echo "======================================"

# Database connection details
DB_USER="postgres"
DB_NAME="posey"

# Check if PostgreSQL container is running
if ! docker ps | grep -q "posey_postgres"; then
    echo "Error: PostgreSQL container is not running!"
    exit 1
fi

echo ""

echo " Q1 - Find order IDs where gloss_qty or poster_qty > 4000"
echo ""

docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME -c "
SELECT id
FROM orders
WHERE gloss_qty > 4000 
   OR poster_qty > 4000;
"

echo ""
echo " Q2 - Orders where standard_qty = 0 and (gloss_qty > 1000 OR poster_qty > 1000)"
echo ""

docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME -c "
SELECT *
FROM orders
WHERE standard_qty = 0 
  AND (gloss_qty > 1000 OR poster_qty > 1000);
"

echo ""
echo " Q3 - Companies starting with 'C' or 'W' with specific contact conditions"
echo ""

docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME -c "
SELECT name
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
  AND (primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
  AND primary_poc NOT LIKE '%eana%';
"

echo ""
echo " Q4 - Region, sales rep, and account information (sorted by account name)"
echo ""

docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME -c "
SELECT 
    r.name AS region_name,
    s.name AS sales_rep_name,
    a.name AS account_name
FROM region r
JOIN sales_reps s ON r.id = s.region_id
JOIN accounts a ON s.id = a.sales_rep_id
ORDER BY a.name;
"

echo ""
echo "=== ALL QUERIES COMPLETED ==="
echo ""
