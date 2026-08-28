-- One cleaned row per address (links customer -> city -> country).
with source as (

    select * from {{ source('pagila', 'address') }}

)

select
    address_id,
    address,
    address2,
    district,
    city_id,
    postal_code,
    phone,
    last_update
from source
