-- TASK 4.2 – Funnel Breakdown with Country-Based Drop-Off Analysis
-- Tracks user progression through funnel steps (from view_item to purchase) across top 3 countries.
-- Calculates distinct user counts at each step and computes country-level and overall drop-off percentages.
-- Ranks funnel steps based on user volume in the United States for consistent event ordering.
-- Useful for identifying critical drop-off points and comparing country-specific behaviors.


WITH
  funnel_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    country,
    MIN(event_timestamp) AS event_time
  FROM
    `turing_data_analytics.raw_events`
  WHERE
    event_name IN ('view_item',
      'add_to_cart',
      'begin_checkout',
      'add_shipping_info',
      'add_payment_info',
      'purchase')
    AND country IN ('United States',
      'India',
      'Canada')
  GROUP BY
    user_pseudo_id,
    event_name,
    country ),
  countries_event AS (
  SELECT
    event_name,
    COUNTIF(country = 'United States') AS united_states,
    COUNTIF(country = 'India') AS india,
    COUNTIF(country = 'Canada') AS canada
  FROM
    funnel_events
  GROUP BY
    event_name ),
  ranked_events AS (
  SELECT
    RANK() OVER (ORDER BY united_states DESC) AS event_order,
    event_name,
    united_states,
    india,
    canada
  FROM
    countries_event ),
  countries_percentages AS (
  SELECT
    *,
    FIRST_VALUE(united_states) OVER (ORDER BY event_order) AS us_base,
    FIRST_VALUE(india) OVER (ORDER BY event_order) AS india_base,
    FIRST_VALUE(canada) OVER (ORDER BY event_order) AS canada_base
  FROM
    ranked_events )
SELECT
  event_order,
  event_name,
  united_states,
  india,
  canada,
  ROUND(100 * (united_states + india+canada )/ (us_base+india_base+canada_base), 2) AS full_percent, 
  ROUND(100 * united_states / us_base, 2) AS us_percent,
  ROUND(100 * india / india_base, 2) AS india_percent,
  ROUND(100 * canada / canada_base, 2) AS canada_percent
FROM
  countries_percentages
ORDER BY
  event_order;