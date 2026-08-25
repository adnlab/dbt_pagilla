---
theme: default
title: dbt Core — Engineering the Modern Data Warehouse
info: A hands-on beginner's course on dbt Core with Postgres & Docker for data engineers.
class: text-left
transition: slide-left
mdc: true
canvasWidth: 1120
fonts:
  sans: Archivo
  mono: JetBrains Mono
  weights: '400,600,700,900'
  local: Anton
drawings:
  enabled: false
---

<div class="frame"></div>

<div class="eyebrow">// Engineering the modern data warehouse</div>

# dbt Core:<br>The Brutalist Blueprint

<div class="mt-8 flow muted">
  A hands-on beginner's course — <b class="tk">dbt + Postgres + Docker</b>, from raw SQL chaos to a tested, self-documenting DAG.
</div>

<div class="abs-bl m-12 mb-10">
  <div class="card tk" style="display:inline-block">
    <div style="font-family:'JetBrains Mono';line-height:1.7">
      RUNTIME: <span class="tk">2.5 HOURS</span><br>
      TARGET:&nbsp; <span class="tk">DATA ENGINEERING · BEGINNER</span><br>
      MODE:&nbsp;&nbsp;&nbsp; <span class="tk">STRICT INSTRUCTION + LIVE LAB</span>
    </div>
  </div>
</div>

---
layout: section
---

<div class="eyebrow">// Today's build order</div>

# What We Will Build

<div class="grid grid-cols-2 gap-x-10 gap-y-3 mt-8 flow">
  <div><span class="num">01</span> The WHY — ELT, and what dbt actually is</div>
  <div><span class="num">02</span> Scaffolding — setup &amp; your first run</div>
  <div><span class="num">03</span> Pipelines — seeds, sources, materializations</div>
  <div><span class="num">04</span> Dynamic SQL — Jinja, macros, hooks, vars</div>
  <div><span class="num">05</span> Trust — tests, snapshots, docs &amp; the DAG</div>
  <div><span class="num">06</span> Best practices + synthesis</div>
</div>

<div class="mt-10 muted">Every module ends with a <span class="tk">▶ LAB CHECKPOINT</span> you run inside a fully Dockerized dbt + Postgres stack.</div>

---
layout: section
---

<div class="eyebrow">// Module 01 · 20 min</div>

# 01 — The Why<br>& dbt Foundations

<div class="mt-6 muted flow">Before we install anything: <b class="tk">what problem is dbt even solving?</b></div>

---

## Life Without dbt

<div class="grid grid-cols-2 gap-8 mt-2">

<div class="card">
<div class="box-h amber">// The analytics_v3_FINAL.sql era</div>

```sql
-- run_reports.sql (600 lines, one file)
DROP TABLE IF EXISTS reporting.users;
CREATE TABLE reporting.users AS
SELECT ... FROM raw.users u
JOIN raw.orders o ON o.uid = u.id  -- hope this is fresh?
WHERE ...;
-- then paste into a cron job. pray.
```

- Hardcoded table names everywhere
- No idea what runs *before* what
</div>

<div class="card">
<div class="box-h amber">// What actually hurts</div>

<div class="dont"><b>No dependency graph</b> — you guess the run order by hand</div>
<div class="dont"><b>No tests</b> — bad data ships silently to dashboards</div>
<div class="dont"><b>No docs / lineage</b> — "what feeds this table?" = archaeology</div>
<div class="dont"><b>Copy-paste SQL</b> — one logic change, 12 files to edit</div>
<div class="dont"><b>"Works on my machine"</b> — no dev vs prod separation</div>
</div>

</div>

<div class="mt-5 slab">dbt exists to make analytics code behave like <span class="hi">software</span>: versioned, tested, modular, documented.</div>

---

## The Paradigm Shift: ETL → ELT

<div class="grid grid-cols-2 gap-8 mt-2">

<div class="card">
<div class="box-h amber">// ETL — the legacy workshop</div>

- <b>E</b>xtract → <b>T</b>ransform → <b>L</b>oad
- Transform on a *separate* server (Python/Scala)
- Bottleneck: moving heavy data in &amp; out over the network
- Brittle, hand-crafted scripts
</div>

