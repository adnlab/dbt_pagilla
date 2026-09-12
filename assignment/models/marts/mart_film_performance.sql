with films as (

    select * from {{ ref('dim_films') }}

),

revenue as (

    select
        film_id,
        sum(amount) as total_revenue
    from {{ ref('fact_payments') }}
    group by film_id

)

select
    d.film_id,
    d.title,
    d.category,
    d.rental_rate,
    d.inventory_count,
    coalesce(d.times_rented, 0) as times_rented,
    coalesce(r.total_revenue, 0) as total_revenue
from films d
left join revenue r on r.film_id = d.film_id