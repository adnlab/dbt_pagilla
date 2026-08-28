-- Resolve address -> city -> country. One row per address_id.
with addresses as (

    select * from {{ ref('stg_addresses') }}

),

cities as (

    select * from {{ ref('stg_cities') }}

),

countries as (

    select * from {{ ref('stg_countries') }}

)

select
    a.address_id,
    a.district,
    c.city,
    co.country
from addresses a
left join cities c on c.city_id = a.city_id
left join countries co on co.country_id = c.country_id