<div class="card tk">
<div class="box-h">// ELT — the modern foundry</div>

- <b>E</b>xtract → <b>L</b>oad → <b>T</b>ransform
- Load raw first, transform *inside* the warehouse
- Compute is elastic &amp; native (Postgres, BigQuery, Snowflake)
- Transform = standardized SQL, orchestrated by <b class="tk">dbt</b>
</div>

</div>

<div class="mt-5 flow"><b class="tk">dbt owns the "T".</b> The warehouse does the heavy lifting; dbt tells it what to build and in what order.</div>

---

## What Is dbt? (It Is NOT a Database)

<div class="flow mt-2 mb-4">Three kinds of files go in → one dependency-aware graph of SQL comes out.</div>

<div class="grid grid-cols-7 gap-3 items-center mt-2">

<div class="card col-span-2">
<code>model.sql</code><br><span class="muted text-sm">Transformation logic (SELECT)</span>
<div class="mt-3"><code>schema.yml</code><br><span class="muted text-sm">Tests &amp; docs</span></div>
<div class="mt-3"><code>macro.sql</code><br><span class="muted text-sm">Jinja functions</span></div>
</div>

<div class="text-center tk text-3xl">→</div>

<div class="card tk col-span-2 text-center">
<div class="box-h">// COMPILE ENGINE</div>
<div class="flow text-xl tk" style="font-family:'JetBrains Mono'">dbt compile</div>
</div>

<div class="text-center tk text-3xl">→</div>

<div class="slab col-span-1 text-center" style="font-size:0.8rem">RAW EXECUTABLE SQL</div>

</div>

<blockquote class="mt-5">dbt is a <b>software-engineering framework</b> that compiles SQL + Jinja + YAML into a <b>Directed Acyclic Graph (DAG)</b> — then hands warehouse-native SQL to your database.</blockquote>

---

## dbt Core vs dbt Cloud + Adapters

<div class="grid grid-cols-2 gap-8 mt-2">

<div class="card tk">
<div class="box-h">// dbt Core — what we use today</div>

- Open-source **command-line** tool (`pip`/`uv` install)
- You run it locally or in your own CI
- Free, self-hosted, full control
</div>

<div class="card">
<div class="box-h">// dbt Cloud</div>

- Managed scheduling, browser IDE, hosting
- Account-based, paid platform
- Same core concepts underneath
</div>

</div>

<div class="mt-5 box-h">// One dbt, many warehouses — via ADAPTERS</div>
<div class="flow mt-2">
  <code>dbt-postgres</code> · <code>dbt-bigquery</code> · <code>dbt-snowflake</code> · <code>dbt-redshift</code> · <code>dbt-duckdb</code>
</div>
<div class="mt-3 muted">Write once. Swap the adapter, keep the models. <b class="tk">This class targets <code>dbt-postgres</code>.</b></div>

---

## Why Teams Adopt dbt — The Benefits

<div class="grid grid-cols-2 gap-x-10 gap-y-2 mt-3">

<div class="do"><b>Modularity</b> — one model = one <code>SELECT</code>; compose with <code>ref()</code></div>
<div class="do"><b>Automatic DAG</b> — dbt infers run order from your references</div>
<div class="do"><b>Testing built in</b> — <code>unique</code>, <code>not_null</code>, custom SQL tests</div>
<div class="do"><b>Docs &amp; lineage</b> — a browsable graph, generated from code</div>
<div class="do"><b>Version control</b> — it's just files → Git, PRs, code review</div>
<div class="do"><b>Dev / prod parity</b> — same code, different target schema</div>
<div class="do"><b>Reusability</b> — macros &amp; packages kill copy-paste</div>
<div class="do"><b>Idempotent</b> — run it once or 1000×, same result</div>
</div>

<div class="mt-6 slab">You stop writing throwaway queries. You start <span class="hi">engineering the warehouse</span>.</div>

---
layout: section
---

<div class="eyebrow">// Module 02 · 20 min</div>

# 02 — Scaffolding<br>Setup & First Run

<div class="mt-6 muted flow"><b class="tk">Postgres + dbt, both in Docker</b>. Get everyone to a green <code>dbt debug</code>.</div>

---

## The Stack: Postgres + dbt in Docker

