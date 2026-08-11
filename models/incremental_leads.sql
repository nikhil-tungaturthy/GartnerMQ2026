{{
    config(
        materialized='incremental',
        unique_key='lead_id',
        incremental_strategy='merge'
    )
}}

with source_leads as (

    select
        id as lead_id,
        first_name,
        last_name,
        title,
        company,
        email,
        phone,
        street,
        city,
        state,
        postal_code,
        country,
        created_date,
        last_modified_date,
        lead_source,
        status,
        industry
    from {{ source('salesforce', 'lead') }}
    where not is_deleted
      and not is_converted

    {% if is_incremental() %}
      and last_modified_date >= (
          select coalesce(max(last_modified_date), '1900-01-01'::timestamp_ntz)
          from {{ this }}
      )
    {% endif %}

)

select *
from source_leads
