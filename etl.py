import psycopg2
import logging

logging.basicConfig(level=logging.INFO)

def run_etl():
    logging.info("ETL started")

    conn = psycopg2.connect(
        host="localhost",
        dbname="data_engineering",
        user="de_user",
        password="uadmlt123"
    )


    conn.autocommit = False
    logging.info("Transaction mode ON (autocommit = False)")

    cur = conn.cursor()
    try:
        # 1️⃣ INSERT DATA
        cur.execute(
            "INSERT INTO etl_test (id, note) VALUES (%s, %s);",
            ( "0", "this should fail quality check")
        )
        logging.info("Inserted 1 row into etl_test")

        # 2️⃣ DATA QUALITY CHECK
        cur.execute(
            "SELECT COUNT(*) FROM etl_test WHERE id IS NULL;"
        )
        bad_rows = cur.fetchone()[0]
        logging.info(f"Bad rows count: {bad_rows}")

         # ❌ Nếu data không đạt → FAIL
        if bad_rows > 0:
            raise Exception("Data quality check failed: NULL id found")

        conn.commit()
    except Exception as e:
        conn.rollback()
        logging.error(f"Error occurred: {e}")

    finally:
        cur.close()
        conn.close()
        logging.info("Connection closed")

    # --- SQL ĐẦU TIÊN ---
    # cur.execute("SELECT * from raw_orders;")
    # result = cur.fetchone()[0] # fetchone là lấy 1 dòng kết quả, [0] cột đầu tiên
    # logging.info(f"Result of SELECT 1: {result}")

    

    

    

if __name__ == "__main__":
    run_etl()

