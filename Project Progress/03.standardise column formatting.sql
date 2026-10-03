--- Standardise formatting in each column

UPDATE staging.customer_activity_extract
SET client_number = UPPER(LTRIM(RTRIM(client_number)));

UPDATE staging.customer_activity_extract
SET first_name = UPPER(LEFT(LTRIM(RTRIM(first_name)), 1))
                 + LOWER(SUBSTRING(LTRIM(RTRIM(first_name)), 2, LEN(LTRIM(RTRIM(first_name)))));

UPDATE staging.customer_activity_extract
SET last_name = UPPER(LEFT(LTRIM(RTRIM(last_name)), 1))
                 + LOWER(SUBSTRING(LTRIM(RTRIM(last_name)), 2, LEN(LTRIM(RTRIM(first_name)))));

UPDATE staging.customer_activity_extract
SET email = LOWER(LTRIM(RTRIM(email)));

UPDATE staging.customer_activity_extract
SET mobile_number =
    CASE
        WHEN LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(mobile_number,
             ' ', ''), '-', ''), '(', ''), ')', ''), '+', ''), 2) = '27'
        THEN '0' + SUBSTRING(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(mobile_number,
            ' ', ''), '-', ''), '(', ''), ')', ''), '+', ''),
            3,
            20
        )

        ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(mobile_number,
             ' ', ''), '-', ''), '(', ''), ')', ''), '+', '')
    END;

