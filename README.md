# Olist Data Engineering Pipeline

End-to-end Data Engineering project built with Python, PostgreSQL, SQL, and Docker using the Brazilian E-Commerce Public Dataset by Olist.

The project demonstrates data ingestion, ETL/ELT workflows, data cleaning, dimensional modeling, automated data quality validation, and analytical SQL.

## Architecture

```text
Kaggle CSV Dataset
        ↓
Dockerized PostgreSQL
        ↓
RAW Layer
        ↓
STAGING Layer
        ↓
Data Warehouse
        ↓
Data Quality Checks
        ↓
Analytics

- **RAW:** source CSV files loaded as-is
- **STAGING:** deduplication, NULL filtering, text trimming, price and freight validation
- **Data Warehouse:** star schema (see below)


## Tech Stack
- Python
- PostgreSQL
- SQL
- Docker
- Docker Compose
- psycopg2
- Git / GitHub


##  Dataset

This project uses the Brazilian E-Commerce Public Dataset by Olist, available on Kaggle.

It contains customers, orders, products, sellers, order items, payments, reviews, geolocation and product categories.

Raw CSV files are not included in this repository. Place them in data/raw/.

Data Warehouse

The warehouse follows a star schema:

Fact table: fact_sales, with one row per order item
Dimensions: dim_customers, dim_products, dim_sellers, dim_date


##  SQL Analytics
The project includes analysis for:
- Total revenue and orders
- Average order value
- Monthly revenue
- Month-over-month growth
- Top product categories
- Top sellers
- Revenue by state
- Customer spending
- Running cumulative revenue
SQL techniques include JOINs, CTEs, aggregations, LAG(), RANK(), and window functions.


##  Data Quality
Automated checks validate:
- Duplicates
- Missing foreign keys
- Negative prices
- Invalid freight values
- Incorrect totals
- Warehouse row counts
