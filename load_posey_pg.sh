
#!/bin/bash

# Script to load CSV data into PostgreSQL running in Docker


echo ""
echo "Starting PostgreSQL and Adminer containers..."
docker-compose up -d


echo "Loading CSV data into PostgreSQL"
echo "================================"

# Database connection details
DB_NAME="posey"
DB_USER="postgres"

#  Checking if PostgreSQL container is running
if ! docker ps | grep -q "posey_postgres"; then
    echo "Error: PostgreSQL container is not running!"
    exit 1
fi

# Checking if posey data files exist
if [ ! -d "posey_data" ] || [ -z "$(ls -A posey_data/*.csv 2>/dev/null)" ]; then
    echo "Error: No CSV files found in posey_data folder!"
    exit 1
fi

echo "Found CSV files:"
ls posey_data/*.csv
echo ""

echo "Creating database tables and loading data..."
echo ""
# Create tables and load data using psql in Docker
echo "Loading accounts table..."

docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME << 'EOF'
DROP TABLE IF EXISTS accounts CASCADE;
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    website VARCHAR(255),
    lat NUMERIC,
    long NUMERIC,
    primary_poc VARCHAR(255),
    sales_rep_id INTEGER
);
EOF

# Copying data from CSV file
docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME -c "\COPY accounts(id,name,website,lat,long,primary_poc,sales_rep_id) FROM '/docker-entrypoint-initdb.d/accounts.csv' WITH CSV HEADER;"
echo ""

echo "Loading region table..."
docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME << 'EOF'
DROP TABLE IF EXISTS region CASCADE;
CREATE TABLE region (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);
EOF

docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME -c "\COPY region(id,name) FROM '/docker-entrypoint-initdb.d/region.csv' WITH CSV HEADER;"
echo ""

echo "Loading sales_reps table..."
docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME << 'EOF'
DROP TABLE IF EXISTS sales_reps CASCADE;
CREATE TABLE sales_reps (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    region_id INTEGER
);
EOF

docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME -c "\COPY sales_reps(id,name,region_id) FROM '/docker-entrypoint-initdb.d/sales_reps.csv' WITH CSV HEADER;"
echo ""

echo "Loading orders table..."
docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME << 'EOF'
DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    account_id INTEGER,
    occurred_at TIMESTAMP,
    standard_qty INTEGER,
    gloss_qty INTEGER,
    poster_qty INTEGER,
    total INTEGER,
    standard_amt_usd NUMERIC,
    gloss_amt_usd NUMERIC,
    poster_amt_usd NUMERIC,
    total_amt_usd NUMERIC
);
EOF

docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME -c "\COPY orders(id,account_id,occurred_at,standard_qty,gloss_qty,poster_qty,total,standard_amt_usd,gloss_amt_usd,poster_amt_usd,total_amt_usd) FROM '/docker-entrypoint-initdb.d/orders.csv' WITH CSV HEADER;"
echo ""

echo "Loading web_events table..."
docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME << 'EOF'
DROP TABLE IF EXISTS web_events CASCADE;
CREATE TABLE web_events (
    id SERIAL PRIMARY KEY,
    account_id INTEGER,
    occurred_at TIMESTAMP,
    channel VARCHAR(255)
);
EOF

docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME -c "\COPY web_events(id,account_id,occurred_at,channel) FROM '/docker-entrypoint-initdb.d/web_events.csv' WITH CSV HEADER;"
echo ""

echo "✓ All data loaded successfully!"
echo ""
echo "You can now:"
echo "1. Access Adminer at: http://localhost:8080"
echo "2. Use these connection details:"
echo "   - System: PostgreSQL"
echo "   - Server: postgres"
echo "   - Username: postgres"  
echo "   - Password: password123"
echo "   - Database: posey"
echo ""
echo "3. Or connect via command line:"
echo "   docker exec -it posey_postgres psql -U postgres -d posey"
echo ""

# Show table counts
echo "Table record counts:"
docker exec -i posey_postgres psql -U $DB_USER -d $DB_NAME -c "
SELECT 'accounts' as table_name, COUNT(*) as records FROM accounts
UNION ALL
SELECT 'orders' as table_name, COUNT(*) as records FROM orders  
UNION ALL
SELECT 'region' as table_name, COUNT(*) as records FROM region
UNION ALL
SELECT 'sales_reps' as table_name, COUNT(*) as records FROM sales_reps
UNION ALL  
SELECT 'web_events' as table_name, COUNT(*) as records FROM web_events;
"


