-- Staging = light clean-up over ONE source (Pagila's customer table).
with source as (

    select * from {{ source('pagila', 'customer') }}

)

select
    customer_id,
    first_name,
    last_name,
    {{ full_name('first_name', 'last_name') }} as full_name,   -- macro
    email,
    address_id,
    store_id,
    activebool as is_active,
    create_date,
    last_update
from source
