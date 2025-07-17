-- TASK 5.1: RFM Analysis for Customer Segmentation
-- ---------------------------------------------------
-- Objective:
-- - Use one year of data (2010-12-01 to 2011-12-01)
-- - Calculate Recency, Frequency, Monetary (RFM) values per user
-- - Use APPROX_QUANTILES to assign R, F, M scores (1 to 4)
-- - Calculate common RFM score by concatenating R, F, M
-- - Segment customers: Best, Loyal, Big Spenders, Lost, Others
-- - Final output used for Tableau/Power BI dashboard
-- ---------------------------------------------------
-- Reference date for recency: 2011-12-01


WITH
  invoice_data AS (
    SELECT
      CustomerID AS customer_id,
      InvoiceNo As invoice_number,
      DATE(InvoiceDate) AS invoice_date,
      SUM(Quantity * UnitPrice) AS total_spent
    FROM
      `tc-da-1.turing_data_analytics.rfm`
    WHERE
      InvoiceDate BETWEEN '2010-12-01' AND '2011-12-01'
      AND CustomerID IS NOT NULL
    GROUP BY
      customer_id,
      InvoiceNo,
      invoice_date
    HAVING
      total_spent > 0
  ),
  rfm_base AS (
    SELECT
      customer_id,
      MAX(invoice_date) AS last_purchase_date,
      COUNT(DISTINCT invoice_data.invoice_number) AS frequency,
      SUM(total_spent) AS monetary
    FROM
      invoice_data
    GROUP BY
      customer_id
  ),
  rfm_calculated AS (
    SELECT
      customer_id,
      last_purchase_date,
      frequency,
      monetary,
      DATE_DIFF(DATE('2011-12-01'), last_purchase_date, DAY) AS recency
    FROM
      rfm_base
  ),
  quantiles AS (
    SELECT
      APPROX_QUANTILES(recency, 4) AS recency_quartiles,
      APPROX_QUANTILES(frequency, 4) AS frequency_quartiles,
      APPROX_QUANTILES(monetary, 4) AS monetary_quartiles
    FROM
      rfm_calculated
  ),
  rfm_scored AS (
    SELECT
      rfm_calculated.*,
      CASE
        WHEN recency <= quantiles.recency_quartiles[OFFSET(1)] THEN 4
        WHEN recency <= quantiles.recency_quartiles[OFFSET(2)] THEN 3
        WHEN recency <= quantiles.recency_quartiles[OFFSET(3)] THEN 2
        ELSE 1
      END AS r_score,
      CASE
        WHEN frequency <= quantiles.frequency_quartiles[OFFSET(1)] THEN 1
        WHEN frequency <= quantiles.frequency_quartiles[OFFSET(2)] THEN 2
        WHEN frequency <= quantiles.frequency_quartiles[OFFSET(3)] THEN 3
        ELSE 4
      END AS f_score,
      CASE
        WHEN monetary <= quantiles.monetary_quartiles[OFFSET(1)] THEN 1
        WHEN monetary <= quantiles.monetary_quartiles[OFFSET(2)] THEN 2
        WHEN monetary <= quantiles.monetary_quartiles[OFFSET(3)] THEN 3
        ELSE 4
      END AS m_score
    FROM
      rfm_calculated, quantiles
  ),
  final_rfm AS (
    SELECT
      *,
      ROUND((f_score + m_score)/2.0, 0) AS fm_score
    FROM
      rfm_scored
  ),
  segments AS (
    SELECT
      *,
     CASE
  WHEN (r_score = 4 AND fm_score = 4) THEN 'Champions'
  WHEN (r_score = 4 AND fm_score = 3) OR (r_score = 3 AND fm_score = 4) THEN 'Loyal Customers'
  WHEN (r_score = 3 AND fm_score = 3) OR (r_score = 3 AND fm_score = 2) THEN 'Potential Loyalists'
  WHEN (r_score = 4 AND fm_score IN (1,2)) THEN 'Recent Customers'
  WHEN (r_score = 3 AND fm_score = 1) OR (r_score = 2 AND fm_score = 1) THEN 'Promising'
  WHEN (r_score = 2 AND fm_score = 2) THEN 'About to Sleep'
  WHEN (r_score = 2 AND fm_score = 3) THEN 'Customers Needing Attention'
  WHEN (r_score = 2 AND fm_score = 4) OR (r_score = 1 AND fm_score = 3) THEN 'At Risk'
  WHEN (r_score = 1 AND fm_score = 4) THEN 'Cant Lose Them'
  WHEN (r_score = 1 AND fm_score = 2) THEN 'Hibernating'
  WHEN (r_score = 1 AND fm_score = 1) THEN 'Lost'
END AS segment


    FROM
      final_rfm
  ),
  segment_summary AS (
    SELECT
      segment,
      COUNT(customer_id) AS num_customers,
      ROUND(AVG(r_score), 2) AS avg_r_score,
      ROUND(AVG(f_score), 2) AS avg_f_score,
      ROUND(AVG(m_score), 2) AS avg_m_score,
      ROUND(AVG(monetary), 2) AS avg_monetary,
      ROUND(AVG(recency), 2) AS avg_recency,
      ROUND(AVG(frequency), 2) AS avg_frequency
    FROM
      segments
    GROUP BY
      segment
    ORDER BY
      num_customers DESC
  )
SELECT
  *
FROM
  segment_summary;
