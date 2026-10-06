-- DATA QUALITY CHECKS

-- 1. Check for duplicate customers
SELECT customer_id, COUNT(*)
FROM warehouse.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- 2. Check for duplicate products
SELECT product_id, COUNT(*)
FROM warehouse.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- 3. Check for duplicate sellers
SELECT seller_id, COUNT(*)
FROM warehouse.dim_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- 4. Check for duplicate fact rows
SELECT order_id, order_item_id, COUNT(*)
FROM warehouse.fact_sales
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- 5. Check for missing foreign keys
SELECT *
FROM warehouse.fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL
   OR seller_key IS NULL
   OR date_key IS NULL;


-- 6. Check for negative prices
SELECT *
FROM warehouse.fact_sales
WHERE price < 0;


-- 7. Check for negative freight values
SELECT *
FROM warehouse.fact_sales
WHERE freight_value < 0;


-- 8. Check for invalid total amount
SELECT *
FROM warehouse.fact_sales
WHERE total_amount <> price + freight_value;


-- 9. Check for invalid order status
SELECT DISTINCT order_status
FROM warehouse.fact_sales
ORDER BY order_status;


-- 10. Check row counts
SELECT 'dim_customers' AS table_name, COUNT(*) AS row_count
FROM warehouse.dim_customers

UNION ALL

SELECT 'dim_products', COUNT(*)
FROM warehouse.dim_products

UNION ALL

SELECT 'dim_sellers', COUNT(*)
FROM warehouse.dim_sellers

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM warehouse.dim_date

UNION ALL

SELECT 'fact_sales', COUNT(*)
FROM warehouse.fact_sales;