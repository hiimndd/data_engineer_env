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


def scd2_update_dim_customer(cur):
    cur.execute("""
        UPDATE dim_customer d
        SET end_date = CURRENT_DATE,
            is_current = false
        FROM raw_customers r
        WHERE d.email = r.email
          AND d.is_current = true
          AND d.customer_name <> r.customer_name;
    """)
    logging.info("dim_customer: closed old versions")

def scd2_insert_dim_customer(cur):
    cur.execute("""
        INSERT INTO dim_customer (
            email,
            customer_name,
            start_date,
            end_date,
            is_current
        )
        SELECT
            r.email,
            r.customer_name,
            CURRENT_DATE,
            NULL,
            true
        FROM raw_customers r
        WHERE NOT EXISTS (
            SELECT 1
            FROM dim_customer d
            WHERE d.email = r.email
              AND d.is_current = true
              AND d.customer_name = r.customer_name
        );
    """)
    logging.info("dim_customer: inserted new versions")



def update_fact_orders(cur):
    cur.execute("""
        UPDATE fact_orders f
        SET amount = r.amount,
            status = r.status
        FROM raw_orders r
        WHERE f.order_id = r.order_id
          AND (
              f.amount <> r.amount
              OR f.status <> r.status
          );
    """)
    logging.info("fact_orders: updated existing orders")

def insert_fact_orders(cur):
    cur.execute("""
        INSERT INTO fact_orders (
            order_id,
            customer_sk,
            product_sk,
            order_time,
            amount,
            status
        )
        SELECT
            r.order_id,
            c.customer_sk,
            p.product_sk,
            r.order_time,
            r.amount,
            r.status
        FROM raw_orders r
        JOIN dim_customer c
          ON r.customer_email = c.email
         AND c.is_current = true
        JOIN dim_product p
          ON r.product_sku = p.sku
        WHERE NOT EXISTS (
            SELECT 1
            FROM fact_orders f
            WHERE f.order_id = r.order_id
        );
    """)
    logging.info("fact_orders: inserted new orders")


def check_fact_duplicate(cur):
    cur.execute("""
        SELECT COUNT(*)
        FROM (
            SELECT order_id
            FROM fact_orders
            GROUP BY order_id
            HAVING COUNT(*) > 1
        ) t;
    """)
    bad = cur.fetchone()[0]
    logging.info(f"fact_orders duplicate count: {bad}")
    return bad == 0

def check_fact_null_key(cur):
    cur.execute("""
        SELECT COUNT(*)
        FROM fact_orders
        WHERE order_id IS NULL
           OR customer_sk IS NULL
           OR product_sk IS NULL;
    """)
    bad = cur.fetchone()[0]
    logging.info(f"fact_orders null key count: {bad}")
    return bad == 0

def run_etl():
    logging.info("DW ETL started")

    conn = get_connection()
    cur = conn.cursor()

    try:
        # DIM
        scd2_update_dim_customer(cur)
        scd2_insert_dim_customer(cur)

        # FACT
        update_fact_orders(cur)
        insert_fact_orders(cur)

        # QUALITY
        if not check_fact_duplicate(cur):
            raise Exception("Duplicate fact_orders detected")

        if not check_fact_null_key(cur):
            raise Exception("Null key in fact_orders")

        conn.commit()
        logging.info("DW ETL committed successfully")

    except Exception as e:
        conn.rollback()
        logging.error(f"DW ETL failed, rolled back. Reason: {e}")

    finally:
        cur.close()
        conn.close()
        logging.info("Connection closed")    



if __name__ == "__main__":
    run_etl()


    