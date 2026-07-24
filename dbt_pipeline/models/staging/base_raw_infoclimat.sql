with source as (
        select * from {{ source('raw', 'infoclimat') }}
  ),
  renamed as (
      select
        {{ adapter.quote("_airbyte_raw_id") }},
        {{ adapter.quote("_airbyte_extracted_at") }},
        {{ adapter.quote("_airbyte_meta") }},
        {{ adapter.quote("_airbyte_generation_id") }},
        {{ adapter.quote("data") }},
        {{ adapter.quote("errors") }},
        {{ adapter.quote("hourly") }},
        {{ adapter.quote("status") }},
        {{ adapter.quote("metadata") }},
        {{ adapter.quote("stations") }}

      from source
  )
  select * from renamed
    