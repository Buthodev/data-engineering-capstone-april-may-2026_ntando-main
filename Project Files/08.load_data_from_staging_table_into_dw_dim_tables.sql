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


----------------------------------------------------------------------------------

--- ETL Pipeline Statement 'DW Loading' Package

--- Load staging tables into DW Dim tables

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
    s.client_number,
    s.first_name,
    s.last_name,
    s.gender,
    s.date_of_birth,
    s.signup_date,
    s.mobile_number,
    s.email
FROM stg_Customer360.staging.customer_activity_extract s
WHERE NOT EXISTS (
    SELECT 1
    FROM dim_client d
    WHERE d.client_number = s.client_number
);


INSERT INTO dim_location (
    city,
    province
)
SELECT DISTINCT
    s.city,
    s.province
FROM stg_Customer360.staging.customer_activity_extract s
WHERE NOT EXISTS (
    SELECT 1
    FROM dim_location d
    WHERE d.city = s.city
      AND d.province = s.province
);



INSERT INTO dim_event (
    event_date,
    event_type
)
SELECT DISTINCT
    s.event_date,
    s.event_type
FROM stg_Customer360.staging.customer_activity_extract s
WHERE NOT EXISTS (
    SELECT 1
    FROM dim_event d
    WHERE d.event_date = s.event_date
      AND d.event_type = s.event_type
);



INSERT INTO dim_flag (
    resolved_flag
)
SELECT DISTINCT
    s.resolved_flag
FROM stg_Customer360.staging.customer_activity_extract s
WHERE NOT EXISTS (
    SELECT 1
    FROM dim_flag d
    WHERE d.resolved_flag = s.resolved_flag
);



INSERT INTO dim_channel (
    channel
)
SELECT DISTINCT
    s.channel
FROM stg_Customer360.staging.customer_activity_extract s
WHERE NOT EXISTS (
    SELECT 1
    FROM dim_channel d
    WHERE d.channel = s.channel
);



INSERT INTO dim_account (
    account_number,
    product_type,
    account_status,
    transaction_type
)
SELECT DISTINCT
    s.account_number,
    s.product_type,
    s.account_status,
    s.transaction_type
FROM stg_Customer360.staging.customer_activity_extract s
WHERE NOT EXISTS (
    SELECT 1
    FROM dim_account d
    WHERE d.account_number = s.account_number
      AND d.product_type = s.product_type
      AND d.account_status = s.account_status
      AND d.transaction_type = s.transaction_type
);



INSERT INTO dim_interaction (
    interaction_type
)
SELECT DISTINCT
    s.interaction_type
FROM stg_Customer360.staging.customer_activity_extract s
WHERE NOT EXISTS (
    SELECT 1
    FROM dim_interaction d
    WHERE d.interaction_type = s.interaction_type
);






