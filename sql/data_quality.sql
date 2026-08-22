USE ecommerce_analytics;

-- =========================================================
-- ROW COUNT VALIDATION
-- =========================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'reviews', COUNT(*)
FROM reviews

UNION ALL

SELECT 'product_category_translation', COUNT(*)
FROM product_category_translation;


-- =========================================================
--  2. DUPLICATE VALIDATION
-- =========================================================

-- =========================================================
--  DUPLICATE CHECK - CUSTOMERS
-- =========================================================

-- customer_id should be unique
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- customer_unique_id can legitimately repeat.
-- This identifies customers having multiple customer records.
SELECT
    customer_unique_id,
    COUNT(*) AS record_count
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;


-- Summary of customer IDs vs actual unique customers
SELECT
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;


-- =========================================================
--  DUPLICATE CHECK - ORDERS
-- =========================================================

-- order_id should be unique
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Summary
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_rows
FROM orders;


-- =========================================================
--  DUPLICATE CHECK - ORDER ITEMS
-- =========================================================

-- order_id alone is NOT unique.
-- The correct key is (order_id, order_item_id).

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- Summary
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT(order_id, '-', order_item_id))
        AS unique_order_items,
    COUNT(*) -
    COUNT(DISTINCT CONCAT(order_id, '-', order_item_id))
        AS duplicate_rows
FROM order_items;


-- =========================================================
--  DUPLICATE CHECK - PRODUCTS
-- =========================================================

-- product_id should be unique
SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Summary
SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(*) - COUNT(DISTINCT product_id) AS duplicate_rows
FROM products;


-- =========================================================
--  DUPLICATE CHECK - SELLERS
-- =========================================================

-- seller_id should be unique
SELECT
    seller_id,
    COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- Summary
SELECT
    COUNT(*) AS total_sellers,
    COUNT(DISTINCT seller_id) AS unique_sellers,
    COUNT(*) - COUNT(DISTINCT seller_id) AS duplicate_rows
FROM sellers;


-- =========================================================
--  DUPLICATE CHECK - PAYMENTS
-- =========================================================

-- order_id alone is NOT unique.
-- Correct key is (order_id, payment_sequential).

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS duplicate_count
FROM payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;


-- Summary
SELECT
    COUNT(*) AS total_rows,
    COUNT(
        DISTINCT CONCAT(order_id, '-', payment_sequential)
    ) AS unique_payment_records,
    COUNT(*) -
    COUNT(
        DISTINCT CONCAT(order_id, '-', payment_sequential)
    ) AS duplicate_rows
FROM payments;


-- =========================================================
--  DUPLICATE CHECK - REVIEWS
-- =========================================================

-- review_id should be unique
SELECT
    review_id,
    COUNT(*) AS duplicate_count
FROM reviews
GROUP BY review_id
HAVING COUNT(*) > 1;


-- Summary
SELECT
    COUNT(*) AS total_reviews,
    COUNT(DISTINCT review_id) AS unique_reviews,
    COUNT(*) - COUNT(DISTINCT review_id) AS duplicate_rows
FROM reviews;


-- =========================================================
-- DUPLICATE CHECK - PRODUCT CATEGORY TRANSLATION
-- =========================================================

-- product_category_name should be unique
SELECT
    product_category_name,
    COUNT(*) AS duplicate_count
FROM product_category_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;


-- Summary
SELECT
    COUNT(*) AS total_categories,
    COUNT(DISTINCT product_category_name) AS unique_categories,
    COUNT(*) - COUNT(DISTINCT product_category_name) AS duplicate_rows
FROM product_category_translation;


-- =========================================================
-- 3. NULL VALUE CHECKS
-- =========================================================

-- ---------------------------------------------------------
-- CUSTOMERS
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(customer_unique_id IS NULL) AS customer_unique_id_nulls,
    SUM(customer_zip_code_prefix IS NULL) AS zip_code_nulls,
    SUM(customer_city IS NULL) AS city_nulls,
    SUM(customer_state IS NULL) AS state_nulls
