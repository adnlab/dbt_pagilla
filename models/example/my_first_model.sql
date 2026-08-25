-- The classic "hello world". Config overrides the folder default (view)
-- and builds a physical table instead. Inspect the compiled SQL in
-- target/compiled/dbt_class/models/example/my_first_model.sql
{{ config(materialized='table') }}

select
    1 as id,
    'hello dbt' as message
