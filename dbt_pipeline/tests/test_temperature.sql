-- test_temperature.sql --

SELECT *
FROM {{ ref('fct_forecast_meteo') }}
WHERE temperature_celsius < -30 OR temperature_celsius > 55