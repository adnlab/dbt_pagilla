# Assignment: Data Build Tool — Studi Kasus Toko Rental DVD (Pagila)

> **!!Catatan:** Diharapkan seluruh pengerjaan Assignment tidak sepenuhnya
> mengandalkan penggunaan AI.
>
> *"Proses belajar ibarat menanam pohon. Jika hanya mengandalkan AI tanpa
> memahami esensinya, yang berkembang bukan kompetensimu, melainkan
> ketergantungan yang melemahkan."* — Learning Design Dibimbing

**Data Engineer · Periode: Data Build Tool**

Assignment ini adaptasi dari studi kasus retail ke dataset **Pagila** — sample
database standar PostgreSQL (sebuah **toko rental DVD**, ~51.000 payment &
rental). Environment (Postgres + dbt + data) **sudah disiapkan di Docker**,
jadi kamu bisa **langsung fokus membangun model**, tanpa setup manual.

---

## Objectives

1. Memahami struktur project dbt yang sudah ter-setup (Docker + PostgreSQL + Pagila).
2. Melakukan insert data lookup ke PostgreSQL menggunakan **dbt Seed**.
3. Melakukan cleansing data raw (Pagila) menjadi **staging**.
4. Membuat **intermediate/dimensional** level pada dbt.
5. Membuat **mart** level pada dbt.
6. Menerapkan **best practice** pada dbt development.
7. Melakukan query berdasarkan requirement.
8. Mengembangkan **full cycle** dbt project (seed → staging → intermediate → mart → snapshot → test → run).

## Deskripsi Assignment

Kamu akan dilatih workflow end-to-end dbt: **raw → staging → intermediate → mart**
dengan studi kasus data toko rental DVD (Pagila). Raw data sudah tersedia di
schema `public` (di-load otomatis oleh Docker); tugasmu membangun transformasinya.

---

## Setup (sudah disediakan — tidak perlu setup manual)

Raw layer Pagila sudah otomatis ter-load ke PostgreSQL di container. Kamu cukup:

```bash
# dari root project (dbt_class/)
docker compose up -d                       # nyalakan Postgres + build image dbt
docker compose run --rm --service-ports dbt bash

# di dalam container:
cd assignment
dbt debug                                  # harus "All checks passed!"
```

Semua model kamu tulis di folder **`assignment/`** ini. Output model masuk ke
schema **`dev_assignment`** (terpisah dari contoh yang dibahas di kelas, yang
ada di schema `dev`). File `models/staging/_sources.yml` sudah menyediakan
deklarasi source Pagila — kamu tinggal memakainya lewat `{{ source('pagila', ...) }}`.

> **Raw tables (source `pagila`, schema `public`) yang tersedia:**
> `customer`, `rental`, `payment`, `film`, `category`, `film_category`,
> `inventory`, `store`, `staff`, `address`, `city`, `country`.

---

## Detail Assignment

Buat struktur folder best practice, minimal: **staging, intermediate, marts,
snapshots, tests**. Selalu gunakan `{{ ref() }}` dan `{{ source() }}` — jangan
hardcode nama tabel.

---

### Soal 0: Insert Lookup dengan DBT Seed — *(bobot 5)*

Karena raw data Pagila sudah ter-load, di soal ini kamu berlatih **`dbt seed`**
untuk memasukkan sebuah tabel lookup kecil.

- Buat file `seeds/category_priority.csv` dengan kolom: `category`, `priority`.
- Isi mapping kategori film → prioritas bisnis, contoh:
  ```csv
  category,priority
  Action,High
  Sci-Fi,High
  Children,Medium
  Documentary,Low
  ```
- Jalankan `dbt seed`. Tabel akan dipakai kembali di `dim_films` (Soal 2.2).

---

### Soal 1: Membuat Staging Models — *(bobot 20)*

Buat **6 staging models** dalam bentuk **view** dari source Pagila:
`stg_customers`, `stg_rentals`, `stg_payments`, `stg_films`, `stg_inventory`, `stg_stores`.

**Aturan umum:**
- Normalisasi nama kolom menjadi `snake_case`.
- Beri alias kolom ID sesuai entity: `customer_id`, `rental_id`, `payment_id`,
  `film_id`, `inventory_id`, `store_id`.
- Konversi kolom datetime ke tipe `timestamp` dan beri nama yang jelas
  (mis. `rental_date` → `rented_at`, `payment_date` → `paid_at`,
  `create_date` → `created_at`).
- Gunakan `source()`/`ref()` sesuai struktur project.

**Kolom minimal per model:**