<div class="grid grid-cols-2 gap-8 mt-2">

<div class="card">
<div class="box-h">// docker-compose.yml — two services</div>

```yaml
services:
  postgres:            # the warehouse
    image: postgres:16
    ports: ["5432:5432"]

  dbt:                 # dbt Core itself
    build: ./docker/dbt
    profiles: ["dbt"]
    environment:
      DBT_HOST: postgres   # reach pg over
    volumes: [".:/usr/app"]  # the network
    working_dir: /usr/app
```
</div>

<div class="card tk">
<div class="box-h">// Everything runs in a container</div>

```bash
# build images + start Postgres
docker compose up -d

# drop into the dbt container…
docker compose run --rm \
  --service-ports dbt bash

# …now dbt runs in here:
dbt debug   # "All checks passed!"
```
</div>

</div>

<div class="mt-5 lab">
No local Python needed — dbt lives in its own image. Postgres is reachable at host <code>postgres</code> over the compose network. Every <code>dbt …</code> below runs <b class="tk">inside this shell</b>.
</div>

---

## The Project Tree

<div class="grid grid-cols-2 gap-8 mt-2 items-start">

<div class="card">
```bash
dbt_class/
├── dbt_project.yml   # the master plan
├── profiles.yml      # warehouse credentials
├── models/           # your SELECT logic
│   └── example/
│       ├── my_first_model.sql
│       └── schema.yml
├── macros/           # reusable Jinja
├── seeds/            # static CSV lookups
├── snapshots/        # SCD Type 2 history
└── tests/            # custom SQL tests
```
</div>

<div>
<div class="box-h">// What lives where</div>

- <code>dbt_project.yml</code> — paths, project name, global config
- <code>profiles.yml</code> — *how* to connect (the keycard)
- <code>models/</code> — the transformations (the whole point)
- <code>macros/</code> — DRY Jinja functions
- <code>seeds/</code> — tiny static CSVs (<code>dbt seed</code>)
- <code>snapshots/</code> — track history over time
- <code>tests/</code> — data-quality assertions

<div class="mt-4 muted">Folders map to dbt <b class="tk">resource types</b> — dbt knows what each one means.</div>
</div>

</div>

---

## The Wiring: Configuration YAML

<div class="grid grid-cols-2 gap-6 mt-2">

<div class="card">
<div class="box-h">// dbt_project.yml — project definition</div>

```yaml
name: 'dbt_class'
profile: 'dbt_class'
model-paths: ['models']

models:
  dbt_class:
    +materialized: view    # default
```
</div>

<div class="card tk">
<div class="box-h">// profiles.yml — Postgres credentials</div>

```yaml
dbt_class:
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: dbt
      password: dbt
      dbname: analytics
      schema: dev
      threads: 4
  target: dev
```
</div>

</div>

<div class="mt-4 muted"><code>profile:</code> in the project must match the <b class="tk">top key</b> in profiles.yml. This mismatch is the #1 beginner error.</div>

---

## The Command Lifecycle

<div class="grid grid-cols-3 gap-6 mt-4">

<div class="card">
<div class="box-h">// Step 1 — verify power</div>
<div class="flow tk text-lg">dbt debug</div>
<div class="mt-3">Tests the <code>profiles.yml</code> connection. Validates credentials &amp; network. <b>No data moved.</b></div>
</div>

<div class="card">
<div class="box-h">// Step 2 — read blueprints</div>
<div class="flow tk text-lg">dbt compile</div>
<div class="mt-3">Reads <code>.sql</code>/<code>.yml</code>, evaluates Jinja, writes raw SQL to <code>target/compiled/</code>. <b>Still no data moved.</b></div>
</div>

<div class="card tk">
<div class="box-h">// Step 3 — start machines</div>
<div class="flow tk text-lg">dbt run</div>
<div class="mt-3">Executes compiled SQL against Postgres — physically builds your tables &amp; views.</div>
</div>

</div>

<div class="mt-6 flow"><b class="tk">debug → compile → run.</b> Learn this loop; you'll type it 100× a day.</div>

---

## Your First Run

<div class="grid grid-cols-2 gap-8 mt-2 items-start">

<div>
<div class="box-h">// models/example/my_first_model.sql</div>

