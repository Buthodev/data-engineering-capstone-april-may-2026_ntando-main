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

--- Eastern Cape: 191 customers, 12.87% 
--- Kwa Zulu-Natal: 187 customers, 12.60%
--- Mpumalanga: 176 customers, 11.86%
--- Western Cape: 165 customers, 11.12%
--- Free State: 164 customers, 11.05%
--- Gauteng: 164 customers, 11.05%
--- North West: 158 customers, 10.65%
--- Northern Cape: 142 customers, 9.57%
--- Limpopo: 137 customers, 9.23%

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

--- Under 20: 33 customers, 2.22%
--- 20-29: 255 customers, 17.18%
--- 30-39: 260 customers, 17.52%
--- 40-49: 239 customers, 16.11%
--- 50-59: 252 customers, 16.98%
--- 60-69: 250 customers, 16.85%
--- 70+: 195 customers, 13.14%

--- The bank has a total of 1484 customers.

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

--- October 2024: 23 signups
--- November 2024: 38 signups, 65.22% growth
--- December 2024: 30 signups, -21.05% growth
--- January 2025: 37 signups, 23.33% growth
--- February 2025: 47 signups, 27.03% growth
--- March 2025: 41 signups, -12.77% growth
--- April 2025: 37 signups, -9.76% growth
--- May 2025: 39 signups, 5.41% growth
--- June 2025: 21 signups, -46.15% growth

--- The signup growth is trending flat with the positive and negative growth percentages fluctuations and consistent new signups each month.

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

--- The total number of customer records with at least one problem is 139.
--- Out of the 139 problematic records, the breakdown is as follows:
--- 113 missing mobile number
--- 29 missing email addresses
--- 0 duplicate client numbers
--- 0 duplicate identity records

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


--- Savings: 678 customers, 45.69%
--- Credit card: 673 customers, 45.35%
--- Personal loan: 649 customers, 43.73%
--- Customers with multiple products: 1219, 82.14% of total customers


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


--- Savings: Total = 135441481.13, Average = 38631.34
--- Personal Loan: Total = 80513506.81, Average = 23610.99
--- Credit Card: Total = 37946095.23, Average = 10780.14

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


--- The cross-sell count is 382

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


--- 358 credit cards accounts or 10.17% of the total credit card accounts are within 90% of their credit limit.

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


--- POS channel has the highest transaction count with 22454 total transactions
--- Online Banking channel has the highest total transaction value with 33781284.79 total value
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
            -120,
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
            -120,
            ld.latest_event_date
        )
        THEN 'Active'
        ELSE 'Not Active'
    END

ORDER BY
    customer_status DESC;

--- I define an "active customer" as one who has had at least one transaction or interaction within the last 120 days from the latest date in the data. This definition captures customers who are currently engaged with the bank's services.
--- Using that definition, there are:
--- 31 active customers which represent 2.09% of the total customer base.
--- 1453 not active customers which represent 97.91% of the total customer base.


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
--- Nadia Pillay:223344.72
--- Ayesha De vill: 155464.43
--- Marike Adams: 155256.80
--- Karabo Naidoo: 155009.28
--- Chane Mabaso: 154276.80
--- Andile Abraham: 146465.84
--- Naledi Abraham: 146415.30
--- David De vil: 144039.45
--- Ilse Smith: 143697.00
--- Sam Dlam: 137946.69
--- Marike Naidoo: 136697.96
--- Johan Steyn: 136630.17
--- Vusi Nkosi: 134736.66
--- Riaan Nkosi: 134203.32
--- Mpho Peter: 130751.55
--- Ayesha Smith: 124481.75
--- Karabo De vill: 117040.10
--- Kyle Peter: 116541.66
--- Thabo Mabaso: 113164.66
--- Grace Botha: 112698.70


--- 13. What is the average number of interactions per customer, split by interaction type?

WITH interaction_counts AS
(
    SELECT
        i.interaction_type,
        COUNT(*) AS total_interactions
    FROM dbo.fact_account_activity AS f
    INNER JOIN dbo.dim_interaction AS i
        ON f.interaction_id = i.interaction_id
    GROUP BY
        i.interaction_type
),

total_customers AS
(
    SELECT
        COUNT(*) AS customer_count
    FROM dbo.dim_client
)

