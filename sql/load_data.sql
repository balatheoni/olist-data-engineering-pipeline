COPY raw.customers
FROM '/data/raw/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY raw.geolocation
FROM '/data/raw/olist_geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY raw.order_items
FROM '/data/raw/olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY raw.order_payments
FROM '/data/raw/olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY raw.order_reviews
FROM '/data/raw/olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY raw.orders
FROM '/data/raw/olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY raw.products
FROM '/data/raw/olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY raw.sellers
FROM '/data/raw/olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY raw.category_translation
FROM '/data/raw/product_category_name_translation.csv'
DELIMITER ','
CSV HEADER;