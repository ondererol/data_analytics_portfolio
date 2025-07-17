-- TASK 4.1 – Identify Top 3 Countries by Funnel Engagement
-- Filters raw event data to include only funnel-related events (view_item to purchase).
-- Calculates distinct user counts per funnel step and aggregates total funnel users per country.
-- Returns the top 3 countries with the highest funnel activity.


WITH
  funnel_events AS (
  SELECT
    country,
    event_name,
    user_pseudo_id
  FROM
    `turing_data_analytics.raw_events`
  WHERE
    event_name IN ('view_item',
      'add_to_cart',
      'begin_checkout',
      'add_shipping_info',
      'add_payment_info',
      'purchase') ),
  step_counts AS (
  SELECT
    country,
    event_name,
    COUNT(DISTINCT user_pseudo_id) AS user_count
  FROM
    funnel_events
  GROUP BY
    country,
    event_name ),
  total_per_country AS (
  SELECT
    country,
    SUM(user_count) AS total_funnel_users
  FROM
    step_counts
  GROUP BY
    country )
SELECT
  country,
  total_funnel_users
FROM
  total_per_country
ORDER BY
  total_funnel_users DESC
LIMIT
  3;