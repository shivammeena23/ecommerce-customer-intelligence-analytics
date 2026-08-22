USE ecommerce_analytics;

-- =========================================================
-- OLIST E-COMMERCE ANALYTICS PROJECT
-- FINAL SQL ANALYSIS
-- =========================================================

-- =========================================================
-- FOUNDATIONAL VIEW 1
-- ONE ROW PER ORDER
-- =========================================================

CREATE OR REPLACE VIEW vw_order_sales AS

SELECT
    order_id,

    ROUND(SUM(price), 2) AS product_revenue,

    ROUND(SUM(freight_value), 2) AS freight_value,

    ROUND(SUM(price + freight_value), 2) AS total_order_value,

    COUNT(*) AS items_count

FROM order_items

GROUP BY order_id;


-- =========================================================
-- FOUNDATIONAL VIEW 2
-- ORDER + DELIVERY INFORMATION
-- =========================================================

CREATE OR REPLACE VIEW vw_order_delivery AS

SELECT
    order_id,
    customer_id,
    order_status,

    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    ) AS delivery_days,

    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'

        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date
            THEN 'On Time'

        ELSE 'Late'
    END AS delivery_status

FROM orders;

-- =========================================================
-- FOUNDATIONAL VIEW 3
-- CUSTOMER + ORDER INFORMATION
-- =========================================================

CREATE OR REPLACE VIEW vw_customer_orders AS

SELECT
    o.order_id,

    c.customer_unique_id,
    c.customer_state,
    c.customer_city,

    o.order_status,
    o.order_purchase_timestamp

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id;
    
    
-- =========================================================
-- Q1. OVERALL BUSINESS KPIs
-- =========================================================

SELECT

    ROUND(
        SUM(os.product_revenue),
        2
    ) AS total_revenue,

    ROUND(
        SUM(os.freight_value),
        2
    ) AS total_freight,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(os.product_revenue) / COUNT(*),
        2
    ) AS average_order_value,

    (
        SELECT COUNT(DISTINCT customer_unique_id)
        FROM customers
    ) AS total_customers,

    (
        SELECT COUNT(DISTINCT product_id)
        FROM products
    ) AS total_products,

    (
        SELECT COUNT(DISTINCT seller_id)
        FROM sellers
    ) AS total_sellers,

    (
        SELECT ROUND(AVG(review_score), 2)
        FROM reviews
    ) AS average_review_score

FROM vw_order_sales os

JOIN orders o
    ON os.order_id = o.order_id

WHERE o.order_status = 'delivered';

-- =========================================================
-- Q2. MONTHLY SALES TREND
-- =========================================================

WITH monthly_sales AS (

    SELECT

        YEAR(o.order_purchase_timestamp) AS order_year,

        MONTH(o.order_purchase_timestamp) AS order_month,

        SUM(oi.price) AS revenue,

        COUNT(DISTINCT o.order_id) AS orders

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
),

sales_with_previous AS (

    SELECT

        order_year,
        order_month,
        revenue,
        orders,

        LAG(revenue) OVER (
            ORDER BY order_year, order_month
        ) AS previous_month_revenue

    FROM monthly_sales
)

SELECT

    order_year,

    order_month,

    ROUND(revenue, 2) AS revenue,

    orders,

    ROUND(
        revenue / orders,
        2
    ) AS average_order_value,

    ROUND(
        100.0 *
        (revenue - previous_month_revenue)
        /
        NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_revenue_growth_pct

FROM sales_with_previous

ORDER BY
    order_year,
    order_month;
    
    
-- =========================================================
-- Q3A. CATEGORY SALES PERFORMANCE
-- =========================================================

SELECT

    COALESCE(
        p.product_category_name,
        'Unknown'
    ) AS product_category,

    COUNT(DISTINCT oi.product_id) AS products,

    COUNT(DISTINCT oi.order_id) AS orders,

    COUNT(*) AS items_sold,

    ROUND(SUM(oi.price), 2) AS revenue,

    ROUND(
        100.0 * SUM(oi.price)
        /
        SUM(SUM(oi.price)) OVER (),
        2
    ) AS revenue_contribution_pct

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'delivered'

GROUP BY
    p.product_category_name

ORDER BY revenue DESC;


-- =========================================================
-- Q3B. TOP PRODUCTS
-- =========================================================

SELECT

    oi.product_id,

    COALESCE(
        p.product_category_name,
        'Unknown'
    ) AS product_category,

    COUNT(*) AS items_sold,

    COUNT(DISTINCT oi.order_id) AS orders,

    ROUND(SUM(oi.price), 2) AS revenue

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'delivered'

GROUP BY
    oi.product_id,
    p.product_category_name

ORDER BY revenue DESC

LIMIT 20;

-- =========================================================
-- Q4. CUSTOMER GEOGRAPHY
-- =========================================================

SELECT

    c.customer_state,

    COUNT(DISTINCT c.customer_unique_id) AS customers,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        SUM(oi.price),
        2
    ) AS revenue

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY
    c.customer_state

