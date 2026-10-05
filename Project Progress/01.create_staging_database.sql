--- create staging database then load raw data

CREATE DATABASE stg_Customer360;
GO

--- create schema for staging database
CREATE SCHEMA stg;
GO


---------------------------------------------------------------------------------


--- ETL Pipeline SQL Statement 'Staging Package'

--- Create staging database

IF NOT EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = 'stg_Customer360'
)
BEGIN
    CREATE DATABASE stg_Customer360;
END;
GO

--- Create staging schema

USE stg_Customer360;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'staging'
)
BEGIN
    EXEC('CREATE SCHEMA staging');
END;
GO