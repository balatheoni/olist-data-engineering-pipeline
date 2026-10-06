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
