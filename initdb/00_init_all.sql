-- Автоматическая инициализация БД при первом запуске контейнера

DROP TABLE IF EXISTS mock_data;

CREATE TABLE mock_data (
    id INT,
    customer_first_name TEXT,
    customer_last_name TEXT,
    customer_age INT,
    customer_email TEXT,
    customer_country TEXT,
    customer_postal_code TEXT,
    customer_pet_type TEXT,
    customer_pet_name TEXT,
    customer_pet_breed TEXT,
    seller_first_name TEXT,
    seller_last_name TEXT,
    seller_email TEXT,
    seller_country TEXT,
    seller_postal_code TEXT,
    product_name TEXT,
    product_category TEXT,
    product_price NUMERIC(10,2),
    product_quantity INT,
    sale_date TEXT,
    sale_customer_id INT,
    sale_seller_id INT,
    sale_product_id INT,
    sale_quantity INT,
    sale_total_price NUMERIC(12,2),
    store_name TEXT,
    store_location TEXT,
    store_city TEXT,
    store_state TEXT,
    store_country TEXT,
    store_phone TEXT,
    store_email TEXT,
    pet_category TEXT,
    product_weight NUMERIC(10,2),
    product_color TEXT,
    product_size TEXT,
    product_brand TEXT,
    product_material TEXT,
    product_description TEXT,
    product_rating NUMERIC(3,1),
    product_reviews INT,
    product_release_date TEXT,
    product_expiry_date TEXT,
    supplier_name TEXT,
    supplier_contact TEXT,
    supplier_email TEXT,
    supplier_phone TEXT,
    supplier_address TEXT,
    supplier_city TEXT,
    supplier_country TEXT
);

COPY mock_data FROM '/docker-entrypoint-initdb.d/mock_data/MOCK_DATA.csv' WITH (FORMAT csv, HEADER true);
COPY mock_data FROM '/docker-entrypoint-initdb.d/mock_data/MOCK_DATA (1).csv' WITH (FORMAT csv, HEADER true);
COPY mock_data FROM '/docker-entrypoint-initdb.d/mock_data/MOCK_DATA (2).csv' WITH (FORMAT csv, HEADER true);
COPY mock_data FROM '/docker-entrypoint-initdb.d/mock_data/MOCK_DATA (3).csv' WITH (FORMAT csv, HEADER true);
COPY mock_data FROM '/docker-entrypoint-initdb.d/mock_data/MOCK_DATA (4).csv' WITH (FORMAT csv, HEADER true);
COPY mock_data FROM '/docker-entrypoint-initdb.d/mock_data/MOCK_DATA (5).csv' WITH (FORMAT csv, HEADER true);
COPY mock_data FROM '/docker-entrypoint-initdb.d/mock_data/MOCK_DATA (6).csv' WITH (FORMAT csv, HEADER true);
COPY mock_data FROM '/docker-entrypoint-initdb.d/mock_data/MOCK_DATA (7).csv' WITH (FORMAT csv, HEADER true);
COPY mock_data FROM '/docker-entrypoint-initdb.d/mock_data/MOCK_DATA (8).csv' WITH (FORMAT csv, HEADER true);
COPY mock_data FROM '/docker-entrypoint-initdb.d/mock_data/MOCK_DATA (9).csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_supplier CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_seller CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;

CREATE TABLE dim_customer (
    customer_id SERIAL PRIMARY KEY,
    source_customer_id INT,
    first_name TEXT,
    last_name TEXT,
    age INT,
    email TEXT,
    country TEXT,
    postal_code TEXT,
    pet_type TEXT,
    pet_name TEXT,
    pet_breed TEXT
);

CREATE TABLE dim_seller (
    seller_id SERIAL PRIMARY KEY,
    source_seller_id INT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    country TEXT,
    postal_code TEXT
);

CREATE TABLE dim_store (
    store_id SERIAL PRIMARY KEY,
    store_name TEXT,
    location TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    phone TEXT,
    email TEXT
);

CREATE TABLE dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name TEXT,
    contact TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    country TEXT
);

CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE,
    day_num INT,
    month_num INT,
    year_num INT,
    quarter_num INT
);

CREATE TABLE dim_product (
    product_id SERIAL PRIMARY KEY,
    source_product_id INT,
    product_name TEXT,
    category TEXT,
    price NUMERIC(10,2),
    weight NUMERIC(10,2),
    color TEXT,
    size TEXT,
    brand TEXT,
    material TEXT,
    description TEXT,
    rating NUMERIC(3,1),
    reviews INT,
    release_date DATE,
    expiry_date DATE,
    pet_category TEXT,
    supplier_id INT REFERENCES dim_supplier(supplier_id)
);

CREATE TABLE fact_sales (
    fact_id SERIAL PRIMARY KEY,
    sale_id INT,
    date_id INT REFERENCES dim_date(date_id),
    customer_id INT REFERENCES dim_customer(customer_id),
    seller_id INT REFERENCES dim_seller(seller_id),
    product_id INT REFERENCES dim_product(product_id),
    store_id INT REFERENCES dim_store(store_id),
    quantity INT,
    total_price NUMERIC(12,2)
);

