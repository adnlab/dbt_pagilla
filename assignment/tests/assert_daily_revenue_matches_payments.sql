with source as (

    select
        (select sum(amount) from {{ ref('stg_payments') }}) as total_revenue,
        (select count(payment_id) from {{ ref('stg_payments') }}) as total_payments

),

mart as (

    select
        sum(total_revenue) as total_revenue,
        sum(total_payments) as total_payments
    from {{ ref('mart_daily_revenue') }}

)

select *
from source
cross join mart
where source.total_revenue != mart.total_revenue
    or source.total_payments != mart.total_payments