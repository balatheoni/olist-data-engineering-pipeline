-- ANALYTICS QUERIES


-- 1. TOTAL REVENUE
SELECT
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM warehouse.fact_sales;


-- 2. TOTAL ORDERS
SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM warehouse.fact_sales;


-- 3. AVERAGE ORDER VALUE
SELECT
    ROUND(
        SUM(total_amount) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM warehouse.fact_sales;


-- 4. REVENUE BY MONTH
SELECT
    d.year,
    d.month,
    d.month_name,
    ROUND(SUM(f.total_amount), 2) AS revenue
FROM warehouse.fact_sales f
JOIN warehouse.dim_date d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;


-- 5. MONTH-OVER-MONTH REVENUE GROWTH
WITH monthly_revenue AS (
    SELECT
        d.year,
        d.month,
        SUM(f.total_amount) AS revenue
    FROM warehouse.fact_sales f
    JOIN warehouse.dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month
),

growth AS (
    SELECT
        year,
        month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY year, month
        ) AS previous_month_revenue

    FROM monthly_revenue
)

SELECT
    year,
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,

    ROUND(
        (
            revenue - previous_month_revenue
        )
        / NULLIF(previous_month_revenue, 0)
        * 100,
        2
    ) AS growth_percentage

FROM growth
ORDER BY year, month;


-- 6. TOP 10 PRODUCT CATEGORIES BY REVENUE
SELECT
    COALESCE(
        p.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,

    ROUND(SUM(f.total_amount), 2) AS revenue,

    COUNT(*) AS items_sold

FROM warehouse.fact_sales f

JOIN warehouse.dim_products p
    ON f.product_key = p.product_key

GROUP BY category

ORDER BY revenue DESC

LIMIT 10;


-- 7. TOP 10 SELLERS BY REVENUE
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,

    ROUND(SUM(f.total_amount), 2) AS revenue,

    COUNT(DISTINCT f.order_id) AS orders

FROM warehouse.fact_sales f

JOIN warehouse.dim_sellers s
    ON f.seller_key = s.seller_key

GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state

ORDER BY revenue DESC

LIMIT 10;


-- 8. REVENUE BY CUSTOMER STATE
SELECT
    c.customer_state,

    ROUND(SUM(f.total_amount), 2) AS revenue,

    COUNT(DISTINCT f.order_id) AS orders

FROM warehouse.fact_sales f

JOIN warehouse.dim_customers c
    ON f.customer_key = c.customer_key

GROUP BY c.customer_state

ORDER BY revenue DESC;


-- 9. TOP CUSTOMERS BY SPENDING
SELECT
    c.customer_unique_id,

    ROUND(SUM(f.total_amount), 2) AS total_spent,

    COUNT(DISTINCT f.order_id) AS number_of_orders

FROM warehouse.fact_sales f

JOIN warehouse.dim_customers c
    ON f.customer_key = c.customer_key

GROUP BY c.customer_unique_id

ORDER BY total_spent DESC

LIMIT 10;


-- 10. ORDER STATUS DISTRIBUTION
SELECT
    order_status,

    COUNT(DISTINCT order_id) AS orders

FROM warehouse.fact_sales

GROUP BY order_status

ORDER BY orders DESC;


-- 11. DAILY REVENUE RANK WITHIN EACH MONTH
WITH daily_sales AS (
    SELECT
        d.year,
        d.month,
        d.full_date,

        SUM(f.total_amount) AS daily_revenue

    FROM warehouse.fact_sales f

    JOIN warehouse.dim_date d
        ON f.date_key = d.date_key

    GROUP BY
        d.year,
        d.month,
        d.full_date
)

SELECT
    year,
    month,
    full_date,

    ROUND(daily_revenue, 2) AS daily_revenue,

    RANK() OVER (
        PARTITION BY year, month
        ORDER BY daily_revenue DESC
    ) AS revenue_rank

FROM daily_sales

ORDER BY
    year,
    month,
    revenue_rank;


-- 12. RUNNING CUMULATIVE REVENUE
WITH daily_revenue AS (
    SELECT
        d.full_date,
        SUM(f.total_amount) AS revenue

    FROM warehouse.fact_sales f

    JOIN warehouse.dim_date d
        ON f.date_key = d.date_key

    GROUP BY d.full_date
)

SELECT
    full_date,

    ROUND(revenue, 2) AS daily_revenue,

    ROUND(
        SUM(revenue) OVER (
            ORDER BY full_date
        ),
        2
    ) AS cumulative_revenue

FROM daily_revenue

ORDER BY full_date;