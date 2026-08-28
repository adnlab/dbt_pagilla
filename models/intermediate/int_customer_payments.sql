-- Payment totals per customer — shared by dim_customers.
with payments as (

    select * from {{ ref('stg_payments') }}

)

select
    customer_id,
    count(*) as payment_count,
    sum(amount) as lifetime_value
from payments
group by customer_id
