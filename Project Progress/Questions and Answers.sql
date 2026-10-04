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

--- Eastern Cape: 270 customers, 13.04% 
--- Kwa Zulu-Natal: 263 customers, 12.71%
--- Mpumalanga: 250 customers, 12.08%
--- Western Cape: 238 customers, 11.50%
--- Gauteng: 236 customers, 11,40%
--- North West: 227 customers, 10.97%
--- Free State: 213 customers, 10.29%
--- Northern Cape: 189 customers, 9.13%
--- Limpopo: 184 customers, 8.89%

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

--- Under 20: 288 customers, 2.32%
--- 20-29: 2178 customers, 17.54%
--- 30-39: 2130 customers, 17.15%
--- 40-49: 2016 customers, 16.23%
--- 50-59: 2100 customers, 16.91%
--- 60-69: 2040 customers, 16.43%
--- 70+: 1668 customers, 13.43%

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

--- October 2024: 204 signups
--- November 2024: 324 signups, 58.82% growth
--- December 2024: 246 signups, -24.07% growth
--- January 2025: 318 signups, 29.27% growth
--- February 2025: 378 signups, 18.87% growth
--- March 2025: 312 signups, -17.46% growth
--- April 2025: 294 signups, -5.77% growth
--- May 2025: 336 signups, 14.29% growth
--- June 2025: 180 signups, -46.43% growth

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

--- The total number of customer records with at least one problem is 12420.
--- Out of the 12420 problematic records, the breakdown is as follows:
--- 924 missing mobile number
--- 246 missing email addresses
--- 12420 duplicate client numbers and 12420 duplicate identities (name + date of birth)

--- 1170 customer records have valid problems as the duplicate client numbers and identities represent multiple transactions from the same customer.

--- 5. How many customers hold each product type, and how many hold more than one product (cross-holding)?

