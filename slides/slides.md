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
section: Introduction
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
section: Introduction
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
section: 01 · The Why
---

<div class="eyebrow">// Module 01 · 20 min</div>

# 01 — The Why<br>& dbt Foundations

<div class="ghostnum">01</div>

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

<div class="flowrow center mt-5" style="gap:10px">
  <div class="badge amber">ETL</div>
  <div class="node" style="text-align:center;padding:7px 12px"><div class="t">Extract</div></div>
  <div class="arw sm">▶</div>
  <div class="node paper" style="text-align:center;padding:7px 12px"><div class="t">Transform</div><div class="s">outside server</div></div>
  <div class="arw sm">▶</div>
  <div class="node" style="text-align:center;padding:7px 12px"><div class="t">Load</div></div>
  <div class="muted" style="margin-left:8px">heavy data crosses the network twice</div>
</div>

<div class="flowrow center mt-2" style="gap:10px">
  <div class="badge">ELT</div>
  <div class="node" style="text-align:center;padding:7px 12px"><div class="t">Extract</div></div>
  <div class="arw sm">▶</div>
  <div class="node" style="text-align:center;padding:7px 12px"><div class="t">Load</div></div>
  <div class="arw sm">▶</div>
  <div class="node solid" style="text-align:center;padding:7px 12px"><div class="t">Transform</div><div class="s">inside warehouse · dbt</div></div>
  <div class="tk" style="margin-left:8px;font-weight:700">dbt owns the "T"</div>
</div>

---

## What Is dbt? (It Is NOT a Database)

<div class="flow mt-1 mb-5 muted">Three kinds of files go in <span class="tk">▸</span> one dependency-aware graph of SQL comes out.</div>

<div class="flowrow center">

  <div class="stack" style="flex:0 0 30%">
    <div class="node"><div class="t">model.sql</div><div class="s">Transformation logic — SELECT</div></div>
    <div class="node"><div class="t">schema.yml</div><div class="s">Tests &amp; docs</div></div>
    <div class="node"><div class="t">macro.sql</div><div class="s">Jinja functions</div></div>
  </div>

  <div class="arw">▶</div>

  <div class="node solid big pop" style="flex:0 0 26%; text-align:center; align-items:center">
    <div class="t">dbt&nbsp;compile</div>
    <div class="s">the engine</div>
  </div>

  <div class="arw">▶</div>

  <div class="node big" style="flex:1; align-items:center; text-align:center">
    <div class="t">RAW<br>EXECUTABLE<br>SQL</div>
  </div>

</div>

<blockquote class="mt-6">dbt is <b>NOT a database</b>. It is a <b>software-engineering framework</b> that compiles SQL + Jinja + YAML into a <b>Directed Acyclic Graph</b> — then hands warehouse-native SQL to your database to run.</blockquote>

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

<div class="flowrow center mt-2">
  <div class="node tk" style="flex:0 0 22%; align-items:center; text-align:center">
    <div class="t">SQL · Jinja<br>· YAML</div>
    <div class="s">your models</div>
  </div>
  <div class="arw">▶</div>
  <div class="node solid big pop" style="flex:0 0 22%; align-items:center; text-align:center">
    <div class="t">dbt&nbsp;Core</div>
    <div class="s">+ adapter</div>
  </div>
  <div class="arw">▶</div>
  <div class="stack" style="flex:1">
    <div class="colrow">
      <div class="node" style="text-align:center"><div class="t">Postgres</div></div>
      <div class="node" style="text-align:center"><div class="t">BigQuery</div></div>
      <div class="node" style="text-align:center"><div class="t">Snowflake</div></div>
    </div>
    <div class="colrow">
      <div class="node" style="text-align:center"><div class="t">Redshift</div></div>
      <div class="node" style="text-align:center"><div class="t">DuckDB</div></div>
      <div class="node" style="text-align:center"><div class="t">Databricks</div></div>
    </div>
  </div>
</div>

<div class="mt-4 muted">Write once. Swap the adapter, keep the models. <b class="tk">This class targets <code>dbt-postgres</code>.</b></div>

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
section: 02 · Scaffolding
---

<div class="eyebrow">// Module 02 · 20 min</div>

