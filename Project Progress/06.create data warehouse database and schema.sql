--- Create database for data warehouse

CREATE DATABASE Customer360_DW;
GO

--- Create schema for data warehouse database

USE Customer360_DW;
GO

CREATE SCHEMA dw;
GO


---------------------------------------------------------------------------------

--- ETL Pipeline Statement 'DW Loading' Package

--- Create data warehouse

IF NOT EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = 'Customer360_DW'
)
BEGIN
    CREATE DATABASE Customer360_DW;
END;
GO

--- Create DW schema

USE Customer360_DW;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'dw'
)
BEGIN
    EXEC('CREATE SCHEMA dw');
END;
GO


