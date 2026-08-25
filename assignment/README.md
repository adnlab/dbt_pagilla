# Assignment: Data Build Tool — DVD Rental Store Case Study (Pagila)

> **!!Note:** The entire assignment is expected NOT to rely fully on the use of AI.
>
> *"Learning is like planting a tree. If one only relies on AI without
> understanding the essence, what grows is not competence, but a weakening
> dependence."* — Learning Design Dibimbing

**Data Engineer · Period: Data Build Tool**

This assignment adapts the retail case study to the **Pagila** dataset — the
standard PostgreSQL sample database (a **DVD rental store**, ~51,000 payments &
rentals). The environment (Postgres + dbt + data) **is already provisioned in
Docker**, so students can go straight to **building the models** with no manual setup.

---

## Objectives

1. Understand the structure of a pre-configured dbt project (Docker + PostgreSQL + Pagila).
2. Insert a lookup table into PostgreSQL using **dbt Seed**.
3. Cleanse raw data (Pagila) into a **staging** layer.
4. Build the **intermediate / dimensional** level in dbt.
5. Build the **mart** level in dbt.
6. Apply **best practices** in dbt development.
7. Query based on requirements.
8. Develop a **full-cycle** dbt project (seed → staging → intermediate → mart → snapshot → test → run).

## Description

In this assignment, students practice the end-to-end dbt workflow — **raw →
staging → intermediate → mart** — using a DVD-rental store case study (Pagila).
The raw data is already available in the `public` schema (auto-loaded by Docker);
the task is to build the transformations on top of it.

---

## Setup (already provided — no manual setup needed)

The Pagila raw layer is auto-loaded into PostgreSQL inside the container. To
start:

```bash
# from the project root (dbt_class/)
docker compose up -d                       # start Postgres + build the dbt image
docker compose run --rm --service-ports dbt bash

# inside the container:
cd assignment
dbt debug                                  # expect "All checks passed!"
```

All models are written inside the **`assignment/`** folder. Model output goes to
the **`dev_assignment`** schema (isolated from the in-class demo, which uses
`dev`). The file `models/staging/_sources.yml` already declares the Pagila
sources — reference them via `{{ source('pagila', ...) }}`.

> **Raw tables (source `pagila`, schema `public`):**
> `customer`, `rental`, `payment`, `film`, `category`, `film_category`,
> `inventory`, `store`, `staff`, `address`, `city`, `country`.

---

## Detail

Build a best-practice folder structure with, at minimum: **staging,
intermediate, marts, snapshots, tests**. Always use `{{ ref() }}` and
`{{ source() }}` — never hardcode table names.

---

### Task 0: Insert a Lookup with DBT Seed — *(weight 5)*

Since the Pagila raw data is already loaded, this task is about practicing
**`dbt seed`** to load a small lookup table.

- Create `seeds/rating_descriptions.csv` with columns: `rating`, `description`.
- Fill it with the MPAA rating descriptions:
  ```csv
  rating,description
  G,General Audiences
  PG,Parental Guidance Suggested
  PG-13,Parents Strongly Cautioned
  R,Restricted
  NC-17,Adults Only
  ```
- Run `dbt seed`. This table is reused in `dim_films` (Task 2.2) to add a
  `rating_description` column via `ref()`.

---

### Task 1: Build Staging Models — *(weight 20)*

Build **6 staging models** as **views** from the Pagila sources:
`stg_customers`, `stg_rentals`, `stg_payments`, `stg_films`, `stg_inventory`, `stg_stores`.

**General rules:**
- Normalize column names to `snake_case`.
- Alias ID columns to match the entity: `customer_id`, `rental_id`,
  `payment_id`, `film_id`, `inventory_id`, `store_id`.
- Cast datetime columns to `timestamp` and give them clear names
  (e.g. `rental_date` → `rented_at`, `payment_date` → `paid_at`,
  `create_date` → `created_at`).
- Use `source()` / `ref()` per the project structure.

**Minimum columns per model:**

| Model | Source | Columns |
|---|---|---|
| `stg_customers` | `customer` | customer_id, first_name, last_name, email, is_active, created_at, last_update |
| `stg_rentals` | `rental` | rental_id, customer_id, inventory_id, staff_id, rented_at, returned_at |
| `stg_payments` | `payment` | payment_id, customer_id, rental_id, staff_id, amount, paid_at |
| `stg_films` | `film` | film_id, title, description, rental_rate, replacement_cost, length_minutes, rating |
| `stg_inventory` | `inventory` | inventory_id, film_id, store_id |
| `stg_stores` | `store` | store_id, manager_staff_id, address_id |

> Note: the `rating` column in Pagila is an `enum` — cast it to text (`rating::text`).

**Output:** 6 views in the staging schema.

---

### Task 2: Build 3 Intermediate / Dimensional Tables — *(weight 20)*

#### 2.1 `dim_customers`
Columns: `customer_id`, `customer_name`, `total_rentals`, `first_rented_at`,
`last_rented_at`, `lifetime_payment_total`.
- Use `stg_customers` as the main customer data.
- `customer_name` = first + last name (build/use a `full_name` **macro**).
- `total_rentals` = number of rentals per customer (from `stg_rentals`).
- `first_rented_at` / `last_rented_at` = first & last rental date.
- `lifetime_payment_total` = total `amount` of all the customer's payments
  (from `stg_payments`).
- If a customer has no rentals/payments → set `total_rentals` and
  `lifetime_payment_total` to `0`.

