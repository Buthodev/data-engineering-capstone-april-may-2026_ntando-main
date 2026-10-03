--- create staging database then load raw data

CREATE DATABASE stg_Customer360;
GO

--- create schema for staging database
CREATE SCHEMA stg;
GO

CREATE DATABASE Customer360_DW;
GO

USE Customer360_DW;
GO

CREATE SCHEMA source;
GO
CREATE SCHEMA staging;
GO
CREATE SCHEMA dw;
GO