

CREATE TABLE staging.customer_activity_extract (
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