**Data Pipeline for Customer, Product, Orders and Order_Items Data Processing using Delta Lake & PySpark**
## **Project Overview**
This project implements an **ETL pipeline** using **PySpark** and **Databricks** to process customer, product, orders and order_items. The pipeline reads streaming data from **AWS (S3)**, processes it in multiple stages (**Bronze, Silver, and Gold layers**), and stores the transformed data into Delta tables for further analytics.

## **Architecture**
The project follows a **Medallion Architecture (Bronze, Silver, Gold)**:
1. **Bronze Layer (Raw Data)**
   - Ingests raw customer, product, orders and order_items.
   - Stores data in a **Delta table** without transformations.
   - Each batch is assigned a unique `batch_id` and ingestion timestamp.

2. **Silver Layer (Cleansed & Transformed Data)**
   - Cleans and normalizes data (e.g., date formatting, phone number standardization).
   - Removes duplicates and applies data transformations.
   - Handles **Slowly Changing Dimensions Type 2 (SCD2)** for historical tracking.
   - Stores the transformed data in a Silver Delta table.

3. **Gold Layer (Aggregated & Analytical Data)**
   - Creates **dimensional models** (fact and dimension tables).
   - Implements **SCD Type 2** in dimension tables for tracking historical changes.
   - Provides clean, analytics-ready data.

---

## **Technologies Used**
- **PySpark** (Structured Streaming for real-time processing)
- **AWS** (Cloud storage and compute)
- **Databricks** (Managed Spark environment)
- **Python / PySpark** (Data processing)