ORDER BY customers DESC;


-- =========================================================
-- CUSTOMER RETENTION ANALYSIS
-- =========================================================

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,

        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS order_number

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    WHERE o.order_status = 'delivered'
),

customer_summary AS (

    SELECT
        customer_unique_id,

        COUNT(*) AS total_orders,

        MIN(order_purchase_timestamp) AS first_order_date,

        MAX(order_purchase_timestamp) AS last_order_date

    FROM customer_orders

    GROUP BY customer_unique_id
)

SELECT

    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN total_orders = 1 THEN 1
            ELSE 0
        END
    ) AS one_time_customers,

    SUM(
        CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS repeat_customer_rate_pct,

    ROUND(
        AVG(total_orders),
        2
    ) AS average_orders_per_customer

FROM customer_summary;

-- =========================================================
-- CUSTOMER REPEAT PURCHASE TIMING
-- =========================================================

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,
        o.order_purchase_timestamp,

        LAG(o.order_purchase_timestamp) OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS previous_order_date

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    WHERE o.order_status = 'delivered'
)

SELECT

    COUNT(*) AS repeat_orders,

    ROUND(
        AVG(
            DATEDIFF(
                order_purchase_timestamp,
                previous_order_date
            )
        ),
        2
    ) AS average_days_between_orders,

    ROUND(
        MIN(
            DATEDIFF(
                order_purchase_timestamp,
                previous_order_date
            )
        ),
        2
    ) AS minimum_days_between_orders,

    ROUND(
        MAX(
            DATEDIFF(
                order_purchase_timestamp,
                previous_order_date
            )
        ),
        2
    ) AS maximum_days_between_orders

FROM customer_orders

WHERE previous_order_date IS NOT NULL;

-- =========================================================
-- FIRST PURCHASE MONTH FOR EACH CUSTOMER
-- =========================================================

SELECT
    c.customer_unique_id,

    MIN(o.order_purchase_timestamp) AS first_purchase_date,

    YEAR(
        MIN(o.order_purchase_timestamp)
    ) AS first_purchase_year,

    MONTH(
        MIN(o.order_purchase_timestamp)
    ) AS first_purchase_month

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

WHERE o.order_status = 'delivered'

GROUP BY
    c.customer_unique_id

ORDER BY
    first_purchase_date;

-- =========================================================
-- Q6. HIGH-VALUE CUSTOMERS
-- =========================================================

SELECT

    c.customer_unique_id,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        SUM(oi.price),
        2
    ) AS total_revenue

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY
    c.customer_unique_id

ORDER BY total_revenue DESC

LIMIT 20;


-- =========================================================
-- Q7. SELLER PERFORMANCE
-- =========================================================

SELECT

    oi.seller_id,

    s.seller_state,

    COUNT(DISTINCT oi.order_id) AS orders,

    COUNT(*) AS items_sold,

    ROUND(
        SUM(oi.price),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.price)
        /
        COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN sellers s
    ON oi.seller_id = s.seller_id

WHERE o.order_status = 'delivered'

GROUP BY
    oi.seller_id,
    s.seller_state

ORDER BY revenue DESC

LIMIT 20;


-- =========================================================
-- Q8. SELLER REVENUE CONCENTRATION
-- =========================================================

WITH seller_revenue AS (

    SELECT

        oi.seller_id,

        SUM(oi.price) AS revenue

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        oi.seller_id
),

ranked_sellers AS (

    SELECT

        seller_id,

        revenue,

        NTILE(10) OVER (
            ORDER BY revenue DESC
        ) AS seller_decile

    FROM seller_revenue
)

SELECT

    ROUND(
        SUM(
            CASE
                WHEN seller_decile = 1
                    THEN revenue
                ELSE 0
            END
        ),
        2
    ) AS top_10_percent_revenue,

    ROUND(
        SUM(revenue),
        2
    ) AS total_revenue,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN seller_decile = 1
                    THEN revenue
                ELSE 0
            END
        )
        /
        SUM(revenue),
        2
    ) AS top_10_percent_revenue_share

FROM ranked_sellers;


-- =========================================================
-- Q9. OVERALL DELIVERY PERFORMANCE
-- =========================================================

SELECT

    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(delivery_days),
        2
    ) AS average_delivery_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN delivery_status = 'On Time'
                    THEN 1
                ELSE 0
            END
        )
        /
        COUNT(*),
        2
    ) AS on_time_rate,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN delivery_status = 'Late'
                    THEN 1
                ELSE 0
            END
        )
        /
        COUNT(*),
        2
    ) AS late_delivery_rate,

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_estimated_delivery_date
            )
        ),
        2
    ) AS average_delay_days

FROM vw_order_delivery

