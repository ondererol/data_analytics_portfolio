-- TASK 1.5
-- Report monthly sales by country and region, including order count, unique customers, salespersons, and total amount.
-- Include all customer types.

SELECT
  LAST_DAY(DATE(sales_orders_header.OrderDate)) AS order_month,
  territory.CountryRegionCode AS country_region_code,
  territory.Name AS region,
  COUNT(*) AS number_orders,
  COUNT(DISTINCT sales_orders_header.CustomerID) AS number_customers,
  COUNT(DISTINCT SalesPersonID) AS no_sales_persons,
  CAST(SUM(TotalDue) AS INT) AS total_with_tax
FROM
  `adwentureworks_db.salesorderheader` AS sales_orders_header
JOIN
  `adwentureworks_db.salesterritory` AS territory
ON
  sales_orders_header.TerritoryID = territory.TerritoryID
GROUP BY
  country_region_code,
  region,
  order_month;