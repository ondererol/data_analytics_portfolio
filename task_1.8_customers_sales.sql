-- TASK 1.8
-- Add country-level tax metrics to the sales ranking report:
-- - mean_tax_rate: average of the highest tax rate per province (no duplicates)
-- - perc_provinces_w_tax: percentage of provinces with available tax data per country


WITH
  table_sales AS (
  SELECT
    LAST_DAY(DATE(sales_orders_header.OrderDate)) AS order_month,
    territory.CountryRegionCode AS country_region_code,
    territory.Name AS region,
    COUNT(SalesOrderID) AS number_orders,
    COUNT(DISTINCT CustomerID) AS number_customers,
    COUNT(DISTINCT SalesPersonID) AS number_sales_persons,
    CAST(SUM(TotalDue) AS INT) AS Total_with_tax,
  FROM
    `adwentureworks_db.salesorderheader` AS sales_orders_header
  JOIN
    `adwentureworks_db.salesterritory` AS territory
  ON
    sales_orders_header.TerritoryID = territory.TerritoryID
  GROUP BY
    country_region_code,
    region,
    order_month),
  tax_rate_per_country AS (
  SELECT
    state_province.CountryRegionCode AS country_region_code,
    ROUND (AVG (TaxRate), 1) AS mean_tax_rate,
    ROUND (COUNT (DISTINCT sales_tax_rate.StateProvinceID) / COUNT (DISTINCT state_province.StateProvinceID), 2) AS perc_provinces_with_tax
  FROM
    `adwentureworks_db.stateprovince` AS state_province
  LEFT JOIN
    `adwentureworks_db.salestaxrate` sales_tax_rate
  ON
    state_province.StateProvinceID = sales_tax_rate.StateProvinceID
  GROUP BY
    state_province.CountryRegionCode )
SELECT
  order_month,
  table_sales.country_region_code,
  table_sales.region AS region,
  number_orders,
  number_customers,
  number_sales_persons,
  Total_with_tax,
  RANK() OVER (PARTITION BY Region ORDER BY Total_with_tax DESC) AS country_sales_rank,
  SUM(total_with_tax) OVER(PARTITION BY table_sales.country_region_code, Region ORDER BY order_month) AS cumulative_sum,
  mean_tax_rate,
  perc_provinces_with_tax
FROM
  table_sales
JOIN
  tax_rate_per_country
ON
  table_sales.country_region_code = tax_rate_per_country.country_region_code
WHERE
  table_sales.country_region_code = 'US'
ORDER BY
  country_region_code,
  region DESC,
  country_sales_rank;