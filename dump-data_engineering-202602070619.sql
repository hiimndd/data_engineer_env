--
-- PostgreSQL database dump
--

-- Dumped from database version 15.15 (Debian 15.15-1.pgdg13+1)
-- Dumped by pg_dump version 17.0

-- Started on 2026-02-07 06:19:28

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 216 (class 1259 OID 16403)
-- Name: dim_customer; Type: TABLE; Schema: public; Owner: de_user
--

CREATE TABLE public.dim_customer (
    customer_sk integer NOT NULL,
    email text,
    customer_name text,
    start_date date,
    end_date date,
    is_current boolean
);


ALTER TABLE public.dim_customer OWNER TO de_user;

--
-- TOC entry 215 (class 1259 OID 16402)
-- Name: dim_customer_customer_sk_seq; Type: SEQUENCE; Schema: public; Owner: de_user
--

CREATE SEQUENCE public.dim_customer_customer_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_customer_customer_sk_seq OWNER TO de_user;

--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 215
-- Name: dim_customer_customer_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: de_user
--

ALTER SEQUENCE public.dim_customer_customer_sk_seq OWNED BY public.dim_customer.customer_sk;


--
-- TOC entry 218 (class 1259 OID 16412)
-- Name: dim_product; Type: TABLE; Schema: public; Owner: de_user
--

CREATE TABLE public.dim_product (
    product_sk integer NOT NULL,
    sku text,
    product_name text
);


ALTER TABLE public.dim_product OWNER TO de_user;

--
-- TOC entry 217 (class 1259 OID 16411)
-- Name: dim_product_product_sk_seq; Type: SEQUENCE; Schema: public; Owner: de_user
--

CREATE SEQUENCE public.dim_product_product_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_product_product_sk_seq OWNER TO de_user;

--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 217
-- Name: dim_product_product_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: de_user
--

ALTER SEQUENCE public.dim_product_product_sk_seq OWNED BY public.dim_product.product_sk;


--
-- TOC entry 222 (class 1259 OID 24589)
-- Name: etl_orders_clean; Type: TABLE; Schema: public; Owner: de_user
--

CREATE TABLE public.etl_orders_clean (
    order_id integer,
    customer_email text,
    product_sku text,
    order_time timestamp without time zone,
    amount integer,
    status text
);


ALTER TABLE public.etl_orders_clean OWNER TO de_user;

--
-- TOC entry 214 (class 1259 OID 16397)
-- Name: etl_test; Type: TABLE; Schema: public; Owner: de_user
--

CREATE TABLE public.etl_test (
    id integer,
    note text
);


ALTER TABLE public.etl_test OWNER TO de_user;

--
-- TOC entry 221 (class 1259 OID 16433)
-- Name: fact_orders; Type: TABLE; Schema: public; Owner: de_user
--

CREATE TABLE public.fact_orders (
    order_id integer NOT NULL,
    customer_sk integer,
    product_sk integer,
    order_time timestamp without time zone,
    amount integer,
    status text
);


ALTER TABLE public.fact_orders OWNER TO de_user;

--
-- TOC entry 219 (class 1259 OID 16420)
-- Name: raw_customers; Type: TABLE; Schema: public; Owner: de_user
--

CREATE TABLE public.raw_customers (
    email text,
    customer_name text
);


ALTER TABLE public.raw_customers OWNER TO de_user;

--
-- TOC entry 220 (class 1259 OID 16428)
-- Name: raw_orders; Type: TABLE; Schema: public; Owner: de_user
--

CREATE TABLE public.raw_orders (
    order_id integer,
    customer_email text,
    product_sku text,
    order_time timestamp without time zone,
    amount integer,
    status text
);


ALTER TABLE public.raw_orders OWNER TO de_user;

--
-- TOC entry 3288 (class 2604 OID 16406)
-- Name: dim_customer customer_sk; Type: DEFAULT; Schema: public; Owner: de_user
--

ALTER TABLE ONLY public.dim_customer ALTER COLUMN customer_sk SET DEFAULT nextval('public.dim_customer_customer_sk_seq'::regclass);


--
-- TOC entry 3289 (class 2604 OID 16415)
-- Name: dim_product product_sk; Type: DEFAULT; Schema: public; Owner: de_user
--

ALTER TABLE ONLY public.dim_product ALTER COLUMN product_sk SET DEFAULT nextval('public.dim_product_product_sk_seq'::regclass);


--
-- TOC entry 3440 (class 0 OID 16403)
-- Dependencies: 216
-- Data for Name: dim_customer; Type: TABLE DATA; Schema: public; Owner: de_user
--

