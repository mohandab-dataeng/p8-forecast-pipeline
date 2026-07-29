{{ config(
    materialized = 'table',
    indexes = [
        {'columns': ['id_station'], 'type': 'btree', 'unique':True},
        {'columns': ['nom_station'], 'type': 'btree'},
        {'columns': ['ville'], 'type': 'btree'},
        {'columns': ['pays'], 'type': 'btree'}
    ]
) }}

SELECT * FROM {{ ref('int_dim_station') }}