# 02 — Scaffolding<br>Setup & First Run

<div class="ghostnum">02</div>

<div class="mt-6 muted flow"><b class="tk">Postgres + dbt, both in Docker</b>. Get everyone to a green <code>dbt debug</code>.</div>

---

## The Stack: Postgres + dbt in Docker

<div class="grid grid-cols-2 gap-8 mt-2">

<div class="card">
<div class="box-h">// docker-compose.yml — the lab stack</div>

```yaml
services:
  postgres:            # the warehouse (Pagila auto-loaded)
    image: postgres:18
    ports: ["15432:5432"]

  whodb:               # browse raw data in the browser
    image: clidey/whodb
    ports: ["15424:8080"]

  dbt-docs:            # lineage + model docs
    build: ./docker/dbt
    ports: ["15480:8080"]

  dbt:                 # dbt Core CLI (on demand)
    build: ./docker/dbt
    profiles: ["dbt"]
    environment:
      DBT_HOST: postgres
    volumes: [".:/usr/app"]
```
</div>

<div class="card tk">
<div class="box-h">// Everything runs in a container</div>

```bash
# build images + start postgres, whodb, dbt-docs
docker compose up -d

# browse Pagila at http://localhost:15424 (click the pre-loaded profile)

# drop into the dbt container…
docker compose run --rm dbt bash

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
│   ├── staging/      # stg_* — 1:1 with sources (views)
│   ├── intermediate/ # int_* — joins & rollups (views)
│   ├── marts/        # dim_* / fct_* — business tables
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
- <code>models/staging/</code> — light cleanup, one model per source table
- <code>models/intermediate/</code> — joins &amp; prep between staging and marts
- <code>models/marts/</code> — final dim/fct tables for BI
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
    staging:
      +materialized: view
    intermediate:
      +materialized: view
    marts:
      +materialized: table
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
      port: 15432          # host port; containers use DBT_PORT=5432
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

<div class="flowrow mt-4">

  <div class="node pop" style="flex:1">
    <span class="badge ghost">STEP 1 · VERIFY POWER</span>
    <div class="t" style="margin:10px 0 6px;color:var(--tk)">dbt debug</div>
    <div class="s" style="font-size:0.86rem">Tests the <code>profiles.yml</code> connection — credentials &amp; network. <b style="color:#fff">No data moved.</b></div>
  </div>

  <div class="arw">▶</div>

  <div class="node pop" style="flex:1">
    <span class="badge ghost">STEP 2 · READ BLUEPRINTS</span>
    <div class="t" style="margin:10px 0 6px;color:var(--tk)">dbt compile</div>
    <div class="s" style="font-size:0.86rem">Evaluates Jinja, writes raw SQL to <code>target/compiled/</code>. <b style="color:#fff">Still no data moved.</b></div>
  </div>

  <div class="arw">▶</div>

  <div class="node solid pop" style="flex:1">
    <span class="badge ghost" style="border-color:var(--ink);color:var(--ink)">STEP 3 · START MACHINES</span>
    <div class="t" style="margin:10px 0 6px">dbt run</div>
    <div class="s" style="font-size:0.86rem">Executes compiled SQL against Postgres — physically builds tables &amp; views.</div>
  </div>

</div>

<div class="mt-6 slab" style="display:inline-block">debug <span class="tk">▶</span> compile <span class="tk">▶</span> run &nbsp;— learn this loop; you'll type it 100× a day.</div>

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
section: 03 · Pipelines
---

<div class="eyebrow">// Module 03 · 30 min</div>

# 03 — Pipelines<br>Seeds · Sources · Materializations

<div class="ghostnum">03</div>

<div class="mt-6 muted flow">How data <b class="tk">enters</b>, how dbt <b class="tk">references</b> it, and how you <b class="tk">shape</b> it.</div>

---

## Raw Materials: Seeds & Sources

<div class="flowrow mt-2 items-start">

  <div class="card" style="flex:1">
  <div class="box-h">1 · External data</div>

  <b class="tk">Seeds</b> — small static <code>.csv</code> (mappings, lookups) loaded with <code>dbt seed</code>.

  <div class="mt-3"><b class="tk">Sources</b> — raw tables already in the warehouse (loaded by ingestion).</div>
  </div>

  <div class="arw">▶</div>

  <div class="card" style="flex:1">
  <div class="box-h">2 · YAML binding</div>

  ```yaml
  sources:
    - name: pagila
      schema: public
      tables:
        - name: customer
        - name: payment
  ```
  </div>

  <div class="arw">▶</div>

  <div class="card tk" style="flex:1">
  <div class="box-h">3 · Reference in SQL</div>

  ```sql
  -- not: from public.payment
  from {{ source('pagila','payment') }}

  -- not: from dev.stg_customers
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
[<b>source</b>: pagila.payment]<br>
&nbsp;&nbsp;↓<br>
[<b>view</b>: stg_payments]<br>
&nbsp;&nbsp;↓<br>
[<b>view</b>: int_customer_payments]<br>
&nbsp;&nbsp;↓<br>
[<b>table</b>: dim_customers]
</div>

