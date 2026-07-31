{{ config(materialized = 'view') }}

SELECT * FROM {{ ref('stg_dim_station') }}