--- 1. How many customers does the bank have per province, and what share of the total does each province represent?

SELECT
    l.province,
    COUNT(DISTINCT f.client_id) AS customer_count,
    CAST(
        COUNT(DISTINCT f.client_id) * 100.0
        / SUM(COUNT(DISTINCT f.client_id)) OVER ()
        AS DECIMAL(5,2)
    ) AS percentage_of_total
FROM dbo.fact_account_activity AS f
INNER JOIN dbo.dim_location AS l
    ON f.location_id = l.location_id
GROUP BY
    l.province
ORDER BY
    customer_count DESC;

--- Eastern Cape: 266 customers, 13.10% 
--- Kwa Zulu-Natal: 261 customers, 12.86%
--- Mpumalanga: 246 customers, 12.12%
--- Western Cape: 231 customers, 11.38%
--- Gauteng: 228 customers, 11.23%
--- North West: 220 customers, 10.84%
--- Free State: 210 customers, 10.34%
--- Northern Cape: 185 customers, 9.11%
--- Limpopo: 183 customers, 9.01%

--- 2. What is the age distribution of the customer base? Present it in age bands of your own choosing and justify the bands.

SELECT
    age_band,
    COUNT(*) AS customer_count,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS percentage_of_total
FROM
(
    SELECT DISTINCT
        c.client_id,
        CASE
            WHEN c.date_of_birth IS NULL THEN 'Unknown'
            
            WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
                 - CASE
                     WHEN DATEADD(
                         YEAR,
                         DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                         c.date_of_birth
                       ) > GETDATE()
                     THEN 1
                     ELSE 0
                   END < 20
                THEN 'Under 20'

            WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
                 - CASE
                     WHEN DATEADD(
                         YEAR,
                         DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                         c.date_of_birth
                       ) > GETDATE()
                     THEN 1
                     ELSE 0
                   END BETWEEN 20 AND 29
                THEN '20-29'

            WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
                 - CASE
                     WHEN DATEADD(
                         YEAR,
                         DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                         c.date_of_birth
                       ) > GETDATE()
                     THEN 1
                     ELSE 0
                   END BETWEEN 30 AND 39
                THEN '30-39'

            WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
                 - CASE
                     WHEN DATEADD(
                         YEAR,
                         DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                         c.date_of_birth
                       ) > GETDATE()
                     THEN 1
                     ELSE 0
                   END BETWEEN 40 AND 49
                THEN '40-49'

            WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
                 - CASE
                     WHEN DATEADD(
                         YEAR,
                         DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                         c.date_of_birth
                       ) > GETDATE()
                     THEN 1
                     ELSE 0
                   END BETWEEN 50 AND 59
                THEN '50-59'

            WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
                 - CASE
                     WHEN DATEADD(
                         YEAR,
                         DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                         c.date_of_birth
                       ) > GETDATE()
                     THEN 1
                     ELSE 0
                   END BETWEEN 60 AND 69
                THEN '60-69'

            ELSE '70+'
        END AS age_band
    FROM dbo.dim_client AS c
) AS customer_age
GROUP BY age_band
ORDER BY
    CASE age_band
        WHEN 'Under 20' THEN 1
        WHEN '20-29' THEN 2
        WHEN '30-39' THEN 3
        WHEN '40-49' THEN 4
        WHEN '50-59' THEN 5
        WHEN '60-69' THEN 6
        WHEN '70+' THEN 7
        WHEN 'Unknown' THEN 8
    END;

--- Please note that the age bands are in gaps of 10 years.

--- Under 20: 47 customers, 2.32%
--- 20-29: 354 customers, 17.44%
--- 30-39: 349 customers, 17.19%
--- 40-49: 328 customers, 16.16%
--- 50-59: 347 customers, 17.09%
--- 60-69: 333 customers, 16.40%
--- 70+: 272 customers, 13.40%

--- 3. How many customers have signed up per month over the last two years? Is signup growth trending up, flat, or down?

