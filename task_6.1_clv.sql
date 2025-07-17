-- TASK 6.1 CLV Analysis via Weekly Revenue Cohorts
--
-- Calculates average revenue per user (ARPU) over a 12-week period 
-- for cohorts grouped by registration week.
-- 
-- Logic:
-- - Identify registration week per user
-- - Track weekly revenue for each user across 12 weeks
-- - Join and group by cohort to get revenue by week (week_0 to week_12)
--
-- This provides the foundation to visualize cumulative CLV (Customer Lifetime Value)
-- across cohorts, and to detect which cohorts perform best over time.


WITH
  user_registration_week AS (
  SELECT
    user_pseudo_id AS user_id,
    DATE_TRUNC(PARSE_DATE('%Y%m%d', MIN(event_date)), WEEK(SUNDAY)) AS registration_week
  FROM
    `turing_data_analytics.raw_events`
  GROUP BY
    user_pseudo_id ),

  weekly_purchases AS (
  SELECT
    user_pseudo_id AS user_id,
    DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK(SUNDAY)) AS purchase_week,
    purchase_revenue_in_usd AS revenue
  FROM
    `turing_data_analytics.raw_events`
  WHERE
    event_name = 'purchase'
    AND purchase_revenue_in_usd > 0 ),

  cohort_data AS (
  SELECT
    r.user_id,
    r.registration_week,
    p.purchase_week,
    DATE_DIFF(p.purchase_week, r.registration_week, WEEK(SUNDAY)) AS week_number,
    p.revenue
  FROM
    user_registration_week r
  LEFT JOIN
    weekly_purchases p
  ON
    r.user_id = p.user_id )
    
SELECT
  registration_week,
  COUNT(DISTINCT user_id) AS total_users,
  ROUND(SUM(
    IF
      (week_number = 0, revenue, 0)), 2) AS week_0,
  ROUND(SUM(
    IF
      (week_number = 1, revenue, 0)), 2) AS week_1,
  ROUND(SUM(
    IF
      (week_number = 2, revenue, 0)), 2) AS week_2,
  ROUND(SUM(
    IF
      (week_number = 3, revenue, 0)), 2) AS week_3,
  ROUND(SUM(
    IF
      (week_number = 4, revenue, 0)), 2) AS week_4,
  ROUND(SUM(
    IF
      (week_number = 5, revenue, 0)), 2) AS week_5,
  ROUND(SUM(
    IF
      (week_number = 6, revenue, 0)), 2) AS week_6,
  ROUND(SUM(
    IF
      (week_number = 7, revenue, 0)), 2) AS week_7,
  ROUND(SUM(
    IF
      (week_number = 8, revenue, 0)), 2) AS week_8,
  ROUND(SUM(
    IF
      (week_number = 9, revenue, 0)), 2) AS week_9,
  ROUND(SUM(
    IF
      (week_number = 10, revenue, 0)), 2) AS week_10,
  ROUND(SUM(
    IF
      (week_number = 11, revenue, 0)), 2) AS week_11,
  ROUND(SUM(
    IF
      (week_number = 12, revenue, 0)), 2) AS week_12
FROM
  cohort_data
GROUP BY
  registration_week
ORDER BY
  registration_week;