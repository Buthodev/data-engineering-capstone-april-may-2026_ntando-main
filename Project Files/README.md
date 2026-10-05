Customer 360 Data Engineering Pipeline

Overview
This project implements a Customer 360 data pipeline using SQL Server. The pipeline loads source data into staging tables, cleans and standardises the data, removes duplicates, and then transforms and loads the prepared data into a dimensional data warehouse using a star schema.

The pipeline scripts are located in the Project Progress folder and should be executed in the order shown below.

Prerequisites
Before running the pipeline, ensure that:

SQL Server is installed and running.

You have access to the correct SQL Server instance.

You have sufficient permissions to create databases, schemas, tables, and load data.

SQL Server Management Studio (SSMS) or another SQL Server-compatible query editor is available.

The required source data is available in the project.

Pipeline Execution
Run the SQL scripts sequentially.

1. Create the staging database
Run:

01.create_staging_database.sql

This creates the database used as the staging area for the source data.

2. Create staging tables
Run:

02.create_staging_tables.sql

This creates the staging tables where the source data will initially be stored.

3. Standardise column formatting
Run:

03.standardise column formatting.sql

This step standardises the data, including column formatting and values, to ensure consistency before further processing.

4. Deduplicate staging data
Run:

04.deduplication of data in staging table.sql

This step identifies and removes duplicate records from the staging tables.

5. Create the data warehouse
Run:

05.create data warehouse database and schema.sql

This creates the data warehouse database and the required database schema.

6. Create data warehouse tables
Run:

06.create dw tables.sql

This creates the dimension and fact tables required for the Customer 360 star schema.

7. Load the data warehouse
Run:

07.load data from staging table into dim and fact table.sql

This transforms the prepared staging data and loads it into the appropriate dimension and fact tables in the data warehouse.

8. Run validation and analysis queries
After the warehouse load has completed successfully, run:

Questions and Answers.sql

This script contains queries used to validate and analyse the Customer 360 data stored in the warehouse.

Execution Order
The complete pipeline should be executed in the following order:

01 → 02 → 03 → 04 → 05 → 06 → 07 → Questions and Answers

Following this order is important because each stage depends on objects or data created by the preceding stage.

Pipeline Flow
Source Data
     │
     ▼
Staging Database
     │
     ▼
Staging Tables
     │
     ▼
Standardisation
     │
     ▼
Deduplication
     │
     ▼
Data Warehouse
     │
     ▼
Dimension & Fact Tables
     │
     ▼
Validation & Analysis

Expected Outcome
At the end of the pipeline:

Source data has been loaded into the staging environment.

Data has been standardised and cleaned.

Duplicate records have been removed.

The Customer 360 data warehouse has been created.

Dimension and fact tables have been populated.

The resulting warehouse can be queried using Questions and Answers.sql.

Troubleshooting
If a script fails:

Check that the previous script completed successfully.

Confirm that the required database, schema, or tables exist.

Verify that you are connected to the correct SQL Server instance.

Check that your account has the required permissions.

Review the SQL Server error message before proceeding to the next script.

Important: Do not skip pipeline stages unless you have confirmed that all required databases, tables, and data already exist.