-- ============================================================
-- Exercise: Create The Couriers Table   (SQL Lab · Easy · DDL Commands)
--
-- Question:
--   You're onboarding a new couriers service for the delivery platform.
--   The couriers table already exists but is missing its constraints
--   and defaults. Alter the table to add:
--     * full_name : NOT NULL
--     * phone     : UNIQUE
--     * joined_on : defaults to today's date
--     * is_active : defaults to TRUE
--   Then insert one row for Ravi Kumar with phone 9876543210, using only
--   the full_name and phone columns, and return the inserted row with
--   columns courier_id, full_name, phone and is_active.
--
-- Command types used:
--   DDL : DROP, CREATE   -> change structure
--   DML : INSERT         -> change data
--   DQL : SELECT         -> read data
-- ============================================================

-- 1. [DDL] Remove the existing table so it can be recreated with the rules.
--    WARNING: this deletes any data already in the table.
DROP TABLE IF EXISTS couriers;

-- 2. [DDL] Recreate the table with all constraints and defaults.
CREATE TABLE couriers (
    courier_id INT AUTO_INCREMENT PRIMARY KEY,  -- unique ID, generated automatically
    full_name  VARCHAR(50) NOT NULL,            -- name is required
    phone      VARCHAR(10) UNIQUE,              -- no two couriers can share a number
    joined_on  DATE DEFAULT (CURRENT_DATE),     -- today's date if not given (brackets required)
    is_active  BOOLEAN DEFAULT TRUE             -- active unless stated otherwise (stored as 1)
);

-- 3. [DML] Insert Ravi Kumar using only full_name and phone.
--    courier_id, joined_on and is_active are filled in automatically.
INSERT INTO couriers (full_name, phone)
VALUES ('Ravi Kumar', '9876543210');

-- 4. [DQL] Return the inserted row with only the requested columns.
--    phone is UNIQUE, so this finds exactly one row.
SELECT courier_id, full_name, phone, is_active
FROM couriers
WHERE phone = '9876543210';