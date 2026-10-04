--- Check duplicates in the staging table for analysis

WITH Duplicates AS
(
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
    amount,
        ROW_NUMBER() OVER (
            PARTITION BY Email
            ORDER BY
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
        ) AS RowNum
    FROM staging.customer_activity_extract
)
SELECT *
FROM Duplicates
WHERE RowNum > 1;

--- Client number, Event Type and Event Date are columns that can be used to identify duplicates in the staging table.
--- The SQL query below will preview the duplicates based on these columns that idenifyaccurate duplicates.

WITH Duplicates AS
(
    SELECT
        client_number,
        first_name,
        last_name,
        event_type,
        event_date,
        ROW_NUMBER() OVER (
            PARTITION BY
                client_number,
                first_name,
                last_name,
                event_type,
                event_date
            ORDER BY client_number
        ) AS RowNum
    FROM staging.customer_activity_extract
)
SELECT *
FROM Duplicates
WHERE RowNum > 1;

--- Now that we have identified the duplicates, we can delete them from the staging table. The SQL query below will delete the duplicates based on the columns that identify accurate duplicates.

WITH Duplicates AS
( 
SELECT
client_number,
event_type,
event_date,
ROW_NUMBER() OVER (
PARTITION BY
client_number,
event_type,
event_date
ORDER BY client_number
) AS RowNum
FROM staging.customer_activity_extract
)
DELETE FROM Duplicates
WHERE RowNum > 1;

--- We can verify that the duplicates have been deleted from the staging table by running the query below. The query will return no results if the duplicates have been successfully deleted.

WITH Duplicates AS
(
    SELECT
        client_number,
        event_type,
        event_date,
        ROW_NUMBER() OVER (
            PARTITION BY
                client_number,
                event_type,
                event_date
            ORDER BY client_number
        ) AS RowNum
    FROM staging.customer_activity_extract
)
SELECT *
FROM Duplicates
WHERE RowNum > 1;