<div class="mt-3 muted text-sm"><b class="tk">Rule:</b> only staging touches <code>source()</code>. Marts only use <code>ref()</code>.</div>
</div>

</div>

---

## The Layering Model

<div class="grid grid-cols-3 gap-4 mt-3">

<div class="iconcard">
  <span class="glyph">①</span>
  <div class="name">Staging</div>
  <div class="desc">1:1 with a source table. Rename, cast, light cleanup. <code>source()</code> lives here only.</div>
</div>

<div class="iconcard" style="border-color:var(--tk);box-shadow:6px 6px 0 var(--tk)">
  <span class="glyph">②</span>
  <div class="name">Intermediate</div>
  <div class="desc">Joins &amp; rollups between staging models. Shared prep reused by multiple marts.</div>
</div>

<div class="iconcard">
  <span class="glyph">③</span>
  <div class="name">Marts</div>
  <div class="desc">Final dim/fct tables for BI. <b class="tk">Only <code>ref()</code></b> — never <code>source()</code>.</div>
</div>

</div>

<div class="mt-5 card">
<div class="box-h">// dim_customers — the right way</div>

```sql
-- staging
from {{ ref('stg_customers') }}

-- intermediate (geo + payment totals)
from {{ ref('int_addresses') }}
from {{ ref('int_customer_payments') }}

-- ✗ never in a mart:
-- from {{ source('pagila', 'address') }}
```
</div>

---

## Shaping the Data: 5 Materializations

<div class="grid grid-cols-5 gap-3 mt-3">

<div class="iconcard">
  <span class="glyph">◇</span>
  <div class="name">View</div>
  <div class="desc">A saved query over real tables. Rebuilt on every read.</div>
</div>

<div class="iconcard">
  <span class="glyph">▦</span>
  <div class="name">Table</div>
  <div class="desc">Physical storage, rebuilt from scratch each run.</div>
</div>

<div class="iconcard" style="border-color:var(--tk);box-shadow:6px 6px 0 var(--tk)">
  <span class="glyph">Δ</span>
  <div class="name">Incremental</div>
  <div class="desc">Appends / merges only new rows (the delta).</div>
</div>

<div class="iconcard">
  <span class="glyph">◈</span>
  <div class="name">Ephemeral</div>
  <div class="desc">Inlined as a CTE — never physically stored.</div>
</div>

<div class="iconcard">
  <span class="glyph">⟳</span>
  <div class="name">Mat. View</div>
  <div class="desc">View logic + auto-refreshing physical storage.</div>
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
<div class="box-h">// models/fct_payments.sql</div>

```sql
{{ config(
  materialized='incremental',
  unique_key='payment_id'
) }}

select * from {{ ref('stg_payments') }}

{% if is_incremental() %}
  -- only rows newer than what we have
  where payment_date > (select max(payment_date) from {{ this }})
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

# 2. build layer by layer
dbt run --select staging          # stg_* views
dbt run --select intermediate     # int_* views
dbt run --select dim_customers dim_films

# 3. run the incremental fact (~51k rows)
dbt run --select fct_payments      # full first time
dbt run --select fct_payments      # delta only the 2nd time
```
</div>