COPY public.dim_customer (customer_sk, email, customer_name, start_date, end_date, is_current) FROM stdin;
2	bob@gmail.com	Bob	2023-01-01	\N	t
1	alice@gmail.com	Alice	2023-01-01	2026-02-04	f
3	alice@gmail.com	Alice Nguyen	2026-02-04	\N	t
\.


--
-- TOC entry 3442 (class 0 OID 16412)
-- Dependencies: 218
-- Data for Name: dim_product; Type: TABLE DATA; Schema: public; Owner: de_user
--

COPY public.dim_product (product_sk, sku, product_name) FROM stdin;
1	SKU_A	Laptop
2	SKU_B	Mouse
\.


--
-- TOC entry 3446 (class 0 OID 24589)
-- Dependencies: 222
-- Data for Name: etl_orders_clean; Type: TABLE DATA; Schema: public; Owner: de_user
--

COPY public.etl_orders_clean (order_id, customer_email, product_sku, order_time, amount, status) FROM stdin;
1001	alice@gmail.com	SKU_A	2024-01-01 10:00:00	1000	PAID
\.


--
-- TOC entry 3438 (class 0 OID 16397)
-- Dependencies: 214
-- Data for Name: etl_test; Type: TABLE DATA; Schema: public; Owner: de_user
--

COPY public.etl_test (id, note) FROM stdin;
1	insert from python etl
0	this should fail quality check
0	this should fail quality check
0	this should fail quality check
1	production style etl
\.


--
-- TOC entry 3445 (class 0 OID 16433)
-- Dependencies: 221
-- Data for Name: fact_orders; Type: TABLE DATA; Schema: public; Owner: de_user
--

COPY public.fact_orders (order_id, customer_sk, product_sk, order_time, amount, status) FROM stdin;
1002	2	2	2024-01-02 11:00:00	200	PAID
1001	3	1	2024-01-01 10:00:00	500	PAID
\.


--
-- TOC entry 3443 (class 0 OID 16420)
-- Dependencies: 219
-- Data for Name: raw_customers; Type: TABLE DATA; Schema: public; Owner: de_user
--

COPY public.raw_customers (email, customer_name) FROM stdin;
alice@gmail.com	Alice Nguyen
bob@gmail.com	Bob
alice@gmail.com	Alice Nguyen
bob@gmail.com	Bob
\.


--
-- TOC entry 3444 (class 0 OID 16428)
-- Dependencies: 220
-- Data for Name: raw_orders; Type: TABLE DATA; Schema: public; Owner: de_user
--

COPY public.raw_orders (order_id, customer_email, product_sku, order_time, amount, status) FROM stdin;
1002	bob@gmail.com	SKU_B	2024-01-02 11:00:00	200	PAID
1001	alice@gmail.com	SKU_A	2024-01-01 10:00:00	0	CANCELED
1001	bob@gmail.com	SKU_A	2026-02-05 01:10:46.62307	500	PAID
1001	ndd@gmail.com	SKU_A	2025-12-01 10:00:00	980	\N
1001	ndd@gmail.com	SKU_A	2025-12-01 10:00:00	980	\N
\N	bob@gmail.com	SKU_A	2026-02-07 03:51:12.008355	500	PAID
\.


--
-- TOC entry 3454 (class 0 OID 0)
-- Dependencies: 215
-- Name: dim_customer_customer_sk_seq; Type: SEQUENCE SET; Schema: public; Owner: de_user
--

SELECT pg_catalog.setval('public.dim_customer_customer_sk_seq', 3, true);


--
-- TOC entry 3455 (class 0 OID 0)
-- Dependencies: 217
-- Name: dim_product_product_sk_seq; Type: SEQUENCE SET; Schema: public; Owner: de_user
--

SELECT pg_catalog.setval('public.dim_product_product_sk_seq', 2, true);


--
-- TOC entry 3291 (class 2606 OID 16410)
-- Name: dim_customer dim_customer_pkey; Type: CONSTRAINT; Schema: public; Owner: de_user
--

ALTER TABLE ONLY public.dim_customer
    ADD CONSTRAINT dim_customer_pkey PRIMARY KEY (customer_sk);


--
-- TOC entry 3293 (class 2606 OID 16419)
-- Name: dim_product dim_product_pkey; Type: CONSTRAINT; Schema: public; Owner: de_user
--

ALTER TABLE ONLY public.dim_product
    ADD CONSTRAINT dim_product_pkey PRIMARY KEY (product_sk);


--
-- TOC entry 3295 (class 2606 OID 16439)
-- Name: fact_orders fact_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: de_user
--

ALTER TABLE ONLY public.fact_orders
    ADD CONSTRAINT fact_orders_pkey PRIMARY KEY (order_id);


-- Completed on 2026-02-07 06:19:28

--
-- PostgreSQL database dump complete
--

