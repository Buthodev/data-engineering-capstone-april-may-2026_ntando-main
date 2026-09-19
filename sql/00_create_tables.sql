-- Landing table for the raw combined extract in data/raw/activity_extract.csv.
-- Use this as the SSIS Flat File / OLE DB destination target for your
-- staging load. Types are intentionally loose (mostly VARCHAR) because the
-- source data has not been cleaned yet. Coerce types further downstream
-- once you have profiled what is actually in each column.
--
-- This single wide table matches the source file shape only. Splitting it
-- into a proper staging layer and then a dimensional model is your task.
-- Adjust this script if your own profiling says a different data type or
-- length is more appropriate, and note why in your data quality write up.

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

CREATE TABLE source.customer_activity_extract (
    client_number      VARCHAR(20),
    first_name         VARCHAR(100),
    last_name          VARCHAR(100),
    email               VARCHAR(200),
    mobile_number       VARCHAR(50),
    date_of_birth       VARCHAR(20),   -- land as text, cast after profiling
    gender               VARCHAR(10),
    province             VARCHAR(100),
    city                 VARCHAR(100),
    signup_date          VARCHAR(20),
    event_type           VARCHAR(30),
    event_date           VARCHAR(20),
    account_number       VARCHAR(20),
    product_type         VARCHAR(50),
    account_status       VARCHAR(20),
    credit_limit         VARCHAR(20),
    loan_amount          VARCHAR(20),
    account_balance      VARCHAR(20),
    channel               VARCHAR(50),
    interaction_type     VARCHAR(50),
    resolved_flag         VARCHAR(5),
    transaction_type      VARCHAR(50),
    amount                 VARCHAR(20)
);
GO

-- The staging and dw schemas are deliberately left empty here.
-- Splitting this single extract into cleaned staging tables, then into
-- your final dimension and fact tables, is your task. See README.md.
