-- TASK 3.2 Weekly Cohort Retention Rates (Normalized)
-- Calculates weekly retention rates for each cohort based on retained user counts.
-- Uses static week mapping (0–6) and sets week_0 = 1.0 (100%) as baseline.
-- Divides each week's retained count by the week_0 cohort size.
-- Useful for heatmaps and trendline visualization in Tableau or Sheets.


WITH base AS (
  SELECT DISTINCT
    user_pseudo_id,
    country,
    category,
    MIN(subscription_start) AS subscription_start,
    MIN(subscription_end) AS subscription_end,
    DATE_TRUNC(MIN(subscription_start), WEEK(SUNDAY)) AS cohort_week
  FROM `turing_data_analytics.subscriptions`
  WHERE subscription_start BETWEEN DATE '2020-11-01' AND DATE '2021-01-30'
  GROUP BY user_pseudo_id, country, category
),

weeks AS (
  SELECT 0 AS week_number UNION ALL
  SELECT 1 UNION ALL
  SELECT 2 UNION ALL
  SELECT 3 UNION ALL
  SELECT 4 UNION ALL
  SELECT 5 UNION ALL
  SELECT 6
),

expanded AS (
  SELECT
    b.user_pseudo_id,
    b.cohort_week,
    w.week_number,
    DATE_ADD(b.cohort_week, INTERVAL w.week_number WEEK) AS target_week_start,
    b.subscription_end
  FROM base b
  CROSS JOIN weeks w
),

retention AS (
  SELECT
    cohort_week,
    week_number,
    COUNT(user_pseudo_id) AS retained_users
  FROM expanded
  WHERE subscription_end IS NULL OR subscription_end >= target_week_start
  GROUP BY cohort_week, week_number
),

pivoted AS (
  SELECT
    cohort_week,
    MAX(CASE WHEN week_number = 0 THEN retained_users ELSE 0 END) AS week_0,
    MAX(CASE WHEN week_number = 1 THEN retained_users ELSE 0 END) AS week_1,
    MAX(CASE WHEN week_number = 2 THEN retained_users ELSE 0 END) AS week_2,
    MAX(CASE WHEN week_number = 3 THEN retained_users ELSE 0 END) AS week_3,
    MAX(CASE WHEN week_number = 4 THEN retained_users ELSE 0 END) AS week_4,
    MAX(CASE WHEN week_number = 5 THEN retained_users ELSE 0 END) AS week_5,
    MAX(CASE WHEN week_number = 6 THEN retained_users ELSE 0 END) AS week_6
  FROM retention
  WHERE DATE_ADD(cohort_week, INTERVAL week_number WEEK) <= DATE '2021-01-30'
  GROUP BY cohort_week
)

SELECT
  cohort_week,
  1.0 AS week_0,
  ROUND(SAFE_DIVIDE(week_1, week_0), 2) AS week_1,
  ROUND(SAFE_DIVIDE(week_2, week_0), 2) AS week_2,
  ROUND(SAFE_DIVIDE(week_3, week_0), 2) AS week_3,
  ROUND(SAFE_DIVIDE(week_4, week_0), 2) AS week_4,
  ROUND(SAFE_DIVIDE(week_5, week_0), 2) AS week_5,
  ROUND(SAFE_DIVIDE(week_6, week_0), 2) AS week_6
FROM pivoted
ORDER BY cohort_week;
