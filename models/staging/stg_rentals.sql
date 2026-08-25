-- One row per rental (a DVD checked out from a store).
with source as (

    select * from {{ source('pagila', 'rental') }}

)

select
    rental_id,
    rental_date,
    return_date,
    inventory_id,
    customer_id,
    staff_id
from source
