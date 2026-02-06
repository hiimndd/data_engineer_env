import psycopg2
import logging

logging.basicConfig(level=logging.INFO)

def run_etl():
    conn = psycopg2.connect(
        host="localhost",
        dbname="dw",
        user="postgres",
        password="password"
    )
    conn.autocommit = False  # QUAN TRỌNG
    cur = conn.cursor()

    try:
        logging.info("ETL started")

        # 1. Transform / Load
        cur.execute("SQL_UPDATE_OR_INSERT_HERE")

        # 2. Data quality check
        cur.execute("SQL_CHECK_HERE")
        bad_rows = cur.fetchone()[0]

        if bad_rows > 0:
            raise Exception("Data quality check failed")

        conn.commit()
        logging.info("ETL committed successfully")

    except Exception as e:
        conn.rollback()
        logging.error(f"ETL failed: {e}")
        raise

    finally:
        cur.close()
        conn.close()