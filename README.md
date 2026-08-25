# dbt Class — dbt Core + Postgres + Docker

A tiny, fully-runnable dbt project for a beginner data-engineering class.
Postgres runs in Docker; you run dbt Core from your machine against it.
Every step here maps to a **▶ LAB CHECKPOINT** in [`slides/`](slides/).

```
raw (Docker Postgres)  ──sources──▶  staging (views)  ──▶  marts (tables)
      seeds ─────────────ref─────────────┘                 tests · snapshots · docs
```

## 0. One-time setup

```bash
# Python env with dbt + the Postgres adapter
uv venv --python 3.11
uv pip install -r requirements.txt     # or: uv add dbt-core dbt-postgres
source .venv/bin/activate

# tell dbt to use the profiles.yml in this folder
export DBT_PROFILES_DIR=$(pwd)
```

## 1. Module 02 — bring up the warehouse & connect

```bash
docker compose up -d      # Postgres on localhost:5432, raw layer auto-loaded
dbt debug                 # expect: "All checks passed!"
dbt run --select my_first_model
```

## 2. Module 03 — seeds, sources & materializations

```bash
dbt seed                                    # load payment_types.csv
dbt run --select stg_customers fct_sales    # views + a table
dbt run --select fct_events                 # incremental: full build
dbt run --select fct_events                 # incremental: delta only (INSERT 0 0)
```

## 3. Module 04 — dynamic SQL (macro, hooks, vars)

```bash
dbt run --select stg_payments               # uses the cents_to_dollars() macro + seed
# every model's +post-hook grants SELECT to the "reporter" role
dbt run --select fct_events --vars '{"start_date": "2024-06-01"}'
```

## 4. Module 05 — trust: tests, history, docs

```bash
dbt test                      # 16 generic + singular tests
dbt snapshot                  # SCD Type 2 history of raw.customers
dbt build --select +fct_sales # run + test the model and everything upstream
dbt docs generate && dbt docs serve   # lineage graph at http://localhost:8080
```

## Peek at the results

```bash
docker exec -it dbt_class_pg psql -U dbt -d analytics \
  -c "select * from dev.fct_sales order by order_id;"
```

## Project layout

```
dbt_project.yml        project config (paths, vars, post-hook, materializations)
profiles.yml           Postgres connection (the "keycard")
docker-compose.yml     Postgres 16
docker/init/           SQL that seeds the raw layer on first boot -> dbt SOURCES
seeds/                 payment_types.csv (a tiny static lookup)
models/
  example/             my_first_model.sql  (hello world, table)
  staging/             stg_* views + _staging.yml (sources + tests)
  marts/               fct_sales (table), fct_events (incremental) + tests
macros/                cents_to_dollars.sql
snapshots/             customers_snapshot.sql (SCD Type 2)
tests/                 assert_fct_sales_amount_positive.sql (singular test)
slides/                the lecture deck (Slidev)
```

## Reset / teardown

```bash
dbt clean                       # remove target/
docker compose down             # stop Postgres (keeps data volume)
docker compose down -v          # stop + wipe data (fresh raw layer next boot)
```