```sql
{{ config(materialized='table') }}

select 1 as id, 'hello dbt' as message
```

<div class="mt-4 box-h">// dbt turns it into...</div>

```sql
create table analytics.dev.my_first_model
as (
  select 1 as id, 'hello dbt' as message
);
```
</div>

<div class="lab">
Build it and inspect the result in Postgres:

```bash
# inside: docker compose run --rm dbt bash
dbt run --select my_first_model
# then from another shell:
#   docker exec -it dbt_class_pg \
#     psql -U dbt -d analytics \
#     -c 'select * from dev.my_first_model;'
```
Open <code>target/compiled/…/my_first_model.sql</code> — see the raw SQL dbt generated.
</div>

</div>

---
layout: section
---

<div class="eyebrow">// Module 03 · 30 min</div>

# 03 — Pipelines<br>Seeds · Sources · Materializations

<div class="mt-6 muted flow">How data <b class="tk">enters</b>, how dbt <b class="tk">references</b> it, and how you <b class="tk">shape</b> it.</div>

---

## Raw Materials: Seeds & Sources

<div class="grid grid-cols-3 gap-4 mt-2 items-start flow text-sm">

<div class="card">
<div class="box-h">// External data</div>

<b class="tk">Seeds</b> — small static <code>.csv</code> (country codes, mappings) loaded with <code>dbt seed</code>.

<div class="mt-3"><b class="tk">Sources</b> — raw tables already in the warehouse (loaded by ingestion).</div>
</div>

<div class="card">
<div class="box-h">// YAML binding (sources)</div>

```yaml
sources:
  - name: raw_data
    schema: raw
    tables:
      - name: books
      - name: customers
```
</div>

<div class="card tk">
<div class="box-h">// Reference in SQL</div>

```sql
-- instead of: from raw.books
from {{ source('raw_data','books') }}

-- instead of: from dev.customers
from {{ ref('stg_customers') }}
```
</div>

</div>

<div class="mt-5 flow"><b class="tk">Seeds ≠ ingestion.</b> Use seeds only for tiny lookups — never to load high-volume raw data.</div>

---

## `ref()` and `source()` — The Rule

<div class="grid grid-cols-2 gap-8 mt-2 items-start">

<div>
<div class="do"><b>Always</b> use <code v-pre>{{ ref('model') }}</code> for dbt models</div>
<div class="do"><b>Always</b> use <code v-pre>{{ source('sys','tbl') }}</code> for raw tables</div>
<div class="dont"><b>Never</b> hardcode <code>schema.table</code> paths</div>

<div class="mt-4 muted">Why it matters:</div>
- dbt builds the <b class="tk">DAG</b> from these references
- It auto-resolves dev vs prod schema
- Rename a model → downstream refs still work
</div>

<div class="card">
<div class="box-h">// The DAG dbt infers</div>

<div class="flow" style="line-height:2.2">
[<b>source</b>: raw.books]<br>
&nbsp;&nbsp;↓<br>
[<b>view</b>: stg_books]<br>
&nbsp;&nbsp;↓<br>
[<b>table</b>: fct_sales]
</div>

<div class="mt-3 muted text-sm">No manifest to maintain by hand — the references <i>are</i> the graph.</div>
</div>

</div>

---

## Shaping the Data: 5 Materializations

<div class="grid grid-cols-5 gap-3 mt-3 flow text-sm">

<div class="card">
<div class="box-h">VIEW</div>
Masquerades a query over real tables. Rebuilt logic each read.
</div>

<div class="card">
<div class="box-h">TABLE</div>
Physical storage, rebuilt from scratch every run.
</div>

<div class="card tk">
<div class="box-h">INCREMENTAL</div>
Appends / merges only new data batches (delta).
</div>

<div class="card">
<div class="box-h">EPHEMERAL</div>
Acts as a CTE — never physically stored.
</div>

<div class="card">
<div class="box-h">MAT. VIEW</div>
View logic + auto-refreshing physical storage.
</div>

</div>

<div class="mt-6 card tk text-center">
<div class="flow text-xl tk" v-pre>{{ config(materialized='table') }}</div>
</div>

