1. Overall performance (exclude cancelled orders)
SELECT
    COUNT(*) AS valid_orders,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(AVG(net_revenue), 2) AS average_order_value,
    ROUND(100.0 * SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END)
          / COUNT(*), 2) AS return_rate_pct
FROM orders
WHERE order_status <> 'Cancelled';

-- 2. Monthly revenue trend
SELECT
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(net_revenue), 2) AS revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY 1
ORDER BY 1;

-- 3. Category performance and return rate
SELECT
    category,
    COUNT(*) AS order_count,
    ROUND(SUM(net_revenue), 2) AS revenue,
    ROUND(100.0 * AVG(CASE WHEN order_status = 'Returned' THEN 1.0 ELSE 0.0 END), 2)
        AS return_rate_pct
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY category
ORDER BY revenue DESC;

-- 4. Repeat-purchase rate
WITH customer_orders AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS order_count
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS active_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(100.0 * SUM(CASE WHEN order_count > 1 THEN 1.0 ELSE 0.0 END)
          / COUNT(*), 2) AS repeat_customer_rate_pct
FROM customer_orders;

-- 5. Channel performance
SELECT
    acquisition_channel,
    COUNT(*) AS orders,
    ROUND(SUM(net_revenue), 2) AS revenue,
    ROUND(AVG(net_revenue), 2) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY acquisition_channel
ORDER BY revenue DESC;

-- 6. High-return category x acquisition channel combinations
SELECT
    category,
    acquisition_channel,
    COUNT(*) AS orders,
    ROUND(100.0 * AVG(CASE WHEN order_status = 'Returned' THEN 1.0 ELSE 0.0 END), 2)
        AS return_rate_pct
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY category, acquisition_channel
HAVING COUNT(*) >= 20
ORDER BY return_rate_pct DESC;
