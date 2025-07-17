-- TASK 2.2 – Order-Level Profitability KPIs
-- Calculate total orders, total sales, cost, profit, and profit margin.
-- Includes average profit per order and per customer.

WITH OrderProfit AS (
  SELECT
    soh.SalesOrderID,
    soh.CustomerID,
    soh.TotalDue, 
    SUM(sod.OrderQty * p.StandardCost) AS TotalCost, 
    soh.TotalDue - SUM(sod.OrderQty * p.StandardCost) AS Profit  
  FROM
    `adwentureworks_db.salesorderheader` soh
  JOIN
    `adwentureworks_db.salesorderdetail` sod
    ON soh.SalesOrderID = sod.SalesOrderID
  JOIN
    `adwentureworks_db.product` p
    ON sod.ProductID = p.ProductID
  GROUP BY
    soh.SalesOrderID, soh.CustomerID, soh.TotalDue
),
FinalKPIs AS (
  SELECT
    COUNT(*) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    ROUND(SUM(TotalDue)) AS TotalSales,
    ROUND(SUM(TotalCost)) AS TotalCost,
    ROUND(SUM(Profit)) AS TotalProfit,
    ROUND(SAFE_DIVIDE(SUM(Profit), COUNT(*))) AS AvgProfitPerOrder,
    ROUND(SAFE_DIVIDE(SUM(Profit), COUNT(DISTINCT CustomerID))) AS AvgProfitPerCustomer,
    ROUND(SAFE_DIVIDE(SUM(Profit), SUM(TotalDue)), 2) AS AvgProfitMargin
  FROM OrderProfit
)
SELECT * FROM FinalKPIs;
