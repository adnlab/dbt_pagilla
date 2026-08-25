{#
  A SNAPSHOT captures how each row looked over time (SCD Type 2).
  strategy='timestamp' -> dbt watches the updated_at column. When it
  changes, the old row is closed off (dbt_valid_to set) and a new
  version is opened (dbt_valid_from). Run it with:  dbt snapshot
#}
{% snapshot customers_snapshot %}

{{
  config(
    target_schema='snapshots',
    unique_key='id',
    strategy='timestamp',
    updated_at='updated_at'
  )
}}

select * from {{ source('raw', 'customers') }}

{% endsnapshot %}