<div class="mt-4 muted">Set it per-model in <code>config()</code>, or as a default in <code>dbt_project.yml</code>. <span class="tk">Materialized views: Postgres 16 support varies — verify on your adapter.</span></div>

---

## The Materialization Decision Matrix

| Strategy | Build time | Storage | Query | Best for |
|---|---|---|---|---|
| **View** | Instant | Zero | Slower | Light renames, filtering, logic abstraction |
| **Table** | Slow | High | Fast | Heavy joins, BI dashboard endpoints |
| **Incremental** | Fast *(delta)* | High | Fast | Massive event streams, time-series |
| **Ephemeral** | N/A *(CTE)* | Zero | Depends | Reusable intermediate steps, no clutter |
| **Mat. View** | Auto-refresh | Medium | Fastest | Pre-computed aggregates, near real-time |

<div class="mt-5 grid grid-cols-2 gap-6">
<div class="do"><b>DO</b> match strategy to transformation cost &amp; refresh needs</div>
<div class="dont"><b>DON'T</b> turn everything into a view — dashboards rebuild on every read</div>
</div>

---

## Deep Dive: Incremental Models

<div class="grid grid-cols-2 gap-8 mt-2 items-start">

<div class="card tk">
<div class="box-h">// models/fct_events.sql</div>

```sql
{{ config(
  materialized='incremental',
  unique_key='event_id'
) }}

select * from {{ source('raw','events') }}

{% if is_incremental() %}
  -- only rows newer than what we have
  where event_ts > (select max(event_ts) from {{ this }})
{% endif %}
```
</div>

<div>
- First run → builds the full table
- Next runs → <b class="tk">only new rows</b> get processed
- <code>is_incremental()</code> is true only when the table already exists
- <code v-pre>{{ this }}</code> = the model's own current table
- <code>unique_key</code> → merge/upsert instead of blind append

<div class="mt-4 muted">The single biggest cost saver on large datasets.</div>
</div>

</div>

---

## LAB — Build the Pipeline

<div class="lab mt-4">
Load a seed, declare a source, and materialize a model — watch the DAG come alive.

```bash
# inside: docker compose run --rm dbt bash
# 1. load a tiny static lookup CSV
dbt seed

# 2. build a staging view + a fact table
dbt run --select stg_customers fct_sales

# 3. run only incrementally
dbt run --select fct_events        # full first time
dbt run --select fct_events        # delta only the 2nd time
```
</div>

<div class="mt-5 flow muted">Check Postgres after each step: <code>dev.stg_customers</code> is a <b class="tk">view</b>, <code>dev.fct_sales</code> is a <b class="tk">table</b>.</div>

---
layout: section
---

<div class="eyebrow">// Module 04 · 30 min</div>

# 04 — Dynamic SQL<br>Jinja · Macros · Hooks · Vars

<div class="mt-6 muted flow">Bring <b class="tk">programming</b> into SQL — flexible, reusable, DRY pipelines.</div>

---

## Jinja: Control Flow Inside SQL

<div class="grid grid-cols-2 gap-8 mt-2 items-start">

<div class="card">
<div class="box-h" v-pre>// Conditionals &amp; the {{ this }} var</div>

```sql
select *
from {{ ref('events') }}
{% if is_incremental() %}
  where date > (select max(date) from {{ this }})
{% endif %}
```
</div>

<div class="card">
<div class="box-h">// Loops — generate repetitive SQL</div>

```sql
select
  {% for p in ['web','ios','android'] %}
  sum(case when platform='{{ p }}'
      then revenue end) as rev_{{ p }}
  {%- if not loop.last %},{% endif %}
  {% endfor %}
from {{ ref('orders') }}
```
</div>

</div>

<div class="mt-5 grid grid-cols-2 gap-6">
<div class="do"><b>DO</b> use whitespace control <code>{%- … -%}</code> for clean compiled SQL</div>
<div class="dont"><b>DON'T</b> nest curlies <code v-pre>{{ {{ x }} }}</code> — it breaks the compiler</div>
</div>

---

## Macros — Functions for SQL

<div class="grid grid-cols-2 gap-8 mt-2 items-start">

<div class="card tk">
<div class="box-h">// macros/generate_schema_name.sql</div>

