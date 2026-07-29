{{ config(materialized = 'view') }}
{% do ref('mapping_vent_direction') %}

SELECT DISTINCT
    *,
    '40'::INT AS semaine,
    '10'::INT AS mois,
    '2024'::INT AS annee,
    'weather_underground' AS source_origine
FROM (
    SELECT * FROM (
        {{ stg_macro_weather(source('raw', 'weather_ichtegem'), 'IICHTE19') }}
    )
    UNION ALL
    SELECT * FROM (
        {{ stg_macro_weather(source('raw', 'weather_la_madeleine'), 'ILAMAD25') }}
    )
) AS macro_result
