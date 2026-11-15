-- ============================================================
-- Exercise: Apply Bulk Supplier Discounts
--           (SQL Lab · Medium · DQL,DML)
--
-- Scenario
--
-- You manage the database for an e-commerce platform. For an
-- upcoming holiday sale, the merchandising team wants to apply a
-- 20% discount to the prices of all products. However, this
-- discount should only apply to products provided by suppliers
-- whose status is currently 'Active'.
--
-- Task
--
-- Write a single SQL query to update the price in the Products
-- table for all qualifying items.
--
-- Database Schema
--
-- You have two tables, Products and Suppliers.
--
-- Suppliers
--
-- Column         Type     Description
-- supplier_id    INTEGER  Unique identifier for the supplier.
-- supplier_name  TEXT     Name of the supplier.
-- status         TEXT     'Active' or 'Inactive'.
--
-- Products
--
-- Column         Type     Description
-- product_id     INTEGER  Unique identifier for the product.
-- product_name   TEXT     Name of the product.
-- price          REAL     Current price of the product.
-- supplier_id    INTEGER  Foreign key referencing the supplier.
--
-- Sample data:
--
--   Suppliers (4 rows)
--   supplier_id | supplier_name | status
--   1           | TechCorp      | Active
--   2           | GadgetPros    | Active
--   3           | OldParts Inc. | Inactive
--   4           | InnovateX     | Active
--
--   Products (7 rows)
--   product_id | product_name    | price | supplier_id
--   1          | Laptop          | 1200  | 1
--   2          | Mouse           | 25    | 1
--   3          | Keyboard        | 75    | 2
--   4          | Vintage Monitor | 150   | 3
--   5          | Webcam          | 50    | 2
--   6          | USB Hub         | 30    | 3
--   7          | Smartwatch      | 300   | 4
--
-- Command types used:
--   DQL : SELECT -> read data (to verify before changing)
--   DML : UPDATE -> change data
-- ============================================================


-- ############################################################
-- TASK 1 of 2
-- Apply a 20% discount to the price of all products from
-- suppliers with an 'Active' status. After your update, the
-- final state of the `Products` table should be returned,
-- ordered by `product_id`.
-- ############################################################

-- ------------------------------------------------------------
-- BUILDING IT STEP BY STEP (verify with SELECT first)
-- ------------------------------------------------------------

-- Step 1. [DQL] Find the active suppliers on their own.
--         Result: 1, 2, 4
SELECT supplier_id
FROM Suppliers
WHERE status = 'Active';

-- Step 2. [DQL] Use that list with IN.
--         Hard-coded version: WHERE supplier_id IN (1, 2, 4)
--         Better: put the Step 1 query inside the brackets.
--         This is a SUBQUERY: the inner query runs first, and its
--         result (1, 2, 4) becomes the list for IN.
--         Result: Laptop, Mouse, Keyboard, Webcam, Smartwatch
--         (Vintage Monitor and USB Hub excluded: supplier 3 is Inactive)
SELECT *
FROM Products
WHERE supplier_id IN (
    SELECT supplier_id
    FROM Suppliers
    WHERE status = 'Active'
);

-- Step 3. [DQL] Preview the new prices. Nothing is changed yet.
--         20% discount = keep 80% = price * 0.8
--         Result (checked in the lab):
--         product_name | price | discounted_price
--         Laptop       | 1200  | 960
--         Mouse        | 25    | 20
--         Keyboard     | 75    | 60
--         Webcam       | 50    | 40
--         Smartwatch   | 300   | 240
SELECT product_name,
       price,
       price * 0.8 AS discounted_price
FROM Products
WHERE supplier_id IN (
    SELECT supplier_id
    FROM Suppliers
    WHERE status = 'Active'
);

-- ------------------------------------------------------------
-- FINAL ANSWER - TASK 1
-- ------------------------------------------------------------

-- 1. [DML] Same WHERE as the preview; only the top changes:
--    SELECT ... FROM Products  ->  UPDATE Products SET price = ...
UPDATE Products
SET price = price * 0.8
WHERE supplier_id IN (
    SELECT supplier_id
    FROM Suppliers
    WHERE status = 'Active'
);

-- 2. [DQL] Return the final table, ordered by product_id.
--    Expected:
--    1 | Laptop          | 960 | 1
--    2 | Mouse           | 20  | 1
--    3 | Keyboard        | 60  | 2
--    4 | Vintage Monitor | 150 | 3   (unchanged, supplier Inactive)
--    5 | Webcam          | 40  | 2
--    6 | USB Hub         | 30  | 3   (unchanged, supplier Inactive)
--    7 | Smartwatch      | 240 | 4
SELECT *
FROM Products
ORDER BY product_id;


-- ############################################################
-- TASK 2 of 2
-- The finance team wants a more refined promotion: for products
-- supplied by suppliers with an 'Active' status, apply a 30%
-- discount if the price is above $100, or a 10% discount if the
-- price is $100 or below. Products from suppliers that are not
-- 'Active' should remain unchanged. Write a single SQL statement
-- to update the price column accordingly, then return the final
-- state of the Products table ordered by product_id.
--
-- NOTE: The lab resets the table for Task 2, so prices start
--       from the original values again (Laptop 1200 etc.).
-- ############################################################

-- ------------------------------------------------------------
-- BUILDING IT STEP BY STEP (verify with SELECT first)
-- ------------------------------------------------------------

-- Step 1. [DQL] Check the current prices before changing anything.
SELECT * FROM Products ORDER BY product_id;

