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

UPDATE staging.customer_activity_extract
SET gender =
    CASE
        WHEN UPPER(LTRIM(RTRIM(gender))) IN ('M', 'MALE')
            THEN 'Male'

        WHEN UPPER(LTRIM(RTRIM(gender))) IN ('F', 'FEMALE')
            THEN 'Female'

        WHEN UPPER(LTRIM(RTRIM(gender))) IN ('O', 'OTHER')
            THEN 'Other'

        WHEN gender IS NULL
            OR LTRIM(RTRIM(gender)) = ''
            THEN 'Unknown'

        ELSE 'Unknown'
    END;

UPDATE staging.customer_activity_extract
SET province =
    CASE
        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('GAUTENG', 'GAUTENG PROVINCE')
            THEN 'Gauteng'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('WESTERN CAPE', 'WESTERN CAPE PROVINCE')
            THEN 'Western Cape'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('KWAZULU-NATAL', 'KWAZULU NATAL', 'KZN')
            THEN 'KwaZulu-Natal'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('EASTERN CAPE', 'EASTERN CAPE PROVINCE')
            THEN 'Eastern Cape'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('FREE STATE', 'FREE STATE PROVINCE')
            THEN 'Free State'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('LIMPOPO', 'LIMPOPO PROVINCE')
            THEN 'Limpopo'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('MPUMALANGA', 'MPUMALANGA PROVINCE')
            THEN 'Mpumalanga'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('NORTH WEST', 'NORTH WEST PROVINCE', 'NORTHWEST')
            THEN 'North West'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('NORTHERN CAPE', 'NORTHERN CAPE PROVINCE')
            THEN 'Northern Cape'

        WHEN province IS NULL
            OR LTRIM(RTRIM(province)) = ''
            THEN 'Unknown'

        ELSE 'Unknown'
    END;

--- Verify formatting has been standardised

SELECT *
FROM staging.customer_activity_extract;


-----------------------------------------------------------------------------


--- ETL Pipeline Statement 'Staging Package'

USE stg_Customer360;
GO

-- Standardise client number
UPDATE staging.customer_activity_extract
SET client_number = UPPER(LTRIM(RTRIM(client_number)))
WHERE client_number <> UPPER(LTRIM(RTRIM(client_number)))
   OR client_number IS NULL;
GO


-- Standardise first name
UPDATE staging.customer_activity_extract
SET first_name =
    UPPER(LEFT(LTRIM(RTRIM(first_name)), 1))
    + LOWER(SUBSTRING(
        LTRIM(RTRIM(first_name)),
        2,
        LEN(LTRIM(RTRIM(first_name)))
    ))
WHERE first_name <> (
    UPPER(LEFT(LTRIM(RTRIM(first_name)), 1))
    + LOWER(SUBSTRING(
        LTRIM(RTRIM(first_name)),
        2,
        LEN(LTRIM(RTRIM(first_name)))
    ))
)
OR first_name IS NULL;
GO


-- Standardise last name
UPDATE staging.customer_activity_extract
SET last_name =
    UPPER(LEFT(LTRIM(RTRIM(last_name)), 1))
    + LOWER(SUBSTRING(
        LTRIM(RTRIM(last_name)),
        2,
        LEN(LTRIM(RTRIM(last_name)))
    ))
WHERE last_name <> (
    UPPER(LEFT(LTRIM(RTRIM(last_name)), 1))
    + LOWER(SUBSTRING(
        LTRIM(RTRIM(last_name)),
        2,
        LEN(LTRIM(RTRIM(last_name)))
    ))
)
OR last_name IS NULL;
GO


-- Standardise email
UPDATE staging.customer_activity_extract
SET email = LOWER(LTRIM(RTRIM(email)))
WHERE email <> LOWER(LTRIM(RTRIM(email)))
   OR email IS NULL;
GO


