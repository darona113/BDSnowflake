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