TRUNCATE TABLE fact_sales, dim_product, dim_date, dim_store, dim_seller, dim_customer, dim_supplier RESTART IDENTITY CASCADE;

INSERT INTO dim_supplier (
    supplier_name,
    contact,
    email,
    phone,
    address,
    city,
    country
)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM mock_data;

INSERT INTO dim_customer (
    source_customer_id,
    first_name,
    last_name,
    age,
    email,
    country,
    postal_code,
    pet_type,
    pet_name,
    pet_breed
)
SELECT
    sale_customer_id,
    MAX(customer_first_name) AS first_name,
    MAX(customer_last_name) AS last_name,
    MAX(customer_age) AS age,
    MAX(customer_email) AS email,
    MAX(customer_country) AS country,
    MAX(customer_postal_code) AS postal_code,
    MAX(customer_pet_type) AS pet_type,
    MAX(customer_pet_name) AS pet_name,
    MAX(customer_pet_breed) AS pet_breed
FROM mock_data
GROUP BY sale_customer_id;

INSERT INTO dim_seller (
    source_seller_id,
    first_name,
    last_name,
    email,
    country,
    postal_code
)
SELECT
    sale_seller_id,
    MAX(seller_first_name) AS first_name,
    MAX(seller_last_name) AS last_name,
    MAX(seller_email) AS email,
    MAX(seller_country) AS country,
    MAX(seller_postal_code) AS postal_code
FROM mock_data
GROUP BY sale_seller_id;

INSERT INTO dim_store (
    store_name,
    location,
    city,
    state,
    country,
    phone,
    email
)
SELECT
    store_name,
    MAX(store_location) AS location,
    MAX(store_city) AS city,
    MAX(store_state) AS state,
    MAX(store_country) AS country,
    store_phone,
    store_email
FROM mock_data
GROUP BY store_name, store_phone, store_email;

INSERT INTO dim_date (
    full_date,
    day_num,
    month_num,
    year_num,
    quarter_num
)
SELECT DISTINCT
    sale_date::date,
    EXTRACT(DAY FROM sale_date::date)::int,
    EXTRACT(MONTH FROM sale_date::date)::int,
    EXTRACT(YEAR FROM sale_date::date)::int,
    EXTRACT(QUARTER FROM sale_date::date)::int
FROM mock_data
WHERE sale_date IS NOT NULL;

INSERT INTO dim_product (
    source_product_id,
    product_name,
    category,
    price,
    weight,
    color,
    size,
    brand,
    material,
    description,
    rating,
    reviews,
    release_date,
    expiry_date,
    pet_category,
    supplier_id
)
SELECT
    m.sale_product_id,
    MAX(m.product_name) AS product_name,
    MAX(m.product_category) AS category,
    MAX(m.product_price) AS price,
    MAX(m.product_weight) AS weight,
    MAX(m.product_color) AS color,
    MAX(m.product_size) AS size,
    MAX(m.product_brand) AS brand,
    MAX(m.product_material) AS material,
    MAX(m.product_description) AS description,
    MAX(m.product_rating) AS rating,
    MAX(m.product_reviews) AS reviews,
    MAX(NULLIF(m.product_release_date, '')::date) AS release_date,
    MAX(NULLIF(m.product_expiry_date, '')::date) AS expiry_date,
    MAX(m.pet_category) AS pet_category,
    MIN(s.supplier_id) AS supplier_id
FROM mock_data m
JOIN dim_supplier s
    ON COALESCE(m.supplier_name, '') = COALESCE(s.supplier_name, '')
   AND COALESCE(m.supplier_email, '') = COALESCE(s.email, '')
   AND COALESCE(m.supplier_phone, '') = COALESCE(s.phone, '')
GROUP BY m.sale_product_id;

TRUNCATE TABLE fact_sales RESTART IDENTITY CASCADE;

INSERT INTO fact_sales (
    sale_id,
    date_id,
    customer_id,
    seller_id,
    product_id,
    store_id,
    quantity,
    total_price
)
SELECT
    m.id,
    d.date_id,
    c.customer_id,
    s.seller_id,
    p.product_id,
    st.store_id,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
JOIN dim_date d
    ON m.sale_date::date = d.full_date
JOIN dim_customer c
    ON m.sale_customer_id = c.source_customer_id
JOIN dim_seller s
    ON m.sale_seller_id = s.source_seller_id
JOIN dim_store st
    ON COALESCE(m.store_name, '') = COALESCE(st.store_name, '')
   AND COALESCE(m.store_email, '') = COALESCE(st.email, '')
   AND COALESCE(m.store_phone, '') = COALESCE(st.phone, '')
JOIN dim_product p
    ON m.sale_product_id = p.source_product_id;

ANALYZE;