<div class="mt-5 flow muted">Check Postgres: <code>dev.stg_customers</code> &amp; <code>dev.int_addresses</code> are <b class="tk">views</b>; <code>dev.dim_customers</code> is a <b class="tk">table</b>.</div>

---
layout: section
section: 04 · Dynamic SQL
---

<div class="eyebrow">// Module 04 · 30 min</div>

# 04 — Dynamic SQL<br>Jinja · Macros · Hooks · Vars

<div class="ghostnum">04</div>

<div class="mt-6 muted flow">Bring <b class="tk">programming</b> into SQL — flexible, reusable, DRY pipelines.</div>

---

## Jinja: Control Flow Inside SQL

<div class="grid grid-cols-2 gap-8 mt-2 items-start">

<div class="card">
<div class="box-h" v-pre>// Conditionals &amp; the {{ this }} var</div>

```sql
select *
from {{ ref('stg_payments') }}
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
<div class="box-h">// macros/full_name.sql</div>

```sql
{% macro full_name(first_col, last_col) -%}
  {{ first_col }} || ' ' || {{ last_col }}
{%- endmacro %}

-- in stg_customers.sql:
{{ full_name('first_name', 'last_name') }} as full_name
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

<div class="flow mt-1 mb-3 muted">Run SQL <b class="tk">around</b> your models — grants, logging, cleanup. Top ▸ bottom = execution order.</div>

<div class="svg-wrap mt-1">
<svg viewBox="0 0 1000 252" width="1000" height="252" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg" font-family="'JetBrains Mono', monospace">
  <line x1="46" y1="24" x2="46" y2="228" stroke="#12d3c8" stroke-width="4"/>
  <!-- rows: 30 66 102 138 174 210 ; bar h=30 -->
  <!-- 1 on-run-start -->
  <circle cx="46" cy="30" r="9" fill="#0a0a0a" stroke="#12d3c8" stroke-width="3"/>
  <text x="46" y="34" fill="#fff" font-size="12px" font-weight="800" text-anchor="middle">1</text>
  <rect x="72" y="15" width="900" height="30" fill="#141518" stroke="#12d3c8" stroke-width="2"/>
  <text x="88" y="35" fill="#12d3c8" font-size="16px" font-weight="800">on-run-start</text>
  <text x="520" y="35" fill="#8b8f96" font-size="14px">once, at the very beginning of the run</text>
  <!-- 2 pre-hook -->
  <circle cx="46" cy="66" r="9" fill="#0a0a0a" stroke="#12d3c8" stroke-width="3"/>
  <text x="46" y="70" fill="#fff" font-size="12px" font-weight="800" text-anchor="middle">2</text>
  <rect x="72" y="51" width="900" height="30" fill="#141518" stroke="#12d3c8" stroke-width="2"/>
  <text x="88" y="71" fill="#12d3c8" font-size="16px" font-weight="800">pre-hook</text>
  <text x="520" y="71" fill="#8b8f96" font-size="14px">right before a specific model builds</text>
  <!-- 3 JINJA COMPILATION (teal) -->
  <circle cx="46" cy="102" r="9" fill="#0a0a0a" stroke="#12d3c8" stroke-width="3"/>
  <text x="46" y="106" fill="#fff" font-size="12px" font-weight="800" text-anchor="middle">3</text>
  <rect x="72" y="87" width="900" height="30" fill="#12d3c8"/>
  <text x="88" y="107" fill="#0a0a0a" font-size="16px" font-weight="800">[ JINJA COMPILATION ]</text>
  <text x="520" y="107" fill="#0a0a0a" font-size="14px">ref() + macros resolve into raw SQL</text>
  <!-- 4 SQL EXECUTION (white) -->
  <circle cx="46" cy="138" r="9" fill="#0a0a0a" stroke="#12d3c8" stroke-width="3"/>
  <text x="46" y="142" fill="#fff" font-size="12px" font-weight="800" text-anchor="middle">4</text>
  <rect x="72" y="123" width="900" height="30" fill="#f2f2f0"/>
  <text x="88" y="143" fill="#0a0a0a" font-size="16px" font-weight="800">[ SQL EXECUTION ]</text>
  <text x="520" y="143" fill="#0a0a0a" font-size="14px">the warehouse runs the DDL / DML</text>
  <!-- 5 post-hook -->
  <circle cx="46" cy="174" r="9" fill="#0a0a0a" stroke="#12d3c8" stroke-width="3"/>
  <text x="46" y="178" fill="#fff" font-size="12px" font-weight="800" text-anchor="middle">5</text>
  <rect x="72" y="159" width="900" height="30" fill="#141518" stroke="#12d3c8" stroke-width="2"/>
  <text x="88" y="179" fill="#12d3c8" font-size="16px" font-weight="800">post-hook</text>
  <text x="520" y="179" fill="#8b8f96" font-size="14px">right after that model (e.g. GRANT)</text>
  <!-- 6 on-run-end -->
  <circle cx="46" cy="210" r="9" fill="#0a0a0a" stroke="#12d3c8" stroke-width="3"/>
  <text x="46" y="214" fill="#fff" font-size="12px" font-weight="800" text-anchor="middle">6</text>
  <rect x="72" y="195" width="900" height="30" fill="#141518" stroke="#12d3c8" stroke-width="2"/>
  <text x="88" y="215" fill="#12d3c8" font-size="16px" font-weight="800">on-run-end</text>
  <text x="520" y="215" fill="#8b8f96" font-size="14px">once, at the very end of the run</text>
