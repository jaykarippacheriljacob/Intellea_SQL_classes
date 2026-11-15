/* =====================================================================
   DAY 6 - SQL PRACTICE NOTES
   Topics: INNER JOIN, LEFT JOIN, RIGHT JOIN, Filtering NULLs,
           COALESCE, FULL OUTER JOIN (UNION), JOIN + Aggregates,
           Error clinic
   ===================================================================== */


/* ---------------------------------------------------------------------
   0. SETUP
   --------------------------------------------------------------------- */

CREATE DATABASE IF NOT EXISTS join_practice;
USE join_practice;

DROP TABLE IF EXISTS Marks;
DROP TABLE IF EXISTS Students;

CREATE TABLE Students (
    id    INT PRIMARY KEY,
    name  VARCHAR(50) NOT NULL
);

CREATE TABLE Marks (
    id     INT PRIMARY KEY,
    marks  INT
);

INSERT INTO Students (id, name) VALUES
    (1, 'Arun'),
    (2, 'Rahul'),
    (3, 'Priya'),
    (4, 'Sneha');

INSERT INTO Marks (id, marks) VALUES
    (1, 90),
    (2, 85),
    (5, 70),
    (6, 95);

/* Who matches whom:
     id 1, 2 -> in BOTH tables         (Arun, Rahul)
     id 3, 4 -> only in Students       (Priya, Sneha - no marks)
     id 5, 6 -> only in Marks          (marks with no student)        */
SELECT * FROM Students ORDER BY id;
SELECT * FROM Marks    ORDER BY id;


/* ---------------------------------------------------------------------
   1. WHAT IS A JOIN?

   A JOIN combines rows from TWO tables using a COMMON column.

   SYNTAX:
     SELECT columns
     FROM table1                 -- LEFT table
     JOIN table2                 -- RIGHT table
       ON table1.common_column = table2.common_column;

   "Left"  = the table written BEFORE the word JOIN
   "Right" = the table written AFTER  the word JOIN

     INNER JOIN -> only matching rows
     LEFT JOIN  -> ALL left rows  + matches (no match -> NULL)
     RIGHT JOIN -> ALL right rows + matches (no match -> NULL)
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   2. INNER JOIN - only the overlap

   Keeps a row ONLY when the id exists in BOTH tables.
   Priya, Sneha (no marks) and ids 5, 6 (no student) are dropped.
   --------------------------------------------------------------------- */

-- Result: (1, Arun, 90), (2, Rahul, 85)
SELECT s.id, s.name, m.marks
FROM Students AS s
INNER JOIN Marks AS m
ON s.id = m.id
ORDER BY s.id;


/* ---------------------------------------------------------------------
   3. LEFT JOIN - keep every row of the LEFT table

   Every student appears. If a student has no marks row,
   the Marks columns come back as NULL.
   --------------------------------------------------------------------- */

-- Result: (1, Arun, 90), (2, Rahul, 85), (3, Priya, NULL), (4, Sneha, NULL)
SELECT s.id, s.name, m.marks
FROM Students AS s
LEFT JOIN Marks AS m
ON s.id = m.id
ORDER BY s.id;

-- Only students WITH marks (removes NULL rows -> same as INNER JOIN)
-- Result: (1, Arun, 90), (2, Rahul, 85)
SELECT s.id, s.name, m.marks
FROM Students AS s
LEFT JOIN Marks AS m
ON s.id = m.id
WHERE m.id IS NOT NULL
ORDER BY s.id;

-- Only students WITHOUT marks  (the "find missing" pattern)
-- Result: (3, Priya, NULL), (4, Sneha, NULL)
SELECT s.id, s.name, m.marks
FROM Students AS s
LEFT JOIN Marks AS m ON s.id = m.id
WHERE m.id IS NULL
ORDER BY s.id;


/* ---------------------------------------------------------------------
   4. RIGHT JOIN - keep every row of the RIGHT table

   Every marks row appears. If a marks row has no matching student,
   the Students columns come back as NULL.

   NOTE: A RIGHT JOIN is just a LEFT JOIN with the tables swapped:
           FROM Students s RIGHT JOIN Marks m ...
           FROM Marks m    LEFT  JOIN Students s ...   (same result)
         Most people only use LEFT JOIN for this reason.
   --------------------------------------------------------------------- */

