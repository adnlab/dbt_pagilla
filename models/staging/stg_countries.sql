-- One cleaned row per country.
with source as (

    select * from {{ source('pagila', 'country') }}

)

select
    country_id,
    country,
    last_update
from source