SELECT
    ic.interaction_type,
    ic.total_interactions,
    CAST(
        ic.total_interactions * 1.0
        / NULLIF(tc.customer_count, 0)
        AS DECIMAL(10,2)
    ) AS average_interactions_per_customer

FROM interaction_counts AS ic
CROSS JOIN total_customers AS tc

ORDER BY
    average_interactions_per_customer DESC;

--- Zero interactions:62.94 average interactions per customer
--- Query: 1.36 average interactions per customer
--- Complaint: 0.60 average interactions per customer
--- Product Application: 0.60 average interactions per customer
--- Feedback: 0.31 average interactions per customer
--- Fraud Report: 0.14 average interactions per customer

--- 14. Which channel is most used for complaints specifically, versus other interaction types?

SELECT
    CASE
        WHEN UPPER(LTRIM(RTRIM(i.interaction_type))) = 'COMPLAINT'
        THEN 'Complaint'
        ELSE 'Other Interaction'
    END AS interaction_category,

    ch.channel,

    COUNT(*) AS interaction_count,

    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY
                CASE
                    WHEN UPPER(LTRIM(RTRIM(i.interaction_type))) = 'COMPLAINT'
                    THEN 'Complaint'
                    ELSE 'Other Interaction'
                END
        )
        AS DECIMAL(5,2)
    ) AS percentage_of_interactions

FROM dbo.fact_account_activity AS f

INNER JOIN dbo.dim_interaction AS i
    ON f.interaction_id = i.interaction_id

INNER JOIN dbo.dim_channel AS ch
    ON f.channel_id = ch.channel_id

GROUP BY
    CASE
        WHEN UPPER(LTRIM(RTRIM(i.interaction_type))) = 'COMPLAINT'
        THEN 'Complaint'
        ELSE 'Other Interaction'
    END,
    ch.channel

ORDER BY
    interaction_category,
    interaction_count DESC;

--- Complaints are most frequently handled through the Call channel which accounts for 21.74% of all complaint interactions.


--- 15. What is the resolution rate (resolved_flag = Y) by channel? Which channel resolves the least, and could that be sample-size noise rather than a real difference?

WITH channel_resolution AS
(
    SELECT
        ch.channel,

        COUNT(*) AS total_interactions,

        SUM(
            CASE
                WHEN UPPER(LTRIM(RTRIM(fg.resolved_flag))) = 'Y'
                THEN 1
                ELSE 0
            END
        ) AS resolved_interactions,

        SUM(
            CASE
                WHEN UPPER(LTRIM(RTRIM(fg.resolved_flag))) = 'N'
                THEN 1
                ELSE 0
            END
        ) AS unresolved_interactions

    FROM dbo.fact_account_activity AS f

    INNER JOIN dbo.dim_channel AS ch
        ON f.channel_id = ch.channel_id

    INNER JOIN dbo.dim_flag AS fg
        ON f.flag_id = fg.flag_id

    GROUP BY
        ch.channel
)

SELECT
    channel,
    total_interactions,
    resolved_interactions,
    unresolved_interactions,

    CAST(
        resolved_interactions * 100.0
        / NULLIF(total_interactions, 0)
        AS DECIMAL(5,2)
    ) AS resolution_rate_percent

FROM channel_resolution

ORDER BY
    resolution_rate_percent ASC;

--- To compare with a larger sample size

WITH channel_resolution AS
(
    SELECT
        ch.channel,

        COUNT(*) AS total_interactions,

        SUM(
            CASE
                WHEN UPPER(LTRIM(RTRIM(fg.resolved_flag))) = 'Y'
                THEN 1
                ELSE 0
            END
        ) AS resolved_interactions

    FROM dbo.fact_account_activity AS f

    INNER JOIN dbo.dim_channel AS ch
        ON f.channel_id = ch.channel_id

    INNER JOIN dbo.dim_flag AS fg
        ON f.flag_id = fg.flag_id

    GROUP BY
        ch.channel
),

overall AS
(
    SELECT
        SUM(total_interactions) AS total_interactions,
        SUM(resolved_interactions) AS resolved_interactions
    FROM channel_resolution
)