-- Result: (1, Arun, 1, 90), (2, Rahul, 2, 85),
--         (NULL, NULL, 5, 70), (NULL, NULL, 6, 95)
SELECT s.id AS student_id, s.name, m.id AS marks_id, m.marks
FROM Students AS s
RIGHT JOIN Marks AS m ON s.id = m.id
ORDER BY m.id;

-- Only marks rows WITH a student
-- Result: (1, Arun, 1, 90), (2, Rahul, 2, 85)
SELECT s.id AS student_id, s.name, m.id AS marks_id, m.marks
FROM Students AS s
RIGHT JOIN Marks AS m ON s.id = m.id
WHERE s.id IS NOT NULL
ORDER BY m.id;

-- Only marks rows WITHOUT a student
-- Result: (NULL, NULL, 5, 70), (NULL, NULL, 6, 95)
SELECT s.id AS student_id, s.name, m.id AS marks_id, m.marks
FROM Students AS s
RIGHT JOIN Marks AS m ON s.id = m.id
WHERE s.id IS NULL
ORDER BY m.id;


/* ---------------------------------------------------------------------
   5. HANDLING NULL - WHERE vs COALESCE

   WHERE col IS NULL / IS NOT NULL -> REMOVES rows
   COALESCE(col, replacement)      -> KEEPS rows, only changes the
                                      displayed value
   IFNULL(col, replacement)        -> same as COALESCE (MySQL only)

   NOTE: Use IS NULL, never = NULL. (see Error clinic)
   --------------------------------------------------------------------- */

-- Every student, NULL marks shown as 0
-- Result: (1, Arun, 90), (2, Rahul, 85), (3, Priya, 0), (4, Sneha, 0)
SELECT s.id, s.name, COALESCE(m.marks, 0) AS marks
FROM Students AS s
LEFT JOIN Marks AS m ON s.id = m.id
ORDER BY s.id;

-- Every marks row, NULL names shown as 'Unknown'
-- Result: (1, Arun, 90), (2, Rahul, 85), (5, Unknown, 70), (6, Unknown, 95)
SELECT m.id AS marks_id, COALESCE(s.name, 'Unknown') AS student_name, m.marks
FROM Students AS s
RIGHT JOIN Marks AS m ON s.id = m.id
ORDER BY m.id;


/* ---------------------------------------------------------------------
   6. FULL OUTER JOIN - everything from BOTH tables

   MySQL does NOT support FULL OUTER JOIN directly.
   Build it with: LEFT JOIN  +  UNION ALL  +  RIGHT JOIN (unmatched only)

   NOTE: The WHERE s.id IS NULL in the 2nd part stops ids 1, 2 from
         appearing twice. Without it, use UNION (removes duplicates,
         but slower).
   --------------------------------------------------------------------- */

-- Result (6 rows):
--   (1, Arun, 1, 90), (2, Rahul, 2, 85),
--   (3, Priya, NULL, NULL), (4, Sneha, NULL, NULL),
--   (NULL, NULL, 5, 70), (NULL, NULL, 6, 95)
SELECT s.id AS student_id, s.name, m.id AS marks_id, m.marks
FROM Students AS s
LEFT JOIN Marks AS m ON s.id = m.id
UNION ALL
SELECT s.id AS student_id, s.name, m.id AS marks_id, m.marks
FROM Students AS s
RIGHT JOIN Marks AS m ON s.id = m.id
WHERE s.id IS NULL;


/* ---------------------------------------------------------------------
   7. JOIN + AGGREGATES (links to Day 5)

   Aggregates work on the JOINED result.
   Remember: COUNT(*) counts all rows, COUNT(column) skips NULLs.
   --------------------------------------------------------------------- */

-- Result: total_students 4, students_with_marks 2, avg_marks 87.5
SELECT COUNT(*)               AS total_students,
       COUNT(m.marks)         AS students_with_marks,
       ROUND(AVG(m.marks), 1) AS avg_marks
FROM Students AS s
LEFT JOIN Marks AS m ON s.id = m.id;


/* ---------------------------------------------------------------------
   8. CLAUSE ORDER (with JOIN)

   WRITING order:
     SELECT -> FROM -> JOIN -> ON -> WHERE -> GROUP BY -> HAVING
            -> ORDER BY -> LIMIT

   EXECUTION order:
     FROM -> JOIN/ON -> WHERE -> GROUP BY -> HAVING -> SELECT
          -> ORDER BY -> LIMIT

   This explains why:
   - ON runs before WHERE  -> a filter in ON keeps LEFT JOIN rows,
                              a filter in WHERE can remove them
                              (see Error 4)
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   9. ERROR CLINIC
   Wrong queries are commented out so this file runs without errors.
   --------------------------------------------------------------------- */

