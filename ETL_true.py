import csv
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


def extract_orders_from_csv(path):
    orders = []
    with open(path, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            orders.append(row)
    return orders

def transform_orders(raw_orders):
    cleaned = []

    for o in raw_orders:
        amount = int(o["amount"])

        if o["status"] == "CANCELED":
            continue

        if amount <= 0:
            continue

        cleaned.append({
            "order_id": int(o["order_id"]),
            "customer_email": o["customer_email"],
            "product_sku": o["product_sku"],
            "order_time": o["order_time"],
            "amount": amount,
            "status": o["status"]
        })

    return cleaned

def load_orders(cur, orders):
    for o in orders:
        cur.execute(
            """
            INSERT INTO etl_orders_clean
            (order_id, customer_email, product_sku, order_time, amount, status)
            VALUES (%s, %s, %s, %s, %s, %s);
            """,
            (
                o["order_id"],
                o["customer_email"],
                o["product_sku"],
                o["order_time"],
                o["amount"],
                o["status"]
            )
        )

def check_duplicate(cur):
    cur.execute("""
        SELECT COUNT(*)
        FROM (
            SELECT order_id
            FROM etl_orders_clean
            GROUP BY order_id
            HAVING COUNT(*) > 1
        ) t;
    """)
    bad = cur.fetchone()[0]
    logging.info(f"fact_orders duplicate count: {bad}")
    return bad == 0

    

def run_etl():
    raw = extract_orders_from_csv("orders_raw.csv")
    logging.info(f"Extracted {len(raw)} rows")
    logging.info(f"First row raw: {raw}")
    cleaned = transform_orders(raw)

    conn = get_connection()
    cur = conn.cursor()

    try:
        load_orders(cur, cleaned)
        if not check_duplicate(cur):
            raise Exception("Duplicate fact_orders detected")

        conn.commit()
    except Exception as e:
        conn.rollback()
        logging.error(f"DW ETL failed, rolled back. Reason: {e}")
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    run_etl()