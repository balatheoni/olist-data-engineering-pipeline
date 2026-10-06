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
```

- **RAW:** source CSV files loaded as-is
- **STAGING:** deduplication, NULL filtering, text trimming, price and freight validation
- **Data Warehouse:** star schema (see below)

## Tech Stack

- Python
- PostgreSQL
- SQL
- Docker / Docker Compose
- psycopg2
- Git / GitHub

## Dataset

This project uses the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), available on Kaggle.

It contains customers, orders, products, sellers, order items, payments, reviews, geolocation and product categories.

Raw CSV files are not included in this repository. Place them in `data/raw/`.

## Data Warehouse

The warehouse follows a star schema:

- **Fact table:** `fact_sales`, with one row per order item
- **Dimensions:** `dim_customers`, `dim_products`, `dim_sellers`, `dim_date`

## SQL Analytics

The project includes analysis for:

- Total revenue and orders
- Average order value
- Monthly revenue and month-over-month growth
- Top product categories and top sellers
- Revenue by state
- Customer spending
- Running cumulative revenue

SQL techniques include JOINs, CTEs, aggregations, `LAG()`, `RANK()`, and window functions.

## Data Quality

Automated checks validate:

- Duplicates
- Missing foreign keys
- Negative prices
- Invalid freight values
- Incorrect totals
- Warehouse row counts

## Project Structure

```text
├── data/raw/            # Olist CSV files (not committed)
├── sql/                 # create_tables, load_data, clean_data,
│                        # create_warehouse, quality_checks, analytics
├── src/pipeline.py      # runs the full pipeline
├── docker-compose.yml
├── requirements.txt
└── .env.example
```

## Getting Started

1. Clone the repository and install dependencies:

   ```bash
   git clone https://github.com/balatheoni/olist-data-engineering-pipeline.git
   cd olist-data-engineering-pipeline
   python -m venv .venv
   .venv\Scripts\Activate.ps1      # macOS/Linux: source .venv/bin/activate
   python -m pip install -r requirements.txt
   ```

2. Create a `.env` file using `.env.example` as a template.
3. Download the dataset from Kaggle and place the CSV files in `data/raw/`.
4. Start PostgreSQL and run the pipeline:

   ```bash
   docker compose up -d
   python src/pipeline.py
   ```
