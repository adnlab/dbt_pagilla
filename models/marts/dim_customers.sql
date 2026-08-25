-- A customer dimension: identity + location + lifetime value.
-- Materialized as a TABLE (folder default) because BI reads it often.
with customers as (

    select * from {{ ref('stg_customers') }}

),

-- resolve the address -> city -> country chain from the raw sources
geo as (

    select
        a.address_id,
        a.district,
        c.city,
        co.country
    from {{ source('pagila', 'address') }} a
    left join {{ source('pagila', 'city') }}    c  on c.city_id = a.city_id
    left join {{ source('pagila', 'country') }} co on co.country_id = c.country_id

),

payments as (

    select
        customer_id,
        count(*)     as payment_count,
        sum(amount)  as lifetime_value
    from {{ ref('stg_payments') }}
    group by customer_id

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
left join geo g      on g.address_id = c.address_id
left join payments p on p.customer_id = c.customer_id
