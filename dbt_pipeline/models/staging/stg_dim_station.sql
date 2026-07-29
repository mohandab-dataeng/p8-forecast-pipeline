{{ config(materialized = 'view') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'infoclimat') }}
),

deplie AS (
    SELECT
        station.value AS data_station
    FROM source s,
        LATERAL jsonb_array_elements(s.stations) AS station(value)
),

infoclimat_stations AS (
    SELECT DISTINCT
        data_station ->> 'id' AS id_station,
        data_station ->> 'name' AS nom_station,
        (data_station ->> 'latitude')::NUMERIC  AS latitude,
        (data_station ->> 'longitude')::NUMERIC AS longitude,
        (data_station ->> 'elevation')::NUMERIC AS altitude_m,
        data_station ->> 'type' AS type_station,
        NULL::TEXT AS ville,
        'France' AS pays,
        NULL::TEXT AS hardware,
        NULL::TEXT AS software,
        data_station -> 'license' ->> 'license' AS license,
        data_station -> 'license' ->> 'url' AS licence_url,
        data_station -> 'license' ->> 'source' AS licence_source,
        data_station -> 'license' ->> 'metadonnees' AS licence_metadonnees,
        'infoclimat' AS source_origine
    FROM deplie
),

weather_underground_stations AS (
    SELECT
        station_id AS id_station,
        station_name AS nom_station,
        latitude::NUMERIC,
        longitude::NUMERIC,
        elevation::NUMERIC AS altitude_m,
        NULL::TEXT AS type_station,
        city::TEXT AS ville,
        CASE
        WHEN station_id = 'IICHTE19' THEN 'Belgique'
            ELSE 'France'
            END AS pays,
        hardware::TEXT,
        software::TEXT,
        NULL::TEXT AS license,
        NULL::TEXT AS licence_url,
        NULL::TEXT AS licence_source,
        NULL::TEXT AS licence_metadonnees,
        'weather_underground' AS source_origine
    FROM {{ ref('weather_stations') }}
)

SELECT * FROM infoclimat_stations
UNION ALL
SELECT * FROM weather_underground_stations