WHERE order_status = 'delivered'

  AND order_delivered_customer_date IS NOT NULL

  AND order_estimated_delivery_date IS NOT NULL;
  
  
-- =========================================================
-- Q10. LOGISTICS PERFORMANCE BY STATE
-- =========================================================

SELECT

    c.customer_state,

    COUNT(DISTINCT o.order_id) AS delivered_orders,

    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.order_delivered_customer_date
                     > o.order_estimated_delivery_date
                    THEN 1
                ELSE 0
            END
        )
        /
        COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_rate

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'

  AND o.order_delivered_customer_date IS NOT NULL

  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    c.customer_state

HAVING COUNT(DISTINCT o.order_id) >= 50

ORDER BY
    late_delivery_rate DESC;
    
-- =========================================================
-- Q10B. SELLERS WITH DELIVERY PROBLEMS
-- =========================================================

SELECT

    oi.seller_id,

    COUNT(DISTINCT o.order_id) AS delivered_orders,

    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.order_delivered_customer_date
                     > o.order_estimated_delivery_date
                    THEN 1
                ELSE 0
            END
        )
        /
        COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_rate

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered'

  AND o.order_delivered_customer_date IS NOT NULL

  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    oi.seller_id

HAVING COUNT(DISTINCT o.order_id) >= 20

ORDER BY
    late_delivery_rate DESC;
    

-- =========================================================
-- Q11. MONTHLY DELIVERY PERFORMANCE
-- =========================================================

SELECT

    YEAR(order_purchase_timestamp) AS order_year,

    MONTH(order_purchase_timestamp) AS order_month,

    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN order_delivered_customer_date
                     > order_estimated_delivery_date
                    THEN 1
                ELSE 0
            END
        )
        /
        COUNT(*),
        2
    ) AS late_delivery_rate

FROM orders

WHERE order_status = 'delivered'

  AND order_delivered_customer_date IS NOT NULL

  AND order_estimated_delivery_date IS NOT NULL

GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)

ORDER BY
    order_year,
    order_month;
    

-- =========================================================
-- Q12. PAYMENT METHOD ANALYSIS
-- =========================================================

SELECT

    p.payment_type,

    COUNT(DISTINCT p.order_id) AS orders,

    ROUND(
        SUM(p.payment_value),
        2
    ) AS total_payment_value,

    ROUND(
        AVG(p.payment_value),
        2
    ) AS average_payment_value,

    ROUND(
        AVG(p.payment_installments),
        2
    ) AS average_installments

FROM payments p

GROUP BY
    p.payment_type

ORDER BY
    total_payment_value DESC;
    

-- =========================================================
-- Q13A. CUSTOMER SATISFACTION SUMMARY
-- =========================================================

SELECT

    ROUND(
        AVG(review_score),
        2
    ) AS average_review_score,

    COUNT(*) AS total_reviews

FROM reviews;

-- =========================================================
-- Q13B. REVIEW SCORE DISTRIBUTION
-- =========================================================

SELECT

    review_score,

    COUNT(*) AS reviews,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS review_percentage

FROM reviews

GROUP BY
    review_score

ORDER BY
    review_score;
    
-- =========================================================
-- Q14. DELIVERY PERFORMANCE VS CUSTOMER SATISFACTION
-- =========================================================

SELECT

    od.delivery_status,

    COUNT(DISTINCT od.order_id) AS orders,

    COUNT(r.review_id) AS reviews,

    ROUND(
        AVG(r.review_score),
        2
    ) AS average_review_score

FROM vw_order_delivery od

JOIN reviews r
    ON od.order_id = r.order_id

WHERE od.order_status = 'delivered'

  AND od.delivery_status IN ('On Time', 'Late')

GROUP BY
    od.delivery_status

ORDER BY
    average_review_score DESC;
    

-- =========================================================
-- Q15A. OVERALL FREIGHT IMPACT
-- =========================================================

SELECT

    ROUND(
        SUM(price),
        2
    ) AS product_value,

    ROUND(
        SUM(freight_value),
        2
    ) AS total_freight,

    ROUND(
        AVG(freight_value),
        2
    ) AS average_freight_per_item,

    ROUND(
        100.0 *
        SUM(freight_value)
        /
        NULLIF(SUM(price), 0),
        2
    ) AS freight_percentage

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered';


-- =========================================================
-- Q15B. FREIGHT BY CATEGORY
-- =========================================================

SELECT

    COALESCE(
        p.product_category_name,
        'Unknown'
    ) AS product_category,

    ROUND(
        SUM(oi.price),
        2
    ) AS product_revenue,

    ROUND(
        SUM(oi.freight_value),
        2
    ) AS freight_value,

    ROUND(
        100.0 *
        SUM(oi.freight_value)
        /
        NULLIF(SUM(oi.price), 0),
        2
    ) AS freight_percentage

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'delivered'

GROUP BY
    p.product_category_name

ORDER BY
    freight_percentage DESC;