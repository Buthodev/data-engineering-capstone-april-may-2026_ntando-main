--- Q1

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


--- Q2

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

--- Q3

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

--- Q4

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

--- Q5

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

--- Q6

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

--- Q7

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

--- Q8

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

--- Q9

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


--- Q10

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


--- Q11

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


--- Q12

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

--- Q13

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


--- Q14

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

--- Q15

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


--- Q16

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


--- Q17

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


--- Q18

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

--- Q19

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


--- Q20

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