FROM customers;


-- ---------------------------------------------------------
-- ORDERS
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(order_status IS NULL) AS order_status_nulls,
    SUM(order_purchase_timestamp IS NULL) AS purchase_timestamp_nulls,
    SUM(order_approved_at IS NULL) AS approved_at_nulls,
    SUM(order_delivered_carrier_date IS NULL) AS delivered_carrier_date_nulls,
    SUM(order_delivered_customer_date IS NULL) AS delivered_customer_date_nulls,
    SUM(order_estimated_delivery_date IS NULL) AS estimated_delivery_date_nulls
FROM orders;


-- ---------------------------------------------------------
-- ORDER ITEMS
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(order_item_id IS NULL) AS order_item_id_nulls,
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(seller_id IS NULL) AS seller_id_nulls,
    SUM(shipping_limit_date IS NULL) AS shipping_limit_date_nulls,
    SUM(price IS NULL) AS price_nulls,
    SUM(freight_value IS NULL) AS freight_value_nulls
FROM order_items;


-- ---------------------------------------------------------
-- PRODUCTS
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(product_category_name IS NULL) AS category_nulls,
    SUM(product_name_lenght IS NULL) AS name_length_nulls,
    SUM(product_description_lenght IS NULL) AS description_length_nulls,
    SUM(product_photos_qty IS NULL) AS photos_qty_nulls,
    SUM(product_weight_g IS NULL) AS weight_nulls,
    SUM(product_length_cm IS NULL) AS length_nulls,
    SUM(product_height_cm IS NULL) AS height_nulls,
    SUM(product_width_cm IS NULL) AS width_nulls
FROM products;


-- ---------------------------------------------------------
-- SELLERS
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    SUM(seller_id IS NULL) AS seller_id_nulls,
    SUM(seller_zip_code_prefix IS NULL) AS zip_code_nulls,
    SUM(seller_city IS NULL) AS city_nulls,
    SUM(seller_state IS NULL) AS state_nulls
FROM sellers;


-- ---------------------------------------------------------
-- PAYMENTS
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(payment_sequential IS NULL) AS payment_sequential_nulls,
    SUM(payment_type IS NULL) AS payment_type_nulls,
    SUM(payment_installments IS NULL) AS installments_nulls,
    SUM(payment_value IS NULL) AS payment_value_nulls
FROM payments;


-- ---------------------------------------------------------
-- REVIEWS
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    SUM(review_id IS NULL) AS review_id_nulls,
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(review_score IS NULL) AS review_score_nulls,
    SUM(review_comment_title IS NULL) AS comment_title_nulls,
    SUM(review_comment_message IS NULL) AS comment_message_nulls,
    SUM(review_creation_date IS NULL) AS creation_date_nulls,
    SUM(review_answer_timestamp IS NULL) AS answer_timestamp_nulls
FROM reviews;


-- ---------------------------------------------------------
-- PRODUCT CATEGORY TRANSLATION
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    SUM(product_category_name IS NULL) AS category_name_nulls,
    SUM(product_category_name_english IS NULL) AS english_category_nulls
FROM product_category_translation;


-- =========================================================
-- 4. RANGE & QUALITY CHECKS
-- =========================================================


-- =========================================================
-- 4.1 PRODUCTS - NUMERIC RANGE CHECKS
-- =========================================================

-- ---------------------------------------------------------
-- Product Weight
-- ---------------------------------------------------------

-- Identify products with zero or negative weight.
SELECT
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    product_photos_qty
FROM products
WHERE product_weight_g IS NOT NULL
  AND product_weight_g <= 0;

-- DATA QUALITY FINDING:
-- 4 products have product_weight_g = 0.
-- Their other product attributes are populated and appear valid.
-- These records are retained as source-data anomalies.
-- No values are modified or deleted.

