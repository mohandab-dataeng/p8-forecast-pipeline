-- test_comptage.sql --

WITH comptage_intermediate AS (
    SELECT COUNT(*) AS nb FROM {{ ref('int_fct_forecast') }}
),

comptage_mart AS (
    SELECT COUNT(*) AS nb FROM {{ ref('fct_forecast_meteo') }}
)

SELECT *
FROM comptage_intermediate, comptage_mart
WHERE comptage_intermediate.nb != comptage_mart.nb