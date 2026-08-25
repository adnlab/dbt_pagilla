-- SINGULAR test: a plain SQL query that must return ZERO rows to pass.
-- Here we assert no payment ever has a negative amount.
select
    payment_id,
    amount
from {{ ref('fct_payments') }}
where amount < 0
