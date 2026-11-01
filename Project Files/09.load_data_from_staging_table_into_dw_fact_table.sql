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

--------------------------------------------------------------------------------

--- ETL Pipeline Statement 'DW Loading' Package

IF NOT EXISTS (
    SELECT 1
    FROM dbo.fact_account_activity
)
BEGIN
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
END;
GO