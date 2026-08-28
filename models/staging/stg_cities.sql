-- One cleaned row per city.
with source as (

    select * from {{ source('pagila', 'city') }}

)

select
    city_id,
    city,
    country_id,
    last_update
from source
