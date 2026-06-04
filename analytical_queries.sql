-- ====================================================================
-- PROJECT: SaudiVibe Commerce Analytics Platform
-- DESCR: Core Executive Insights Engine (PostgreSQL)
-- ====================================================================

-- 1. REGIONAL PRODUCT PERFORMANCE (MARKET PENETRATION)
-- Ranks product categories by total SAR revenue within each Saudi Region using DENSE_RANK().
WITH RegionalRevenue AS (
    SELECT 
        c.region AS saudi_region,
        p.category AS product_category,
        SUM(o.total_amount_sar) AS total_revenue_sar,
        COUNT(o.order_id) AS total_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN shipments s ON o.order_id = s.order_id
    JOIN products p ON p.product_id = (
        SELECT p2.product_id FROM products p2 
        WHERE o.total_amount_sar >= p2.price_sar LIMIT 1
    )
    GROUP BY c.region, p.category
)
SELECT 
    saudi_region,
    product_category,
    ROUND(total_revenue_sar, 2) AS total_revenue_sar,
    total_orders,
    DENSE_RANK() OVER(PARTITION BY saudi_region ORDER BY total_revenue_sar DESC) AS regional_rank
FROM RegionalRevenue;


-- 2. RAMADAN & EID SEASONALITY ANALYSIS (PEAK DEMAND FORECASTING)
-- Compares sales metrics during the Ramadan/Eid peak season vs the rest of the year.
WITH SeasonalMetrics AS (
    SELECT 
        CASE 
            WHEN EXTRACT(MONTH FROM order_date) IN (3, 4) THEN 'Ramadan/Eid Peak (Mar-Apr)'
            ELSE 'Rest of the Year'
        END AS season_period,
        COUNT(order_id) AS order_count,
        SUM(total_amount_sar) AS gross_sales_sar,
        AVG(total_amount_sar) AS average_order_value_sar
    FROM orders
    GROUP BY 1
)
SELECT 
    season_period,
    order_count,
    ROUND(gross_sales_sar, 2) AS gross_sales_sar,
    ROUND(average_order_value_sar, 2) AS average_order_value_sar,
    ROUND((gross_sales_sar / SUM(gross_sales_sar) OVER()) * 100, 2) AS sales_contribution_percentage
FROM SeasonalMetrics;


-- 3. LOGISTICS EFFICIENCY & KSA DELIVERY SLA (SUPPLY CHAIN HEALTH)
-- Tracks delivery performance against the national 3-day SLA target from regional hubs.
SELECT 
    w.warehouse_name,
    c.city AS destination_city,
    c.region AS destination_region,
    COUNT(s.shipment_id) AS total_shipments,
    ROUND(AVG(s.actual_delivery - s.estimated_delivery + 3), 1) AS avg_transit_days,
    COUNT(CASE WHEN (s.actual_delivery - s.estimated_delivery + 3) > 3 THEN 1 END) AS sla_violations_count,
    ROUND((COUNT(CASE WHEN (s.actual_delivery - s.estimated_delivery + 3) > 3 THEN 1 END)::NUMERIC / COUNT(s.shipment_id)) * 100, 2) AS sla_violation_rate_pct
FROM shipments s
JOIN orders o ON s.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN warehouses w ON s.warehouse_id = w.warehouse_id
WHERE s.shipment_status IN ('Delivered', 'Delayed')
GROUP BY w.warehouse_name, c.city, c.region
HAVING AVG(s.actual_delivery - s.estimated_delivery + 3) > 3
ORDER BY avg_transit_days DESC;


-- 4. CUSTOMER LIFETIME VALUE (RFM SEGMENTATION)
-- Profiles customer accounts into strategic commercial cohorts based on RFM behavior metrics.
WITH CustomerRFM AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_order_date,
        COUNT(order_id) AS frequency,
        SUM(total_amount_sar) AS monetary
    FROM orders
    GROUP BY customer_id
),
RFM_Scores AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.email,
        monetary AS lifetime_value_sar,
        frequency,
        NTILE(3) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(3) OVER (ORDER BY monetary DESC) AS m_score
    FROM CustomerRFM r
    JOIN customers c ON r.customer_id = c.customer_id
)
SELECT 
    customer_id,
    customer_name,
    email,
    ROUND(lifetime_value_sar, 2) AS lifetime_value_sar,
    frequency,
    CASE 
        WHEN f_score = 1 AND m_score = 1 THEN 'VIP Customer'
        WHEN f_score = 3 OR m_score = 3 THEN 'At Risk / Low Value'
        ELSE 'Regular Customer'
    END AS customer_segment
FROM RFM_Scores
ORDER BY lifetime_value_sar DESC;


-- 5. WAREHOUSE STOCK & FULFILLMENT ALERT (DEMAND BENCHMARKING)
-- Triggers inventory reorder safety flags using dynamic warehouse demand baseline tracking.
WITH WarehouseDemand AS (
    SELECT 
        s.warehouse_id,
        p.product_name,
        p.stock_quantity AS current_stock,
        COUNT(o.order_id) AS total_warehouse_orders
    FROM orders o
    JOIN shipments s ON o.order_id = s.order_id
    CROSS JOIN products p
    GROUP BY s.warehouse_id, p.product_name, p.stock_quantity
),
FulfillmentAlerts AS (
    SELECT 
        warehouse_id,
        product_name,
        current_stock,
        total_warehouse_orders,
        ROUND(total_warehouse_orders / 12.0, 0) AS benchmark_demand
    FROM WarehouseDemand
)
SELECT 
    w.warehouse_name,
    fa.product_name,
    fa.current_stock,
    fa.benchmark_demand AS historical_demand_benchmark,
    ROUND((fa.current_stock::NUMERIC / fa.benchmark_demand), 2) AS stock_to_demand_ratio,
    'CRITICAL REORDER ALERT' AS operational_status
FROM FulfillmentAlerts fa
JOIN warehouses w ON fa.warehouse_id = w.warehouse_id
WHERE w.is_active = TRUE 
  AND fa.current_stock < (fa.benchmark_demand * 0.75)
ORDER BY stock_to_demand_ratio ASC;
