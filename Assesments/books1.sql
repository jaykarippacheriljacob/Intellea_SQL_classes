-- ============================================================
-- Exercise: Select Only Title and Author
--           (SQL Lab · Easy · Projection)
--
-- Question:
--   Projection means choosing which columns come back from a
--   table, instead of pulling every column with SELECT *.
--   The catalog team only needs each book's title and who wrote
--   it. Write a query that returns only the title and author
--   columns from the books table, for every row.
--
-- Command types used:
--   DQL : SELECT -> read data
-- ============================================================


-- 1. [DQL] List only the needed columns, separated by commas.
--    No WHERE, so every row comes back.
SELECT title, author
FROM books;


-- ============================================================
-- KEY POINTS / COMMON MISTAKES
-- ============================================================
--
-- Projection vs filtering
--   Projection (choosing columns) -> the list after SELECT
--   Filtering  (choosing rows)    -> the WHERE clause
--
-- Missing comma between columns
--   Wrote:  SELECT title author FROM books;
--   Why:    No error! MySQL treats author as an alias for title,
--           so you get ONE column of titles headed "author".
--   Fix:    SELECT title, author FROM books;
--
-- Comma after the last column
--   Wrote:  SELECT title, author, FROM books;
--   Why:    Error 1064 (syntax error near 'FROM').
--   Fix:    No comma before FROM.
--
-- Column order is up to you
--   SELECT author, title FROM books; returns the same data with
--   the columns swapped. The result follows your list's order.
-- ============================================================