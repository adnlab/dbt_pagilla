-- One row per payment. Pagila's payment table is partitioned by month —
-- selecting the parent transparently returns every partition.
with source as (

    select * from {{ source('pagila', 'payment') }}

)

select
    payment_id,
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date
from source
