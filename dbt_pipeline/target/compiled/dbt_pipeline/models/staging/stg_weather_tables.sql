
depends_on: "meteoforecast"."raw"."mapping_vent_direction"
-- 1. Récupération dynamique de toutes les tables 'weather_%' dans le schéma 'raw' essentiel permet la scalabilite.


-- 2. Boucle sur les tables trouvées automatiquement

    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_ichtegem_011024"
),

cleaned AS (
    SELECT
        CAST('2024-10-01' AS DATE) AS date_jour,
        CAST('2024-10-01' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'IICHTE19' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_ichtegem_021024"
),

cleaned AS (
    SELECT
        CAST('2024-10-02' AS DATE) AS date_jour,
        CAST('2024-10-02' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'IICHTE19' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_ichtegem_031024"
),

cleaned AS (
    SELECT
        CAST('2024-10-03' AS DATE) AS date_jour,
        CAST('2024-10-03' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'IICHTE19' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_ichtegem_041024"
),

cleaned AS (
    SELECT
        CAST('2024-10-04' AS DATE) AS date_jour,
        CAST('2024-10-04' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'IICHTE19' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_ichtegem_051024"
),

cleaned AS (
    SELECT
        CAST('2024-10-05' AS DATE) AS date_jour,
        CAST('2024-10-05' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'IICHTE19' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_ichtegem_061024"
),

cleaned AS (
    SELECT
        CAST('2024-10-06' AS DATE) AS date_jour,
        CAST('2024-10-06' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'IICHTE19' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_ichtegem_071024"
),

cleaned AS (
    SELECT
        CAST('2024-10-07' AS DATE) AS date_jour,
        CAST('2024-10-07' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'IICHTE19' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_la_madeleine_011024"
),

cleaned AS (
    SELECT
        CAST('2024-10-01' AS DATE) AS date_jour,
        CAST('2024-10-01' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'ILAMAD25' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_la_madeleine_021024"
),

cleaned AS (
    SELECT
        CAST('2024-10-02' AS DATE) AS date_jour,
        CAST('2024-10-02' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'ILAMAD25' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_la_madeleine_031024"
),

cleaned AS (
    SELECT
        CAST('2024-10-03' AS DATE) AS date_jour,
        CAST('2024-10-03' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'ILAMAD25' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_la_madeleine_041024"
),

cleaned AS (
    SELECT
        CAST('2024-10-04' AS DATE) AS date_jour,
        CAST('2024-10-04' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'ILAMAD25' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_la_madeleine_051024"
),

cleaned AS (
    SELECT
        CAST('2024-10-05' AS DATE) AS date_jour,
        CAST('2024-10-05' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'ILAMAD25' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_la_madeleine_061024"
),

cleaned AS (
    SELECT
        CAST('2024-10-06' AS DATE) AS date_jour,
        CAST('2024-10-06' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'ILAMAD25' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

     UNION ALL 


    
    
        
    

    SELECT * FROM (
        








WITH source AS (
    SELECT * FROM "meteoforecast"."raw"."weather_la_madeleine_071024"
),

cleaned AS (
    SELECT
        CAST('2024-10-07' AS DATE) AS date_jour,
        CAST('2024-10-07' || ' ' || "Time" AS TIMESTAMP) AS horodatage,

        -- Nettoyage, castage, renomage et conversion des métriques
        ROUND(CAST((NULLIF(regexp_replace("Temperature", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS temperature_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Humidity", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS humidite_pourcentage,
        ROUND(CAST(NULLIF(regexp_replace("Pressure", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 33.8639, 2) AS pression_hpa,
        ROUND(CAST((NULLIF(regexp_replace("Dew_Point", '[^0-9.-]', '', 'g'), '')::NUMERIC - 32) * 5.0 / 9.0 AS NUMERIC), 2) AS point_rosee_celsius,
        ROUND(CAST(NULLIF(regexp_replace("Speed", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS vitesse_vent_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Gust", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 1.60934, 2) AS rafales_kmh,
        ROUND(CAST(NULLIF(regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_mm_h,
        ROUND(CAST(NULLIF(regexp_replace("Precip_Accum", '[^0-9.-]', '', 'g'), '') AS NUMERIC) * 25.4, 2) AS precipitation_cumul_mm,
        ROUND(CAST(NULLIF(regexp_replace("Solar", '[^0-9.-]', '', 'g'), '') AS NUMERIC), 2) AS rayonnement_solaire_wm2,
        "UV"::NUMERIC AS uv_indice,
        TRIM("Wind") AS direction_vent_cardinal,
        'ILAMAD25' AS id_station
    FROM source
),

-- Conversion des valeurs cardinale en degré
converted AS (
    SELECT
        c.date_jour,
        c.horodatage,
        c.temperature_celsius,
        c.humidite_pourcentage,
        c.pression_hpa,
        c.point_rosee_celsius,
        c.vitesse_vent_kmh,
        ic.degres AS direction_vent_degres,
        c.rafales_kmh,
        c.precipitation_mm_h,
        c.precipitation_cumul_mm,
        c.uv_indice,
        c.rayonnement_solaire_wm2,
        c.id_station
    FROM cleaned c
    LEFT JOIN "meteoforecast"."raw"."mapping_vent_direction" ic
        ON UPPER(TRIM(c.direction_vent_cardinal)) = UPPER(TRIM(ic.cardinal))
)

SELECT * FROM converted


    )

    

