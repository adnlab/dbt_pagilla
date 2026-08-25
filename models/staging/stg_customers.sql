-- Staging = light clean-up over ONE source. Materialized as a view.
with source as (

    select * from {{ source('raw', 'customers') }}

)

select
    id                                   as customer_id,
    first_name,
    last_name,
    first_name || ' ' || last_name       as full_name,
    email,
    country_code,
    updated_at
from source