| Model | Sumber | Kolom |
|---|---|---|
| `stg_customers` | `customer` | customer_id, first_name, last_name, email, is_active, created_at, last_update |
| `stg_rentals` | `rental` | rental_id, customer_id, inventory_id, staff_id, rented_at, returned_at |
| `stg_payments` | `payment` | payment_id, customer_id, rental_id, staff_id, amount, paid_at |
| `stg_films` | `film` | film_id, title, description, rental_rate, replacement_cost, length_minutes, rating |
| `stg_inventory` | `inventory` | inventory_id, film_id, store_id |
| `stg_stores` | `store` | store_id, manager_staff_id, address_id |

> Catatan: kolom `rating` di Pagila bertipe `enum` — cast ke text (`rating::text`).

**Output:** 6 view di schema staging.

---

### Soal 2: Membuat 3 Table Intermediate/Dimensional — *(bobot 20)*

#### 2.1 `dim_customers`
Kolom: `customer_id`, `customer_name`, `total_rentals`, `first_rented_at`,
`last_rented_at`, `lifetime_payment_total`.
- Gunakan `stg_customers` sebagai data utama customer.
- `customer_name` = gabungan first + last name (buat/gunakan **macro** `full_name`).
- `total_rentals` = jumlah rental unik per customer (dari `stg_rentals`).
- `first_rented_at` / `last_rented_at` = tanggal rental pertama & terakhir.
- `lifetime_payment_total` = total `amount` seluruh payment customer (dari `stg_payments`).
- Jika customer belum punya rental/payment → `total_rentals` dan
  `lifetime_payment_total` diisi `0`.

#### 2.2 `dim_films`
Kolom: `film_id`, `title`, `category`, `rating`, `rental_rate`,
`inventory_count`, `times_rented`, `is_available`.
- Gunakan `stg_films` sebagai data utama film.
- `category` = kategori film (dari `film_category` → `category`). Satu film bisa
  punya beberapa kategori → gabungkan jadi satu string dipisah koma
  (`string_agg`) agar tetap **1 baris per film**.
- `inventory_count` = jumlah copy di `stg_inventory` per film.
- `times_rented` = jumlah rental film tersebut (rental melalui inventory).
- `is_available` = `true` jika `inventory_count > 0`.
- Jika film belum punya inventory → `inventory_count` & `times_rented` = `0`,
  `is_available` = `false`.

#### 2.3 `fact_payments`
Kolom: `payment_id`, `paid_at`, `paid_date`, `customer_id`, `customer_name`,
`staff_id`, `store_id`, `rental_id`, `film_id`, `film_title`, `amount`.
- Gunakan `stg_payments` sebagai data utama transaksi.
- Join ke `stg_customers` untuk `customer_name`.
- Join ke `stg_rentals` → `stg_inventory` untuk `rental_id`, `film_id`, `store_id`.
- Join ke `stg_films` untuk `film_title`.
- `paid_date` = tanggal (date) dari `paid_at`.

---

### Soal 3: Membuat 3 Table Mart — *(bobot 20)*

#### 3.1 `mart_customer_performance`
Kolom: `customer_id`, `customer_name`, `total_rentals`, `first_rented_at`,
`last_rented_at`, `lifetime_payment_total`, `average_payment_value`.
- Gunakan `dim_customers` sebagai sumber data.
- `average_payment_value` = `lifetime_payment_total` / `total_rentals`.
- Jika `total_rentals = 0` → `average_payment_value` = `0` (hindari pembagian nol).

#### 3.2 `mart_daily_revenue`
Kolom: `paid_date`, `store_id`, `total_payments`, `unique_customers`, `total_revenue`.
- Gunakan `fact_payments` sebagai sumber data.
- `total_payments` = jumlah payment per `paid_date` dan `store_id`.
- `unique_customers` = jumlah customer unik per `paid_date` dan `store_id`.
- `total_revenue` = total `amount` per `paid_date` dan `store_id`.

> Catatan: Pagila tidak menyimpan pajak/subtotal seperti data retail, sehingga
> mart ini fokus pada **revenue harian per toko**.

#### 3.3 `mart_film_performance`
Kolom: `film_id`, `title`, `category`, `rental_rate`, `inventory_count`,
`times_rented`, `total_revenue`.
- Gunakan `dim_films` sebagai data utama product.
- `times_rented` diambil dari `dim_films`.
- `total_revenue` = total `amount` untuk film tersebut (dari `fact_payments`).
- Jika film belum pernah dirental → `times_rented` & `total_revenue` = `0`.

---

### Soal 4: Membuat 2 Table Snapshot — *(bobot 20)*

