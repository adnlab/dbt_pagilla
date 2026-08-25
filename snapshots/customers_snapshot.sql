{#
  A SNAPSHOT captures how each row looked over time (SCD Type 2).
  strategy='timestamp' -> dbt watches the last_update column. When it
  changes, the old row is closed off (dbt_valid_to set) and a new
  version is opened (dbt_valid_from). Run it with:  dbt snapshot
#}
{% snapshot customers_snapshot %}

{{
  config(
    target_schema='snapshots',
    unique_key='customer_id',
    strategy='timestamp',
    updated_at='last_update'
  )
}}

select * from {{ source('pagila', 'customer') }}

{% endsnapshot %}