-- ---------------------------------------------------------
-- Product Dimensions
-- ---------------------------------------------------------

-- Check for invalid product length
SELECT *
FROM products
WHERE product_length_cm IS NOT NULL
  AND product_length_cm <= 0;


-- Check for invalid product height
SELECT *
FROM products
WHERE product_height_cm IS NOT NULL
  AND product_height_cm <= 0;


-- Check for invalid product width
SELECT *
FROM products
WHERE product_width_cm IS NOT NULL
  AND product_width_cm <= 0;


-- Check for negative number of product photos
SELECT *
FROM products
WHERE product_photos_qty IS NOT NULL
  AND product_photos_qty < 0;


-- Check for negative product name length
SELECT *
FROM products
WHERE product_name_lenght IS NOT NULL
  AND product_name_lenght < 0;


-- Check for negative product description length
SELECT *
FROM products
WHERE product_description_lenght IS NOT NULL
  AND product_description_lenght < 0;



-- =========================================================
-- 4.2 PAYMENTS - RANGE & QUALITY CHECKS
-- =========================================================


-- ---------------------------------------------------------
-- Payment Value
-- ---------------------------------------------------------

-- Check for negative payment values.
SELECT *
FROM payments
WHERE payment_value < 0;


-- DATA QUALITY FINDING:
-- No negative payment values were found.
-- payment_value is within the expected non-negative range.


-- ---------------------------------------------------------
-- Payment Installments
-- ---------------------------------------------------------

-- Check for zero or negative installment values.
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM payments
WHERE payment_installments <= 0;


-- DATA QUALITY FINDING:
-- 2 credit_card payment records have payment_installments = 0.
-- These records are retained as source-data anomalies.
-- No values are modified or deleted.


-- Check installment distribution by payment type.
SELECT
    payment_type,
    payment_installments,
    COUNT(*) AS record_count
FROM payments
GROUP BY
    payment_type,
    payment_installments
ORDER BY
    payment_type,
    payment_installments;


-- Check zero-installment records by payment type.
SELECT
    payment_type,
    COUNT(*) AS zero_installment_records
FROM payments
WHERE payment_installments = 0
GROUP BY payment_type;


-- ---------------------------------------------------------
-- Payment Sequential Number
-- ---------------------------------------------------------

-- Check for invalid payment sequence numbers.
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM payments
WHERE payment_sequential <= 0;

-- DATA QUALITY FINDING:
-- Payment sequential numbers are expected to be positive.
-- Any records returned by the query above require investigation.
-- No values are modified or deleted.

-- ---------------------------------------------------------
-- Payment Value Statistics
-- ---------------------------------------------------------

-- Check the overall payment value range and distribution.
SELECT
    MIN(payment_value) AS minimum_payment,
    MAX(payment_value) AS maximum_payment,
    AVG(payment_value) AS average_payment
FROM payments;


-- Check the overall installment range.
SELECT
    MIN(payment_installments) AS minimum_installments,
    MAX(payment_installments) AS maximum_installments
FROM payments;


-- Check the overall payment sequence range.
SELECT
    MIN(payment_sequential) AS minimum_payment_sequence,
    MAX(payment_sequential) AS maximum_payment_sequence
FROM payments;


-- ---------------------------------------------------------
-- Payment Type Quality Check
-- ---------------------------------------------------------

-- Payment type distribution.
SELECT
    payment_type,
    COUNT(*) AS payment_count
FROM payments
GROUP BY payment_type
ORDER BY payment_count DESC;


-- List all distinct payment types.
SELECT DISTINCT
    payment_type
FROM payments
ORDER BY payment_type;



-- =========================================================
-- 4.3 ORDER ITEMS - RANGE CHECKS
-- =========================================================

-- Check for negative product prices
SELECT *
FROM order_items
WHERE price < 0;


-- Check for negative freight values
SELECT *
FROM order_items
WHERE freight_value < 0;


