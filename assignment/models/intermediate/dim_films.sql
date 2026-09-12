with films as (

    select * from {{ ref('stg_films') }}

),

categories as (

    select
        fc.film_id,
        string_agg(cat.name, ', ' order by cat.name) as category
    from {{ source('pagila', 'film_category') }} fc
    inner join {{ source('pagila', 'category') }} cat on fc.category_id = cat.category_id
    group by fc.film_id

),

rating_descriptions as (

    select * from {{ ref('rating_descriptions') }}

),

inventory as (

    select
        film_id,
        count(*) as inventory_count
    from {{ ref('stg_inventory') }}
    group by film_id

),

rentals as (

    select
        i.film_id,
        count(*) as times_rented
    from {{ ref('stg_inventory') }} i
    inner join {{ ref('stg_rentals') }} r on i.inventory_id = r.inventory_id
    group by i.film_id

)

select
    f.film_id,
    f.title,
    c.category,
    f.rating,
    rd.description as rating_description,
    f.rental_rate,
    coalesce(inv.inventory_count, 0) as inventory_count,
    coalesce(ra.times_rented, 0) as times_rented,
    coalesce(inv.inventory_count, 0) > 0 as is_available
from films f
left join categories c on c.film_id = f.film_id
left join rating_descriptions rd on rd.rating = f.rating
left join inventory inv on inv.film_id = f.film_id
left join rentals ra on ra.film_id = f.film_id