with customers as (

    select * from {{ ref('dim_customers') }}

)

select
    customer_id,
    customer_name,
    total_rentals,
    first_rented_at,
    last_rented_at,
    lifetime_payment_total,
    case
        when total_rentals = 0 then 0
        else round(lifetime_payment_total / total_rentals, 2)
    end as average_payment_value
from customers