-- Check for invalid order item IDs
SELECT *
FROM order_items
WHERE order_item_id <= 0;



-- =========================================================
-- 4.4 REVIEWS - RANGE & QUALITY CHECKS
-- =========================================================


-- ---------------------------------------------------------
-- Review Score Validation
-- ---------------------------------------------------------

-- Review scores should be between 1 and 5.
SELECT *
FROM reviews
WHERE review_score < 1
   OR review_score > 5;


-- DATA QUALITY FINDING:
-- No review scores outside the valid range of 1 to 5 were found.
-- All non-NULL review scores are valid.


-- ---------------------------------------------------------
-- Review Score Distribution
-- ---------------------------------------------------------

SELECT
    review_score,
    COUNT(*) AS review_count
FROM reviews
GROUP BY review_score
ORDER BY review_score;


-- Check all distinct review scores.
SELECT DISTINCT
    review_score
FROM reviews
ORDER BY review_score;


-- DATA QUALITY OBSERVATION:
-- Review scores range from 1 to 5.
-- A high proportion of reviews have a score of 5.
-- This is treated as a characteristic of the dataset,
-- not as a data-quality error.


-- =========================================================
-- 4.5 CUSTOMERS - ZIP CODE CHECKS
-- =========================================================

-- Check for negative ZIP code prefixes
SELECT *
FROM customers
WHERE customer_zip_code_prefix < 0;


-- Check minimum and maximum ZIP code prefix
SELECT
    MIN(customer_zip_code_prefix) AS min_zip_code,
    MAX(customer_zip_code_prefix) AS max_zip_code
FROM customers;


-- Check customer state distribution
SELECT
    customer_state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_state
ORDER BY customer_count DESC;


-- Check all distinct customer states
SELECT DISTINCT
    customer_state
FROM customers
ORDER BY customer_state;



-- =========================================================
-- 4.6 SELLERS - ZIP CODE CHECKS
-- =========================================================

-- Check for negative ZIP code prefixes
SELECT *
FROM sellers
WHERE seller_zip_code_prefix < 0;


-- Check minimum and maximum ZIP code prefix
SELECT
    MIN(seller_zip_code_prefix) AS min_zip_code,
    MAX(seller_zip_code_prefix) AS max_zip_code
FROM sellers;


-- Check seller state distribution
SELECT
    seller_state,
    COUNT(*) AS seller_count
FROM sellers
GROUP BY seller_state
ORDER BY seller_count DESC;


-- Check all distinct seller states
SELECT DISTINCT
    seller_state
FROM sellers
ORDER BY seller_state;


-- =========================================================
-- 4.7 ORDERS - DATE/TIME QUALITY CHECKS
-- =========================================================


-- ---------------------------------------------------------
-- Approval Before Purchase
-- ---------------------------------------------------------

SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at
FROM orders
WHERE order_approved_at IS NOT NULL
  AND order_approved_at < order_purchase_timestamp;


-- DATA QUALITY FINDING:
-- No orders have approval timestamps earlier than purchase timestamps.


-- ---------------------------------------------------------
-- Carrier Delivery Before Purchase
-- ---------------------------------------------------------

SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_carrier_date
FROM orders
WHERE order_delivered_carrier_date IS NOT NULL
  AND order_delivered_carrier_date < order_purchase_timestamp;


-- DATA QUALITY FINDING:
-- 166 orders have order_delivered_carrier_date earlier than
-- order_purchase_timestamp.
-- These records contain a logically inconsistent timestamp sequence.
-- Records are retained in the raw dataset.
-- No timestamps are modified or deleted.


-- ---------------------------------------------------------
-- Customer Delivery Before Purchase
-- ---------------------------------------------------------

SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date < order_purchase_timestamp;


-- DATA QUALITY FINDING:
-- No orders have customer delivery timestamps earlier
-- than their purchase timestamps.


-- ---------------------------------------------------------
-- Customer Delivery Before Carrier Delivery
-- ---------------------------------------------------------

