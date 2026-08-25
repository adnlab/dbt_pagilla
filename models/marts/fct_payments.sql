-- The payments fact table (~51k rows). Built INCREMENTALLY: the first run
-- loads everything; later runs only process payments newer than what's
-- already there — the whole point of incremental models on big tables.
{{
  config(
    materialized='incremental',
    unique_key='payment_id'
  )
}}

with payments as (

    select * from {{ ref('stg_payments') }}

),

customers as (

    select customer_id, full_name from {{ ref('stg_customers') }}

)

select
    p.payment_id,
    p.customer_id,
    c.full_name as customer_name,
    p.staff_id,
    p.rental_id,
    p.amount,
    p.payment_date
from payments p
left join customers c on c.customer_id = p.customer_id

-- var() lets us shift the window without editing code:
--   dbt run --select fct_payments --vars '{"start_date": "2022-04-01"}'
where p.payment_date >= '{{ var("start_date") }}'

{% if is_incremental() %}
    -- Only on runs where the table ALREADY exists: grab just the new rows.
    and p.payment_date > (select max(payment_date) from {{ this }})
{% endif %}