```sql
{% macro generate_schema_name(custom, node) -%}
  {%- if custom is none -%}
    {{ target.schema }}
  {%- else -%}
    {{ custom | trim }}
  {%- endif -%}
{%- endmacro %}
```
</div>

<div>
- A macro is a <b class="tk">reusable function</b> written in Jinja
- Abstract repeated logic once, call it everywhere
- Some macros are <b class="tk">special</b> — dbt calls them by name
  - <code>generate_schema_name</code> controls output schemas
- Call your own: <code v-pre>{{ my_macro(arg) }}</code>

<div class="mt-4 muted">Macros are functions. Jinja is the control flow. Together they compile <b class="tk">context-aware</b> SQL.</div>
</div>

</div>

---

## Hooks & The Execution Order

<div class="flow mt-2 mb-4">Run SQL <b class="tk">around</b> your models — grants, logging, cleanup.</div>

<div class="grid grid-cols-2 gap-x-10 gap-y-2 flow">
<div><b class="tk">on-run-start</b> — once, at the beginning of <code>dbt run</code></div>
<div><b class="tk">pre-hook</b> — right before a specific model builds</div>
<div class="slab" style="grid-column:span 2">[ JINJA COMPILATION ] → dbt resolves ref()/macros into raw SQL</div>
<div class="slab" style="grid-column:span 2"><span class="hi">[ SQL EXECUTION ]</span> the warehouse runs the DDL/DML</div>
<div><b class="tk">post-hook</b> — right after that model builds (e.g. GRANT)</div>
<div><b class="tk">on-run-end</b> — once, at the very end of the run</div>
</div>

<div class="card mt-4">

```yaml
models:
  dbt_class:
    +post-hook: "grant select on {{ this }} to reporter"
```
</div>

---

## Variables — Parametrize Everything

<div class="grid grid-cols-2 gap-8 mt-2 items-start">

<div class="card">
<div class="box-h">// define in dbt_project.yml</div>

```yaml
vars:
  start_date: '2024-01-01'
  is_staff_excluded: true
```
</div>

<div class="card tk">
<div class="box-h">// use in a model</div>

```sql
select * from {{ ref('events') }}
where event_date >= '{{ var("start_date") }}'
{% if var('is_staff_excluded') %}
  and not is_staff
{% endif %}
```
</div>

</div>

<div class="mt-4 box-h">// override at the command line</div>

```bash
dbt run --vars '{"start_date": "2025-01-01"}'
```

<div class="mt-3 muted">Same models, different windows — backfills, environments, and one-off reruns without editing code.</div>

---

## LAB — Make It Dynamic

<div class="lab mt-4">
Write a macro, call it from a model, and re-run with an overridden variable.

```bash
# inside: docker compose run --rm dbt bash
# 1. add macros/cents_to_dollars.sql, use it in a model
dbt run --select stg_payments

# 2. add a post-hook grant, confirm it fired
dbt run --select fct_sales

# 3. override a var at runtime
dbt run --select fct_events --vars '{"start_date":"2025-06-01"}'
```
</div>

<div class="mt-5 flow muted">Inspect <code>target/compiled/</code> to see your Jinja resolved into plain SQL.</div>

---
layout: section
---

<div class="eyebrow">// Module 05 · 30 min</div>

# 05 — Ensuring Trust<br>Tests · History · Docs

<div class="mt-6 muted flow">A data product is only as good as the <b class="tk">trust</b> it commands.</div>

---

## Inspection: The Testing Binary

<div class="grid grid-cols-2 gap-8 mt-2 items-start">

<div class="card tk">
<div class="box-h">// Generic tests</div>

- Predefined, **schema-level**, configured in YAML
- Core types: <code>unique</code>, <code>not_null</code>, <code>accepted_values</code>, <code>relationships</code>

```yaml
columns:
  - name: id
    data_tests:
      - unique
      - not_null
```
</div>

<div class="card">
<div class="box-h">// Singular tests</div>

- Custom, **data-level**, authored as SQL in <code>/tests</code>
- Must return <b class="amber">ZERO rows</b> to pass

```sql
-- tests/grade_in_bounds.sql
select id from {{ ref('calc_grades') }}
where grade < 0 or grade > 100
```
</div>

</div>