/* ERROR 1 - Using = NULL instead of IS NULL  (no error, wrong result)
   Wrote:
     SELECT s.name FROM Students s
     LEFT JOIN Marks m ON s.id = m.id
     WHERE m.id = NULL;
   Result: 0 rows
   Why:    NULL is "unknown". Nothing is ever equal to NULL,
           not even NULL itself.
   Fix:    Use IS NULL.                                                */
SELECT s.name
FROM Students AS s
LEFT JOIN Marks AS m ON s.id = m.id
WHERE m.id IS NULL;                                -- Priya, Sneha


/* ERROR 2 - Ambiguous column name
   Wrote:
     SELECT id, name, marks FROM Students s
     INNER JOIN Marks m ON s.id = m.id;
   Error:  1052 - Column 'id' in field list is ambiguous
   Why:    BOTH tables have a column called id. MySQL doesn't know
           which one you mean.
   Fix:    Prefix with the table alias (s.id or m.id).                 */
SELECT s.id, s.name, m.marks
FROM Students AS s
INNER JOIN Marks AS m ON s.id = m.id;


/* ERROR 3 - Missing FROM ... JOIN part / missing ON
   Wrote:
     SELECT s.id, s.name, m.marks FROM
     ON s.id = m.id;
   Error:  1064 - You have an error in your SQL syntax
   Why:    After FROM you need: table1 alias JOIN table2 alias ON ...
   ALSO:   LEFT JOIN / RIGHT JOIN without ON -> Error 1064
   Fix:    Write the full FROM ... JOIN ... ON ...                     */
SELECT s.id, s.name, m.marks
FROM Students AS s
LEFT JOIN Marks AS m ON s.id = m.id;


/* ERROR 4 - Right-table filter in WHERE turns LEFT JOIN into INNER JOIN
   (no error, wrong result)
   Wrote:
     SELECT s.name, m.marks FROM Students s
     LEFT JOIN Marks m ON s.id = m.id
     WHERE m.marks > 80;
   Result: only Arun, Rahul  -> Priya, Sneha disappeared!
   Why:    Their marks are NULL. NULL > 80 is not TRUE, so WHERE
           removes them.
   Fix:    Put the condition in ON to keep every student.              */
-- Result: (Arun, 90), (Rahul, 85), (Priya, NULL), (Sneha, NULL)
SELECT s.name, m.marks
FROM Students AS s
LEFT JOIN Marks AS m ON s.id = m.id AND m.marks > 80;


/* ERROR 5 - FULL OUTER JOIN in MySQL
   Wrote:
     SELECT * FROM Students s FULL OUTER JOIN Marks m ON s.id = m.id;
   Error:  1064 - syntax error
   Why:    MySQL does not support FULL OUTER JOIN.
   Fix:    LEFT JOIN + UNION ALL + RIGHT JOIN ... WHERE left.id IS NULL
           (see Section 6).

   ALSO WATCH typos:
     c.sutomer_name    -> Error 1054 - Unknown column
     JOIN order_item   -> Error 1146 - Table doesn't exist
                          (check the table is created first)          */


/* =====================================================================
   QUICK REVISION
   ---------------------------------------------------------------------
   Left / Right table  -> table before JOIN / table after JOIN
   INNER JOIN          -> only matching rows
   LEFT JOIN           -> all left rows, unmatched right side = NULL
   RIGHT JOIN          -> all right rows, unmatched left side = NULL
   RIGHT = LEFT swapped-> A RIGHT JOIN B  ==  B LEFT JOIN A
   Find missing rows   -> LEFT JOIN ... WHERE right.id IS NULL
   NULL check          -> IS NULL / IS NOT NULL  (never = NULL)
   WHERE vs COALESCE   -> removes rows vs replaces displayed NULL
   ON vs WHERE         -> filter in ON keeps LEFT rows,
                          filter in WHERE can drop them
   Same column name    -> always prefix with alias (s.id, m.id)
   FULL OUTER JOIN     -> not in MySQL: LEFT + UNION ALL + RIGHT(IS NULL)
   Execution order     -> FROM JOIN/ON WHERE GROUP BY HAVING SELECT
                          ORDER BY LIMIT
   ===================================================================== */