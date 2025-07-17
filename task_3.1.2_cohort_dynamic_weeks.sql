-- TASK 3.1.2 – Weekly Cohort Retention (Dynamic Week Calculation)
-- Dynamically calculates weekly retention using DATE_DIFF between subscription start and end weeks.
-- Tracks retained users from week 0 through week 6 without hardcoding week numbers.
-- Ideal for extended analysis (e.g., 12 or more weeks) and scalable retention pipelines.
-- Includes logic to exclude incomplete trailing cohorts from future weeks.


WITH
  week_0 AS (
  SELECT
    DISTINCT user_pseudo_id AS user,
    category,
    country,
    subscription_start AS start_date,
    DATETIME_TRUNC(subscription_start, WEEK) AS start_week,
    subscription_end AS end_date,
    DATETIME_TRUNC(subscription_end, WEEK) AS end_week
  FROM
    `turing_data_analytics.subscriptions`
  WHERE
    subscription_start BETWEEN DATE '2020-11-01'
    AND DATE '2021-01-30'
  ORDER BY
    subscription_start)
SELECT
  start_week AS cohort,
  /*calculating starting number of users per each cohort*/ COUNT(user) AS week_0,
  /*calculating retained users per each week for each cohort*/ COUNT(
  IF
    (DATE_DIFF(end_week, start_week, WEEK) > 0
      OR end_week IS NULL, user, NULL)) AS week_1,
  COUNT(
  IF
    ((DATE_DIFF(end_week, start_week, WEEK) > 1
        OR end_week IS NULL)
      AND start_week < (
      SELECT
        MAX(start_week)
      FROM
        week_0), user, NULL)) AS week_2,
  COUNT(
  IF
    ((DATE_DIFF(end_week, start_week, WEEK) > 2
        OR end_week IS NULL)
      AND start_week < (
      SELECT
        DATETIME_SUB(MAX(start_week), INTERVAL 1 WEEK)
      FROM
        week_0), user, NULL)) AS week_3,
  COUNT(
  IF
    ((DATE_DIFF(end_week, start_week, WEEK) > 3
        OR end_week IS NULL)
      AND start_week < (
      SELECT
        DATETIME_SUB(MAX(start_week), INTERVAL 2 WEEK)
      FROM
        week_0), user, NULL)) AS week_4,
  COUNT(
  IF
    ((DATE_DIFF(end_week, start_week, WEEK) > 4
        OR end_week IS NULL)
      AND start_week < (
      SELECT
        DATETIME_SUB(MAX(start_week), INTERVAL 3 WEEK)
      FROM
        week_0), user, NULL)) AS week_5,
  COUNT(
  IF
    ((DATE_DIFF(end_week, start_week, WEEK) > 5
        OR end_week IS NULL)
      AND start_week < (
      SELECT
        DATETIME_SUB(MAX(start_week), INTERVAL 4 WEEK)
      FROM
        week_0), user, NULL)) AS week_6
FROM
  week_0
GROUP BY
  cohort
ORDER BY
  cohort;