#### 2.2 `dim_films`
Columns: `film_id`, `title`, `category`, `rating`, `rating_description`,
`rental_rate`, `inventory_count`, `times_rented`, `is_available`.
- Use `stg_films` as the main film data.
- `category` = film category (from `film_category` → `category`). A film may
  have several categories → concatenate them into one comma-separated string
  (`string_agg`) so there is still **one row per film**.
- `rating_description` = from the `rating_descriptions` seed (join on `rating`).
- `inventory_count` = number of copies in `stg_inventory` per film.
- `times_rented` = number of rentals of that film (rentals via inventory).
- `is_available` = `true` when `inventory_count > 0`.
- If a film has no inventory → `inventory_count` & `times_rented` = `0`,
  `is_available` = `false`.

#### 2.3 `fact_payments`
Columns: `payment_id`, `paid_at`, `paid_date`, `customer_id`, `customer_name`,
`staff_id`, `store_id`, `rental_id`, `film_id`, `film_title`, `amount`.
- Use `stg_payments` as the main transaction data.
- Join `stg_customers` for `customer_name`.
- Join `stg_rentals` → `stg_inventory` for `rental_id`, `film_id`, `store_id`.
- Join `stg_films` for `film_title`.
- `paid_date` = the date (day) of `paid_at`.

---

### Task 3: Build 3 Mart Tables — *(weight 20)*

#### 3.1 `mart_customer_performance`
Columns: `customer_id`, `customer_name`, `total_rentals`, `first_rented_at`,
`last_rented_at`, `lifetime_payment_total`, `average_payment_value`.
- Use `dim_customers` as the source.
- `average_payment_value` = `lifetime_payment_total` / `total_rentals`.
- If `total_rentals = 0` → `average_payment_value` = `0` (avoid divide-by-zero).

#### 3.2 `mart_daily_revenue`
Columns: `paid_date`, `store_id`, `total_payments`, `unique_customers`, `total_revenue`.
- Use `fact_payments` as the source.
- `total_payments` = number of payments per `paid_date` and `store_id`.
- `unique_customers` = distinct customers per `paid_date` and `store_id`.
- `total_revenue` = total `amount` per `paid_date` and `store_id`.

> Note: Pagila does not store tax/subtotal like retail data, so this mart
> focuses on **daily revenue per store**.

#### 3.3 `mart_film_performance`
Columns: `film_id`, `title`, `category`, `rental_rate`, `inventory_count`,
`times_rented`, `total_revenue`.
- Use `dim_films` as the main product data.
- `times_rented` comes from `dim_films`.
- `total_revenue` = total `amount` for that film (from `fact_payments`).
- If a film has never been rented → `times_rented` & `total_revenue` = `0`.

---

### Task 4: Build 2 Snapshots — *(weight 20)*

#### 4.1 `snap_customers`
- Columns from source: `customer_id`, `customer_name`.
- Use `stg_customers` as the snapshot source.
- `unique_key` = `customer_id`.
- Use **strategy `check`**, `check_cols = ['customer_name']` to detect changes
  in the customer name.
- The snapshot must produce a history of `customer_name` changes per `customer_id`.

#### 4.2 `snap_films`
- Columns from source: `film_id`, `title`, `rental_rate`, `rating`, `description`.
- Use `stg_films` as the snapshot source.
- `unique_key` = `film_id`.
- Use **strategy `check`**, `check_cols = ['title', 'rental_rate', 'rating', 'description']`.
- The snapshot must produce a history of film attribute changes per `film_id`.

---

### Task 5: Build DBT Tests — *(weight 10)*

Build **2 custom (singular) tests** to confirm the mart transformations match
the source data. Design each query to **fail (return rows)** when there is a
mismatch.

#### 5.1 `assert_customer_performance_matches_rentals`
Confirm that:
- The total `total_rentals` in `mart_customer_performance` matches the number of
  rentals in `stg_rentals`.
- The total `lifetime_payment_total` in `mart_customer_performance` matches the
  total `amount` in `stg_payments`.

#### 5.2 `assert_daily_revenue_matches_payments`
Confirm that:
- The total `total_revenue` in `mart_daily_revenue` matches the total `amount`
  in `stg_payments`.
- The total `total_payments` in `mart_daily_revenue` matches the number of
  payments in `stg_payments`.

---

### Task 6: Run dbt — *(weight 5)*

Run the DBT commands from inside the container (`cd assignment`):

- Run `dbt test` and **screenshot** the result.
- Run `dbt run` (or `dbt build`) and **screenshot** the result.
- The screenshots must show: the command executed, the execution status, and the
  number of models/tests that ran successfully.

---

## Tools

PostgreSQL, DBeaver (optional), dbt, Python, Docker — **all already provided** in
this project (Postgres + dbt run inside Docker).

## Submission

**Deadline:** at most H+7 of class (23:30 WIB).

Submit to the LMS as a compressed file containing:
1. The project folder (`assignment/`)
2. A screenshot of the `dbt test` result
3. A screenshot of the `dbt run` result

## Grading

| No. | Aspect | Parameter | Max Weight |
|---|---|---|---|
| 1 | Data Build Tool | Insert a lookup into PostgreSQL using DBT Seed | 5 |
| 2 | | Cleanse raw → staging | 20 |
| 3 | | Build intermediate models | 20 |
| 4 | | Build mart models | 20 |
| 5 | | Build snapshots | 20 |
| 6 | | Build DBT tests | 10 |
| 7 | | Running DBT test and DBT run | 5 |

## References
- dbt models: https://docs.getdbt.com/docs/build/sql-models
- dbt snapshots: https://docs.getdbt.com/docs/build/snapshots
- dbt tests: https://docs.getdbt.com/docs/build/data-tests
- Pagila schema: https://github.com/devrimgunduz/pagila
