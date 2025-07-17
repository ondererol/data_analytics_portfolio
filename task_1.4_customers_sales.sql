-- TASK 1.4
-- Select active North American customers who spent ≥ 2500 or placed ≥ 5 orders.
-- Split address into address number and street name. Order by country, state, and last order date.

WITH
  table_sales AS (
  SELECT
    customer.customerID AS customer_id,
    contact.FirstName AS customer_first_name,
    contact.LastName AS customer_last_name,
    CONCAT(contact.FirstName, ' ', COALESCE(contact.MiddleName, ''), ' ', contact.LastName) AS customer_full_name,
    CONCAT(COALESCE(contact.Title, 'Dear'), ' ', contact.LastName) AS adressing_title,
    contact.EmailAddress AS email_adress,
    contact.phone AS phone_number,
    customer.accountnumber AS account_number,
    'Individual' AS customer_type,
    address.City AS customer_city,
    address.addressline1 AS address_line_1,
    address.addressline2 AS address_line_2,
    state_province.name AS state,
    country.name AS country,
    state_province.countryregioncode AS country_code,
    COUNT(sales_orders_header.SalesOrderID) AS number_of_orders,
    ROUND (SUM(sales_orders_header.TotalDue),3) AS total_amount,
    MAX(sales_orders_header.OrderDate) AS latest_order_date
  FROM
    `adwentureworks_db.customer` AS customer
  LEFT JOIN
    `adwentureworks_db.individual` AS individual
  ON
    individual.customerID = customer.CustomerID
  JOIN
    `adwentureworks_db.contact` AS contact
  ON
    contact.ContactId = individual.ContactID
  JOIN
    `adwentureworks_db.customeraddress`AS customer_address
  ON
    customer_address.CustomerID = customer.CustomerID
  JOIN (
    SELECT
      customer_address.CustomerID,
      MAX(customer_address.AddressID) AS address_id
    FROM
      `adwentureworks_db.customeraddress` AS customer_address
    GROUP BY
      customer_address.CustomerID ) AS latest_address
  ON
    latest_address.CustomerID = customer.CustomerID
  JOIN
    `adwentureworks_db.address` AS address
  ON
    address.AddressID = customer_address.AddressID
  JOIN
    `adwentureworks_db.stateprovince`AS state_province
  ON
    state_province.StateProvinceID = address.StateProvinceID
  JOIN
    `adwentureworks_db.countryregion` AS country
  ON
    country.CountryRegionCode = state_province.CountryRegionCode
  LEFT JOIN
    `adwentureworks_db.salesorderheader` AS sales_orders_header
  ON
    sales_orders_header.ContactID = contact.ContactId
  WHERE
    customer.CustomerType = 'I'
  GROUP BY
    customer.customerID,
    contact.FirstName,
    contact.LastName,
    contact.MiddleName,
    contact.Title,
    contact.EmailAddress,
    contact.Phone,
    customer.AccountNumber,
    address.City,
    address.AddressLine1,
    address.AddressLine2,
    state_province.Name,
    country,
    country_code
  ORDER BY
    total_amount DESC)
SELECT
  table_sales.*,
  LEFT(address_line_1, STRPOS(address_line_1, ' ') - 1) AS address_no,
  RIGHT(address_line_1, LENGTH(address_line_1) - STRPOS(address_line_1, ' ')) AS street_name
FROM
  table_sales
WHERE
  table_sales.country_code IN ('US','CA','MX')
  AND (table_sales.number_of_orders > 5
    OR table_sales.total_amount >= 2500)
ORDER BY
  country,
  state,
  table_sales.latest_order_date;