-- A fact table: one row per order, with its customer and total paid.
-- Materialized as a TABLE (folder default) because dashboards read it a lot.
with orders as (

    select * from {{ ref('stg_orders') }}

),

payments as (

    select
        order_id,
        sum(amount) as amount
    from {{ ref('stg_payments') }}
    group by order_id

),

customers as (

    select * from {{ ref('stg_customers') }}

)

select
    o.order_id,
    o.customer_id,
    c.full_name          as customer_name,
    o.order_date,
    o.status,
    coalesce(p.amount, 0) as amount
from orders o
left join payments p on p.order_id = o.order_id
left join customers c on c.customer_id = o.customer_id
