-- Film dimension: catalogue enriched with category and rating label.
-- Built only from staging, seeds, and intermediate — never from raw sources.
with films as (

    select * from {{ ref('stg_films') }}

),

categories as (

    select * from {{ ref('int_film_categories') }}

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
left join ratings r on r.rating = f.rating
