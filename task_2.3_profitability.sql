-- TASK 2.3 – Product-Level Profitability (Production Cost-Based)
-- Calculate net profit and profit margin per product using production costs (ActualCost).
-- Combines sales data with manufacturing cost data from work orders.


WITH SalesData AS (
    SELECT
        sod.ProductID,
        SUM(sod.OrderQty * sod.UnitPrice) AS TotalSales
    FROM `adwentureworks_db.salesorderdetail` sod
    GROUP BY sod.ProductID
),
ProductionCost AS (
    SELECT
        wo.ProductID,
        SUM(wo.ActualCost) AS TotalActualCost
    FROM `adwentureworks_db.workorderrouting` wo
    GROUP BY wo.ProductID
)
SELECT
    s.ProductID,
    p.Name AS ProductName,
    s.TotalSales,
    pc.TotalActualCost,
    s.TotalSales - pc.TotalActualCost AS NetProfit,
    SAFE_DIVIDE(s.TotalSales - pc.TotalActualCost, s.TotalSales) AS NetProfitMargin
FROM SalesData s
JOIN `adwentureworks_db.product` p ON s.ProductID = p.ProductID
LEFT JOIN ProductionCost pc ON s.ProductID = pc.ProductID
ORDER BY NetProfit DESC;
