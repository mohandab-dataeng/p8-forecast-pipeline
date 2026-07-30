{{ config(
    materialized = 'table',
    indexes = [
      {'columns': ['id_forecast'], 'type': 'btree', 'unique': True},
      {'columns': ['id_station'], 'type': 'btree'},
      {'columns': ['horodatage'], 'type': 'btree'},
      {'columns': ['jour'], 'type': 'btree'}
    ],
     post_hook = [
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_fct_forecast_meteo_id_station FOREIGN KEY (id_station) REFERENCES {{ ref('dim_station_meteo') }} (id_station)",
        "ALTER TABLE {{ this }} ADD CONSTRAINT fk_fct_forecast_meteo_id_time FOREIGN KEY (id_time) REFERENCES {{ ref('dim_time') }} (id_time)"
     ]
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['f.id_station', 'f.horodatage', 'f.jour', 'f.source_origine', 'f.raw_id']) }} AS id_forecast,
    f.id_station,
    f.horodatage::TIME,
    f.jour::DATE,
    f.semaine,
    f.mois,
    f.annee,
    {{ dbt_utils.generate_surrogate_key(['f.annee', 'f.mois', 'f.semaine', 'f.jour']) }} AS id_time,
    f.temperature_celsius,
    f.humidite_pourcentage,
    f.pression_hpa,
    f.point_rosee_celsius,
    f.vitesse_vent_kmh,
    f.direction_vent_degres,
    f.rafales_kmh,
    f.precipitation_mm_h,
    f.precipitation_cumul_mm,
    f.uv_indice,
    f.rayonnement_solaire_wm2,
    f.source_origine,
    d.nom_station,
    d.latitude,
    d.longitude,
    d.ville,
    d.pays
FROM {{ ref('int_fct_forecast') }} AS f
LEFT JOIN {{ ref('int_dim_station') }} AS d
    ON f.id_station = d.id_station
