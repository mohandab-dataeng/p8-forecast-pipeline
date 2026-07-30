{{ config(
    materialized = 'table',
    indexes = [
      {'columns': ['id_time'], 'type': 'btree', 'unique': True}
    ]
) }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['annee', 'mois', 'semaine', 'jour']) }} AS id_time,
    annee,
    mois,
    semaine, 
    jour
FROM {{ ref('int_fct_forecast') }}