SELECT
    cr.channel,
    cr.total_interactions,
    cr.resolved_interactions,

    CAST(
        cr.resolved_interactions * 100.0
        / NULLIF(cr.total_interactions, 0)
        AS DECIMAL(5,2)
    ) AS resolution_rate_percent,

    CAST(
        o.resolved_interactions * 100.0
        / NULLIF(o.total_interactions, 0)
        AS DECIMAL(5,2)
    ) AS overall_resolution_rate_percent,

    CAST(
        (
            cr.resolved_interactions * 100.0
            / NULLIF(cr.total_interactions, 0)
        )
        -
        (
            o.resolved_interactions * 100.0
            / NULLIF(o.total_interactions, 0)
        )
        AS DECIMAL(5,2)
    ) AS difference_from_overall_percentage_points,

    CASE
        WHEN cr.total_interactions < 100
            THEN 'Small sample - difference may be noise'
        WHEN cr.total_interactions < 500
            THEN 'Moderate sample - interpret with caution'
        ELSE 'Large sample - more reliable'
    END AS sample_size_assessment

FROM channel_resolution AS cr
CROSS JOIN overall AS o

ORDER BY
    resolution_rate_percent ASC;



--- Resolution rates by channel are as follows:
--- ATM: 0%
--- Mobile App: 0%
--- Online Banking: 0%
--- POS: 0%
--- EFT: 0%
--- Branch: 4.76%
--- Call: 74.72%
--- WhatsApp: 74.75%
--- Email: 76.02%
--- Chat: 77.24%  

--- The channels with 0% resolution rates are reliable as they have been chacked with a larger sample size, indicating that these channels may not be effective for resolving customer issues.
--- The channels with higher resolution rates, such as Call, WhatsApp, Email and Chat, have larger sample sizes and are more reliable indicators of effective resolution.

--- 16. Segment customers into a small number of value tiers based on transaction activity (your choice of method, quartiles, fixed thresholds, etc.). Report the customer count and total transaction value per tier.

WITH customer_transaction_value AS
(
    SELECT
        c.client_id,
        c.client_number,
        c.first_name,
        c.last_name,

        COALESCE(SUM(f.amount), 0) AS total_transaction_value

    FROM dbo.dim_client AS c

    LEFT JOIN dbo.fact_account_activity AS f
        ON c.client_id = f.client_id

    GROUP BY
        c.client_id,
        c.client_number,
        c.first_name,
        c.last_name
),

customer_tiers AS
(
    SELECT
        client_id,
        client_number,
        first_name,
        last_name,
        total_transaction_value,

        NTILE(4) OVER (
            ORDER BY total_transaction_value
        ) AS value_quartile

    FROM customer_transaction_value
)

SELECT
    CASE value_quartile
        WHEN 1 THEN 'Low Value'
        WHEN 2 THEN 'Medium Value'
        WHEN 3 THEN 'High Value'
        WHEN 4 THEN 'Very High Value'
    END AS value_tier,

    COUNT(*) AS customer_count,

    SUM(total_transaction_value) AS total_transaction_value,

    CAST(
        AVG(total_transaction_value)
        AS DECIMAL(18,2)
    ) AS average_transaction_value_per_customer

FROM customer_tiers

GROUP BY
    value_quartile

ORDER BY
    value_quartile;


--- The customer segmentation into value tiers based on transaction activity is as follows:
--- Low Value: 371 customers; Total Transaction Value: -159205.05
--- Medium Value: 371 customers; Total Transaction Value: -54010.55
--- High Value: 371 customers; Total Transaction Value: -4512.31
--- Very High Value: 371 customers; Total Transaction Value: 44799.42


--- 17. Build a simple customer lifecycle segmentation (e.g. New / Active / At risk / Dormant) using signup date and activity recency. State your thresholds and justify them. Report the customer count per segment.

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
        c.client_number,
        c.signup_date,
        MAX(e.event_date) AS last_activity_date

    FROM dbo.dim_client AS c

    LEFT JOIN dbo.fact_account_activity AS f
        ON c.client_id = f.client_id

    LEFT JOIN dbo.dim_event AS e
        ON f.event_id = e.event_id

    GROUP BY
        c.client_id,
        c.client_number,
        c.signup_date
),

