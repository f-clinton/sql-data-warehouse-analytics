# SQL Data Warehouse Analytics

**Description**  
This repository contains all the SQL scripts, solution files, and documentation needed to build, load, clean, and analyze a small data warehouse. The data warehouse’s focus is on three core entities—**Customers**, **Products**, and **Sales**—and includes:  
- Database/schema creation  
- Bulk-loading raw CSV files  
- Data cleaning and transformation  
- Analytical views (sales over time, top performers, recency, segments)  
- Sample queries for deeper analysis  


---

## Files & Folders

- <a href = "https://github.com/f-clinton/sql-data-warehouse-analytics/blob/main/SQLQuery2.sql">**CreateDatabaseAndSchemas.sql**</a>: builds (or rebuilds) the `DataWarehouseAnalytics` database and `gold` schema, then bulk-loads raw CSV data into staging tables.
- **Views And Reports**: creates views such as `gold.report_of_customers` and `gold.report_of_products`.
- <a href = "https://github.com/f-clinton/sql-data-warehouse-analytics/blob/main/productReport.sql">**ProductReport.sql**</a>: contains additional product-level analytics (running totals, recency, segmentation).
- <a href = "https://github.com/f-clinton/sql-data-warehouse-analytics/blob/main/customerReport.sql" >**CustomerReport.sql**</a>: contains additional product-level analytics (running totals, recency, segmentation).

---

## High-Level Workflow

1. **Create Database & Load Raw Data**  
   - Execute it to:  
     1. Drop (if it exists) and recreate the `DataWarehouseAnalytics` database.  
     2. Create the `gold` schema and raw staging tables (`dim_customers`, `dim_products`, `fact_sales`).  
     3. Bulk-load the raw CSV files into those staging tables.  

2. **Clean & Transform Data**   
     1. Deduplicate and trim text columns.  
     2. Convert text dates to proper `DATE` types.  
     3. Handle missing/NULL values and convert numeric columns.  
     4. Rename working tables into final production tables (`gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`).  

3. **Create Analytical Views**   
     - `gold.report_of_customers` – aggregates customer purchase behavior, total spend, order counts, and segment labels.  
     - `gold.report_of_products` – aggregates product sales, lifespan, recency, and performance segments.  

4. **Run Sample Analytics**  
   - Execute `productReport.sql` for deeper product-level insights (e.g., YoY comparisons, window functions, segment shifts).  
   - Execute `customerReport.sql` for customer-level metrics (e.g., lifetime value, recency/frequency, segment analysis).  

---

