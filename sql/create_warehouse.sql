
-- OLIST DATA WAREHOUSE
-- Star Schema

CREATE SCHEMA IF NOT EXISTS warehouse;


-- DROP OLD TABLES


DROP TABLE IF EXISTS warehouse.fact_sales CASCADE;
DROP TABLE IF EXISTS warehouse.dim_date CASCADE;
DROP TABLE IF EXISTS warehouse.dim_customers CASCADE;
DROP TABLE IF EXISTS warehouse.dim_products CASCADE;
DROP TABLE IF EXISTS warehouse.dim_sellers CASCADE;



-- DIMENSION: CUSTOMERS


CREATE TABLE warehouse.dim_customers (
    customer_key BIGSERIAL PRIMARY KEY,
    customer_id VARCHAR(50) UNIQUE NOT NULL,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);


INSERT INTO warehouse.dim_customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM staging.customers;



-- DIMENSION: PRODUCTS


CREATE TABLE warehouse.dim_products (
    product_key BIGSERIAL PRIMARY KEY,
    product_id VARCHAR(50) UNIQUE NOT NULL,
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);


INSERT INTO warehouse.dim_products (
    product_id,
    product_category_name,
    product_category_name_english,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    p.product_id,
    p.product_category_name,
    ct.product_category_name_english,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM staging.products p
LEFT JOIN staging.category_translation ct
    ON p.product_category_name = ct.product_category_name;



-- DIMENSION: SELLERS


CREATE TABLE warehouse.dim_sellers (
    seller_key BIGSERIAL PRIMARY KEY,
    seller_id VARCHAR(50) UNIQUE NOT NULL,
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);


INSERT INTO warehouse.dim_sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM staging.sellers;



-- DIMENSION: DATE


CREATE TABLE warehouse.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    month_name VARCHAR(20),
    day INTEGER,
    day_of_week INTEGER,
    day_name VARCHAR(20)
);


INSERT INTO warehouse.dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day,
    day_of_week,
    day_name
)
SELECT
    TO_CHAR(date_value, 'YYYYMMDD')::INTEGER AS date_key,
    date_value::DATE AS full_date,
    EXTRACT(YEAR FROM date_value)::INTEGER AS year,
    EXTRACT(QUARTER FROM date_value)::INTEGER AS quarter,
    EXTRACT(MONTH FROM date_value)::INTEGER AS month,
    TRIM(TO_CHAR(date_value, 'Month')) AS month_name,
    EXTRACT(DAY FROM date_value)::INTEGER AS day,
    EXTRACT(ISODOW FROM date_value)::INTEGER AS day_of_week,
    TRIM(TO_CHAR(date_value, 'Day')) AS day_name
FROM GENERATE_SERIES(
    (
        SELECT MIN(order_purchase_timestamp)::DATE
        FROM staging.orders
    ),
    (
        SELECT MAX(order_purchase_timestamp)::DATE
        FROM staging.orders
    ),
    INTERVAL '1 day'
) AS date_value;



-- FACT TABLE: SALES
-- Grain: one row per order item


CREATE TABLE warehouse.fact_sales (
    sales_key BIGSERIAL PRIMARY KEY,

    order_id VARCHAR(50) NOT NULL,
    order_item_id INTEGER NOT NULL,

    date_key INTEGER,
    customer_key BIGINT,
    product_key BIGINT,
    seller_key BIGINT,

    order_status VARCHAR(50),

    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),
    total_amount NUMERIC(10,2),

    FOREIGN KEY (date_key)
        REFERENCES warehouse.dim_date(date_key),

    FOREIGN KEY (customer_key)
        REFERENCES warehouse.dim_customers(customer_key),

    FOREIGN KEY (product_key)
        REFERENCES warehouse.dim_products(product_key),

    FOREIGN KEY (seller_key)
        REFERENCES warehouse.dim_sellers(seller_key),

    UNIQUE (order_id, order_item_id)
);



-- LOAD FACT TABLE


INSERT INTO warehouse.fact_sales (
    order_id,
    order_item_id,
    date_key,
    customer_key,
    product_key,
    seller_key,
    order_status,
    price,
    freight_value,
    total_amount
)
SELECT
    oi.order_id,
    oi.order_item_id,

    TO_CHAR(
        o.order_purchase_timestamp,
        'YYYYMMDD'
    )::INTEGER AS date_key,

    c.customer_key,
    p.product_key,
    s.seller_key,

    o.order_status,

    oi.price,
    oi.freight_value,

    oi.price + oi.freight_value AS total_amount

FROM staging.order_items oi

JOIN staging.orders o
    ON oi.order_id = o.order_id

LEFT JOIN warehouse.dim_customers c
    ON o.customer_id = c.customer_id

LEFT JOIN warehouse.dim_products p
    ON oi.product_id = p.product_id

LEFT JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id;



-- INDEXES


CREATE INDEX idx_fact_sales_date
ON warehouse.fact_sales(date_key);

CREATE INDEX idx_fact_sales_customer
ON warehouse.fact_sales(customer_key);

CREATE INDEX idx_fact_sales_product
ON warehouse.fact_sales(product_key);

CREATE INDEX idx_fact_sales_seller
ON warehouse.fact_sales(seller_key);

CREATE INDEX idx_fact_sales_order
ON warehouse.fact_sales(order_id);