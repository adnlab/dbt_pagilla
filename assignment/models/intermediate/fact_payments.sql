with payments as (

    select * from {{ ref('stg_payments') }}

),

customers as (

    select
        customer_id,
        {{ full_name('first_name', 'last_name') }} as customer_name
    from {{ ref('stg_customers') }}

),

rentals as (

    select * from {{ ref('stg_rentals') }}

),

inventory as (

    select * from {{ ref('stg_inventory') }}

),

films as (

    select * from {{ ref('stg_films') }}

)

select
    p.payment_id,
    p.paid_at,
    p.paid_at::date as paid_date,
    p.customer_id,
    c.customer_name,
    p.staff_id,
    inv.store_id,
    p.rental_id,
    inv.film_id,
    f.title as film_title,
    p.amount
from payments p
left join customers c on c.customer_id = p.customer_id
left join rentals r on r.rental_id = p.rental_id
left join inventory inv on inv.inventory_id = r.inventory_id
left join films f on f.film_id = inv.film_id