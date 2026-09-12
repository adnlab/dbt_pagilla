with customers as (

    select * from {{ ref('stg_customers') }}

),

rentals as (

    select
        customer_id,
        count(*) as total_rentals,
        min(rented_at) as first_rented_at,
        max(rented_at) as last_rented_at
    from {{ ref('stg_rentals') }}
    group by customer_id

),

payments as (

    select
        customer_id,
        sum(amount) as lifetime_payment_total
    from {{ ref('stg_payments') }}
    group by customer_id

)

select
    c.customer_id,
    {{ full_name('c.first_name', 'c.last_name') }} as customer_name,
    coalesce(r.total_rentals, 0) as total_rentals,
    r.first_rented_at,
    r.last_rented_at,
    coalesce(p.lifetime_payment_total, 0) as lifetime_payment_total
from customers c
left join rentals r on r.customer_id = c.customer_id
left join payments p on p.customer_id = c.customer_id