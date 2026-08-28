-- Customer dimension: identity + location + lifetime value.
-- Built only from staging + intermediate — never from raw sources.
with customers as (

    select * from {{ ref('stg_customers') }}

),

geo as (

    select * from {{ ref('int_addresses') }}

),

payments as (

    select * from {{ ref('int_customer_payments') }}

)

select
    c.customer_id,
    c.full_name,
    c.email,
    c.is_active,
    g.city,
    g.country,
    coalesce(p.payment_count, 0) as payment_count,
    coalesce(p.lifetime_value, 0) as lifetime_value
from customers c
left join geo g on g.address_id = c.address_id
left join payments p on p.customer_id = c.customer_id
