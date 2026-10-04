--- Load data from staging tables into dimension and fact tables in the data warehouse

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


INSERT INTO dim_location (
    city,
    province
)
SELECT DISTINCT
    city,
    province
FROM stg_Customer360.staging.customer_activity_extract;

INSERT INTO dim_event (
    event_date,
    event_type
)
SELECT DISTINCT
    event_date,
    event_type
FROM stg_Customer360.staging.customer_activity_extract;

INSERT INTO dim_flag (
    resolved_flag
)
SELECT DISTINCT
    resolved_flag
FROM stg_Customer360.staging.customer_activity_extract;

INSERT INTO dim_channel (
    channel
)
SELECT DISTINCT
    channel
FROM stg_Customer360.staging.customer_activity_extract;

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

INSERT INTO dim_interaction (
    interaction_type
)
SELECT DISTINCT
    interaction_type
FROM stg_Customer360.staging.customer_activity_extract;

INSERT INTO fact_account_activity (
    event_id,
    location_id,
    client_id,
    account_id,
    interaction_id
)
SELECT 
    e.event_id,
    l.location_id,
    c.client_id,
    a.account_id,
    i.interaction_id
FROM stg_Customer360.staging.customer_activity_extract cae
LEFT JOIN dim_event e ON cae.event_date = e.event_date AND cae.event_type = e.event_type
LEFT JOIN dim_location l ON cae.city = l.city AND cae.province = l.province
LEFT JOIN dim_client c ON cae.client_number = c.client_number
LEFT JOIN dim_account a ON cae.account_number = a.account_number
LEFT JOIN dim_interaction i ON cae.interaction_type = i.interaction_type;

