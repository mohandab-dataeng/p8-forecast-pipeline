{{ config(materialized = 'view') }}
depends_on: {{ ref('mapping_vent_direction') }}

-- 1. Récupération dynamique de toutes les tables 'weather_%' dans le schéma 'raw' essentiel permet la scalabilite.
{% set raw_tables = dbt_utils.get_relations_by_pattern(
    schema_pattern = 'raw',
    table_pattern = 'weather_%'
) %}

-- 2. Boucle sur les tables trouvées automatiquement
{% for t in raw_tables %}
    {# Extraction automatique du station_id depuis le nom de la table #}
    {% if 'ichtegem' in t.identifier %}
        {% set station_id = 'IICHTE19' %}
    {% elif 'la_madeleine' in t.identifier %}
        {% set station_id = 'ILAMAD25' %}
    {% else %}
        {% set station_id = 'UNKNOWN' %}
    {% endif %}

    SELECT * FROM (
        {{ stg_weather(t, station_id) }}
    )

    {% if not loop.last %} UNION ALL {% endif %}

{% endfor %}
