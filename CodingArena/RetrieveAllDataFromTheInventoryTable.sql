-- ============================================================
-- Exercise: Retrieve All Data from the Inventory Table
--           (SQL Lab · Easy · DQL)
--
-- Question:
--   You are given a database table named Inventory that tracks the
--   current stock in a hardware store.
--
--   Table Schema
--   The Inventory table has the following columns:
--   Column      Type     Description
--   item_id     integer  A unique ID for each item (Primary Key).
--   item_name   text     The name of the item.
--   unit_price  real     The price of a single unit of the item.
--   department  text     The department where the item is located.
--
--   Your task is to write a SQL query to retrieve all columns and
--   all rows from this table.
--
--   Task: Write a SQL query to retrieve all data for all items in
--   the `Inventory` table. Order the results by `item_id` in
--   ascending order.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] * returns every column; no WHERE, so every row comes back.
--    ORDER BY item_id sorts lowest id first (ASC is the default).
SELECT *
FROM Inventory
ORDER BY item_id ASC;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- SELECT * vs listing columns
--   SELECT * FROM Inventory;
--   SELECT item_id, item_name, unit_price, department FROM Inventory;
--   Same result here. Listing columns is safer in real projects:
--   the output doesn't change if a column is added later.
--
-- Avoid SELECT * on big tables
--   Pick only the columns you need, and add LIMIT when exploring.
--
-- ASC is optional
--   ORDER BY item_id ASC  =  ORDER BY item_id
--
-- Always add ORDER BY when the task asks for an order
--   Rows often come back in primary-key order anyway, but that's
--   not guaranteed without ORDER BY.
--
-- Check column names first
--   DESCRIBE Inventory;   (or SHOW COLUMNS FROM Inventory;)
-- ============================================================