-- Standardise mobile number
UPDATE staging.customer_activity_extract
SET mobile_number =
    CASE
        WHEN LEFT(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                mobile_number,
                ' ', ''), '-', ''), '(', ''), ')', ''), '+', ''),
            2
        ) = '27'
        THEN '0' + SUBSTRING(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                mobile_number,
                ' ', ''), '-', ''), '(', ''), ')', ''), '+', ''),
            3,
            20
        )

        ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            mobile_number,
            ' ', ''), '-', ''), '(', ''), ')', ''), '+', '')
    END
WHERE mobile_number IS NOT NULL;
GO


-- Standardise gender
UPDATE staging.customer_activity_extract
SET gender =
    CASE
        WHEN UPPER(LTRIM(RTRIM(gender))) IN ('M', 'MALE')
            THEN 'Male'

        WHEN UPPER(LTRIM(RTRIM(gender))) IN ('F', 'FEMALE')
            THEN 'Female'

        WHEN UPPER(LTRIM(RTRIM(gender))) IN ('O', 'OTHER')
            THEN 'Other'

        WHEN gender IS NULL
            OR LTRIM(RTRIM(gender)) = ''
            THEN 'Unknown'

        ELSE 'Unknown'
    END
WHERE gender IS NULL
   OR LTRIM(RTRIM(gender)) = ''
   OR UPPER(LTRIM(RTRIM(gender))) NOT IN
      ('M', 'MALE', 'F', 'FEMALE', 'O', 'OTHER')
   OR gender NOT IN ('Male', 'Female', 'Other', 'Unknown');
GO


-- Standardise province
UPDATE staging.customer_activity_extract
SET province =
    CASE
        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('GAUTENG', 'GAUTENG PROVINCE')
            THEN 'Gauteng'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('WESTERN CAPE', 'WESTERN CAPE PROVINCE')
            THEN 'Western Cape'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('KWAZULU-NATAL', 'KWAZULU NATAL', 'KZN')
            THEN 'KwaZulu-Natal'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('EASTERN CAPE', 'EASTERN CAPE PROVINCE')
            THEN 'Eastern Cape'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('FREE STATE', 'FREE STATE PROVINCE')
            THEN 'Free State'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('LIMPOPO', 'LIMPOPO PROVINCE')
            THEN 'Limpopo'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('MPUMALANGA', 'MPUMALANGA PROVINCE')
            THEN 'Mpumalanga'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('NORTH WEST', 'NORTH WEST PROVINCE', 'NORTHWEST')
            THEN 'North West'

        WHEN UPPER(LTRIM(RTRIM(province))) IN
            ('NORTHERN CAPE', 'NORTHERN CAPE PROVINCE')
            THEN 'Northern Cape'

        WHEN province IS NULL
            OR LTRIM(RTRIM(province)) = ''
            THEN 'Unknown'

        ELSE 'Unknown'
    END
WHERE province IS NULL
   OR LTRIM(RTRIM(province)) = ''
   OR UPPER(LTRIM(RTRIM(province))) NOT IN
      (
          'GAUTENG',
          'GAUTENG PROVINCE',
          'WESTERN CAPE',
          'WESTERN CAPE PROVINCE',
          'KWAZULU-NATAL',
          'KWAZULU NATAL',
          'KZN',
          'EASTERN CAPE',
          'EASTERN CAPE PROVINCE',
          'FREE STATE',
          'FREE STATE PROVINCE',
          'LIMPOPO',
          'LIMPOPO PROVINCE',
          'MPUMALANGA',
          'MPUMALANGA PROVINCE',
          'NORTH WEST',
          'NORTH WEST PROVINCE',
          'NORTHWEST',
          'NORTHERN CAPE',
          'NORTHERN CAPE PROVINCE'
      )
   OR province NOT IN
      (
          'Gauteng',
          'Western Cape',
          'KwaZulu-Natal',
          'Eastern Cape',
          'Free State',
          'Limpopo',
          'Mpumalanga',
          'North West',
          'Northern Cape',
          'Unknown'
      );
GO

