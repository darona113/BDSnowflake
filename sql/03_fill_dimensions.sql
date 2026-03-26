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
