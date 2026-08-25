# dbt Core: The Brutalist Blueprint

![dbt](https://img.shields.io/badge/dbt--core-1.9%2B-12d3c8?style=flat-square)
![Postgres](https://img.shields.io/badge/Postgres-16-0a0a0a?style=flat-square)
![Docker](https://img.shields.io/badge/Docker-compose-12d3c8?style=flat-square)
![build](https://img.shields.io/badge/dbt%20build-PASS%2024-12d3c8?style=flat-square)

A tiny, fully-runnable dbt project for a beginner data-engineering class.
**Both Postgres and dbt Core run in Docker** — no local Python required.
Every step here maps to a **▶ LAB CHECKPOINT** in the slides.

> 📊 **Slides:** https://thosangs.github.io/dbt_lecture/  ·  brutalist × teal, diagram-driven

### The stack

```mermaid
flowchart LR
    subgraph docker["🐳 docker compose"]
        direction LR
        subgraph pg["postgres:16 container"]
            raw[("raw schema<br/>customers · orders<br/>payments · events")]
        end
        subgraph dbtc["dbt container"]
            dbt["dbt Core<br/>+ postgres adapter"]
        end
    end
    dbt -->|reads / writes SQL| raw
```

### The model DAG (what dbt builds)

```mermaid
flowchart LR
    S1[/"source: raw.customers"/] --> M1["stg_customers<br/>(view)"]
    S2[/"source: raw.orders"/] --> M2["stg_orders<br/>(view)"]
    S3[/"source: raw.payments"/] --> M3["stg_payments<br/>(view)"]
    SEED["payment_types<br/>(seed)"] --> M3
    M1 --> F1["fct_sales<br/>(table)"]
    M2 --> F1
    M3 --> F1
    S4[/"source: raw.events"/] --> F2["fct_events<br/>(incremental)"]
    F1 --> T{{"tests · docs"}}
    F2 --> T
```

## The two containers

| Service | What it is |
|---|---|
| `postgres` | The warehouse. Raw layer auto-loaded on first boot. Started by `docker compose up`. |
| `dbt` | dbt Core + the Postgres adapter, in its own image. Invoked on demand with `docker compose run` (it's behind a compose profile, so `up` doesn't start it). |

## 0. Bring up the stack

```bash
docker compose up -d          # build images + start Postgres

# drop into the dbt container — every dbt command runs in here:
docker compose run --rm --service-ports dbt bash
```

You are now inside the container. Run the labs below from this shell.
(One-off without a shell: `docker compose run --rm dbt dbt debug`.)

## 1. Module 02 — connect & first run

```bash
dbt debug                        # expect: "All checks passed!"
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
dbt run --select stg_payments               # uses cents_to_dollars() macro + seed
dbt run --select fct_events --vars '{"start_date": "2024-06-01"}'
```

## 4. Module 05 — trust: tests, history, docs

```bash
dbt test                       # 16 generic + singular tests
dbt snapshot                   # SCD Type 2 history of raw.customers
dbt build --select +fct_sales  # run + test the model and everything upstream
dbt docs generate && dbt docs serve --host 0.0.0.0   # lineage at http://localhost:8080
```

## Peek at the results (from your host, another terminal)

```bash
docker exec -it dbt_class_pg psql -U dbt -d analytics \
  -c "select * from dev.fct_sales order by order_id;"
```

## Project layout

```
docker-compose.yml     postgres + dbt services
docker/init/           SQL that seeds the raw layer on first boot -> dbt SOURCES
docker/dbt/Dockerfile  the dbt Core + Postgres adapter image
dbt_project.yml        project config (paths, vars, post-hook, materializations)
profiles.yml           connection; host is env-driven (container vs local)
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
docker compose down             # stop everything (keeps data volume)
docker compose down -v          # stop + wipe data (fresh raw layer next boot)
```

## Optional: run dbt on your host instead of in Docker

`profiles.yml` reads `DBT_HOST` (defaults to `localhost`), so a host install works too:

```bash
uv venv --python 3.11 && uv pip install -r requirements.txt
source .venv/bin/activate
export DBT_PROFILES_DIR=$(pwd)
docker compose up -d postgres   # just the DB
dbt debug
```