-- Step 2. [DQL] Preview with CASE: a different discount per row.
--         Same subquery as Task 1 picks the Active suppliers.
--         30% off = price * 0.70 | 10% off = price * 0.90
--         Result (checked in the lab):
--         product_name | price | discounted_price
--         Laptop       | 1200  | 840     (above 100 -> 30% off)
--         Mouse        | 25    | 22.5    (100 or below -> 10% off)
--         Keyboard     | 75    | 67.5
--         Webcam       | 50    | 45
--         Smartwatch   | 300   | 210
SELECT product_name,
       price,
       CASE
           WHEN price > 100 THEN price * 0.70
           ELSE price * 0.90
       END AS discounted_price
FROM Products
WHERE supplier_id IN (
    SELECT supplier_id
    FROM Suppliers
    WHERE status = 'Active'
);

-- ------------------------------------------------------------
-- FINAL ANSWER - TASK 2
-- ------------------------------------------------------------

-- 1. [DML] The CASE moves into SET price = ...
--    No AS alias, no FROM: UPDATE names the table at the top.
UPDATE Products
SET price = CASE
                WHEN price > 100 THEN price * 0.70
                ELSE price * 0.90
            END
WHERE supplier_id IN (
    SELECT supplier_id
    FROM Suppliers
    WHERE status = 'Active'
);

-- 2. [DQL] Return the final table, ordered by product_id.
--    Expected:
--    1 | Laptop          | 840  | 1
--    2 | Mouse           | 22.5 | 1
--    3 | Keyboard        | 67.5 | 2
--    4 | Vintage Monitor | 150  | 3   (unchanged, supplier Inactive)
--    5 | Webcam          | 45   | 2
--    6 | USB Hub         | 30   | 3   (unchanged, supplier Inactive)
--    7 | Smartwatch      | 210  | 4
SELECT *
FROM Products
ORDER BY product_id;


-- ============================================================
-- ERRORS MET WHILE SOLVING (and why they happened)
-- ============================================================
--
-- Error 1064 near 'price from products ...'           (Task 1)
--   Wrote:  price * 0.8 AS discounted price
--   Why:    Space in the alias. MySQL takes "discounted" as the
--           alias, then "price" is an unexpected extra word.
--   Fix:    AS discounted_price   (or AS "discounted price")
--
-- Typo in column name                                 (Task 1)
--   Wrote:  WHERE suppiler_id IN (...)
--   Why:    Letters swapped. Would give Error 1054 (Unknown column).
--   Fix:    WHERE supplier_id IN (...)
--
-- Error 1064 near 'where price > 100 then ...'        (Task 2)
--   Wrote:  CASE WHERE price > 100 THEN ...
--   Why:    Inside CASE the keyword is WHEN. WHERE filters rows
--           and can't appear inside a CASE.
--   Fix:    CASE WHEN price > 100 THEN ...
--
-- Error 1064 near 'case ... end as discounted_price'  (Task 2)
--   Wrote:  The SELECT preview's column list and alias inside UPDATE
--   Why:    UPDATE has no column list and no AS. SET needs
--           column = value, and discounted_price isn't a real column.
--   Fix:    SET price = CASE ... END
--
-- Error 1064 near 'FROM Products WHERE ...'           (Task 2)
--   Wrote:  UPDATE Products SET price = CASE ... END
--           FROM Products WHERE ...
--   Why:    UPDATE has no FROM clause; the table is already named
--           right after UPDATE.
--   Fix:    Delete the FROM line.
--
-- Error 1064 near 'endWHERE ...'                      (Task 2)
--   Wrote:  ...ENDWHERE supplier_id IN (...)
--   Why:    Missing space/line break, so MySQL read one unknown
--           word "endWHERE". Happened while deleting the FROM line.
--   Fix:    END on one line, WHERE on the next.
--
-- Missing final SELECT                                (Task 2)
--   Why:    The task asks to return the final table, ordered by
--           product_id.
--   Fix:    SELECT * FROM Products ORDER BY product_id;
--
-- ============================================================
-- KEY POINTS
-- ============================================================
--
-- Subquery
--   A query inside brackets inside another query. It runs first,
--   and its result is used by the outer query. Here it lets you
--   filter Products using data from Suppliers.
--
-- Verify before you UPDATE
--   Write the WHERE as a SELECT first. If the SELECT shows the
--   right rows and values, convert it to UPDATE.
--
-- Converting SELECT preview -> UPDATE
--   SELECT product_name, price,        UPDATE Products
--          <expr> AS new_price    ->   SET price = <expr>
--   FROM Products                      (no FROM)
--   WHERE ...                          WHERE ...   (same)
--
-- SELECT vs UPDATE shape
--   SELECT columns FROM table WHERE ...
--   UPDATE table SET column = value WHERE ...
--
-- CASE goes with WHEN, not WHERE
--   CASE WHEN condition THEN value ELSE value END
--
-- Boundary: "above 100" vs "100 or below"
--   WHEN price > 100 -> 30% off; ELSE covers exactly 100 and below.
--   Using >= 100 would wrongly give a 100 product 30% off.
--
-- Always keep the ELSE in an UPDATE CASE
--   Without ELSE, rows matching no WHEN are set to NULL.
--
-- Discount maths
--   20% off = price * 0.80 | 30% off = price * 0.70
--   10% off = price * 0.90
--   price * 0.2 is WRONG (sets price to 20% of itself)
--
-- Run the UPDATE only once
--   Each run discounts again: 1200 -> 840 -> 588.
--
-- Table name case
--   Use the exact names (Products, Suppliers). This lab accepted
--   lowercase, but on many Linux MySQL servers table names are
--   case-sensitive. Column names and keywords never are.
--
-- Subquery must return one column
--   IN (SELECT supplier_id ...)        -> correct
--   IN (SELECT * FROM Suppliers ...)   -> Error 1241
-- ============================================================