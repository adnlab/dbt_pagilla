with source as (

    select
        (select count(*) from {{ ref('stg_rentals') }}) as total_rentals,
        (select sum(amount) from {{ ref('stg_payments') }}) as total_payments

),

mart as (

    select
        sum(total_rentals) as total_rentals,
        sum(lifetime_payment_total) as total_payments
    from {{ ref('mart_customer_performance') }}

)

select *
from source
cross join mart
where source.total_rentals != mart.total_rentals
    or source.total_payments != mart.total_payments