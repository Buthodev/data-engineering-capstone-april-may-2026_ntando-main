--- Create fact and dimension tables for data warehouse


CREATE TABLE dim_client (
    client_id INT IDENTITY(1,1) PRIMARY KEY,
    client_number VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    gender VARCHAR(20),
    date_of_birth DATE,
    signup_date DATE,
    mobile_number VARCHAR(30),
    email VARCHAR(255)
);

CREATE TABLE dim_location (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    city VARCHAR(100),
    province VARCHAR(100)
);

CREATE TABLE dim_event (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    event_date DATE NOT NULL,
    event_type VARCHAR(100)
);

CREATE TABLE dim_flag (
    flag_id INT IDENTITY(1,1) PRIMARY KEY,
    resolved_flag BIT
);

CREATE TABLE dim_channel (
    channel_id INT IDENTITY(1,1) PRIMARY KEY,
    channel VARCHAR(100)
);

CREATE TABLE dim_account (
    account_id INT IDENTITY(1,1) PRIMARY KEY,
    account_number VARCHAR(50) NOT NULL UNIQUE,
    product_type VARCHAR(100),
    account_status VARCHAR(50),
    transaction_type VARCHAR(100)
);

CREATE TABLE dim_interaction (
    interaction_id INT IDENTITY(1,1) PRIMARY KEY,
    interaction_type VARCHAR(100)
);

CREATE TABLE fact_account_activity (
    activity_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    event_id INT NOT NULL,
    location_id INT,
    client_id INT NOT NULL,
    account_id INT NOT NULL,
    interaction_id INT,
    flag_id INT,
    channel_id INT,

    loan_amount DECIMAL(18,2),
    credit_limit DECIMAL(18,2),
    amount DECIMAL(18,2),
    account_balance DECIMAL(18,2),

    FOREIGN KEY (event_id) REFERENCES dim_event(event_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (client_id) REFERENCES dim_client(client_id),
    FOREIGN KEY (account_id) REFERENCES dim_account(account_id),
    FOREIGN KEY (interaction_id) REFERENCES dim_interaction(interaction_id),
    FOREIGN KEY (flag_id) REFERENCES dim_flag(flag_id),
    FOREIGN KEY (channel_id) REFERENCES dim_channel(channel_id)
);