<div class="mt-5 flow"><code>dbt test</code> runs them all. <b class="tk">Design the query to fail if it finds a problem.</b></div>

---

## Time Travel: Snapshots & SCD Type 2

<div class="card mt-2">
<div class="box-h">// ID: 1 · SALARY: 5000 → 6000 · strategy: timestamp (updated_at)</div>

<div class="flow" style="line-height:2">
[T-0] INSERTED&nbsp;&nbsp;&nbsp; valid_from: 2025-01-01 &nbsp; valid_to: 2025-06-01 &nbsp;<span class="hi-amber">INVALIDATED</span><br>
[T-1] UPDATED→6000 &nbsp; valid_from: 2025-06-01 &nbsp; valid_to: null &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="hi">ACTIVE</span>
</div>
</div>

<div class="mt-5 grid grid-cols-2 gap-8">
<div>
<div class="do"><b>strategy: timestamp</b> — track changes via an <code>updated_at</code> column</div>
</div>
<div>
<div class="dont"><b>strategy: check</b> — compare columns when no timestamp exists (heavier)</div>
</div>
</div>

<div class="mt-3 muted">Snapshots capture <b class="tk">how a row looked over time</b> — dbt manages <code>dbt_valid_from</code> / <code>dbt_valid_to</code> for you. Run with <code>dbt snapshot</code>.</div>

---

## Node Selection & Graph Operators

<div class="card mt-2">
<div class="box-h">// [source: raw] → [view: stg_users] → [table: fct_users] → [dashboards]</div>
</div>

<div class="mt-4 grid grid-cols-1 gap-2 flow">
<div><code>dbt run --select stg_users</code><span class="muted"> — just this one model</span></div>
<div><code>dbt run --select <b class="tk">+</b>fct_users</code><span class="muted"> — fct_users AND all upstream parents</span></div>
<div><code>dbt run --select fct_users<b class="tk">+</b></code><span class="muted"> — fct_users AND all downstream children</span></div>
<div><code>dbt run --select <b class="tk">@</b>fct_users</code><span class="muted"> — parents, the model, and children's parents too</span></div>
<div><code>dbt build --select tag:daily</code><span class="muted"> — run + test everything tagged daily</span></div>
</div>

<div class="mt-5 muted">Selectors let you rebuild <b class="tk">exactly</b> the slice you changed — not the whole warehouse.</div>

---

## The DAG & Self-Documenting Lineage

<div class="grid grid-cols-2 gap-8 mt-2 items-start">

<div>
<div class="box-h">// generate &amp; serve the docs site</div>

```bash
dbt docs generate            # build the manifest
dbt docs serve --host 0.0.0.0  # UI + lineage :8080
```

<div class="mt-4">
- Descriptions you wrote in YAML → rendered docs
- Column-level metadata &amp; test coverage
- An <b class="tk">interactive lineage graph</b> of every model
</div>
</div>

<div class="card tk">
<div class="box-h">// schema.yml drives the docs</div>

```yaml
models:
  - name: fct_sales
    description: "One row per completed order."
    columns:
      - name: order_id
        description: "Primary key."
        data_tests: [unique, not_null]
```
</div>

</div>

<div class="mt-4 flow"><b class="tk">Docs are generated from the same code you already write.</b> No separate wiki to rot.</div>

---

## LAB — Prove It's Trustworthy

<div class="lab mt-4">
Test, snapshot, and publish docs for your pipeline.

```bash
# inside: docker compose run --rm --service-ports dbt bash
# 1. run every generic + singular test
dbt test

# 2. capture a historical snapshot
dbt snapshot

# 3. build + run + test in one shot
dbt build --select +fct_sales

# 4. generate and open the lineage docs
dbt docs generate && dbt docs serve --host 0.0.0.0
```
</div>

<div class="mt-5 flow muted">Break a value on purpose, re-run <code>dbt test</code>, and watch it <span class="amber">fail loudly</span>.</div>

---
layout: section
---

<div class="eyebrow">// Module 06 · 15 min</div>

# 06 — Best Practices<br>& Synthesis

<div class="mt-6 muted flow">Industry <b class="tk">do's and don'ts</b> — then the big picture.</div>

---

## Do's & Don'ts — Modeling & Style

