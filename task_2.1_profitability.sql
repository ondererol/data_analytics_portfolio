--Task 2.1 PRODUCT PROFITABILITY ANALYSIS
-- Calculate total quantity sold, total sales, cost, profit and margin for each product.
-- Grouped by product, sub-category and category. Ordered by profit descending.


WITH
  ProductSales AS (
  SELECT
    p.ProductID,
    p.Name AS ProductName,
    psc.name AS sub_category_name,
    pc.name AS p_catagery_name,
    SUM(sod.OrderQty) AS TotalQuantitySold,
    ROUND (SUM(sod.OrderQty * sod.UnitPrice)) AS TotalSales,
    ROUND (SUM(sod.OrderQty * p.StandardCost)) AS TotalCost,
    ROUND (SUM(sod.OrderQty * sod.UnitPrice) - SUM(sod.OrderQty * p.StandardCost)) AS Profit,
    ROUND (SAFE_DIVIDE( SUM(sod.OrderQty * sod.UnitPrice) - SUM(sod.OrderQty * p.StandardCost), SUM(sod.OrderQty * sod.UnitPrice) ),2) AS ProfitMargin
  FROM
    `adwentureworks_db.salesorderdetail` sod
  JOIN
    `adwentureworks_db.product` p
  ON
    sod.ProductID = p.ProductID
  JOIN
    `adwentureworks_db.productsubcategory` psc
  ON
    p.ProductSubcategoryID=psc.ProductSubcategoryID
  JOIN
    `adwentureworks_db.productcategory` pc
  ON
    pc.ProductCategoryID = psc.ProductCategoryID
  GROUP BY
    p.ProductID,
    p.Name,
    psc.Name,
    pc.Name )
SELECT
  *
FROM
  ProductSales
ORDER BY
  Profit DESC;