SELECT
    order_id,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_carrier_date IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date < order_delivered_carrier_date;


-- DATA QUALITY FINDING:
-- 23 orders have customer delivery timestamps earlier than
-- carrier delivery timestamps.
-- These records contain a logically inconsistent delivery sequence.
-- Records are retained in the raw dataset.
-- No timestamps are modified or deleted.

-- ---------------------------------------------------------
-- Estimated Delivery Before Purchase
-- ---------------------------------------------------------

SELECT
    order_id,
    order_purchase_timestamp,
    order_estimated_delivery_date
FROM orders
WHERE order_estimated_delivery_date < DATE(order_purchase_timestamp);


-- DATA QUALITY FINDING:
-- No orders have an estimated delivery date earlier
-- than the purchase date.

-- Check if estimated delivery date is NULL
SELECT
    COUNT(*) AS estimated_delivery_date_nulls
FROM orders
WHERE order_estimated_delivery_date IS NULL;



-- =========================================================
-- 4.8 ORDERS - DELIVERY PERFORMANCE CHECK
-- =========================================================

-- Count orders delivered later than estimated date
-- This is NOT an error; it is a business metric.
SELECT
    COUNT(*) AS late_deliveries
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date > order_estimated_delivery_date;
  
  -- DATA QUALITY FINDING:
  -- 7827 orders delivered later than estimated date


-- Count orders delivered on or before estimated date
SELECT
    COUNT(*) AS on_time_or_early_deliveries
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date <= order_estimated_delivery_date;

  -- DATA QUALITY FINDING:
  -- 88649 orders delivered on or before estimated date


-- =========================================================
-- 4.9 ORDERS - ORDER STATUS QUALITY CHECK
-- =========================================================

-- Distribution of order statuses
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- List all distinct order statuses
SELECT DISTINCT
    order_status
FROM orders
ORDER BY order_status;



-- =========================================================
-- 4.10 PAYMENTS - PAYMENT TYPE QUALITY CHECK
-- =========================================================

-- Payment type distribution
SELECT
    payment_type,
    COUNT(*) AS payment_count
FROM payments
GROUP BY payment_type
ORDER BY payment_count DESC;


-- List all distinct payment types
SELECT DISTINCT
    payment_type
FROM payments
ORDER BY payment_type;



-- =========================================================
-- 4.11 CUSTOMERS - CITY QUALITY CHECK
-- =========================================================

-- Check for empty customer city values
SELECT
    COUNT(*) AS empty_city_count
FROM customers
WHERE TRIM(customer_city) = '';


-- Check for blank/whitespace-only customer cities
SELECT
    COUNT(*) AS blank_city_count
FROM customers
WHERE customer_city IS NOT NULL
  AND TRIM(customer_city) = '';



-- =========================================================
-- 4.12 SELLERS - CITY QUALITY CHECK
-- =========================================================

-- Check for empty seller city values
SELECT
    COUNT(*) AS empty_city_count
FROM sellers
WHERE TRIM(seller_city) = '';


-- Check for blank/whitespace-only seller cities
SELECT
    COUNT(*) AS blank_city_count
FROM sellers
WHERE seller_city IS NOT NULL
  AND TRIM(seller_city) = '';



-- =========================================================
-- 4.13 PRICE & FREIGHT DISTRIBUTION
-- =========================================================

-- Product price statistics
SELECT
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    AVG(price) AS average_price
FROM order_items;


-- Freight value statistics
SELECT
    MIN(freight_value) AS minimum_freight,
    MAX(freight_value) AS maximum_freight,
    AVG(freight_value) AS average_freight
FROM order_items;


-- =========================================================
-- 4.14 PRICE OUTLIER CHECK
-- =========================================================

-- Identify unusually high-priced products.
-- This is an exploratory check, NOT an automatic data-cleaning rule.

SELECT
    order_id,
    product_id,
    price
