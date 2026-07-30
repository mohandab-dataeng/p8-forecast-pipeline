{{ config(materialized = 'view') }}

WITH fct_infoclimat AS (
    SELECT
        id_station,
        horodatage::TIME,
        date_jour::DATE AS jour,
        semaine,
        mois,
        annee,
        NULL::TEXT AS raw_id,
        temperature_celsius,
        humidite_pourcentage,
        pression_hpa,
        point_rosee_celsius,
        vitesse_vent_kmh,
        direction_vent_degres,
        rafales_kmh,
        precipitation_mm_h,
        precipitation_cumul_mm,
        NULL::NUMERIC AS uv_indice,
        NULL::NUMERIC AS rayonnement_solaire_wm2,
        source_origine
    FROM {{ ref('stg_fct_infoclimat_table') }}
),

fct_weather AS (
    SELECT
        id_station,
        horodatage,
        NULL::DATE AS jour,
        semaine,
        mois,
        annee,
        raw_id::TEXT AS raw_id,
        temperature_celsius,
        humidite_pourcentage,
        pression_hpa,
        point_rosee_celsius,
        vitesse_vent_kmh,
        direction_vent_degres,
        rafales_kmh,
        precipitation_mm_h,
        precipitation_cumul_mm,
        uv_indice,
        rayonnement_solaire_wm2,
        source_origine
    FROM {{ ref('stg_fct_weather_table') }}
)

SELECT * FROM fct_infoclimat
UNION ALL
SELECT * FROM fct_weather
