{{ config(materialized = 'view') }}

SELECT DISTINCT
    *,
    horodatage::DATE AS date_jour,
    EXTRACT(week FROM horodatage)::INT AS semaine,
    EXTRACT(month FROM horodatage)::INT AS mois,
    EXTRACT(year FROM horodatage)::INT AS annee,
    'infoclimat' AS source_origine
FROM ({{ stg_macro_infoclimat(source("raw", "infoclimat")) }}) AS macro_result