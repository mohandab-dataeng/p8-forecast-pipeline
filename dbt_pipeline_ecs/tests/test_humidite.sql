-- test_humidite.sql --

SELECT *
FROM {{ ref('fct_forecast_meteo') }}
WHERE humidite_pourcentage < 0 OR humidite_pourcentage > 100