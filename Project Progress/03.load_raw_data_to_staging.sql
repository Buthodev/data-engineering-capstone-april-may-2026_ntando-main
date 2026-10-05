--- Load raw data into staging tables

USE stg_Customer360
GO

INSERT INTO staging.customer_activity_extract
(
    client_number,
    first_name,
    last_name,
    email,
    mobile_number,
    date_of_birth,
    gender,
    province,
    city,
    signup_date,
    event_type,
    event_date,
    account_number,
    product_type,
    account_status,
    credit_limit,
    loan_amount,
    account_balance,
    channel,
    interaction_type,
    resolved_flag,
    transaction_type,
    amount
)
SELECT
    client_number,
    first_name,
    last_name,
    email,
    mobile_number,
    date_of_birth,
    gender,
    province,
    city,
    signup_date,
    event_type,
    event_date,
    account_number,
    product_type,
    account_status,
    credit_limit,
    loan_amount,
    account_balance,
    channel,
    interaction_type,
    resolved_flag,
    transaction_type,
    amount
FROM dbo.activity_extract;

--- Verify data has been loaded into staging tables

SELECT *
FROM staging.customer_activity_extract; --- Screenshot attached


----------------------------------------------------------------------------------

--- ETL Pipeline Statement 'Staging Package'

USE stg_Customer360;
GO

INSERT INTO staging.customer_activity_extract
(
    client_number,
    first_name,
    last_name,
    email,
    mobile_number,
    date_of_birth,
    gender,
    province,
    city,
    signup_date,
    event_type,
    event_date,
    account_number,
    product_type,
    account_status,
    credit_limit,
    loan_amount,
    account_balance,
    channel,
    interaction_type,
    resolved_flag,
    transaction_type,
    amount
)
SELECT
    s.client_number,
    s.first_name,
    s.last_name,
    s.email,
    s.mobile_number,
    s.date_of_birth,
    s.gender,
    s.province,
    s.city,
    s.signup_date,
    s.event_type,
    s.event_date,
    s.account_number,
    s.product_type,
    s.account_status,
    s.credit_limit,
    s.loan_amount,
    s.account_balance,
    s.channel,
    s.interaction_type,
    s.resolved_flag,
    s.transaction_type,
    s.amount
FROM dbo.activity_extract AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM staging.customer_activity_extract AS t
    WHERE ISNULL(t.client_number, '') = ISNULL(s.client_number, '')
      AND ISNULL(t.first_name, '') = ISNULL(s.first_name, '')
      AND ISNULL(t.last_name, '') = ISNULL(s.last_name, '')
      AND ISNULL(t.email, '') = ISNULL(s.email, '')
      AND ISNULL(t.mobile_number, '') = ISNULL(s.mobile_number, '')
      AND ISNULL(t.date_of_birth, '') = ISNULL(s.date_of_birth, '')
      AND ISNULL(t.gender, '') = ISNULL(s.gender, '')
      AND ISNULL(t.province, '') = ISNULL(s.province, '')
      AND ISNULL(t.city, '') = ISNULL(s.city, '')
      AND ISNULL(t.signup_date, '') = ISNULL(s.signup_date, '')
      AND ISNULL(t.event_type, '') = ISNULL(s.event_type, '')
      AND ISNULL(t.event_date, '') = ISNULL(s.event_date, '')
      AND ISNULL(t.account_number, '') = ISNULL(s.account_number, '')
      AND ISNULL(t.product_type, '') = ISNULL(s.product_type, '')
      AND ISNULL(t.account_status, '') = ISNULL(s.account_status, '')
      AND ISNULL(t.credit_limit, '') = ISNULL(s.credit_limit, '')
      AND ISNULL(t.loan_amount, '') = ISNULL(s.loan_amount, '')
      AND ISNULL(t.account_balance, '') = ISNULL(s.account_balance, '')
      AND ISNULL(t.channel, '') = ISNULL(s.channel, '')
      AND ISNULL(t.interaction_type, '') = ISNULL(s.interaction_type, '')
      AND ISNULL(t.resolved_flag, '') = ISNULL(s.resolved_flag, '')
      AND ISNULL(t.transaction_type, '') = ISNULL(s.transaction_type, '')
      AND ISNULL(t.amount, '') = ISNULL(s.amount, '')
);
GO