-- TASK 4.3 – Funnel Analysis with Category and Country Breakdown
-- Expands funnel analysis by including event category as an additional dimension.
-- Calculates distinct user counts for each funnel step, grouped by country and category.
-- Adds event ordering based on user volume in the United States.
-- Enables granular insights into user behavior across product categories and regions.


WITH
  funnel_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    country,
    category,
    MIN (event_timestamp) AS event_time
  FROM
    `turing_data_analytics.raw_events` events_table
  WHERE
    event_name IN ('view_item',
      'add_to_cart',
      'begin_checkout',
      'add_shipping_info',
      'add_payment_info',
      'purchase')
    AND country IN ('United States',
      'Canada',
      'India')
  GROUP BY
    user_pseudo_id,
    event_name,
    country, category ),
  countries_event AS (
  SELECT
    event_name,
    category,
    COUNTIF (country = 'United States') AS united_states,
    COUNTIF(country = 'India') AS india,
    COUNTIF(country = 'Canada') AS canada,
  FROM
    funnel_events
  GROUP BY
    event_name, category )
SELECT
  RANK() OVER (ORDER BY united_states DESC) AS event_order,
  event_name,
  category,
  united_states,
  india,
  canada
FROM
  countries_event
ORDER BY
  event_order;