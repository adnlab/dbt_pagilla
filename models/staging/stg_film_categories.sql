-- Bridge table: which categories each film belongs to.
with source as (

    select * from {{ source('pagila', 'film_category') }}

)

select
    film_id,
    category_id,
    last_update
from source
