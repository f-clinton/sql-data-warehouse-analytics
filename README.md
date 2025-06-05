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

 **CreateDatabaseAndSchemas.sql**: builds (or rebuilds) the `DataWarehouseAnalytics` database and `gold` schema, then bulk-loads raw CSV data into staging tables.
- **ViewsAndReports.sql**: creates views such as `gold.report_of_customers` and `gold.report_of_products`.
- **ProductReport.sql**: contains additional product-level analytics (running totals, recency, segmentation).


