/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

/*
=============================================================
Drop 'gold' schema and contained objects if they already exist
=============================================================
We must drop any tables inside the 'gold' schema before dropping the schema itself.
*/

-- Drop fact_sales if it exists
IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL
    DROP TABLE gold.fact_sales;
GO

-- Drop dim_products if it exists
IF OBJECT_ID('gold.dim_products', 'U') IS NOT NULL
    DROP TABLE gold.dim_products;
GO

-- Drop dim_customers if it exists
IF OBJECT_ID('gold.dim_customers', 'U') IS NOT NULL
    DROP TABLE gold.dim_customers;
GO

-- Now that tables are dropped, drop the schema if it exists
IF EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'gold'
)
BEGIN
    DROP SCHEMA gold;
END;
GO

/*
=============================================================
Create the 'gold' schema
=============================================================
*/


-- Create Schemas

CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM "C:\Users\ntumf\OneDrive\Desktop\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.dim_customers.csv"
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM "C:\Users\ntumf\OneDrive\Desktop\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.dim_products.csv"
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM "C:\Users\ntumf\OneDrive\Desktop\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.fact_sales.csv"
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);

/*
----------------------------------------------------------------------------------
Data Analysis 
----------------------------------------------------------------------------------
*/

--- I. CHANGE OVER TIME

SELECT 
	YEAR(order_date) as order_year,
	MONTH(order_date) as order_month,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity

	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date), MONTH(order_date)
	ORDER BY YEAR(order_date), MONTH(order_date)


SELECT 
	FORMAT(order_date, 'yyy-MMM') as order_date,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity

	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY FORMAT(order_date, 'yyy-MMM')
	ORDER BY FORMAT(order_date, 'yyy-MMM')


--- II. CUMULATIVE ANALYSIS

-- Calc the total sales per month
-- Also, the running totals sales over time

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales
-- windows function
FROM
	(
	SELECT
		DATETRUNC(month, order_date) as order_date,
		SUM(sales_amount) as total_sales
		FROM gold.fact_sales
		WHERE order_date IS NOT NULL
		--GROUP BY FORMAT(order_date, 'yyyy-MMM-dd')
		GROUP BY DATETRUNC(month, order_date)

	)t

-- Another way is


SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average

-- windows function
FROM
	(
	SELECT
		DATETRUNC(YEAR, order_date) as order_date,
		SUM(sales_amount) as total_sales,
		AVG(price) as avg_price
		FROM gold.fact_sales
		WHERE order_date IS NOT NULL
		--GROUP BY FORMAT(order_date, 'yyyy-MMM-dd')
		GROUP BY DATETRUNC(YEAR, order_date)

	)t
;


-- III. PERFORMANCE ANALYSIS
-- a. Analysing yearly performance of poducts by comparing each product's sales to both its average performance and 
-- the previous year's sales

WITH yearly_product_sales AS 
(
	SELECT 
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
		FROM gold.fact_sales f
		LEFT JOIN gold.dim_products p
		ON f.product_key = p.product_key
		WHERE f.order_date IS NOT NULL
		GROUP BY
		YEAR(f.order_date),
		p.product_name
)

SELECT 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_a,
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'ABOVE Average'
		 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'BELOW Average'
		 Else 'Average'

	END avg_change,

	-- Year over year analysis
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
	CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		 Else 'No change'

	END py_change

	FROM yearly_product_sales
	ORDER BY product_name, order_year
;

-- IV. PART TO WHOLE ANALYSIS
-- Comparing an instrument to the rest to measure its performance compared to other instruments

-- Which categories contribute the most to overall sales?
WITH category_sales AS
(

	SELECT 
		category,
		SUM(sales_amount) AS total_sales
		FROM gold.fact_sales f
		LEFT JOIN gold.dim_products p
		ON p.product_key = f.product_key
		GROUP BY category
)

SELECT 
	category,
	total_sales,
	SUM(total_sales) OVER () overall_sales,
	CONCAT(ROUND( (CAST (total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
	FROM category_sales
	ORDER BY total_sales DESC
;


-- V. DATA SEGMENTATION
-- Grouping data based on a specific range to understand the correlation between measures 

WITH product_segments AS
(
	SELECT 
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		 ELSE 'Above 1000'
	END cost_range
	FROM gold.dim_products
)

SELECT
	cost_range,
	COUNT(product_key) AS total_products
	FROM product_segments
	GROUP BY cost_range
	ORDER BY total_products DESC
;

/* Grouping costomers into three segments based on their spending behavior:
	-VIP: Customers with atleast 12 months of history and spending more than €5000.
	-Regular: Customers with atleast  12 months of history but spending €5000 or less.
	-New: Customers with a lifespan less than 12 months.
Find the total number of customers by each group
*/

WITH customer_spending AS
(
	SELECT 
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,

		MIN(order_date) AS first_order,
		MAX(order_date) AS last_order,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
		FROM gold.fact_sales f
		LEFT JOIN gold.dim_customers c
		ON f.customer_key = c.customer_key
		GROUP BY c.customer_key

)

SELECT 
	customer_segment,
	COUNT(customer_key) AS total_customers

	FROM(
		SELECT
		customer_key,

		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New customer'
		END customer_segment

		FROM customer_spending
)t

GROUP BY customer_segment
ORDER BY total_customers
;

