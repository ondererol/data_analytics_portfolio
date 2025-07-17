-- TASK 3.1.1 Weekly Cohort Retention (Static Week Mapping)
-- Calculates weekly retention for cohorts using a fixed set of week numbers (0 to 6) via UNION ALL.
-- Each user's subscription start date is truncated to cohort week, then retention is tracked across 6 weeks.
-- Suitable for visualizing cohort heatmaps in Tableau or Sheets.
-- Less scalable for long-term analysis, but easier to follow.


WITH base AS (
  SELECT DISTINCT
      user_pseudo_id,
      country,
      category,
    MIN(subscription_start) AS subscription_start,
    MIN(subscription_end) AS subscription_end,
    DATE_TRUNC(MIN(subscription_start), WEEK(SUNDAY)) AS cohort_week
  FROM
    `turing_data_analytics.subscriptions`
  WHERE
    subscription_start BETWEEN DATE '2020-11-01' AND DATE '2021-01-30'
  GROUP BY
    user_pseudo_id,
    country, 
    category
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
  FROM
    base b
  CROSS JOIN
    weeks w
),

retention AS (
  SELECT
    cohort_week,
    week_number,
    COUNT(user_pseudo_id) AS retained_users
  FROM
    expanded
  WHERE
    subscription_end IS NULL
    OR subscription_end >= target_week_start
  GROUP BY
    cohort_week,
    week_number
)

SELECT
  cohort_week,
  MAX(CASE WHEN week_number = 0 THEN retained_users ELSE 0 END) AS week_0,
  MAX(CASE WHEN week_number = 1 THEN retained_users ELSE 0 END) AS week_1,
  MAX(CASE WHEN week_number = 2 THEN retained_users ELSE 0 END) AS week_2,
  MAX(CASE WHEN week_number = 3 THEN retained_users ELSE 0 END) AS week_3,
  MAX(CASE WHEN week_number = 4 THEN retained_users ELSE 0 END) AS week_4,
  MAX(CASE WHEN week_number = 5 THEN retained_users ELSE 0 END) AS week_5,
  MAX(CASE WHEN week_number = 6 THEN retained_users ELSE 0 END) AS week_6
FROM
  retention
WHERE
  DATE_ADD(cohort_week, INTERVAL week_number WEEK) <= DATE '2021-01-30'
GROUP BY
  cohort_week
ORDER BY
  cohort_week;