SELECT
    YEAR(signup_date) AS signup_year,
    MONTH(signup_date) AS signup_month,
    FORMAT(signup_date, 'yyyy-MM') AS signup_period,
    COUNT(DISTINCT client_id) AS customer_signups,

    LAG(COUNT(DISTINCT client_id)) OVER (
        ORDER BY YEAR(signup_date), MONTH(signup_date)
    ) AS previous_month_signups,

    CAST(
        (
            COUNT(DISTINCT client_id)
            - LAG(COUNT(DISTINCT client_id)) OVER (
                ORDER BY YEAR(signup_date), MONTH(signup_date)
            )
        ) * 100.0
        / NULLIF(
            LAG(COUNT(DISTINCT client_id)) OVER (
                ORDER BY YEAR(signup_date), MONTH(signup_date)
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS month_over_month_growth_percent

FROM dbo.dim_client

WHERE signup_date >= DATEADD(YEAR, -2, CAST(GETDATE() AS DATE))
  AND signup_date <= CAST(GETDATE() AS DATE)

GROUP BY
    YEAR(signup_date),
    MONTH(signup_date),
    FORMAT(signup_date, 'yyyy-MM')

ORDER BY
    signup_year,
    signup_month;

--- October 2024: 31 signups
--- November 2024: 54 signups, 74.19% growth
--- December 2024: 41 signups, -24.07% growth
--- January 2025: 52 signups, 26.83% growth
--- February 2025: 62 signups, 19.23% growth
--- March 2025: 52 signups, -16.13% growth
--- April 2025: 49 signups, -5.77% growth
--- May 2025: 53 signups, 8.16% growth
--- June 2025: 30 signups, -43.40% growth

--- The signup growth is trending flat with the positive and negative growth percentages fluctuations.

--- 4. How many customer records look like data quality problems (e.g. missing contact details, duplicate identity)? Report the count and what you count as a "problem".

WITH customer_quality AS
(
    SELECT
        client_id,
        client_number,
        first_name,
        last_name,
        date_of_birth,
        signup_date,
        mobile_number,
        email,

        COUNT(*) OVER (
            PARTITION BY client_number
        ) AS duplicate_client_number,

        COUNT(*) OVER (
            PARTITION BY
                UPPER(LTRIM(RTRIM(first_name))),
                UPPER(LTRIM(RTRIM(last_name))),
                date_of_birth
        ) AS duplicate_identity

    FROM dbo.dim_client
),

problem_records AS
(
    SELECT
        client_id,

        CASE
            WHEN mobile_number IS NULL
              OR LTRIM(RTRIM(mobile_number)) = ''
            THEN 1 ELSE 0
        END AS missing_mobile,

        CASE
            WHEN email IS NULL
              OR LTRIM(RTRIM(email)) = ''
            THEN 1 ELSE 0
        END AS missing_email,

        CASE
            WHEN first_name IS NULL
              OR LTRIM(RTRIM(first_name)) = ''
              OR last_name IS NULL
              OR LTRIM(RTRIM(last_name)) = ''
            THEN 1 ELSE 0
        END AS missing_name,

        CASE
            WHEN date_of_birth IS NULL
            THEN 1 ELSE 0
        END AS missing_date_of_birth,

        CASE
            WHEN signup_date IS NULL
            THEN 1 ELSE 0
        END AS missing_signup_date,

        CASE
            WHEN duplicate_client_number > 1
            THEN 1 ELSE 0
        END AS duplicate_client_number,

        CASE
            WHEN duplicate_identity > 1
            THEN 1 ELSE 0
        END AS duplicate_identity

    FROM customer_quality
)

SELECT
    'Missing mobile number' AS problem_type,
    SUM(missing_mobile) AS problem_count
FROM problem_records

UNION ALL

SELECT
    'Missing email',
    SUM(missing_email)
FROM problem_records

UNION ALL

SELECT
    'Missing first or last name',
    SUM(missing_name)
FROM problem_records

UNION ALL

SELECT
    'Missing date of birth',
    SUM(missing_date_of_birth)
FROM problem_records

UNION ALL

SELECT
    'Missing signup date',
    SUM(missing_signup_date)
FROM problem_records

UNION ALL

SELECT
    'Duplicate client number',
    SUM(duplicate_client_number)
FROM problem_records

UNION ALL

SELECT
    'Duplicate identity (name + date of birth)',
    SUM(duplicate_identity)
FROM problem_records

UNION ALL

SELECT
    'TOTAL CUSTOMER RECORDS WITH AT LEAST ONE PROBLEM',
    COUNT(*)
FROM problem_records
WHERE
    missing_mobile = 1
    OR missing_email = 1
    OR missing_name = 1
    OR missing_date_of_birth = 1
    OR missing_signup_date = 1
    OR duplicate_client_number = 1
    OR duplicate_identity = 1;

--- The total number of customer records with at least one problem is 1175.
--- Out of the 12420 problematic records, the breakdown is as follows:
--- 159 missing mobile number
--- 40 missing email addresses
--- 1092 duplicate client numbers

--- 199 customer records have valid problems as the duplicate client numbers represent multiple transactions from the same customer.

--- 5. How many customers hold each product type, and how many hold more than one product (cross-holding)?

WITH customer_products AS
(
    SELECT
        f.client_id,
        COUNT(DISTINCT a.product_type) AS product_count
    FROM dbo.fact_account_activity AS f
    INNER JOIN dbo.dim_account AS a
        ON f.account_id = a.account_id
    GROUP BY
        f.client_id
),

product_summary AS
(
    SELECT
        a.product_type,
        COUNT(DISTINCT f.client_id) AS customer_count
    FROM dbo.fact_account_activity AS f
    INNER JOIN dbo.dim_account AS a
        ON f.account_id = a.account_id
    GROUP BY
        a.product_type
),

cross_holding AS
(
    SELECT
        COUNT(*) AS customers_with_multiple_products
    FROM customer_products
    WHERE product_count > 1
),

total_customers AS
(
    SELECT COUNT(*) AS total_customers
    FROM dbo.dim_client
)

SELECT
    ps.product_type,
    ps.customer_count,
    CAST(
        ps.customer_count * 100.0 / tc.total_customers
        AS DECIMAL(10,2)
    ) AS percentage_of_customers,
    ch.customers_with_multiple_products,
    CAST(
        ch.customers_with_multiple_products * 100.0
        / tc.total_customers
        AS DECIMAL(10,2)
    ) AS cross_holding_percentage
FROM product_summary AS ps
CROSS JOIN cross_holding AS ch
CROSS JOIN total_customers AS tc
ORDER BY
    ps.customer_count DESC;


--- Savings: 954 customers, 47%
--- Credit card: 940 customers, 46.31%
--- Personal loan: 895 customers, 44.09%
--- Unknown: 1958 customers, 16.09%
--- Customers with multiple products: 1688, 83.15% of total customers


--- 6. What is the total and average account balance by product type?

SELECT
    COALESCE(NULLIF(LTRIM(RTRIM(a.product_type)), ''), 'Unknown') AS product_type,

    SUM(f.account_balance) AS total_account_balance,

    AVG(f.account_balance) AS average_account_balance

FROM dbo.fact_account_activity AS f

INNER JOIN dbo.dim_account AS a
    ON f.account_id = a.account_id

GROUP BY
    COALESCE(NULLIF(LTRIM(RTRIM(a.product_type)), ''), 'Unknown')

ORDER BY
    total_account_balance DESC;


--- Savings: Total = 188177855.72, Average = 38944.09
--- Personal Loan: Total = 108760452.35, Average = 23715.75
--- Credit Card: Total = 53532482.62, Average = 11014.91
--- Unknown: Total: NULL, Average: NULL

--- 7. Which customers hold a Savings account but no Credit Card? Report the count, this is a cross-sell list.

WITH customer_products AS
(
    SELECT
        f.client_id,

        MAX(
            CASE
                WHEN UPPER(LTRIM(RTRIM(a.product_type))) = 'SAVINGS'
                THEN 1
                ELSE 0
            END
        ) AS has_savings,

        MAX(
            CASE
                WHEN UPPER(LTRIM(RTRIM(a.product_type))) = 'CREDIT CARD'
                THEN 1
                ELSE 0
            END
        ) AS has_credit_card

    FROM dbo.fact_account_activity AS f
    INNER JOIN dbo.dim_account AS a
        ON f.account_id = a.account_id

    GROUP BY
        f.client_id
)

SELECT
    COUNT(*) AS cross_sell_customer_count
FROM customer_products
WHERE
    has_savings = 1
    AND has_credit_card = 0;


--- The count is 529

--- 8. What proportion of Credit Card accounts are within 90% of their credit limit?

SELECT
    COUNT(*) AS total_credit_card_accounts,

    SUM(
        CASE
            WHEN f.account_balance >= f.credit_limit * 0.90
            THEN 1
            ELSE 0
        END
    ) AS accounts_within_90_percent,

    CAST(
        SUM(
            CASE
                WHEN f.account_balance >= f.credit_limit * 0.90
                THEN 1
                ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS percentage_within_90_percent

FROM dbo.fact_account_activity AS f

INNER JOIN dbo.dim_account AS a
    ON f.account_id = a.account_id

WHERE UPPER(LTRIM(RTRIM(a.product_type))) = 'CREDIT CARD'
  AND f.credit_limit IS NOT NULL
  AND f.account_balance IS NOT NULL;


--- 485 credit cards accounts or 9.98% of the total credit card accounts are within 90% of their credit limit.

--- 9. What is total transaction value by month, split by transaction type? Are there seasonal patterns?

 SELECT
    YEAR(e.event_date) AS transaction_year,
    MONTH(e.event_date) AS transaction_month,
    FORMAT(e.event_date, 'yyyy-MM') AS transaction_period,
    a.transaction_type,

    SUM(f.amount) AS total_transaction_value

FROM dbo.fact_account_activity AS f

INNER JOIN dbo.dim_event AS e
    ON f.event_id = e.event_id

INNER JOIN dbo.dim_account AS a
    ON f.account_id = a.account_id

WHERE f.amount IS NOT NULL

GROUP BY
    YEAR(e.event_date),
    MONTH(e.event_date),
    FORMAT(e.event_date, 'yyyy-MM'),
    a.transaction_type

ORDER BY
    transaction_year,
    transaction_month,
    a.transaction_type;

--- The data shows that there's a spike in transaction values during the months of December and January, which could be attributed to holiday spending and New Year financial activities.

--- 10. Which transaction channel handles the most transactions, and which handles the highest total value? (These may not be the same channel, explain why, if so.)

SELECT
    ch.channel,
    COUNT(*) AS transaction_count,
    SUM(f.amount) AS total_transaction_value
FROM dbo.fact_account_activity AS f
INNER JOIN dbo.dim_channel AS ch
    ON f.channel_id = ch.channel_id
WHERE f.amount IS NOT NULL
GROUP BY
    ch.channel
ORDER BY
    transaction_count DESC;


--- POS channel has the highest transaction count with 29539 total transactions
--- Online Banking channel has the highest total transaction value with 44208797.06 total value
--- The difference in channels handling the most transactions versus the highest total value can be attributed to the nature of transactions. POS transactions are typically smaller, everyday purchases, leading to a higher count but lower total value. In contrast, Online Banking transactions may involve larger sums, such as bill payments or transfers, resulting in a lower count but higher total value.

--- 11. Define "active customer" using transaction and/or interaction recency, state your definition, and report how many customers are active vs not, as of the latest date in the data.

WITH latest_date AS
(
    SELECT
        MAX(event_date) AS latest_event_date
    FROM dbo.dim_event
),

customer_activity AS
(
    SELECT
        c.client_id,
        MAX(e.event_date) AS last_activity_date
    FROM dbo.dim_client AS c

    LEFT JOIN dbo.fact_account_activity AS f
        ON c.client_id = f.client_id

    LEFT JOIN dbo.dim_event AS e
        ON f.event_id = e.event_id

    GROUP BY
        c.client_id
)

SELECT
    CASE
        WHEN ca.last_activity_date >= DATEADD(
            DAY,
            -90,
            ld.latest_event_date
        )
        THEN 'Active'
        ELSE 'Not Active'
    END AS customer_status,

    COUNT(*) AS customer_count,

    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS percentage_of_customers

FROM customer_activity AS ca
CROSS JOIN latest_date AS ld

GROUP BY
    CASE
        WHEN ca.last_activity_date >= DATEADD(
            DAY,
            -90,
            ld.latest_event_date
        )
        THEN 'Active'
        ELSE 'Not Active'
    END

ORDER BY
    customer_status DESC;

--- I define an "active customer" as one who has had at least one transaction or interaction within the last 90 days from the latest date in the data. This definition captures customers who are currently engaged with the bank's services.
--- Using that definition, there are 34 active customers which represent 0.27% of the total customer base.


--- 12. Who are the top 20 customers by total transaction value in the last 12 months of data? (Use the latest transaction date in the data as your reference point, not today's date, this is a static extract.)

WITH latest_date AS
(
    SELECT
        MAX(e.event_date) AS latest_transaction_date
    FROM dbo.fact_account_activity AS f
    INNER JOIN dbo.dim_event AS e
        ON f.event_id = e.event_id
),

customer_totals AS
(
    SELECT
        f.client_id,
        SUM(f.amount) AS total_transaction_value
    FROM dbo.fact_account_activity AS f
    INNER JOIN dbo.dim_event AS e
        ON f.event_id = e.event_id
    CROSS JOIN latest_date AS ld
    WHERE e.event_date >= DATEADD(
        MONTH,
        -12,
        ld.latest_transaction_date
    )
    AND e.event_date <= ld.latest_transaction_date
    AND f.amount IS NOT NULL
    GROUP BY
        f.client_id
)

SELECT TOP 20
    c.client_id,
    c.client_number,
    c.first_name,
    c.last_name,
    c.mobile_number,
    c.email,
    ct.total_transaction_value
FROM customer_totals AS ct
INNER JOIN dbo.dim_client AS c
    ON ct.client_id = c.client_id
ORDER BY
    ct.total_transaction_value DESC;


--- The top 20 customers by total transaction value in the last 12 months are as follows:
--- Ayesha De Villiers: 172571.75
--- Ayesha De Vill: 172571.75
--- Johan Steyn: 165889.54
--- Nadia Pillay: 156751.80
--- Marike Adams: 155256.80
--- Chane Mabaso: 154276.80
--- Andile Abraham: 146465.84
--- Andile Abrahams: 146465.84
--- David De vil: 144039.45
--- David De Villiers: 144039.45
--- Ilse Smith: 143697.00
--- Sam Dlam: 137946.69
--- Sam Dlamini: 137946.69
--- Marike Naidoo: 136697.96
--- Vusi Nkosi: 134736.66
--- Mpho Peter: 130751.55
--- Mpho Petersen: 130751.55
--- Karabo De vill: 117040.10




