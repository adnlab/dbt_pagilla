-- A film dimension: film + its category + a human-readable rating label
-- pulled from the rating_descriptions SEED (referenced with ref()).
with films as (

    select * from {{ ref('stg_films') }}

),

-- a film can have several categories -> roll them up to one row per film
categories as (

    select
        fc.film_id,
        string_agg(distinct cat.name, ', ' order by cat.name) as category
    from {{ source('pagila', 'film_category') }} fc
    left join {{ source('pagila', 'category') }} cat on cat.category_id = fc.category_id
    group by fc.film_id

),

ratings as (

    select * from {{ ref('rating_descriptions') }}

)

select
    f.film_id,
    f.title,
    c.category,
    f.rental_rate,
    f.length_minutes,
    f.rating,
    r.description as rating_description
from films f
left join categories c on c.film_id = f.film_id
left join ratings r    on r.rating = f.rating
