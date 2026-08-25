-- =====================================================================
-- RAW LAYER — this is what "an ingestion tool already loaded" for us.
-- In dbt these tables become SOURCES: {{ source('raw', '...') }}
-- Runs automatically the first time the Postgres container boots.
-- =====================================================================

create schema if not exists raw;

-- A read-only role used by the post-hook grant demo (Module 04).
do $$
begin
  if not exists (select from pg_roles where rolname = 'reporter') then
    create role reporter nologin;
  end if;
end $$;

-- ---------------------------------------------------------------------
-- raw.customers  (note: has updated_at -> perfect for a timestamp snapshot)
-- ---------------------------------------------------------------------
create table raw.customers (
  id          integer primary key,
  first_name  text,
  last_name   text,
  email       text,
  country_code text,
  updated_at  timestamp
);

insert into raw.customers values
  (1, 'Ayu',   'Pratama',  'ayu@example.com',   'ID', '2024-01-05 09:00:00'),
  (2, 'Budi',  'Santoso',  'budi@example.com',  'ID', '2024-01-06 10:30:00'),
  (3, 'Citra', 'Wijaya',   'citra@example.com', 'SG', '2024-02-01 12:00:00'),
  (4, 'Dewi',  'Lestari',  'dewi@example.com',  'MY', '2024-02-14 08:15:00'),
  (5, 'Eko',   'Nugroho',  'eko@example.com',   'ID', '2024-03-02 16:45:00');

-- ---------------------------------------------------------------------
-- raw.orders
-- ---------------------------------------------------------------------
create table raw.orders (
  id          integer primary key,
  customer_id integer,
  order_date  date,
  status      text
);

insert into raw.orders values
  (101, 1, '2024-05-01', 'completed'),
  (102, 1, '2024-05-03', 'completed'),
  (103, 2, '2024-05-04', 'completed'),
  (104, 3, '2024-05-09', 'shipped'),
  (105, 3, '2024-05-11', 'completed'),
  (106, 4, '2024-05-20', 'returned'),
  (107, 5, '2024-06-01', 'completed'),
  (108, 5, '2024-06-02', 'placed');

-- ---------------------------------------------------------------------
-- raw.payments  (amounts are stored in CENTS -> macro turns them into $)
-- ---------------------------------------------------------------------
create table raw.payments (
  id             integer primary key,
  order_id       integer,
  payment_method text,
  amount_cents   integer
);

insert into raw.payments values
  (1, 101, 'credit_card',   2500),
  (2, 102, 'bank_transfer', 1000),
  (3, 103, 'credit_card',   1750),
  (4, 104, 'gift_card',     3000),
  (5, 105, 'coupon',         500),
  (6, 105, 'credit_card',   1500),
  (7, 106, 'credit_card',   2000),
  (8, 107, 'bank_transfer', 4200);
  -- note: order 108 ('placed') has no payment yet -> tests this edge case

-- ---------------------------------------------------------------------
-- raw.events  (time-series -> perfect for an INCREMENTAL model)
-- ---------------------------------------------------------------------
create table raw.events (
  event_id   integer primary key,
  user_id    integer,
  event_type text,
  event_ts   timestamp
);

insert into raw.events values
  (1,  1, 'login',    '2024-05-01 08:00:00'),
  (2,  1, 'purchase', '2024-05-01 08:12:00'),
  (3,  2, 'login',    '2024-05-04 09:30:00'),
  (4,  3, 'login',    '2024-05-09 10:00:00'),
  (5,  3, 'purchase', '2024-05-11 11:15:00'),
  (6,  4, 'login',    '2024-05-20 07:45:00'),
  (7,  5, 'login',    '2024-06-01 12:00:00'),
  (8,  5, 'purchase', '2024-06-01 12:20:00'),
  (9,  2, 'logout',   '2024-06-02 18:00:00'),
  (10, 5, 'logout',   '2024-06-02 19:30:00');
