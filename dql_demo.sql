/* ============================================================================
   DQL TEACHING DEMO SCRIPT
   Topics : 1) JOINS   2) CASE WHEN with Aggregations   3) WINDOW FUNCTIONS
   Dialect: PostgreSQL (works with only tiny tweaks on MySQL / SQL Server —
            notes are added wherever a dialect needs a different keyword)
   How to use: run section by section during the live session. Each demo
   query has a comment above it explaining WHAT to say and WHAT to point out
   in the output (the "interpretation" step the guide asks for).
   ============================================================================ */


/* ============================================================================
   0. SETUP — SAMPLE SCHEMA (used for ALL three topics so learners only need
      to understand one dataset the whole session)
   ============================================================================ */

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id      INT PRIMARY KEY,
    emp_name    VARCHAR(50),
    department  VARCHAR(30),
    salary      NUMERIC(10,2),
    join_date   DATE
);

CREATE TABLE sales (
    sale_id     INT PRIMARY KEY,
    emp_id      INT,               -- FK -> employees.emp_id (not all emp_ids have sales -> good for JOIN demo)
    region      VARCHAR(20),
    sale_amount NUMERIC(10,2),
    sale_date   DATE
);

INSERT INTO employees (emp_id, emp_name, department, salary, join_date) VALUES
(1,  'Aditi Sharma',  'Sales',       55000, '2022-01-10'),
(2,  'Rohan Mehta',   'Sales',       62000, '2021-06-15'),
(3,  'Kavya Iyer',    'Sales',       48000, '2023-03-01'),
(4,  'Sameer Khan',   'Marketing',   58000, '2022-11-20'),
(5,  'Neha Verma',    'Marketing',   71000, '2020-09-05'),
(6,  'Arjun Rao',     'Engineering', 95000, '2019-04-12'),
(7,  'Priya Nair',    'Engineering', 88000, '2021-01-22'),
(8,  'Vikram Singh',  'Engineering', 102000,'2018-07-30'),
(9,  'Ishaan Gupta',  'HR',          49000, '2023-05-18'),
(10, 'Meera Pillai',  'HR',          52000, '2022-02-14');
-- Note: emp_id 9 and 10 (HR) deliberately have NO sales rows -> shows LEFT/RIGHT/FULL join behavior

INSERT INTO sales (sale_id, emp_id, region, sale_amount, sale_date) VALUES
(101, 1, 'North', 12000, '2024-01-05'),
(102, 1, 'North', 15000, '2024-02-10'),
(103, 1, 'South',  9000, '2024-03-08'),
(104, 2, 'East',  22000, '2024-01-18'),
(105, 2, 'East',  18000, '2024-02-20'),
(106, 3, 'West',   7000, '2024-01-25'),
(107, 3, 'West',  11000, '2024-03-15'),
(108, 4, 'North', 16000, '2024-01-30'),
(109, 5, 'South', 21000, '2024-02-05'),
(110, 5, 'South', 19500, '2024-03-22'),
(111, 6, 'East',  30000, '2024-01-12'),
(112, 7, 'East',  27000, '2024-02-14'),
(113, 8, 'West',  35000, '2024-03-01'),
(999, 55,'North', 5000, '2024-01-01');
-- Note: sale_id 999 has emp_id 55, which does NOT exist in employees -> shows RIGHT/FULL join "orphan" behavior


/* ============================================================================
   1. JOINS
   ============================================================================ */

-- 1.1 Intuition: what does each employee's sales activity look like?
--     Start simple -> plain SELECT from each table first, then combine.
SELECT * FROM employees;
SELECT * FROM sales;

-- 1.2 INNER JOIN
--     Talking point: "only rows that MATCH in both tables survive."
--     HR employees (9, 10) disappear because they have no sales.
SELECT e.emp_name, e.department, s.region, s.sale_amount
FROM employees e
INNER JOIN sales s ON e.emp_id = s.emp_id
ORDER BY e.emp_id;

-- 1.3 LEFT JOIN
--     Talking point: "keep everything on the LEFT (employees), even with no match."
--     HR employees now appear with NULLs for sale columns -> good for finding
--     "employees with zero sales" (a very common real-world ask).
SELECT e.emp_name, e.department, s.region, s.sale_amount
FROM employees e
LEFT JOIN sales s ON e.emp_id = s.emp_id
ORDER BY e.emp_id;

-- 1.3.1 Practical use of LEFT JOIN: find employees with NO sales at all
SELECT e.emp_name, e.department
FROM employees e
LEFT JOIN sales s ON e.emp_id = s.emp_id
WHERE s.sale_id IS NULL;

-- 1.4 RIGHT JOIN
--     Talking point: mirror of LEFT JOIN — keep everything on the RIGHT (sales).
--     Reveals sale_id 999, whose emp_id (55) doesn't exist in employees.
SELECT e.emp_name, s.sale_id, s.emp_id AS sale_table_emp_id, s.sale_amount
FROM employees e
RIGHT JOIN sales s ON e.emp_id = s.emp_id
ORDER BY s.sale_id;

