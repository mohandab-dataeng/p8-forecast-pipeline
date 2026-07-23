{% macro stg_weather(source_name, table_name, station_id) %}

-- Date: extraction de la date à partir du nom de table
{% set suffix = table_name[-6:] %}
{% set jour = suffix[0:2] %}
{% set mois = suffix[2:4] %}
{% set annee = "20" ~ suffix[4:6] %}
{% set date_combine = annee ~ "-" ~ mois ~ "-" ~ jour %}

WITH source AS (
    SELECT * FROM {{ source(source_name, table_name) }}
),

cleaned AS (
    SELECT
        -- Date
        '{{date_combine}}'::date AS date_jour,

        -- Horodatage : reconstruire date + heure
        ('{{ date_combine }}'::date + "Time"::time)  AS horodatage,

        -- Température : extraire nombre, convertir °F → °C
        (regexp_replace("Temperature", '[^0-9.\-]', '', 'g')::float - 32) * 5.0/9.0
            AS temperature,

        -- Humidité : extraire nombre
        regexp_replace("Humidity", '[^0-9.\-]', '', 'g')::float
            AS humidite,

        -- Pression : extraire nombre, convertir in → hPa
        regexp_replace("Pressure", '[^0-9.\-]', '', 'g')::float * 33.86
            AS pression,

        -- Point de rosée : extraire nombre, convertir °F → °C
        (regexp_replace("Dew_Point",  '[^0-9.\-]', '', 'g')::float - 32) * 5.0/9.0
            AS point_rosee,

        -- Vitesse vent : extraire nombre, convertir mph → km/h
        regexp_replace("Speed", '[^0-9.\-]', '', 'g')::float * 1.60934
            AS vitesse_vent,

        -- Direction vent : texte cardinal tel quel
        "Wind" AS direction_vent,

        -- Rafales : extraire nombre, convertir mph → km/h
        regexp_replace("Gust", '[^0-9.\-]', '', 'g')::float * 1.60934
            AS rafales,

        -- Précipitations rate : extraire nombre, convertir in → mm
        regexp_replace("Precip__Rate_", '[^0-9.\-]', '', 'g')::float * 25.4
            AS precipitation,

        -- Précipitations cumulées : extraire nombre, convertir in → mm
        regexp_replace("Precip_Accum", '[^0-9.\-]', '', 'g')::float * 25.4
            AS precipitation_cumul,

        -- UV : déjà numérique (Decimal)
        "UV"::float AS uv_indice,

        -- Rayonnement solaire : extraire nombre
        regexp_replace("Solar", '[^0-9.\-]', '', 'g')::float
            AS rayonement_solaire,

        -- Station ID
        '{{ station_id }}' AS id_station

    FROM source
)

SELECT * FROM cleaned

{% endmacro %}