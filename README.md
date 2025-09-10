
# CDE-ETL-Bash-Script

## Table of Contents
1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [Prerequisites](#prerequisites)
4. [Environment Variables](#environment-variables)
5. [ETL Pipeline](#etl-pipeline)
    - [Extract](#extract)
    - [Transform](#transform)
    - [Load](#load)
    - [Schedule with Cron](#schedule-with-cron)
6. [Architecture Diagram](#architecture-diagram)
7. [Moving JSON and CSV Files](#moving-json-and-csv-files)
8. [Loading the Parch & Posey Dataset](#loading-the-parch--posey-dataset)
9. [Business Questions (SQL)](#business-questions-sql)
10. [Running the Scripts](#running-the-scripts)


## Overview
This project demonstrates a simple end-to-end ETL (Extract–Transform–Load) workflow written entirely in **Bash**.
The pipeline downloads a public CSV file, transforms selected columns, and stages it into a **Gold** dataset.
It also includes utilities to move CSV/JSON files, ingest the Parch & Posey dataset into PostgreSQL, and a collection of SQL scripts answering common business questions.

## Project Structure
```
CDE-ETL-Bash-script/
├── Gold/                     # Final "gold" dataset
├── Transformed/              # Intermediate transformed dataset
├── raw/                      # Raw downloaded data
├── json_and_CSV/             # Destination for moved JSON/CSV files
├── Scripts/
│   ├── bash_scripts/         # All Bash utilities
│   │   ├── etl_pipeline.sh
│   │   ├── move_flies.sh
│   │   ├── run_queries.sh
│   │   └── setup_cron.sh
│   └── sql_scripts/          # SQL answers to business questions
│       ├── q1_orders_over_4000.sql
│       ├── q2_zero_standard_over_1000.sql
│       ├── q3_accounts_c_or_w_ana_not_eana.sql
│       └── q4_region_rep_accounts.sql
├── docker-compose.yml        # PostgreSQL + Adminer containers
├── load_posey_pg.sh          # Loads CSVs into PostgreSQL
└── .gitignore
```

## Prerequisites
- Linux or macOS shell with Bash ≥ 4
- `curl`, `cut`, `sed`, `tail`, `wc`
- Docker & Docker Compose (for PostgreSQL loading)
- Cron (usually preinstalled on Linux)

---

## Environment Variables
The ETL script expects the CSV URL to be stored in an environment variable. Create an `.env` file at the project root and load it before running any scripts:

```bash
cat <<'EOF' > .env
CSV_URL="https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv"
EOF

# load variables into the current shell
source .env
```

You may also export the variable in your shell profile or directly inside [`etl_pipeline.sh`](Scripts/bash_scripts/etl_pipeline.sh).


## ETL Pipeline
Make [`etl_pipeline.sh`](Scripts/bash_scripts/etl_pipeline.sh) executable and run it:

```bash
# Make script executable
chmod +x Scripts/bash_scripts/etl_pipeline.sh

# Run the script
./Scripts/bash_scripts/etl_pipeline.sh
```

### Extract
1. Creates a `raw/` directory.
2. Downloads the CSV from `$CSV_URL` into `raw/data.csv`.
3. Confirms download and prints file size.

### Transform
1. Creates `Transformed/` directory.
2. Renames column **`Variable_code` → `variable_code`**.
3. Selects only `year`, `Value`, `Units`, and `variable_code`.
4. Saves result as `Transformed/2023_year_finance.csv`.

### Load
1. Creates `Gold/` directory.
2. Copies `Transformed/2023_year_finance.csv` into `Gold/`.
3. Confirms the file is present.

### Schedule with Cron
Makes ETL script run automatically - set to run daily at **12:00 AM** with [`setup_cron.sh`](Scripts/bash_scripts/setup_cron.sh):


```bash
# Make script executable
chmod +x Scripts/bash_scripts/setup_cron.sh

# Run the script
./Scripts/bash_scripts/setup_cron.sh

```

This appends the line `0 0 * * * /path/to/etl_pipeline.sh` to the current user’s crontab.

## Architecture Diagram

## Moving JSON and CSV Files
The [`move_flies.sh`](Scripts/bash_scripts/move_flies.sh) script relocates one or more `.csv` and `.json` files to a target directory.

```bash
# Defaults: source = current directory, destination = ./json_and_CSV
bash Scripts/bash_scripts/move_flies.sh [SOURCE_DIR] [DEST_DIR]
```

## Loading the Parch & Posey Dataset
1. Download the Parch & Posey CSV files and place them inside `posey_data/`.
2. Start PostgreSQL and Adminer services using [`docker-compose.yml`](docker-compose.yml):

```bash
docker compose up -d
```

3. Make [`load_posey_pg.sh`](load_posey_pg.sh) executable and run it:

```bash
chmod +x load_posey_pg.sh

./load_posey_pg.sh
```

The script checks that the `posey_postgres` container is running and loads the CSVs into the `posey` database.


## Business Questions (SQL)
SQL scripts reside in [`Scripts/sql_scripts/`](Scripts/sql_scripts/) and are executable via [`run_queries.sh`](Scripts/bash_scripts/run_queries.sh):

```bash
bash Scripts/bash_scripts/run_queries.sh
```

### Queries Included
1. **Order IDs with gloss_qty or poster_qty > 4000** – [`q1_orders_over_4000.sql`](Scripts/sql_scripts/q1_orders_over_4000.sql)
2. **Orders where standard_qty = 0 and (gloss_qty > 1000 or poster_qty > 1000)** – [`q2_zero_standard_over_1000.sql`](Scripts/sql_scripts/q2_zero_standard_over_1000.sql)
3. **Company names starting with 'C' or 'W', contact contains 'ana'/'Ana', excluding 'eana'** – [`q3_accounts_c_or_w_ana_not_eana.sql`](Scripts/sql_scripts/q3_accounts_c_or_w_ana_not_eana.sql)
4. **Region, sales rep, and associated accounts (alphabetical by account)** – [`q4_region_rep_accounts.sql`](Scripts/sql_scripts/q4_region_rep_accounts.sql)


## Running the Scripts
Before running any scripts, ensure they are executable:

```bash
chmod +x Scripts/bash_scripts/*.sh load_posey_pg.sh
```

| Purpose | Command |
|---------|---------|
| Run ETL pipeline | [./Scripts/bash_scripts/etl_pipeline.sh](Scripts/bash_scripts/etl_pipeline.sh) |
| Schedule ETL daily | [./Scripts/bash_scripts/setup_cron.sh](Scripts/bash_scripts/setup_cron.sh) |
| Move JSON/CSV files | [./Scripts/bash_scripts/move_flies.sh](Scripts/bash_scripts/move_flies.sh) \[src\] \[dest\] |
| Load Parch & Posey into PostgreSQL | [./load_posey_pg.sh](load_posey_pg.sh) |
| Execute business queries | [./Scripts/bash_scripts/run_queries.sh](Scripts/bash_scripts/run_queries.sh) |