#### 4.1 `snap_customers`
- Kolom dari source: `customer_id`, `customer_name`.
- Gunakan `stg_customers` sebagai sumber data snapshot.
- `unique_key` = `customer_id`.
- Gunakan **strategy `check`**, `check_cols = ['customer_name']` untuk mendeteksi
  perubahan nama customer.
- Snapshot harus menghasilkan histori perubahan `customer_name` per `customer_id`.

#### 4.2 `snap_films`
- Kolom dari source: `film_id`, `title`, `rental_rate`, `rating`, `description`.
- Gunakan `stg_films` sebagai sumber data snapshot.
- `unique_key` = `film_id`.
- Gunakan **strategy `check`**, `check_cols = ['title', 'rental_rate', 'rating', 'description']`.
- Snapshot harus menghasilkan histori perubahan atribut film per `film_id`.

---

### Soal 5: Membuat DBT Test — *(bobot 10)*

Buat **2 custom (singular) test** untuk memastikan hasil transformasi pada mart
sesuai dengan source data. Rancang query agar **gagal (mengembalikan baris)**
bila ada ketidaksesuaian.

#### 5.1 `assert_customer_performance_matches_rentals`
Memastikan:
- Total `total_rentals` di `mart_customer_performance` sesuai dengan jumlah
  rental di `stg_rentals`.
- Total `lifetime_payment_total` di `mart_customer_performance` sesuai dengan
  total `amount` di `stg_payments`.

#### 5.2 `assert_daily_revenue_matches_payments`
Memastikan:
- Total `total_revenue` di `mart_daily_revenue` sesuai dengan total `amount`
  di `stg_payments`.
- Total `total_payments` di `mart_daily_revenue` sesuai dengan jumlah payment
  di `stg_payments`.

---

### Soal 6: Menjalankan dbt & Reflection Questions — *(bobot 5)*

Jalankan DBT commands dari dalam container (`cd assignment`):

- Jalankan `dbt test` dan **screenshot** hasilnya.
- Jalankan `dbt run` (atau `dbt build`) dan **screenshot** hasilnya.
- Pastikan screenshot memperlihatkan: command yang dijalankan, status eksekusi,
  dan jumlah model/test yang berhasil dijalankan.

**Reflection Questions:**
1. Menurut Anda, apa manfaat membangun model data secara bertahap melalui
   staging → intermediate → mart dalam project dbt?
2. Apa tantangan yang Anda alami ketika membuat model dbt, dan bagaimana Anda
   mengatasinya selama proses pengerjaan?

---

## Tools

PostgreSQL, DBeaver (opsional), dbt, Python, Docker — **semuanya sudah tersedia
di project ini** (Postgres + dbt jalan di dalam Docker).

## Pengumpulan Assignment

**Deadline:** Maksimal H+7 Kelas (Pukul 23.30 WIB)

Dikumpulkan di LMS dalam bentuk file compressed yang terdiri dari:
1. Folder project (`assignment/`)
2. Screenshot hasil `dbt test`
3. Screenshot hasil `dbt run`
4. Jawaban Reflection Questions (pdf)

## Indikator Penilaian

| No. | Aspek | Parameter | Bobot Maksimal |
|---|---|---|---|
| 1 | Data Build Tool | Insert Data (lookup) ke PostgreSQL using DBT Seed | 5 |
| 2 | | Cleansing raw → staging | 20 |
| 3 | | Create model intermediate | 20 |
| 4 | | Create model mart | 20 |
| 5 | | Create Snapshot | 20 |
| 6 | | Create DBT Test | 10 |
| 7 | | Running DBT test, DBT Run, and Reflection Questions | 5 |

## Sanksi Penggunaan AI

Apabila student terdeteksi 100% menggunakan AI, maka hasil assignment akan
diberikan skor 0.

## Ketentuan Pencapaian Nilai
- Nilai minimum Lulus Penyaluran Kerja: **75**
- Nilai minimum Lulus Bootcamp: **65**

## Ketentuan Keterlambatan
- Tepat waktu: sesuai nilai yang diberikan mentor
- Terlambat 12 jam: −3 · 1×24 jam: −6 · 2×24 jam: −12 · 3×24 jam: −18 ·
  4×24 jam: −24 · 5×24 jam: −30 · 6×24 jam: −36 · 7×24 jam: −42

## Referensi
- dbt build a model: https://docs.getdbt.com/docs/build/sql-models
- dbt snapshots: https://docs.getdbt.com/docs/build/snapshots
- dbt tests: https://docs.getdbt.com/docs/build/data-tests
- Pagila schema: https://github.com/devrimgunduz/pagila
