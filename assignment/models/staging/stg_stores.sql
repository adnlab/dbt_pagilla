{{ config(materialized='view') }}

with source as (

    select * from {{ source('pagila', 'store') }}

)

select
    store_id,
    manager_staff_id,
    address_id
from source