FROM order_items
WHERE price > (
    SELECT AVG(price) + 3 * STDDEV(price)
    FROM order_items
)
ORDER BY price DESC;


-- =========================================================
-- 4.15 FREIGHT OUTLIER CHECK
-- =========================================================

-- Identify unusually high freight values.

SELECT
    order_id,
    product_id,
    freight_value
FROM order_items
WHERE freight_value > (
    SELECT AVG(freight_value) + 3 * STDDEV(freight_value)
    FROM order_items
)
ORDER BY freight_value DESC;

-- =========================================================
-- 5. CATEGORICAL VALUE VALIDATION
-- =========================================================

USE ecommerce_analytics;


-- =========================================================
-- 5.1 ORDER STATUS
-- =========================================================

SELECT
    order_status,
    COUNT(*) AS record_count
FROM orders
GROUP BY order_status
ORDER BY record_count DESC;


SELECT DISTINCT
    order_status
FROM orders
WHERE order_status NOT IN (
    'approved',
    'canceled',
    'created',
    'delivered',
    'invoiced',
    'processing',
    'shipped',
    'unavailable'
);


-- =========================================================
-- 5.2 PAYMENT TYPE
-- =========================================================

SELECT
    payment_type,
    COUNT(*) AS record_count
FROM payments
GROUP BY payment_type
ORDER BY record_count DESC;


-- Check for unexpected payment types.

SELECT DISTINCT
    payment_type
FROM payments
WHERE payment_type NOT IN (
    'credit_card',
    'boleto',
    'voucher',
    'debit_card',
    'not_defined'
);


-- Check records where payment type is not defined.

SELECT
    payment_type,
    COUNT(*) AS record_count
FROM payments
WHERE payment_type = 'not_defined'
GROUP BY payment_type;


-- DATA QUALITY FINDING:
-- 'not_defined' is present in the source dataset as a payment type.
-- These records represent payments for which the payment type
-- was not defined in the source data.
-- Records are retained and are not modified or deleted.


-- =========================================================
-- 5.3 REVIEW SCORE
-- =========================================================

SELECT DISTINCT
    review_score
FROM reviews
ORDER BY review_score;


SELECT DISTINCT
    review_score
FROM reviews
WHERE review_score NOT IN (1, 2, 3, 4, 5);


-- =========================================================
-- 5.4 CUSTOMER STATE
-- =========================================================

SELECT
    customer_state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_state
ORDER BY customer_count DESC;


SELECT DISTINCT
    customer_state
FROM customers
WHERE customer_state NOT IN (
    'AC','AL','AP','AM','BA','CE','DF','ES','GO',
    'MA','MT','MS','MG','PA','PB','PR','PE','PI',
    'RJ','RN','RS','RO','RR','SC','SP','SE','TO'
);


-- =========================================================
-- 5.5 SELLER STATE
-- =========================================================

SELECT
    seller_state,
    COUNT(*) AS seller_count
FROM sellers
GROUP BY seller_state
ORDER BY seller_count DESC;


SELECT DISTINCT
    seller_state
FROM sellers
WHERE seller_state NOT IN (
    'AC','AL','AP','AM','BA','CE','DF','ES','GO',
    'MA','MT','MS','MG','PA','PB','PR','PE','PI',
    'RJ','RN','RS','RO','RR','SC','SP','SE','TO'
);


-- =========================================================
-- 5.6 PRODUCT CATEGORY
-- =========================================================

SELECT
    COUNT(DISTINCT product_category_name) AS unique_categories
FROM products
WHERE product_category_name IS NOT NULL;


SELECT
    product_category_name,
    COUNT(*) AS product_count
FROM products
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
ORDER BY product_count DESC;


SELECT
    COUNT(*) AS blank_category_names
FROM products
WHERE product_category_name = '';


-- =========================================================
-- 5.7 PAYMENT TYPE / INSTALLMENT CONSISTENCY
-- =========================================================

