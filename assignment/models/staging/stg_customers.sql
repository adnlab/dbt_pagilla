{{ config(materialized='view') }}

with source as (

    select * from {{ source('pagila', 'customer') }}

)

select
    customer_id,
    first_name,
    last_name,
    email,
    activebool as is_active,
    create_date::timestamp as created_at,
    last_update
from source
