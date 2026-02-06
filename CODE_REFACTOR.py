import psycopg2
import logging

logging.basicConfig(level=logging.INFO)

def get_connection():
    conn = psycopg2.connect(
        host="localhost",
        dbname="data_engineering",
        user="de_user",
        password="uadmlt123"
    )
    conn.autocommit = False
    return conn

def insert_etl_test(cur, row_id, note):
    cur.execute(
        "INSERT INTO etl_test (id, note) VALUES (%s, %s);",
        (row_id, note)
    )
    logging.info("Inserted data into etl_test")

# -------------------------
# DATA QUALITY CHECK
# -------------------------
def check_null_id(cur):
    cur.execute(
        "SELECT COUNT(*) FROM etl_test WHERE id IS NULL;"
    )
    bad_rows = cur.fetchone()[0]
    logging.info(f"Null id count: {bad_rows}")
    return bad_rows == 0

# -------------------------
# MAIN ETL
# -------------------------
def run_etl():
    logging.info("ETL started")

    conn = get_connection()
    cur = conn.cursor()

    try:
        insert_etl_test(cur, 1, "production style etl")

        if not check_null_id(cur):
            raise Exception("Data quality check failed: NULL id")

        conn.commit()
        logging.info("ETL committed successfully")

    except Exception as e:
        conn.rollback()
        logging.error(f"ETL failed, rolled back. Reason: {e}")

    finally:
        cur.close()
        conn.close()
        logging.info("Connection closed")




if __name__ == "__main__":
    run_etl()