SELECT
    payment_type,
    payment_installments,
    COUNT(*) AS record_count
FROM payments
GROUP BY
    payment_type,
    payment_installments
ORDER BY
    payment_type,
    payment_installments;


SELECT
    payment_type,
    payment_installments,
    COUNT(*) AS record_count
FROM payments
WHERE payment_installments = 0
GROUP BY
    payment_type,
    payment_installments;


-- DATA QUALITY FINDING:
-- 2 credit_card records have zero installments.
-- These records are retained as source-data anomalies.
-- No values are modified or deleted.


-- =========================================================
-- 6. REFERENTIAL INTEGRITY VALIDATION
-- =========================================================

-- =========================================================
-- 6.1 ORDERS -> CUSTOMERS
-- =========================================================

SELECT
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- =========================================================
-- 6.2 ORDER ITEMS -> ORDERS
-- =========================================================

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- =========================================================
-- 6.3 ORDER ITEMS -> PRODUCTS
-- =========================================================

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- =========================================================
-- 6.4 ORDER ITEMS -> SELLERS
-- =========================================================

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.seller_id
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- =========================================================
-- 6.5 PAYMENTS -> ORDERS
-- =========================================================

SELECT
    p.order_id,
    p.payment_sequential,
    p.payment_type,
    p.payment_value
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- =========================================================
-- 6.6 REVIEWS -> ORDERS
-- =========================================================

SELECT
    r.review_id,
    r.order_id,
    r.review_score
FROM reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- =========================================================
-- 6.7 CATEGORY TRANSLATION -> PRODUCTS
-- =========================================================

SELECT
    pct.product_category_name,
    pct.product_category_name_english
FROM product_category_translation pct
LEFT JOIN products p
    ON pct.product_category_name = p.product_category_name
WHERE p.product_category_name IS NULL;


-- =========================================================
-- 6.8 PRODUCTS -> CATEGORY TRANSLATION
-- =========================================================

SELECT
    p.product_category_name,
    COUNT(*) AS product_count
FROM products p
LEFT JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND pct.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY product_count DESC;


-- =========================================================
-- 6.9 REFERENTIAL INTEGRITY SUMMARY
-- =========================================================

SELECT

    (
        SELECT COUNT(*)
        FROM orders o
        LEFT JOIN customers c
            ON o.customer_id = c.customer_id
        WHERE c.customer_id IS NULL
    ) AS orders_without_customers,

    (
        SELECT COUNT(*)
        FROM order_items oi
        LEFT JOIN orders o
            ON oi.order_id = o.order_id
        WHERE o.order_id IS NULL
    ) AS order_items_without_orders,

    (
        SELECT COUNT(*)
        FROM order_items oi
        LEFT JOIN products p
            ON oi.product_id = p.product_id
        WHERE p.product_id IS NULL
    ) AS order_items_without_products,

    (
        SELECT COUNT(*)
        FROM order_items oi
        LEFT JOIN sellers s
            ON oi.seller_id = s.seller_id
        WHERE s.seller_id IS NULL
    ) AS order_items_without_sellers,

    (
        SELECT COUNT(*)
        FROM payments p
        LEFT JOIN orders o
            ON p.order_id = o.order_id
        WHERE o.order_id IS NULL
    ) AS payments_without_orders,

    (
        SELECT COUNT(*)
        FROM reviews r
        LEFT JOIN orders o
            ON r.order_id = o.order_id
        WHERE o.order_id IS NULL
    ) AS reviews_without_orders,

    (
        SELECT COUNT(*)
        FROM product_category_translation pct
        LEFT JOIN products p
            ON pct.product_category_name = p.product_category_name
        WHERE p.product_category_name IS NULL
    ) AS translations_without_products;
    
    
-- =========================================================
-- 6.10 FOREIGN KEY CONSTRAINTS
-- =========================================================

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'ecommerce_analytics'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;