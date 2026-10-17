
-- Filing representative dimension for DOB NOW job filings
-- Grain: one row per distinct combination of filing representative attributes

WITH filing_reps AS (

    SELECT DISTINCT
        CAST(NULL AS STRING) AS first_name,
        CAST(NULL AS STRING) AS middle_initial,
        CAST(NULL AS STRING) AS last_name,
        CAST(NULL AS STRING) AS business_name,
        CAST(NULL AS STRING) AS street_name,
        CAST(NULL AS STRING) AS city,
        CAST(NULL AS STRING) AS state,
        CAST(NULL AS STRING) AS zip
    FROM {{ ref('stg_nyc_dob_job_filings') }}

),

dimension_rows AS (

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY
                first_name,
                middle_initial,
                last_name,
                business_name,
                street_name,
                city,
                state,
                zip
        ) AS filing_representative_key,
        first_name,
        middle_initial,
        last_name,
        business_name,
        street_name,
        city,
        state,
        zip
    FROM filing_reps

),

unknown_row AS (

    SELECT
        -1 AS filing_representative_key,
        CAST(NULL AS STRING) AS first_name,
        CAST(NULL AS STRING) AS middle_initial,
        CAST(NULL AS STRING) AS last_name,
        CAST(NULL AS STRING) AS business_name,
        CAST(NULL AS STRING) AS street_name,
        CAST(NULL AS STRING) AS city,
        CAST(NULL AS STRING) AS state,
        CAST(NULL AS STRING) AS zip

)

SELECT *
FROM unknown_row

UNION ALL

SELECT *
FROM dimension_rows
