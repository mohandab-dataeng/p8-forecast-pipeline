-- test_date.sql --

SELECT *
FROM {{ ref('fct_forecast_meteo') }}
WHERE horodatage > now()