-- 1.5 FULL OUTER JOIN
--     Talking point: "everything from both sides — matched AND unmatched."
--     Combines the HR-with-no-sales case AND the orphan-sale case in one result.
--     (MySQL has no FULL JOIN — emulate with LEFT JOIN UNION RIGHT JOIN.)
SELECT e.emp_name, e.department, s.sale_id, s.sale_amount
FROM employees e
FULL OUTER JOIN sales s ON e.emp_id = s.emp_id
ORDER BY e.emp_id;


/* ============================================================================
   2. CASE WHEN WITH AGGREGATIONS
   ============================================================================ */

-- 2.1 Intuition: CASE WHEN = "if / else" logic inside a SELECT.
--     Start with a simple row-level CASE WHEN (no aggregation yet).
SELECT emp_name, department, salary,
       CASE
           WHEN salary >= 90000 THEN 'High'
           WHEN salary >= 60000 THEN 'Medium'
           ELSE 'Entry'
       END AS salary_band
FROM employees;

-- 2.2 Combine CASE WHEN with GROUP BY / aggregation
--     Talking point: "now let's COUNT how many employees fall in each band,
--     per department" — this is the real analyst use case: turning row-level
--     logic into a summarized business metric.
SELECT department,
       CASE
           WHEN salary >= 90000 THEN 'High'
           WHEN salary >= 60000 THEN 'Medium'
           ELSE 'Entry'
       END AS salary_band,
       COUNT(*) AS num_employees
FROM employees
GROUP BY department,
         CASE
             WHEN salary >= 90000 THEN 'High'
             WHEN salary >= 60000 THEN 'Medium'
             ELSE 'Entry'
         END
ORDER BY department, salary_band;

-- 2.3 Conditional aggregation ("pivot-style" summary) — a very common
--     interview favorite: count high vs entry earners side by side per dept.
SELECT department,
       COUNT(CASE WHEN salary >= 90000 THEN 1 END) AS high_earners,
       COUNT(CASE WHEN salary >= 60000 AND salary < 90000 THEN 1 END) AS mid_earners,
       COUNT(CASE WHEN salary < 60000 THEN 1 END) AS entry_earners,
       ROUND(AVG(salary), 0) AS avg_salary
FROM employees
GROUP BY department
ORDER BY department;


/* ============================================================================
   3. WINDOW FUNCTIONS
   ============================================================================ */

-- 3.1 Intuition: window functions calculate ACROSS rows related to the
--     current row, WITHOUT collapsing rows the way GROUP BY does.
--     Show this contrast directly: GROUP BY hides individual rows...
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department;

-- ...but a window function keeps every employee row AND adds the department
-- average alongside it, so you can compare each person to their peer group.
SELECT emp_name, department, salary,
       ROUND(AVG(salary) OVER (PARTITION BY department), 0) AS dept_avg_salary
FROM employees
ORDER BY department;

-- 3.2 RANK / DENSE_RANK / ROW_NUMBER — ranking employees by salary within department
--     Talking point: explain ties. RANK leaves gaps after a tie, DENSE_RANK
--     doesn't, ROW_NUMBER never ties (arbitrary order breaks ties).
SELECT emp_name, department, salary,
       RANK()       OVER (PARTITION BY department ORDER BY salary DESC) AS rnk,
       DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dense_rnk,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS row_num
FROM employees
ORDER BY department, salary DESC;

-- 3.3 Practical usage: "Top earner per department" using RANK
SELECT emp_name, department, salary
FROM (
    SELECT emp_name, department, salary,
           RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rnk
    FROM employees
) ranked
WHERE rnk = 1;

-- 3.4 LEAD / LAG — comparing a sale to the employee's previous / next sale
--     Talking point: great for month-over-month or "change since last event"
--     style analysis, without a self-join.
SELECT emp_id, sale_date, sale_amount,
       LAG(sale_amount)  OVER (PARTITION BY emp_id ORDER BY sale_date) AS prev_sale,
       LEAD(sale_amount) OVER (PARTITION BY emp_id ORDER BY sale_date) AS next_sale,
       sale_amount - LAG(sale_amount) OVER (PARTITION BY emp_id ORDER BY sale_date) AS change_vs_prev
FROM sales
WHERE emp_id IN (1, 5)   -- pick 2 employees with multiple sales to keep the demo readable
ORDER BY emp_id, sale_date;

-- 3.5 Running total with SUM() OVER — cumulative sales per employee over time
SELECT emp_id, sale_date, sale_amount,
       SUM(sale_amount) OVER (PARTITION BY emp_id ORDER BY sale_date
                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM sales
ORDER BY emp_id, sale_date;

/* ============================================================================
   END OF SCRIPT — Summary talking point for the close of the session:
   - JOINS combine tables by matching keys (INNER = only matches,
     LEFT/RIGHT = keep one side's unmatched rows, FULL = keep both sides' unmatched rows)
   - CASE WHEN adds if/else business logic, and becomes powerful once combined
     with GROUP BY / conditional aggregation
   - Window functions calculate across a "window" of related rows WITHOUT
     collapsing the result set the way GROUP BY does — essential for ranking,
     row-to-row comparisons (LEAD/LAG), and running totals
   ============================================================================ */
