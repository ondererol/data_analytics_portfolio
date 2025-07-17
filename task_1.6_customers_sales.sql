-- TASK 1.6
-- Add a cumulative sum of total amount (with tax) earned per country and region to the monthly sales report.
-- Build on Task 2.1 using a CTE or subquery.

WITH
  table_sales AS (
  SELECT
    LAST_DAY(DATE(sales_order.OrderDate)) AS order_month,
    territory.CountryRegionCode AS country_region_code,
    territory.Name AS region,
    COUNT(*) AS number_orders,
    COUNT(DISTINCT CustomerID) AS number_customers,
    COUNT(DISTINCT SalesPersonID) AS no_sales_persons,
    CAST(SUM(TotalDue) AS INT) AS total_with_tax
  FROM
    `adwentureworks_db.salesorderheader` AS sales_order
  JOIN
    `adwentureworks_db.salesterritory` AS territory
  ON
    sales_order.TerritoryID = territory.TerritoryID
  GROUP BY
    country_region_code,
    region,
    order_month)
SELECT
  *,
  SUM(Total_with_tax) OVER(PARTITION BY table_sales.country_region_code, Region ORDER BY order_month) AS cumulative_sum
FROM
  table_sales;