<div class="grid grid-cols-2 gap-8 mt-2">

<div>
<div class="box-h">// Materializations</div>
<div class="do"><b>DO</b> pick strategy by transform cost: views for light, tables for heavy, incremental for huge</div>
<div class="do"><b>DO</b> keep seeds tiny &amp; static (lookups only)</div>
<div class="dont"><b>DON'T</b> use seeds for raw-data ingestion</div>
<div class="dont"><b>DON'T</b> make everything a view — dashboards suffer</div>
</div>

<div>
<div class="box-h">// Coding &amp; templating (Jinja)</div>
<div class="do"><b>DO</b> always use <code>ref()</code> / <code>source()</code>, never hardcode</div>
<div class="do"><b>DO</b> abstract repeated logic into macros</div>
<div class="do"><b>DO</b> apply whitespace control <code>{%- -%}</code></div>
<div class="dont"><b>DON'T</b> nest curly braces</div>
</div>

</div>

---

## Do's & Don'ts — Quality & Performance

<div class="grid grid-cols-2 gap-8 mt-2">

<div>
<div class="box-h">// Data quality &amp; testing</div>
<div class="do"><b>DO</b> test PKs with <code>unique</code> + <code>not_null</code></div>
<div class="do"><b>DO</b> guard referential integrity with <code>relationships</code></div>
<div class="do"><b>DO</b> write singular tests for complex rules</div>
<div class="dont"><b>DON'T</b> ship untested models to production CI</div>
</div>

<div>
<div class="box-h">// Performance</div>
<div class="do"><b>DO</b> prefer incremental for massive tables</div>
<div class="do"><b>DO</b> align refresh cadence to your load cycle</div>
<div class="do"><b>DO</b> use strict checks in dev, baseline in CI</div>
<div class="dont"><b>DON'T</b> full-refresh what a delta could handle</div>
</div>

</div>

---

## The Standard Operating Procedure

<div class="grid grid-cols-1 gap-2 mt-2 flow text-sm">
<div class="card"><span class="tk">[✓]</span> <b>IDEMPOTENCY</b> — models yield the same result run once or 1000× (drop &amp; rebuild)</div>
<div class="card"><span class="tk">[✓]</span> <b>REFERENCES</b> — <code>ref()</code>/<code>source()</code> everywhere; the DAG is sacred</div>
<div class="card"><span class="tk">[✓]</span> <b>CI EFFICIENCY</b> — test on a clone; don't full-refresh incrementals in every job</div>
<div class="card"><span class="tk">[✓]</span> <b>JINJA HYGIENE</b> — "don't nest your curlies"; keep templates readable</div>
<div class="card"><span class="tk">[✓]</span> <b>VERSION CONTROL</b> — every change is a PR; review data logic like app code</div>
</div>

---
layout: center
---

## Synthesis: The Trusted Data Product

<div class="grid grid-cols-3 gap-4 mt-4">
<div class="card tk text-center"><div class="box-h">LOGIC</div>SQL + Jinja + Macros</div>
<div class="card tk text-center"><div class="box-h">STATE</div>YAML + Config + Profiles</div>
<div class="card tk text-center"><div class="box-h">QUALITY</div>Tests + Snapshots + Hooks</div>
</div>

<div class="text-center tk text-3xl mt-3">↓</div>

<div class="slab text-center text-xl">==&gt; dbt compile &amp; run ==&gt;</div>

<div class="text-center tk text-3xl mt-1">↓</div>

<div class="slab text-center mt-1">IDEMPOTENT · SELF-DOCUMENTING · TESTED DAG</div>

<div class="mt-5 text-center flow muted">You are not writing queries. <b class="tk">You are engineering the warehouse.</b></div>

---
layout: end
---

<div class="frame"></div>

<div class="eyebrow">// You're cleared to build</div>

# Go Engineer<br>The Warehouse

<div class="mt-6">
  <span class="chip">docker compose up</span>
  <span class="chip">dbt debug</span>
  <span class="chip">dbt build</span>
  <span class="chip">dbt docs serve</span>
</div>

<div class="mt-8 flow muted">
  The full <b class="tk">dbt + Postgres + Docker</b> lab lives in the project root — clone it, break it, rebuild it.
</div>
