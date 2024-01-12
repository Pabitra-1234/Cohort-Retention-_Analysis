select * from retail

---Cleaning Data

---Total Records = 541909
---135080 Records have no customerID
---406829 Records have customerID

	  
WITH online_retail AS (
    SELECT InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country
    FROM retail
    WHERE CustomerID IS NOT NULL
    AND Quantity > 0
    AND UnitPrice > 0
),
dup_check AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY InvoiceNo, StockCode, Quantity ORDER BY InvoiceDate) AS dup_flag
    FROM online_retail)
select *
into online_retail_main
from dup_check
where dup_flag = 1	


----Clean Data


----BEGIN COHORT ANALYSIS
select * from #online_retail_main

--Unique Identifier (CustomerID)
--Initial Start Date (First Invoice Date)
--Revenue Data
WITH cte_first_purchases AS (
    SELECT CustomerID, MIN(InvoiceDate) AS first_purchase_date
    FROM online_retail_main
    GROUP BY CustomerID
)
SELECT 
    CustomerID,
    first_purchase_date,
    DATE_TRUNC('month', first_purchase_date) AS Cohort_Date  -- Use DATE_TRUNC for month extraction
INTO cohort
FROM cte_first_purchases;

select * from cohort

-------------------- Create Cohort Index(Integer representation of  no.of months passed since the cx first purchage)---------------------------------------------------------
select * from online_retail_main

SELECT
    m.*,
    c.Cohort_Date,
    EXTRACT(YEAR FROM m.InvoiceDate) AS invoice_year,
    EXTRACT(MONTH FROM m.InvoiceDate) AS invoice_month,
    EXTRACT(YEAR FROM c.Cohort_Date) AS cohort_year,
    EXTRACT(MONTH FROM c.Cohort_Date) AS cohort_month,
    (EXTRACT(YEAR FROM m.InvoiceDate) - EXTRACT(YEAR FROM c.Cohort_Date)) AS year_diff,
    (EXTRACT(MONTH FROM m.InvoiceDate) - EXTRACT(MONTH FROM c.Cohort_Date)) AS month_diff,
    (EXTRACT(YEAR FROM m.InvoiceDate) - EXTRACT(YEAR FROM c.Cohort_Date)) * 12 +
    (EXTRACT(MONTH FROM m.InvoiceDate) - EXTRACT(MONTH FROM c.Cohort_Date)) + 1 AS cohort_index
INTO cohort_retention
FROM online_retail_main m
LEFT JOIN cohort c ON m.CustomerID = c.CustomerID;

---Analyse------

select distinct customerid,cohort_date,cohort_index 
from cohort_retention
	    
-- Pivot Data to see the cohort table	  

-- Pivot Data to see the cohort table

WITH distinct_customers AS (
    SELECT DISTINCT CustomerID, Cohort_Date, cohort_index
    FROM cohort_retention
)

SELECT 
    Cohort_Date,
    COUNT(CASE WHEN cohort_index = 1 THEN CustomerID END) AS "Cohort 1",
    COUNT(CASE WHEN cohort_index = 2 THEN CustomerID END) AS "Cohort 2",
    COUNT(CASE WHEN cohort_index = 3 THEN CustomerID END) AS "Cohort 3",
    COUNT(CASE WHEN cohort_index = 4 THEN CustomerID END) AS "Cohort 4",
	COUNT(CASE WHEN cohort_index = 5 THEN CustomerID END) AS "Cohort 5",
	COUNT(CASE WHEN cohort_index = 6 THEN CustomerID END) AS "Cohort 6",
	COUNT(CASE WHEN cohort_index = 7 THEN CustomerID END) AS "Cohort 7",
	COUNT(CASE WHEN cohort_index = 8 THEN CustomerID END) AS "Cohort 8",
	COUNT(CASE WHEN cohort_index = 9 THEN CustomerID END) AS "Cohort 9",
	COUNT(CASE WHEN cohort_index = 10 THEN CustomerID END) AS "Cohort 10",
	COUNT(CASE WHEN cohort_index = 11 THEN CustomerID END) AS "Cohort 11",
	COUNT(CASE WHEN cohort_index = 12 THEN CustomerID END) AS "Cohort 12",
	COUNT(CASE WHEN cohort_index = 13 THEN CustomerID END) AS "Cohort 13"
INTO cohort_pivot
FROM distinct_customers
GROUP BY Cohort_Date

select * from cohort_pivot	  
order by cohort_date	  
	  
	  

	  
	  
	  
	  
	  
	  
	  
