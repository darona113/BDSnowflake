SELECT COUNT(*) AS raw_count FROM mock_data;
SELECT COUNT(*) AS fact_count FROM fact_sales;

SELECT COUNT(*) AS supplier_count FROM dim_supplier;
SELECT COUNT(*) AS customer_count FROM dim_customer;
SELECT COUNT(*) AS seller_count FROM dim_seller;
SELECT COUNT(*) AS store_count FROM dim_store;
SELECT COUNT(*) AS date_count FROM dim_date;
SELECT COUNT(*) AS product_count FROM dim_product;

SELECT SUM(sale_total_price) AS raw_total FROM mock_data;
SELECT SUM(total_price) AS fact_total FROM fact_sales;

SELECT
    fs.fact_id,
    dd.full_date,
    dc.first_name || ' ' || dc.last_name AS customer_name,
    ds.first_name || ' ' || ds.last_name AS seller_name,
    dp.product_name,
    dst.store_name,
    fs.quantity,
    fs.total_price
FROM fact_sales fs
JOIN dim_date dd ON fs.date_id = dd.date_id
JOIN dim_customer dc ON fs.customer_id = dc.customer_id
JOIN dim_seller ds ON fs.seller_id = ds.seller_id
JOIN dim_product dp ON fs.product_id = dp.product_id
JOIN dim_store dst ON fs.store_id = dst.store_id
LIMIT 20;
