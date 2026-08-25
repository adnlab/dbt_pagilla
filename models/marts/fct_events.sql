-- An INCREMENTAL model. First run builds the whole table; later runs only
-- process rows newer than what's already there -> big savings on huge tables.
{{
  config(
    materialized='incremental',
    unique_key='event_id'
  )
}}

select
    event_id,
    user_id,
    event_type,
    event_ts
from {{ source('raw', 'events') }}

-- var() lets us shift the window without editing code:
--   dbt run --select fct_events --vars '{"start_date": "2024-06-01"}'
where event_ts >= '{{ var("start_date") }}'

{% if is_incremental() %}
    -- Only on runs where the table ALREADY exists: grab just the new rows.
    and event_ts > (select max(event_ts) from {{ this }})
{% endif %}