</svg>
</div>

<div class="grid grid-cols-2 gap-6 mt-3 items-center">
<div class="card tk">

```yaml
models:
  dbt_class:
    +post-hook: "grant select on {{ this }} to reporter"
```
</div>
<div class="muted">Steps <b class="tk">1</b> &amp; <b class="tk">6</b> live in <code>dbt_project.yml</code> (once per run). <b class="tk">pre/post-hook</b> attach to each model — perfect for grants, logging &amp; cleanup.</div>
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
select * from {{ ref('stg_payments') }}
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
# 1. add macros/full_name.sql, use it in a model
dbt run --select stg_customers

# 2. add a post-hook grant, confirm it fired
dbt run --select dim_customers

# 3. override a var at runtime
dbt run --select fct_payments --vars '{"start_date":"2022-04-01"}'
```
</div>

<div class="mt-5 flow muted">Inspect <code>target/compiled/</code> to see your Jinja resolved into plain SQL.</div>

---
layout: section
section: 05 · Ensuring Trust
---

<div class="eyebrow">// Module 05 · 30 min</div>

# 05 — Ensuring Trust<br>Tests · History · Docs

<div class="ghostnum">05</div>

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

<div class="card mt-2 pop line">
<div class="box-h">// ID 1 · SALARY 5000 → 6000 · strategy: timestamp (updated_at)</div>

<div class="svg-wrap">
<svg viewBox="0 0 1000 210" width="1000" height="210" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg" font-family="'JetBrains Mono', monospace">
  <!-- change point -->
  <line x1="520" y1="26" x2="520" y2="178" stroke="#8b8f96" stroke-width="2" stroke-dasharray="5 5"/>
  <!-- version 1 (old, invalidated) -->
  <rect x="120" y="34" width="400" height="48" fill="#141518" stroke="#ffd23f" stroke-width="3"/>
  <text x="138" y="58" fill="#ffffff" font-size="16px" font-weight="800">v1 · salary 5000</text>
  <text x="138" y="76" fill="#8b8f96" font-size="13px">valid_from 2025-01-01 → valid_to 2025-06-01</text>
  <rect x="398" y="42" width="112" height="24" fill="#ffd23f"/>
  <text x="454" y="59" fill="#0a0a0a" font-size="12px" font-weight="800" text-anchor="middle">INVALIDATED</text>
  <!-- version 2 (new, active) -->
  <rect x="520" y="104" width="380" height="48" fill="#141518" stroke="#12d3c8" stroke-width="3"/>
  <text x="538" y="128" fill="#ffffff" font-size="16px" font-weight="800">v2 · salary 6000</text>
  <text x="538" y="146" fill="#8b8f96" font-size="13px">valid_from 2025-06-01 → valid_to null</text>
  <rect x="792" y="112" width="92" height="24" fill="#12d3c8"/>
  <text x="838" y="129" fill="#0a0a0a" font-size="12px" font-weight="800" text-anchor="middle">ACTIVE</text>
  <!-- time axis -->
  <line x1="120" y1="180" x2="920" y2="180" stroke="#12d3c8" stroke-width="2"/>
  <g fill="#8b8f96" font-size="12px" text-anchor="middle">
    <line x1="120" y1="176" x2="120" y2="184" stroke="#12d3c8" stroke-width="2"/>
    <text x="120" y="200">2025-01-01</text>
    <line x1="520" y1="176" x2="520" y2="184" stroke="#12d3c8" stroke-width="2"/>
    <text x="520" y="200">2025-06-01 · change</text>
    <line x1="900" y1="176" x2="900" y2="184" stroke="#12d3c8" stroke-width="2"/>
    <text x="900" y="200">now</text>
  </g>
</svg>
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

<div class="flowrow center mt-2" style="gap:8px">
  <div class="node" style="text-align:center;padding:8px 12px"><div class="t" style="font-size:0.92rem">source<br>raw</div></div>
  <div class="arw sm">▶</div>
  <div class="node" style="text-align:center;padding:8px 12px"><div class="t" style="font-size:0.92rem">view<br>stg_payments</div></div>
  <div class="arw sm">▶</div>
  <div class="node" style="text-align:center;padding:8px 12px"><div class="t" style="font-size:0.92rem">view<br>int_customer_payments</div></div>
  <div class="arw sm">▶</div>
  <div class="node solid pop" style="text-align:center;padding:8px 12px"><div class="t" style="font-size:0.92rem">table<br>dim_customers</div></div>
  <div class="arw sm">▶</div>
  <div class="node" style="text-align:center;padding:8px 12px"><div class="t" style="font-size:0.92rem">dashboards</div></div>
</div>

<div class="mt-4 grid grid-cols-1 gap-2 flow">
<div><code>dbt run --select stg_payments</code><span class="muted"> — just this one model</span></div>
<div><code>dbt run --select <b class="tk">+</b>fct_payments</code><span class="muted"> — fct_payments AND all upstream parents</span></div>
<div><code>dbt run --select fct_payments<b class="tk">+</b></code><span class="muted"> — fct_payments AND all downstream children</span></div>
<div><code>dbt run --select <b class="tk">@</b>fct_payments</code><span class="muted"> — parents, the model, and children's parents too</span></div>
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
dbt docs serve --host 0.0.0.0  # UI + lineage :15480 (via compose)
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
  - name: fct_payments
    description: "One row per payment."
    columns:
      - name: payment_id
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
dbt build --select +fct_payments

# 4. generate and open the lineage docs
dbt docs generate && dbt docs serve --host 0.0.0.0
```
</div>

