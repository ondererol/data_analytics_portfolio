-- TASK 1.7
-- Add a sales_rank column to rank regions by total amount (with tax) earned per country and month.
-- Rank 1 = highest-earning region for each country-month.

WITH
  table_sales AS (
  SELECT
    LAST_DAY(DATE(DATE_TRUNC(OrderDate, MONTH)), MONTH) AS order_month,
    CountryRegionCode AS country_region_code,
    Name AS region,
    COUNT(*) AS number_orders,
    COUNT(DISTINCT CustomerID) AS number_customers,
    COUNT(DISTINCT SalesPersonID) AS no_sales_persons,
    CAST(SUM(TotalDue) AS INT64) AS total_with_tax
  FROM
    `adwentureworks_db.salesorderheader` AS sales_order
  JOIN
    `adwentureworks_db.salesterritory` AS territory
  ON
    sales_order.TerritoryID = territory.TerritoryID
  GROUP BY
    country_region_code,
    region,
    order_month )
SELECT
  *,
  RANK() OVER(PARTITION BY table_sales.country_region_code ORDER BY table_sales.total_with_tax DESC) AS sales_rank,
  SUM(total_with_tax) OVER(PARTITION BY table_sales.country_region_code, table_sales.region ORDER BY order_month) AS cumulative_sum
FROM
  table_sales
WHERE
  table_sales.country_region_code = 'FR'
ORDER BY
  country_region_code,
  region,
  sales_rank;