CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.customers;
DROP TABLE IF EXISTS staging.orders;
DROP TABLE IF EXISTS staging.products;
DROP TABLE IF EXISTS staging.order_items;
DROP TABLE IF EXISTS staging.order_payments;
DROP TABLE IF EXISTS staging.order_reviews;
DROP TABLE IF EXISTS staging.sellers;
DROP TABLE IF EXISTS staging.category_translation;


CREATE TABLE staging.customers AS
SELECT DISTINCT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    TRIM(customer_city) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM raw.customers
WHERE customer_id IS NOT NULL;


CREATE TABLE staging.orders AS
SELECT DISTINCT
    order_id,
    customer_id,
    LOWER(TRIM(order_status)) AS order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM raw.orders
WHERE order_id IS NOT NULL;


CREATE TABLE staging.products AS
SELECT DISTINCT
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM raw.products
WHERE product_id IS NOT NULL;


CREATE TABLE staging.order_items AS
SELECT DISTINCT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM raw.order_items
WHERE order_id IS NOT NULL
  AND product_id IS NOT NULL
  AND price >= 0
  AND freight_value >= 0;


CREATE TABLE staging.order_payments AS
SELECT DISTINCT
    order_id,
    payment_sequential,
    LOWER(TRIM(payment_type)) AS payment_type,
    payment_installments,
    payment_value
FROM raw.order_payments
WHERE order_id IS NOT NULL
  AND payment_value >= 0;


CREATE TABLE staging.order_reviews AS
SELECT DISTINCT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM raw.order_reviews
WHERE order_id IS NOT NULL;


CREATE TABLE staging.sellers AS
SELECT DISTINCT
    seller_id,
    seller_zip_code_prefix,
    TRIM(seller_city) AS seller_city,
    UPPER(TRIM(seller_state)) AS seller_state
FROM raw.sellers
WHERE seller_id IS NOT NULL;


CREATE TABLE staging.category_translation AS
SELECT DISTINCT
    product_category_name,
    product_category_name_english
FROM raw.category_translation
WHERE product_category_name IS NOT NULL;