<div class="mt-5 flow muted">Break a value on purpose, re-run <code>dbt test</code>, and watch it <span class="amber">fail loudly</span>.</div>

---
layout: section
section: 06 · Best Practices
---

<div class="eyebrow">// Module 06 · 15 min</div>

# 06 — Best Practices<br>& Synthesis

<div class="ghostnum">06</div>

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

<div class="grid grid-cols-3 gap-5 mt-4">
<div class="node tk pop" style="text-align:center"><div class="t" style="color:var(--tk)">LOGIC</div><div class="s">SQL + Jinja + Macros</div></div>
<div class="node tk pop" style="text-align:center"><div class="t" style="color:var(--tk)">STATE</div><div class="s">YAML + Config + Profiles</div></div>
<div class="node tk pop" style="text-align:center"><div class="t" style="color:var(--tk)">QUALITY</div><div class="s">Tests + Snapshots + Hooks</div></div>
</div>

<div class="flowrow center" style="justify-content:space-around;color:var(--tk);font-size:1.6rem;font-weight:800;margin:6px 0"><span>▼</span><span>▼</span><span>▼</span></div>

<div class="node solid big pop" style="text-align:center;align-items:center"><div class="t">dbt&nbsp;compile&nbsp;&amp;&nbsp;run</div></div>

<div class="text-center" style="color:var(--tk);font-size:1.6rem;font-weight:800;margin:6px 0">▼</div>

<div class="slab text-center" style="font-size:1.15rem">IDEMPOTENT · SELF-DOCUMENTING · TESTED DAG</div>

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
