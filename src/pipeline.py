import os
import sys
import time
import logging
from pathlib import Path

import psycopg2
from dotenv import load_dotenv



# CONFIGURATION


load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "olist_dw")
DB_USER = os.getenv("DB_USER", "olist_user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "olist_password")


BASE_DIR = Path(__file__).resolve().parent.parent
SQL_DIR = BASE_DIR / "sql"


SQL_FILES = [
    "create_tables.sql",
    "load_data.sql",
    "clean_data.sql",
    "create_warehouse.sql",
    "quality_checks.sql",
]



# LOGGING


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)

logger = logging.getLogger(__name__)



# DATABASE CONNECTION


def connect_to_database(max_retries=10, delay=3):
    """
    Connect to PostgreSQL.

    Retries are useful when PostgreSQL is still starting
    inside the Docker container.
    """

    for attempt in range(1, max_retries + 1):

        try:
            connection = psycopg2.connect(
                host=DB_HOST,
                port=DB_PORT,
                database=DB_NAME,
                user=DB_USER,
                password=DB_PASSWORD
            )

            connection.autocommit = True

            logger.info("Connected to PostgreSQL successfully.")

            return connection

        except psycopg2.OperationalError as error:

            logger.warning(
                "Database connection attempt %s/%s failed.",
                attempt,
                max_retries
            )

            if attempt == max_retries:
                logger.error("Could not connect to PostgreSQL.")
                raise error

            time.sleep(delay)



# SQL EXECUTION


def run_sql_file(connection, filename):

    file_path = SQL_DIR / filename

    if not file_path.exists():
        raise FileNotFoundError(
            f"SQL file not found: {file_path}"
        )

    logger.info("Running %s...", filename)

    sql = file_path.read_text(
        encoding="utf-8"
    )

    with connection.cursor() as cursor:
        cursor.execute(sql)

    logger.info("%s completed successfully.", filename)



# PIPELINE


def run_pipeline():

    start_time = time.time()

    logger.info("=" * 55)
    logger.info("Starting Olist Data Engineering Pipeline")
    logger.info("=" * 55)

    connection = None

    try:

        connection = connect_to_database()

        for sql_file in SQL_FILES:
            run_sql_file(
                connection,
                sql_file
            )

        elapsed_time = time.time() - start_time

        logger.info("=" * 55)
        logger.info("Pipeline completed successfully.")
        logger.info(
            "Execution time: %.2f seconds",
            elapsed_time
        )
        logger.info("=" * 55)

    except Exception as error:

        logger.exception(
            "Pipeline failed: %s",
            error
        )

        sys.exit(1)

    finally:

        if connection:
            connection.close()
            logger.info("Database connection closed.")



# ENTRY POINT


if __name__ == "__main__":
    run_pipeline()