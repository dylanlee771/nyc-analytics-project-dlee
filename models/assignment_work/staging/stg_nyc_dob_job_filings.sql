
-- Clean and standardize NYC DOB NOW job filings
-- One row per job filing

WITH source AS (
    SELECT *
    FROM {{ source('raw', 'source_nyc_dob_job_apps') }}
),

cleaned AS (
    SELECT
        CAST(job_filing_number AS STRING) AS job_filing_number,

        UPPER(TRIM(CAST(filing_status AS STRING))) AS filing_status,
        TRIM(CAST(job_type AS STRING)) AS job_type,
        TRIM(CAST(filing_review_type AS STRING)) AS filing_review_type,

        CAST(house_no AS STRING) AS house_number,
        TRIM(CAST(street_name AS STRING)) AS street_name,

        CASE
            WHEN UPPER(TRIM(CAST(borough AS STRING)))
                IN ('MANHATTAN', 'NEW YORK COUNTY')
                THEN 'Manhattan'
            WHEN UPPER(TRIM(CAST(borough AS STRING)))
                IN ('BRONX', 'THE BRONX')
                THEN 'Bronx'
            WHEN UPPER(TRIM(CAST(borough AS STRING)))
                IN ('BROOKLYN', 'KINGS COUNTY')
                THEN 'Brooklyn'
            WHEN UPPER(TRIM(CAST(borough AS STRING)))
                IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY')
                THEN 'Queens'
            WHEN UPPER(TRIM(CAST(borough AS STRING)))
                IN ('STATEN ISLAND', 'RICHMOND COUNTY')
                THEN 'Staten Island'
            ELSE NULL
        END AS borough,

        CAST(postcode AS STRING) AS zip,
        CAST(block AS STRING) AS block,
        CAST(lot AS STRING) AS lot,
        CAST(bin AS STRING) AS bin,
        CAST(bbl AS STRING) AS bbl,
        CAST(council_district AS STRING) AS council_district,
        CAST(census_tract AS STRING) AS census_tract,
        CAST(nta AS STRING) AS nta,

        SAFE_CAST(filing_date AS TIMESTAMP) AS filing_date,
        SAFE_CAST(current_status_date AS TIMESTAMP)
            AS current_status_date,
        SAFE_CAST(first_permit_date AS TIMESTAMP) AS first_permit_date,
        SAFE_CAST(approved_date AS TIMESTAMP) AS approved_date,
        SAFE_CAST(signoff_date AS TIMESTAMP) AS signoff_date,

        TRIM(CAST(building_type AS STRING)) AS building_type,
        SAFE_CAST(existing_stories AS FLOAT64) AS existing_stories,
        SAFE_CAST(proposed_no_of_stories AS FLOAT64)
            AS proposed_stories,
        SAFE_CAST(existing_dwelling_units AS INT64)
            AS existing_dwelling_units,
        SAFE_CAST(proposed_dwelling_units AS INT64)
            AS proposed_dwelling_units,
        SAFE_CAST(initial_cost AS NUMERIC) AS initial_cost,
        SAFE_CAST(total_construction_floor_area AS NUMERIC)
            AS construction_floor_area,

        TRIM(CAST(job_description AS STRING)) AS job_description,
        SAFE_CAST(latitude AS FLOAT64) AS latitude,
        SAFE_CAST(longitude AS FLOAT64) AS longitude,

        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source
    WHERE job_filing_number IS NOT NULL
      AND TRIM(CAST(job_filing_number AS STRING)) != ''
      AND borough IS NOT NULL

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY job_filing_number
        ORDER BY current_status_date DESC NULLS LAST,
                 filing_date DESC NULLS LAST
    ) = 1
)

SELECT *
FROM cleaned
