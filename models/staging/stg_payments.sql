-- Shows THREE dbt building blocks working together:
--   source()  -> the raw payments table
--   ref()     -> the payment_types SEED (a tiny static lookup CSV)
--   macro     -> cents_to_dollars() converts the integer cents to dollars
with payments as (

    select * from {{ source('raw', 'payments') }}

),

types as (

    select * from {{ ref('payment_types') }}

)

select
    p.id                                    as payment_id,
    p.order_id,
    p.payment_method,
    t.payment_type_label,
    {{ cents_to_dollars('p.amount_cents') }} as amount
from payments p
left join types t on t.payment_method = p.payment_method
