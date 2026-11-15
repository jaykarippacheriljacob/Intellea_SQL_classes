-- ============================================================
-- Exercise: End-of-Season Sale
--           (SQL Lab · Easy · DML)
--
-- Question:
--   An outdoor gear store is holding an end-of-season sale to clear
--   out its winter inventory.
--
--   You have access to a products table with the following structure:
--   Column    Type     Description
--   id        INTEGER  A unique identifier for each product.
--   name      TEXT     The name of the product.
--   category  TEXT     The category the product belongs to
--                      (e.g., 'Winter Gear', 'Footwear').
--   price     REAL     The current price of the product.
--
--   Your task is to write a single SQL statement to update the
--   prices for the sale.
--
--   Task: Apply a 20% discount to the price of all products in the
--   'Winter Gear' category. Your query should modify the `products`
--   table in place.
--
-- Command types used:
--   DQL : SELECT -> read data (preview)
--   DML : UPDATE -> change data
-- ============================================================


-- 1. [DQL] Optional preview: check the rows and new prices first
SELECT id, name, price, price * 0.80 AS new_price
FROM products
WHERE category = 'Winter Gear';

-- 2. [DML] 20% off = keep 80% = price * 0.80
--    WHERE limits the change to Winter Gear only.
UPDATE products
SET price = price * 0.80
WHERE category = 'Winter Gear';


-- ============================================================
-- NOTES ON THE VERSION THAT PASSED
-- ============================================================
--
-- Wrote:  SET price = ROUND(price * 0.80)
--         WHERE category IN ('Winter Gear');
--
-- ROUND with no decimals -> whole number (49.99 -> 39.992 -> 40)
--   Not asked for, and it changes the real price.
--   For money, if rounding is wanted: ROUND(price * 0.80, 2)
--
-- IN with one value works, but = is simpler
--   WHERE category IN ('Winter Gear')  =  WHERE category = 'Winter Gear'
--   IN is for lists: IN ('Winter Gear', 'Footwear')
--
-- ============================================================
-- KEY POINTS
-- ============================================================
--
-- Discount maths
--   20% off -> price * 0.80   (or price - price * 0.20)
--   price * 0.20 is WRONG: it sets the price to 20% of itself
--
-- Always use WHERE with UPDATE
--   Without it, EVERY product gets discounted.
--   Workbench safe update mode blocks this (Error 1175):
--   SET SQL_SAFE_UPDATES = 0;  ...  SET SQL_SAFE_UPDATES = 1;
--
-- Run the UPDATE once
--   Each run takes another 20% off: 100 -> 80 -> 64.
--
-- Text matches exactly (apart from case)
--   'Winter Gear' must match the stored value, including the space.
--   'WinterGear' or 'Winter  Gear' would match no rows.
-- ============================================================