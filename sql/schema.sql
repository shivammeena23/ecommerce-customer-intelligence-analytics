-- =========================================================
-- DATABASE: ecommerce_analytics
-- Schema for the Brazilian Olist E-Commerce Dataset
-- =========================================================

CREATE DATABASE IF NOT EXISTS ecommerce_analytics;
USE ecommerce_analytics;

-- =========================================================
-- CUSTOMERS
-- =========================================================
CREATE TABLE IF NOT EXISTS customers (
    customer_id              VARCHAR(64) PRIMARY KEY,
    customer_unique_id       VARCHAR(64) NOT NULL,
    customer_zip_code_prefix VARCHAR(10),
    customer_city            VARCHAR(100),
    customer_state           VARCHAR(5),
    INDEX idx_customer_unique_id (customer_unique_id)
);

-- =========================================================
-- SELLERS
-- =========================================================
CREATE TABLE IF NOT EXISTS sellers (
    seller_id               VARCHAR(64) PRIMARY KEY,
    seller_zip_code_prefix  VARCHAR(10),
    seller_city             VARCHAR(100),
    seller_state            VARCHAR(5)
);

-- =========================================================
-- PRODUCT CATEGORY TRANSLATION
-- =========================================================
CREATE TABLE IF NOT EXISTS product_category_translation (
    product_category_name         VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

-- =========================================================
-- PRODUCTS
-- =========================================================
CREATE TABLE IF NOT EXISTS products (
    product_id                 VARCHAR(64) PRIMARY KEY,
    product_category_name      VARCHAR(100),
    product_name_lenght        INT,
    product_description_lenght INT,
    product_photos_qty         INT,
    product_weight_g           INT,
    product_length_cm          INT,
    product_height_cm          INT,
    product_width_cm           INT,
    FOREIGN KEY (product_category_name)
        REFERENCES product_category_translation (product_category_name)
);

-- =========================================================
-- ORDERS
-- =========================================================
CREATE TABLE IF NOT EXISTS orders (
    order_id                      VARCHAR(64) PRIMARY KEY,
    customer_id                   VARCHAR(64) NOT NULL,
    order_status                  VARCHAR(30),
    order_purchase_timestamp      DATETIME,
    order_approved_at             DATETIME,
    order_delivered_carrier_date  DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
    INDEX idx_order_purchase_timestamp (order_purchase_timestamp)
);

-- =========================================================
-- ORDER ITEMS
-- =========================================================
CREATE TABLE IF NOT EXISTS order_items (
    order_id            VARCHAR(64) NOT NULL,
    order_item_id       INT NOT NULL,
    product_id          VARCHAR(64) NOT NULL,
    seller_id           VARCHAR(64) NOT NULL,
    shipping_limit_date DATETIME,
    price                DECIMAL(10,2),
    freight_value        DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id)   REFERENCES orders (order_id),
    FOREIGN KEY (product_id) REFERENCES products (product_id),
    FOREIGN KEY (seller_id)  REFERENCES sellers (seller_id)
);

-- =========================================================
-- PAYMENTS
-- =========================================================
CREATE TABLE IF NOT EXISTS payments (
    order_id             VARCHAR(64) NOT NULL,
    payment_sequential   INT NOT NULL,
    payment_type         VARCHAR(30),
    payment_installments INT,
    payment_value        DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

-- =========================================================
-- REVIEWS
-- =========================================================
CREATE TABLE IF NOT EXISTS reviews (
    review_id               VARCHAR(64) NOT NULL,
    order_id                VARCHAR(64) NOT NULL,
    review_score            TINYINT,
    review_comment_title    VARCHAR(255),
    review_comment_message  TEXT,
    review_creation_date    DATETIME,
    review_answer_timestamp DATETIME,
    PRIMARY KEY (review_id, order_id),
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

-- =========================================================
-- GEOLOCATION
-- =========================================================
CREATE TABLE IF NOT EXISTS geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat              DECIMAL(10,6),
    geolocation_lng              DECIMAL(10,6),
    geolocation_city             VARCHAR(100),
    geolocation_state            VARCHAR(5),
    INDEX idx_geo_zip (geolocation_zip_code_prefix)
);
