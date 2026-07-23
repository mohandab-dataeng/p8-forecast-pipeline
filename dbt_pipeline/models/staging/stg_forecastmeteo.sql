{{ config(materialized='view') }}

{% set tables = [
    {'table_name': 'weather_ichtegem_011024', 'station_id': 'IICHTE19'},
    {'table_name': 'weather_ichtegem_021024', 'station_id': 'IICHTE19'},
    {'table_name': 'weather_ichtegem_031024', 'station_id': 'IICHTE19'},
    {'table_name': 'weather_ichtegem_041024', 'station_id': 'IICHTE19'},
    {'table_name': 'weather_ichtegem_051024', 'station_id': 'IICHTE19'},
    {'table_name': 'weather_ichtegem_061024', 'station_id': 'IICHTE19'},
    {'table_name': 'weather_ichtegem_071024', 'station_id': 'IICHTE19'},
    {'table_name': 'weather_la_madeleine_011024', 'station_id': 'ILAMAD25'},
    {'table_name': 'weather_la_madeleine_011024', 'station_id': 'ILAMAD25'},
    {'table_name': 'weather_la_madeleine_011024', 'station_id': 'ILAMAD25'},
    {'table_name': 'weather_la_madeleine_011024', 'station_id': 'ILAMAD25'},
    {'table_name': 'weather_la_madeleine_011024', 'station_id': 'ILAMAD25'},
    {'table_name': 'weather_la_madeleine_011024', 'station_id': 'ILAMAD25'},
    {'table_name': 'weather_la_madeleine_011024', 'station_id': 'ILAMAD25'},
] %}

{% for t in tables %}
{{ stg_weather(' ____', t.table_name, t.station_id) }}
{% if not loop.last %}_________ {% endif %}
{% endfor %}
