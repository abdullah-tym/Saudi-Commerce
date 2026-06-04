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
```text
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
