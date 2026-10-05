--- Load data into dim_client table from staging table

INSERT INTO dim_client (
    client_number,
    first_name,
    last_name,
    gender,
    date_of_birth,
    signup_date,
    mobile_number,
    email
)
SELECT DISTINCT
    client_number,
    first_name,
    last_name,
    gender,
    date_of_birth,
    signup_date,
    mobile_number,
    email
FROM stg_Customer360.staging.customer_activity_extract;

--- Load data into dim_location table from staging table


INSERT INTO dim_location (
    city,
    province
)
SELECT DISTINCT
    city,
    province
FROM stg_Customer360.staging.customer_activity_extract;

--- Load data into dim_event table from staging table

INSERT INTO dim_event (
    event_date,
    event_type
)
SELECT DISTINCT
    event_date,
    event_type
FROM stg_Customer360.staging.customer_activity_extract;

--- Load data into dim_flag table from staging table

INSERT INTO dim_flag (
    resolved_flag
)
SELECT DISTINCT
    resolved_flag
FROM stg_Customer360.staging.customer_activity_extract;

--- Load data into dim_channel table from staging table

INSERT INTO dim_channel (
    channel
)
SELECT DISTINCT
    channel
FROM stg_Customer360.staging.customer_activity_extract;

--- Load data into dim_account table from staging table

INSERT INTO dim_account (
    account_number,
    product_type,
    account_status,
    transaction_type
)
SELECT DISTINCT
    account_number,
    product_type,
    account_status,
    transaction_type
FROM stg_Customer360.staging.customer_activity_extract;

--- Load data into dim_interaction table from staging table

INSERT INTO dim_interaction (
    interaction_type
)
SELECT DISTINCT
    interaction_type
FROM stg_Customer360.staging.customer_activity_extract;

--- Verify that the data has been loaded into the dimension tables

SELECT * FROM dbo.dim_client;
SELECT * FROM dbo.dim_location;
SELECT * FROM dbo.dim_event;
SELECT * FROM dbo.dim_flag;
SELECT * FROM dbo.dim_channel;
SELECT * FROM dbo.dim_account;
SELECT * FROM dbo.dim_interaction;

--- Load fact table with foreign keys from dimension tables and other relevant data

INSERT INTO dbo.fact_account_activity
(
    event_id,
    location_id,
    client_id,
    account_id,
    interaction_id,
    flag_id,
    channel_id,
    loan_amount,
    credit_limit,
    amount,
    account_balance
)
SELECT DISTINCT
    e.event_id,
    l.location_id,
    c.client_id,
    a.account_id,
    i.interaction_id,
    f.flag_id,
    ch.channel_id,

    TRY_CONVERT(DECIMAL(18,2), s.loan_amount),
    TRY_CONVERT(DECIMAL(18,2), s.credit_limit),
    TRY_CONVERT(DECIMAL(18,2), s.amount),
    TRY_CONVERT(DECIMAL(18,2), s.account_balance)

FROM stg_Customer360.staging.customer_activity_extract AS s

INNER JOIN dbo.dim_event AS e
    ON e.event_date = TRY_CONVERT(DATE, s.event_date)
   AND e.event_type = s.event_type

INNER JOIN dbo.dim_location AS l
    ON l.city = s.city
   AND l.province = s.province

INNER JOIN dbo.dim_client AS c
    ON c.client_number = s.client_number

INNER JOIN dbo.dim_account AS a
    ON a.account_number = s.account_number

INNER JOIN dbo.dim_interaction AS i
    ON i.interaction_type = s.interaction_type

INNER JOIN dbo.dim_flag AS f
    ON UPPER(LTRIM(RTRIM(f.resolved_flag))) =
       UPPER(LTRIM(RTRIM(s.resolved_flag)))

INNER JOIN dbo.dim_channel AS ch
    ON ch.channel = s.channel;
GO

--- Verify that the data has been loaded into the fact table

SELECT *
FROM dbo.fact_account_activity;


