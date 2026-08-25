-- SINGULAR test: a plain SQL query that must return ZERO rows to pass.
-- Here we assert no order ever has a negative amount.
select
    order_id,
    amount
from {{ ref('fct_sales') }}
where amount < 0
