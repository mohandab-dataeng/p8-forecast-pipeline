{% macro stg_macro_infoclimat(relation) %}

WITH source AS (
    SELECT * FROM {{ relation }}
),

ic_station AS (
    SELECT
        kv.key   AS id_station,
        kv.value AS array_mesure
    FROM source s,
        LATERAL jsonb_each(s.hourly) AS kv(key, value)
    WHERE kv.key != '_params'
),

deplie AS (
    SELECT st.id_station, mesure.value AS mesure_row   
    FROM ic_station st,
        LATERAL jsonb_array_elements(st.array_mesure) AS mesure(value)
)

SELECT
    id_station,
    (mesure_row ->> 'dh_utc')::TIMESTAMP AS horodatage,
    ROUND((mesure_row ->> 'temperature')::NUMERIC, 2) AS temperature_celsius,
    ROUND((mesure_row ->> 'pression')::NUMERIC, 2) AS pression_hpa,
    ROUND((mesure_row ->> 'humidite')::NUMERIC, 2) AS humidite_pourcentage,
    ROUND((mesure_row ->> 'point_de_rosee')::NUMERIC, 2) AS point_rosee_celsius,
    ROUND((mesure_row ->> 'vent_moyen')::NUMERIC, 2) AS vitesse_vent_kmh,
    ROUND((mesure_row ->> 'vent_rafales')::NUMERIC, 2) AS rafales_kmh,
    ROUND((mesure_row ->> 'vent_direction')::NUMERIC, 2) AS direction_vent_degres,
    ROUND((mesure_row ->> 'pluie_1h')::NUMERIC, 2) AS precipitation_mm_h,
    ROUND((mesure_row ->> 'pluie_3h')::NUMERIC, 2) AS precipitation_cumul_mm
FROM deplie

{% endmacro %}