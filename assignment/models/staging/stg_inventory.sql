{{ config(materialized='view') }}

with source as (

    select * from {{ source('pagila', 'inventory') }}

)

select
    inventory_id,
    film_id,
    store_id
from source