customer_segments AS
(
    SELECT
        ca.client_id,
        ca.client_number,
        ca.signup_date,
        ca.last_activity_date,

        CASE

            -- New: signed up and active within the last 90 days
            WHEN ca.signup_date >= DATEADD(
                    DAY,
                    -90,
                    ld.latest_event_date
                 )
             AND ca.last_activity_date >= DATEADD(
                    DAY,
                    -90,
                    ld.latest_event_date
                 )
            THEN 'New'

            -- Active: recent activity, but not a new customer
            WHEN ca.last_activity_date >= DATEADD(
                    DAY,
                    -90,
                    ld.latest_event_date
                 )
            THEN 'Active'

            -- At Risk: inactive for 91–180 days
            WHEN ca.last_activity_date >= DATEADD(
                    DAY,
                    -180,
                    ld.latest_event_date
                 )
            THEN 'At Risk'

            -- Dormant: no activity for more than 180 days
            ELSE 'Dormant'

        END AS lifecycle_segment

    FROM customer_activity AS ca
    CROSS JOIN latest_date AS ld
)

SELECT
    lifecycle_segment,
    COUNT(*) AS customer_count,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS percentage_of_customers

FROM customer_segments

GROUP BY
    lifecycle_segment

ORDER BY
    CASE lifecycle_segment
        WHEN 'New' THEN 1
        WHEN 'Active' THEN 2
        WHEN 'At Risk' THEN 3
        WHEN 'Dormant' THEN 4
    END;

--- The customer lifecycle segmentation based on signup date and activity recency is as follows:
--- New: Signed up and active within the last 90 days
--- Active: Has activity within the last 90 days, but is not a new customer.
--- At Risk: Last activity was 91–180 days ago.
--- Dormant: Last activity was more than 180 days ago.
--- Using these thresholds, the customer counts per segment are:

--- New: 0
--- Active: 22
--- At Risk: 413
--- Dormant: 1049

--- 18. Is there a relationship between number of CRM interactions and transaction value?

WITH customer_activity AS
(
    SELECT
        c.client_id,

        COUNT(
            DISTINCT CASE
                WHEN f.interaction_id IS NOT NULL
                THEN f.activity_id
            END
        ) AS interaction_count,

        COALESCE(
            SUM(f.amount),
            0
        ) AS total_transaction_value

    FROM dbo.dim_client AS c

    LEFT JOIN dbo.fact_account_activity AS f
        ON c.client_id = f.client_id

    GROUP BY
        c.client_id
),

interaction_groups AS
(
    SELECT
        client_id,
        interaction_count,
        total_transaction_value,

        CASE
            WHEN interaction_count = 0
                THEN '0 interactions'

            WHEN interaction_count BETWEEN 1 AND 2
                THEN '1-2 interactions'

            WHEN interaction_count BETWEEN 3 AND 5
                THEN '3-5 interactions'

            WHEN interaction_count BETWEEN 6 AND 10
                THEN '6-10 interactions'

            ELSE '11+ interactions'
        END AS interaction_group

    FROM customer_activity
)

SELECT
    interaction_group,

    COUNT(*) AS customer_count,

    SUM(total_transaction_value) AS total_transaction_value,

    CAST(
        AVG(total_transaction_value)
        AS DECIMAL(18,2)
    ) AS average_transaction_value_per_customer,

    CAST(
        AVG(interaction_count * 1.0)
        AS DECIMAL(10,2)
    ) AS average_interactions_per_customer

FROM interaction_groups

GROUP BY
    interaction_group

ORDER BY
    CASE interaction_group
        WHEN '0 interactions' THEN 1
        WHEN '1-2 interactions' THEN 2
        WHEN '3-5 interactions' THEN 3
        WHEN '6-10 interactions' THEN 4
        WHEN '11+ interactions' THEN 5
    END;


--- The relationship between the number of CRM interactions and transaction value is as follows:
--- 1-2 interactions: 89 customer count; 0 total transaction value
--- 3-5 interactions: 121 customer count; 0 total transaction value
--- 6-10 interactions: 31 customer count; 131451.22 total transaction value
--- 11+ interactions: 1243 customer count; -64287919.14 total transaction value


--- 19. Build a month-over-month retention view: of customers active in month N, what percentage were still active in month N+1?

