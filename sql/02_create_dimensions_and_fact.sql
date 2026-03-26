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
