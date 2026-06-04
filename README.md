# SaudiVibe Commerce: End-to-End E-Commerce & Logistics SQL Analytics Platform

## Business Case & Saudi Vision 2030 Alignment
In alignment with **Saudi Vision 2030**, specifically the **National Transport and Logistics Strategy (NTLS)** and the digital economy initiatives, **SaudiVibe Commerce** is an enterprise-grade analytics platform built to optimize e-commerce operations and supply chain performance within the Kingdom of Saudi Arabia (KSA). 

As the Kingdom rapidly shifts toward a cashless, hyper-connected digital economy, businesses face massive data scaling challenges. This project solves critical real-world operational friction points by providing data-driven visibility into:
* **Logistics Network Optimization:** Measuring fulfillment efficiency from global-facing hubs like King Abdullah Economic City (KAEC) to local distribution nodes.
* **Peak Season Scalability:** Analyzing and quantifying consumer purchasing velocity shifts during high-volume periods such as the Holy Month of Ramadan and Eid.
* **SLA Compliance Tracking:** Identifying regional bottleneck routes failing the domestic 3-day Service Level Agreement (SLA) delivery standards.

---

## Database Architecture
The analytical engine is built on **PostgreSQL**, structured using a highly normalized relational schema designed for optimal write consistency and analytical performance.

### Entity-Relationship (ER) Overview
 +---------------+         +---------------+         +---------------+
 |   CUSTOMERS   |         |    ORDERS     |         |   SHIPMENTS   |
 +---------------+         +---------------+         +---------------+
 | customer_id   |<---+    | order_id      |<---+    | shipment_id   |
 | first_name    |    |    | customer_id   |    +----| order_id      |
 | last_name     |    +---| total_amt_sar |         | warehouse_id  |---+
 | email (.sa)   |         | order_status  |         | tracking_num  |   |
 | phone (+9665) |         +---------------+         | delivery_dates|   |
 | city / region |                                   +---------------+   |
 +---------------+                                                       |
                                                                         |
 +---------------+                                   +---------------+   |
 |   PRODUCTS    |                                   |  WAREHOUSES   |   |
 +---------------+                                   +---------------+   |
 | product_id    |                                   | warehouse_id  |<--+
 | product_name  |                                   | warehouse_name|
 | category      |                                   | city          |
 | price_sar     |                                   | capacity_sqm  |
 +---------------+                                   +---------------+

Performance Optimization
To maximize query velocity across thousands of rows of data, targeted indexing strategies were deployed:

idx_customers_city_region: Multi-column composite index accelerating spatial marketing and distribution queries.

idx_orders_customer: Single-key foreign index facilitating high-speed customer transactional history joins.

idx_shipments_warehouse: Optimizes inventory routing queries by reducing table-scan overhead on complex join conditions.

Core Business Insights Discovered
1. Regional Product Performance
SQL Technique: Common Table Expressions (CTEs), Multi-Table Joins, and DENSE_RANK() Window Functions.

Executive Insight: Evaluates regional revenue velocity across product lines to identify localization opportunities.

Data-Driven Recommendation: If data flags high beauty category revenue in the Western Region (Jeddah/Makkah) versus electronics dominance in the Central Region (Riyadh), supply chain teams should re-allocate warehouse volumes accordingly to reduce long-haul transit costs.

2. Ramadan & Eid Seasonality Analysis
SQL Technique: Conditional Aggregation (CASE WHEN), Date Part Extraction (EXTRACT), and Window-based Trend Percentages.

Executive Insight: Quantifies the historical revenue and order volume spike during March and April to measure seasonal demand shifts.

Data-Driven Recommendation: Proactively scale warehouse staff by 40% and secure temporary last-mile fleet capacity 30 days prior to the Ramadan window to safeguard fulfillment times during the annual peak.

3. Logistics Efficiency & KSA Delivery SLA
SQL Technique: Date Arithmetic, Aggregations, Filter-based SLA Flagging, and HAVING clause filtering.

Executive Insight: Audits fulfillment latency by tracking the exact days elapsed between order processing and actual delivery against the 3-day national SLA target.

Data-Driven Recommendation: Transition lagging delivery routes exceeding the 3-day mark to regional partner couriers or establish a dedicated micro-fulfillment hub in underserved sectors (e.g., Northern or Southern provinces) to maintain compliance.

4. Customer Lifetime Value (RFM Segmentation)
SQL Technique: NTILE(3) Statistical Bucketing, Recency/Frequency Aggregate Math, and Conditional Segmentation.

Executive Insight: Automatically partitions the customer database into actionable cohorts (VIP, Regular, At Risk) based on purchasing value and transaction recurrence.

Data-Driven Recommendation: Launch automated, localized SMS retention campaigns tailored for "At Risk" high-value customers, while allocating personalized loyalty perks to the "VIP" cluster to maximize retention.

5. Warehouse Stock & Fulfillment Alert
SQL Technique: Cross-Join Analytical Subqueries, Safety Stock Ratio Analysis, and Demand Benchmarking.

Executive Insight: Implements predictive inventory safety checks by highlighting active warehouses where localized stock availability drops dangerously below historic volume trends.

Data-Driven Recommendation: Automate an instant Restock Trigger (EDI system) directly to manufacturers when stock-to-demand ratios drop below the 75% benchmark to entirely prevent stockouts on flagship items.

Tech Stack & Implementation Guide
The Stack
Database Engine: PostgreSQL (v14+)

Database Management Platform: pgAdmin 4

Data Synthesis Pipeline: Python 3.x (utilizing psycopg2 and Faker libraries)

Quick Start Installation
Clone the Repository:

Bash
git clone [https://github.com/yourusername/SaudiVibe-Commerce-Analytics.git](https://github.com/yourusername/SaudiVibe-Commerce-Analytics.git)
cd SaudiVibe-Commerce-Analytics
Initialize Database Schema:

Open pgAdmin 4 and create a new database named SaudiVibe_Commerce.

Open the Query Tool, copy the DDL commands from your schema script, and execute them to construct the 5-table schema.

Execute the Data Pipeline:

Install Python dependencies:

Bash
pip install psycopg2 faker
Update the DB_CONFIG dictionary block inside your Python script with your local PostgreSQL password.

Run the script to inject the records:

Bash
python SQL-DATASET.py
Run Analytics:

Open your SQL queries script, paste any of the 5 analytical scripts into pgAdmin, and run them to extract live strategic business intelligence.