WITH monthly_active_customers AS
(
    SELECT DISTINCT
        f.client_id,
        DATEFROMPARTS(
            YEAR(e.event_date),
            MONTH(e.event_date),
            1
        ) AS activity_month

    FROM dbo.fact_account_activity AS f

    INNER JOIN dbo.dim_event AS e
        ON f.event_id = e.event_id

    WHERE e.event_date IS NOT NULL
),

monthly_retention AS
(
    SELECT
        current_month.activity_month AS month_n,

        COUNT(DISTINCT current_month.client_id)
            AS active_customers_month_n,

        COUNT(DISTINCT next_month.client_id)
            AS retained_customers_month_n_plus_1

    FROM monthly_active_customers AS current_month

    LEFT JOIN monthly_active_customers AS next_month
        ON current_month.client_id = next_month.client_id
        AND next_month.activity_month = DATEADD(
            MONTH,
            1,
            current_month.activity_month
        )

    GROUP BY
        current_month.activity_month
)

SELECT
    month_n,

    active_customers_month_n,

    retained_customers_month_n_plus_1,

    CAST(
        retained_customers_month_n_plus_1 * 100.0
        / NULLIF(active_customers_month_n, 0)
        AS DECIMAL(5,2)
    ) AS month_over_month_retention_percent

FROM monthly_retention

ORDER BY
    month_n;

--- I've defined Month N as month 2, which N+1 retained 4 customers with a month-to-month retention of 66.67%    




--- 20. Identify accounts with unusual transaction patterns (e.g. a sudden spike relative to the account's own history) and explain what additional data you'd want to confirm whether it's fraud.


WITH monthly_account_activity AS
(
    SELECT
        f.account_id,
        a.account_number,
        a.product_type,

        DATEFROMPARTS(
            YEAR(e.event_date),
            MONTH(e.event_date),
            1
        ) AS transaction_month,

        SUM(ABS(f.amount)) AS monthly_transaction_value

    FROM dbo.fact_account_activity AS f

    INNER JOIN dbo.dim_account AS a
        ON f.account_id = a.account_id

    INNER JOIN dbo.dim_event AS e
        ON f.event_id = e.event_id

    WHERE f.amount IS NOT NULL
      AND e.event_date IS NOT NULL

    GROUP BY
        f.account_id,
        a.account_number,
        a.product_type,
        DATEFROMPARTS(
            YEAR(e.event_date),
            MONTH(e.event_date),
            1
        )
),

account_history AS
(
    SELECT
        account_id,
        account_number,
        product_type,
        transaction_month,
        monthly_transaction_value,

        AVG(monthly_transaction_value) OVER (
            PARTITION BY account_id
        ) AS average_monthly_value,

        STDEV(monthly_transaction_value) OVER (
            PARTITION BY account_id
        ) AS standard_deviation

    FROM monthly_account_activity
),

anomalies AS
(
    SELECT
        account_id,
        account_number,
        product_type,
        transaction_month,
        monthly_transaction_value,
        average_monthly_value,
        standard_deviation,

        CASE
            WHEN standard_deviation IS NULL
                THEN NULL

            ELSE
                (
                    monthly_transaction_value
                    - average_monthly_value
                )
                / NULLIF(standard_deviation, 0)
        END AS z_score

    FROM account_history
),

flagged_anomalies AS
(
    SELECT
        account_id,
        account_number,
        product_type,
        transaction_month,
        monthly_transaction_value,
        z_score

    FROM anomalies

    WHERE z_score >= 2
)

SELECT
    account_id,
    account_number,
    product_type,

    COUNT(*) AS flagged_transaction_count,

    SUM(monthly_transaction_value) AS flagged_transaction_value,

    MAX(z_score) AS highest_z_score

FROM flagged_anomalies

GROUP BY
    account_id,
    account_number,
    product_type

ORDER BY
    flagged_transaction_count DESC,
    highest_z_score DESC;


--- I would need the following additional information to investigate potential fraud further:
--- Transaction timestamp — unusual activity concentrated at unusual hours.
--- Transaction location — whether transactions occurred in unexpected geographic locations.
--- Device information — new device, browser, or device fingerprint.
--- IP address / login location — especially changes in geographic location.
--- Transaction merchant/beneficiary — new or high-risk recipients.
--- Transaction velocity — many transactions within minutes or hours.
--- Previous transaction history — whether the spike is genuinely abnormal for this customer.
--- Failed login/transaction attempts — potential account takeover indicators.






