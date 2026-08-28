-- Roll film-category bridge up to one row per film.
with film_categories as (

    select * from {{ ref('stg_film_categories') }}

),

categories as (

    select * from {{ ref('stg_categories') }}

)

select
    fc.film_id,
    string_agg(distinct cat.category_name, ', ' order by cat.category_name) as category
from film_categories fc
left join categories cat on cat.category_id = fc.category_id
group by fc.film_id
