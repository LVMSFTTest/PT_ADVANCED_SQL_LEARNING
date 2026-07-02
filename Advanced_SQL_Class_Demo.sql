-- ============================================================================================================================
--    _       _                               _   ____   ___  _
--   / \   __| |_   ____ _ _ __   ___ ___   __| | / ___| / _ \| |
--  / _ \ / _` \ \ / / _` | '_ \ / __/ _ \ / _` | \___ \| | | | |
-- / ___ \ (_| |\ V / (_| | | | | (_|  __/| (_| |  ___) | |_| | |___
--/_/   \_\__,_| \_/ \__,_|_| |_|\___\___| \__,_| |____/ \__\_\_____|
--
--  Day 2 · 3-Hour Session · Advanced SQL — Full Class Demo
--  Dataset: customer_info + salary tables (customer_salary.sql)
--           HR schema (employees, departments, jobs, locations)
--  Author : Class Demo File — Advanced SQL Session
-- ============================================================================================================================
--
--  JUMP TO SECTION — Ctrl+F (Cmd+F on Mac) and search the tag:
--
--  [S0]  SETUP          — Create tables, insert data
--  [S1]  ORDER BY       — Sorting: multi-col, expressions, aliases, CASE, NULLS
--  [S2]  FILTERING      — IN, NOT IN, AND, OR, NOT, BETWEEN, LIKE, NULL
--  [S3]  GROUP BY       — Grouping, HAVING, math, CASE in aggregates
--  [S4]  JOINS          — INNER, LEFT, RIGHT, FULL OUTER (UNION simulation)
--  [S5]  SUBQUERIES     — Scalar, table, correlated, EXISTS, IN-subquery
--  [S6]  WINDOW FUNCS   — RANK, DENSE_RANK, ROW_NUMBER, LEAD, LAG, NTILE, running total
--  [S7]  ETL            — LOAD DATA, INSERT...SELECT, transform patterns
--  [S8]  STATISTICS     — AVG, VARIANCE, STDDEV, manual variance
--  [S9]  STORED PROCS   — CREATE PROCEDURE, IN/OUT params, CALL
--  [S10] WORKSHOP       — All 16 slide-deck questions with answers
-- ============================================================================================================================


-- ============================================================================================================================
-- [S0]  SETUP — Create Database and Tables
-- ============================================================================================================================

CREATE DATABASE IF NOT EXISTS advanced_sql_demo;
USE advanced_sql_demo;

-- ------------------------------------------------------------
-- Q : How do you create a table with a Foreign Key?
-- A : Declare the FK with FOREIGN KEY (column) REFERENCES other_table(column)
--     The referenced column must be a PRIMARY KEY or UNIQUE in the other table.
-- ------------------------------------------------------------

CREATE TABLE customer_info (
    CustomerId  INT           PRIMARY KEY,
    FirstName   VARCHAR(50),
    LastName    VARCHAR(50),
    Age         INT,
    City        VARCHAR(50)
);

CREATE TABLE salary (
    SalaryId    INT           PRIMARY KEY,
    CustomerId  INT,
    Salary      DECIMAL(10, 2),
    FOREIGN KEY (CustomerId) REFERENCES customer_info(CustomerId)
    -- FK means: every CustomerId in salary MUST exist in customer_info
);

-- Load sample data
INSERT INTO customer_info (CustomerId, FirstName, LastName, Age, City) VALUES
(1,  'John',    'Doe',       30, 'New York'),
(2,  'Jane',    'Smith',     25, 'Los Angeles'),
(3,  'Alice',   'Johnson',   28, 'Chicago'),
(4,  'Bob',     'Brown',     35, 'Miami'),
(5,  'Charlie', 'Davis',     22, 'Seattle'),
(6,  'David',   'Wilson',    40, 'New York'),
(7,  'Emma',    'Garcia',    29, 'Los Angeles'),
(8,  'Frank',   'Martinez',  33, 'Houston'),
(9,  'Grace',   'Lopez',     31, 'Miami'),
(10, 'Hannah',  'Clark',     27, 'Chicago'),
(11, 'Isaac',   'Hernandez', 36, 'Seattle'),
(12, 'Jack',    'Lee',       45, 'Los Angeles'),
(13, 'Karen',   'Gonzalez',  38, 'New York'),
(14, 'Leo',     'Adams',     23, 'Miami'),
(15, 'Mia',     'Carter',    34, 'Houston');

INSERT INTO salary (SalaryId, CustomerId, Salary) VALUES
(1,  1,  60000.00),
(2,  2,  55000.00),
(3,  3,  70000.00),
(4,  4,  80000.00),
(5,  5,  45000.00),
(6,  6,  95000.00),
(7,  7,  58000.00),
(8,  8,  75000.00),
(9,  9,  72000.00),
(10, 10, 62000.00),
(11, 11, 90000.00),
(12, 12, 100000.00),
(13, 13, 85000.00),
(14, 14, 50000.00),
(15, 15, 68000.00);

-- Verify data loaded correctly
SELECT COUNT(*) AS customer_count FROM customer_info;  -- expect 15
SELECT COUNT(*) AS salary_count   FROM salary;         -- expect 15


-- ============================================================================================================================
-- [S1]  ORDER BY — Advanced Sorting
-- ============================================================================================================================

-- ------------------------------------------------------------
-- Q : How do you sort by a single column?
-- A : ORDER BY column [ASC | DESC]. ASC is the default.
-- ------------------------------------------------------------

-- All customers sorted A-Z by last name
SELECT FirstName, LastName, City
FROM   customer_info
ORDER BY LastName ASC;

-- Customers sorted by salary highest first
SELECT c.FirstName, c.City, s.Salary
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
ORDER BY s.Salary DESC;

-- ------------------------------------------------------------
-- Q : How do you sort by multiple columns?
-- A : List columns separated by commas. Left = primary sort key.
-- ------------------------------------------------------------

-- Sort by city A-Z, then salary high-to-low within each city
SELECT c.FirstName, c.City, s.Salary
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
ORDER BY c.City ASC, s.Salary DESC;

-- Sort by last name ASC, then first name ASC within same last name
SELECT FirstName, LastName
FROM   customer_info
ORDER BY LastName ASC, FirstName ASC;

-- ------------------------------------------------------------
-- Q : Can you sort using a column alias?
-- A : Yes — ORDER BY runs AFTER SELECT so aliases are available.
--     WHERE runs BEFORE SELECT so aliases do NOT work there.
-- ------------------------------------------------------------

SELECT c.FirstName,
       s.Salary * 12 AS annual_salary
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
ORDER BY annual_salary DESC;   -- alias works here

-- ------------------------------------------------------------
-- Q : How do you sort by a function or expression?
-- A : Put the function directly in ORDER BY.
-- ------------------------------------------------------------

-- Sort by name length (shortest names first)
SELECT FirstName, LENGTH(FirstName) AS name_len
FROM   customer_info
ORDER BY LENGTH(FirstName) ASC;

-- Sort by absolute distance from salary 70000 (closest first)
SELECT c.FirstName, s.Salary,
       ABS(s.Salary - 70000) AS dist_from_70k
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
ORDER BY ABS(s.Salary - 70000) ASC;

-- Sort by absolute value — useful for deviation analysis
SELECT Salary, ABS(Salary) AS abs_val
FROM   salary
ORDER BY ABS(Salary) DESC;

-- ------------------------------------------------------------
-- Q : How do you use CASE WHEN inside ORDER BY for custom priority?
-- A : CASE evaluates to a number — lower numbers sort first.
-- ------------------------------------------------------------

-- New York customers always first, then alphabetical by city
SELECT FirstName, City
FROM   customer_info
ORDER BY
    CASE
        WHEN City = 'New York' THEN 0   -- priority 0 = first
        ELSE                        1   -- everything else after
    END,
    City ASC;                           -- alphabetical within same priority

-- ------------------------------------------------------------
-- Q : How do LIMIT and OFFSET work for pagination?
-- A : LIMIT n = take n rows. OFFSET n = skip first n rows.
-- ------------------------------------------------------------

-- First 5 customers by last name (page 1)
SELECT * FROM customer_info ORDER BY LastName ASC LIMIT 5;

-- Next 3 customers ordered by age descending (skip 5, take 3 = rows 6-8)
SELECT * FROM customer_info ORDER BY Age DESC LIMIT 3 OFFSET 5;

-- 2nd highest salary
SELECT DISTINCT Salary AS second_highest
FROM   salary
ORDER BY Salary DESC
LIMIT  1 OFFSET 1;


-- ============================================================================================================================
-- [S2]  FILTERING — IN, AND, OR, NOT, BETWEEN, LIKE, NULL
-- ============================================================================================================================

-- ------------------------------------------------------------
-- Q : How does IN work?
-- A : Matches a column value against a list. Cleaner than multiple OR.
-- ------------------------------------------------------------

-- Customers in Chicago, Houston, or Seattle
SELECT * FROM customer_info
WHERE  City IN ('Chicago', 'Houston', 'Seattle');

-- Customers NOT in Los Angeles
SELECT * FROM customer_info
WHERE  City NOT IN ('Los Angeles');

-- ------------------------------------------------------------
-- Q : How does AND differ from OR?
-- A : AND: both conditions true. OR: at least one condition true.
-- ------------------------------------------------------------

-- AND: New York customers AND older than 30
SELECT * FROM customer_info
WHERE  City = 'New York' AND Age > 30;

-- OR: New York OR Miami customers
SELECT * FROM customer_info
WHERE  City = 'New York' OR City = 'Miami';

-- NOT: customers NOT from Los Angeles
SELECT * FROM customer_info
WHERE  NOT City = 'Los Angeles';

-- ------------------------------------------------------------
-- Q : Why are parentheses important when mixing AND and OR?
-- A : AND has higher precedence than OR — it evaluates first.
--     Without parentheses you can get unexpected results.
-- ------------------------------------------------------------

-- With parentheses — explicit grouping, clear intent
SELECT * FROM customer_info
WHERE  (City = 'Miami'   AND Age > 30)
    OR (City = 'Chicago' AND Age < 28);

-- ------------------------------------------------------------
-- Q : How does BETWEEN work? Is it inclusive?
-- A : BETWEEN is INCLUSIVE — both start and end values included.
-- ------------------------------------------------------------

-- Customers aged between 25 and 35 (25 and 35 both included)
SELECT * FROM customer_info WHERE Age BETWEEN 25 AND 35;

-- LIKE patterns
-- Customers whose last name starts with 'D'
SELECT * FROM customer_info WHERE LastName LIKE 'D%';

-- Customers whose first name contains the letter 'a'
SELECT * FROM customer_info WHERE FirstName LIKE '%a%';

-- Customers whose first name is exactly 4 characters
SELECT * FROM customer_info WHERE FirstName LIKE '____';   -- 4 underscores

-- Salary-based OR filter (with JOIN)
SELECT c.FirstName, c.Age, s.Salary
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
WHERE  c.Age < 30 OR s.Salary > 70000;


-- ============================================================================================================================
-- [S3]  GROUP BY, HAVING & MATHEMATICAL OPERATIONS
-- ============================================================================================================================

-- ------------------------------------------------------------
-- Q : How does GROUP BY work?
-- A : Splits rows into groups by column values.
--     One aggregate result is returned per group.
-- ------------------------------------------------------------

-- Number of customers per city
SELECT   City, COUNT(*) AS customer_count
FROM     customer_info
GROUP BY City
ORDER BY customer_count DESC;

-- Average salary grouped by age
SELECT   c.Age,
         ROUND(AVG(s.Salary), 2) AS avg_salary
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
GROUP BY c.Age
ORDER BY c.Age;

-- Full stats per city
SELECT   c.City,
         COUNT(*)             AS headcount,
         ROUND(AVG(s.Salary), 2) AS avg_salary,
         MAX(s.Salary)           AS top_salary,
         MIN(s.Salary)           AS min_salary,
         SUM(s.Salary)           AS total_payroll
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
GROUP BY c.City
ORDER BY avg_salary DESC;

-- ------------------------------------------------------------
-- Q : What is HAVING and when do you use it?
-- A : HAVING filters GROUPS after GROUP BY.
--     WHERE filters ROWS before GROUP BY.
--     HAVING can use aggregate functions. WHERE cannot.
-- ------------------------------------------------------------

-- Cities with more than 1 customer
SELECT   City, COUNT(*) AS count
FROM     customer_info
GROUP BY City
HAVING   COUNT(*) > 1;

-- Cities where total salary > 100,000
SELECT   c.City,
         SUM(s.Salary) AS total_salary
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
GROUP BY c.City
HAVING   SUM(s.Salary) > 100000
ORDER BY total_salary DESC;

-- Cities where average salary > 70000, and only for customers > 25 years old
SELECT   c.City,
         ROUND(AVG(s.Salary), 2) AS avg_sal
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
WHERE    c.Age > 25                -- row filter (before grouping)
GROUP BY c.City
HAVING   AVG(s.Salary) > 70000    -- group filter (after grouping)
ORDER BY avg_sal DESC;

-- ------------------------------------------------------------
-- Q : How do you perform arithmetic on columns?
-- A : Use +, -, *, /, MOD directly in SELECT.
-- ------------------------------------------------------------

-- Annual salary, tax (20%), and net pay
SELECT c.FirstName,
       s.Salary                  AS monthly,
       s.Salary * 12             AS annual,
       s.Salary * 12 * 0.20      AS tax_estimate,
       s.Salary * 12 * 0.80      AS net_annual
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId;

-- CASE WHEN for conditional bonus calculation
SELECT c.FirstName, s.Salary,
       CASE
           WHEN s.Salary >= 90000 THEN s.Salary * 0.10   -- 10% bonus
           WHEN s.Salary >= 70000 THEN s.Salary * 0.05   -- 5% bonus
           ELSE                        s.Salary * 0.02   -- 2% bonus
       END AS bonus,
       CASE
           WHEN s.Salary >= 90000 THEN 'High'
           WHEN s.Salary >= 70000 THEN 'Mid'
           ELSE                        'Entry'
       END AS salary_grade
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId;

-- Conditional aggregation: count high vs low earners per city
SELECT   c.City,
         COUNT(CASE WHEN s.Salary >= 70000 THEN 1 END) AS high_earners,
         COUNT(CASE WHEN s.Salary <  70000 THEN 1 END) AS low_earners
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
GROUP BY c.City;


-- ============================================================================================================================
-- [S4]  JOINS — INNER, LEFT, RIGHT, FULL OUTER
-- ============================================================================================================================

-- ------------------------------------------------------------
-- Q : What does INNER JOIN return?
-- A : Only rows that MATCH in BOTH tables. Unmatched rows excluded.
-- ------------------------------------------------------------

-- All customers with their salary (15 rows — all match)
SELECT   c.CustomerId,
         CONCAT(c.FirstName, ' ', c.LastName) AS full_name,
         c.City,
         s.Salary
FROM     customer_info c
INNER JOIN salary s ON c.CustomerId = s.CustomerId
ORDER BY s.Salary DESC;

-- ------------------------------------------------------------
-- Q : What does LEFT JOIN return?
-- A : ALL rows from the left table, plus matching rows from right.
--     Unmatched right rows appear as NULL.
-- ------------------------------------------------------------

-- All customers — salary is NULL if no record (simulated by adding test data)
SELECT   c.FirstName, c.City, s.Salary
FROM     customer_info c
LEFT JOIN salary s ON c.CustomerId = s.CustomerId;

-- Find customers with NO salary record (anti-join pattern)
SELECT   c.FirstName, c.City
FROM     customer_info c
LEFT JOIN salary s ON c.CustomerId = s.CustomerId
WHERE    s.SalaryId IS NULL;   -- NULL on right side means no match

-- ------------------------------------------------------------
-- Q : What does RIGHT JOIN return?
-- A : ALL rows from the right table, plus matching rows from left.
-- ------------------------------------------------------------

SELECT   c.FirstName, c.City,
         s.SalaryId, s.Salary
FROM     customer_info c
RIGHT JOIN salary s ON c.CustomerId = s.CustomerId;

-- ------------------------------------------------------------
-- Q : How do you simulate FULL OUTER JOIN in MySQL?
-- A : UNION of LEFT JOIN and RIGHT JOIN.
--     UNION automatically removes duplicates.
-- ------------------------------------------------------------

SELECT   c.FirstName, c.City, s.Salary
FROM     customer_info c
LEFT JOIN  salary s ON c.CustomerId = s.CustomerId

UNION

SELECT   c.FirstName, c.City, s.Salary
FROM     customer_info c
RIGHT JOIN salary s ON c.CustomerId = s.CustomerId;

-- ------------------------------------------------------------
-- Q : What is the difference between UNION and UNION ALL?
-- A : UNION removes duplicates. UNION ALL keeps all rows (faster).
-- ------------------------------------------------------------

-- Cities with customers older than 35 OR younger than 25 (no duplicates)
SELECT City FROM customer_info WHERE Age > 35
UNION
SELECT City FROM customer_info WHERE Age < 25;

-- Same query but keep duplicates (faster, shows how many qualify)
SELECT City FROM customer_info WHERE Age > 35
UNION ALL
SELECT City FROM customer_info WHERE Age < 25;

-- ------------------------------------------------------------
-- Q : How do you do a self join?
-- A : JOIN the table to itself using two different aliases.
-- ------------------------------------------------------------

-- Find pairs of customers in the same city where one is older
SELECT a.FirstName AS older_customer,
       b.FirstName AS younger_customer,
       a.City,
       a.Age AS age_a, b.Age AS age_b
FROM   customer_info a
JOIN   customer_info b
    ON a.City = b.City
    AND a.Age > b.Age
ORDER BY a.City, a.Age DESC;


-- ============================================================================================================================
-- [S5]  SUBQUERIES — Scalar, Table, Correlated, EXISTS
-- ============================================================================================================================

-- ------------------------------------------------------------
-- Q : What is a scalar subquery?
-- A : Returns a single value. Used in WHERE, SELECT, or HAVING.
-- ------------------------------------------------------------

-- Customers earning more than the company-wide average
SELECT   c.FirstName, c.City, s.Salary
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
WHERE    s.Salary > (SELECT AVG(Salary) FROM salary)   -- single value: ~72,600
ORDER BY s.Salary DESC;

-- Customer with the maximum salary
SELECT c.FirstName, s.Salary
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
WHERE  s.Salary = (SELECT MAX(Salary) FROM salary);

-- Show average salary alongside every row (in SELECT)
SELECT c.FirstName, s.Salary,
       (SELECT ROUND(AVG(Salary), 2) FROM salary) AS company_avg,
       s.Salary - (SELECT AVG(Salary) FROM salary) AS diff_from_avg
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId;

-- ------------------------------------------------------------
-- Q : What is a table subquery (derived table)?
-- A : Returns rows + columns. Used in FROM as a virtual table.
--     Must have an alias.
-- ------------------------------------------------------------

-- Filter the grouped result
SELECT stats.City, stats.avg_sal
FROM   (
    SELECT   c.City,
             ROUND(AVG(s.Salary), 2) AS avg_sal,
             COUNT(*) AS cnt
    FROM     customer_info c
    JOIN     salary s ON c.CustomerId = s.CustomerId
    GROUP BY c.City
) AS stats
WHERE  stats.avg_sal > 70000
ORDER BY stats.avg_sal DESC;

-- ------------------------------------------------------------
-- Q : What is a correlated subquery?
-- A : References a column from the outer query.
--     Re-executes once for every row in the outer query.
-- ------------------------------------------------------------

-- Customers earning more than their OWN city's average salary
SELECT   c.FirstName, c.City, s.Salary
FROM     customer_info  c
JOIN     salary         s  ON c.CustomerId = s.CustomerId
WHERE    s.Salary > (
             SELECT AVG(s2.Salary)
             FROM   customer_info  c2
             JOIN   salary         s2 ON c2.CustomerId = s2.CustomerId
             WHERE  c2.City = c.City    -- references outer query's c.City
         )
ORDER BY c.City, s.Salary DESC;

-- ------------------------------------------------------------
-- Q : How do you use IN with a subquery?
-- A : The subquery returns a list of values; IN tests membership.
-- ------------------------------------------------------------

-- Customers living in cities that have at least 2 customers
SELECT FirstName, City
FROM   customer_info
WHERE  City IN (
    SELECT   City
    FROM     customer_info
    GROUP BY City
    HAVING   COUNT(*) >= 2
)
ORDER BY City;

-- ------------------------------------------------------------
-- Q : How does EXISTS differ from IN?
-- A : EXISTS returns TRUE on the first match (stops early).
--     IN loads the full list first then checks. EXISTS is faster for large tables.
-- ------------------------------------------------------------

-- Customers who have a salary record (EXISTS version)
SELECT c.FirstName, c.City
FROM   customer_info c
WHERE  EXISTS (
    SELECT 1 FROM salary s WHERE s.CustomerId = c.CustomerId
);


-- ============================================================================================================================
-- [S6]  WINDOW FUNCTIONS
-- ============================================================================================================================

-- ------------------------------------------------------------
-- Q : What is a window function? How does it differ from GROUP BY?
-- A : Window function keeps ALL rows, adds a computed column.
--     GROUP BY collapses rows into groups (fewer rows returned).
-- ------------------------------------------------------------

-- Rank all customers by salary (highest = rank 1)
SELECT c.FirstName, c.City, s.Salary,
       ROW_NUMBER()  OVER (ORDER BY s.Salary DESC) AS row_num,
       RANK()        OVER (ORDER BY s.Salary DESC) AS salary_rank,
       DENSE_RANK()  OVER (ORDER BY s.Salary DESC) AS dense_rank
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId;

-- ------------------------------------------------------------
-- Q : What does PARTITION BY do inside OVER()?
-- A : Divides rows into groups like GROUP BY, but all rows still appear.
--     Window function resets for each partition.
-- ------------------------------------------------------------

-- Rank salary within EACH CITY separately
SELECT c.FirstName, c.City, s.Salary,
       RANK() OVER (
           PARTITION BY c.City
           ORDER BY     s.Salary DESC
       ) AS city_rank
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
ORDER BY c.City, city_rank;

-- City average salary alongside every individual row
SELECT c.FirstName, c.City, s.Salary,
       ROUND(AVG(s.Salary) OVER (PARTITION BY c.City), 2) AS city_avg_salary
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
ORDER BY c.City;

-- ------------------------------------------------------------
-- Q : How do you get the top-1 earner per city?
-- A : RANK() with PARTITION BY, wrap in subquery, filter WHERE rank = 1.
--     This is one of the most common interview patterns.
-- ------------------------------------------------------------

SELECT * FROM (
    SELECT c.FirstName, c.City, s.Salary,
           RANK() OVER (PARTITION BY c.City ORDER BY s.Salary DESC) AS rnk
    FROM   customer_info c
    JOIN   salary s ON c.CustomerId = s.CustomerId
) ranked
WHERE  rnk = 1;

-- ------------------------------------------------------------
-- Q : What do LEAD() and LAG() do?
-- A : LAG  returns the value from the PREVIOUS row in the window.
--     LEAD returns the value from the NEXT    row in the window.
-- ------------------------------------------------------------

-- Show previous and next salary for each customer
SELECT c.FirstName, s.Salary,
       LAG(s.Salary)  OVER (ORDER BY s.Salary) AS prev_salary,
       LEAD(s.Salary) OVER (ORDER BY s.Salary) AS next_salary,
       s.Salary - LAG(s.Salary) OVER (ORDER BY s.Salary) AS increase
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
ORDER BY s.Salary;

-- ------------------------------------------------------------
-- Q : How do you calculate a running (cumulative) total?
-- A : SUM() with OVER(ORDER BY) and ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.
-- ------------------------------------------------------------

SELECT c.FirstName, s.Salary,
       SUM(s.Salary) OVER (
           ORDER BY s.Salary
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
ORDER BY s.Salary;

-- Running total partitioned by city
SELECT c.FirstName, c.City, s.Salary,
       SUM(s.Salary) OVER (
           PARTITION BY c.City
           ORDER BY     s.Salary
       ) AS city_running_total
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
ORDER BY c.City, s.Salary;

-- ------------------------------------------------------------
-- Q : What is NTILE()?
-- A : Divides rows into n equal buckets. Useful for quartiles.
-- ------------------------------------------------------------

-- Divide customers into 4 salary quartiles
SELECT c.FirstName, s.Salary,
       NTILE(4) OVER (ORDER BY s.Salary) AS salary_quartile
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId;

-- Salary percentile (100 buckets)
SELECT c.FirstName, s.Salary,
       NTILE(100) OVER (ORDER BY s.Salary) AS percentile
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId;


-- ============================================================================================================================
-- [S7]  ETL — EXTRACT, TRANSFORM, LOAD
-- ============================================================================================================================

-- ------------------------------------------------------------
-- Q : How do you extract data from a CSV file into a table?
-- A : LOAD DATA INFILE with delimiter and line terminator settings.
-- ------------------------------------------------------------

-- Enable file loading (may need admin rights)
-- SET GLOBAL local_infile = 1;

-- Load from CSV (adjust path to your actual file location)
-- LOAD DATA INFILE '/path/to/customers.csv'
-- INTO TABLE customer_info
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (CustomerId, FirstName, LastName, Age, City);

-- ------------------------------------------------------------
-- Q : How do you transform data during a query?
-- A : Use CASE WHEN to normalize, TRIM/UPPER to clean, arithmetic to derive.
-- ------------------------------------------------------------

-- Normalize inconsistent salary scale (if some are 0-5, others 0-10)
SELECT c.FirstName, s.Salary,
       CASE
           WHEN s.Salary <= 5  THEN s.Salary / 5.0
           ELSE                     s.Salary / 10.0
       END AS normalized_salary
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId;

-- Clean up city names (remove whitespace, standardize case)
UPDATE customer_info SET City = TRIM(City);        -- remove leading/trailing spaces
-- UPDATE customer_info SET City = UPPER(City);    -- uncomment to uppercase all

-- Fill NULL ages with the average age
-- UPDATE customer_info
-- SET    Age = (SELECT ROUND(AVG(Age)) FROM customer_info WHERE Age IS NOT NULL)
-- WHERE  Age IS NULL;

-- ------------------------------------------------------------
-- Q : How do you Load (write) transformed data into a new table?
-- A : CREATE TABLE + INSERT ... SELECT — builds and fills in one step.
-- ------------------------------------------------------------

-- Create the target summary table
CREATE TABLE IF NOT EXISTS city_salary_summary (
    City            VARCHAR(50),
    avg_salary      DECIMAL(10, 2),
    total_salary    DECIMAL(12, 2),
    customer_count  INT
);

-- Insert transformed/aggregated data into the target table (the Load step)
INSERT INTO city_salary_summary
SELECT   c.City,
         ROUND(AVG(s.Salary), 2),
         SUM(s.Salary),
         COUNT(*)
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
GROUP BY c.City;

-- Verify the loaded summary
SELECT * FROM city_salary_summary ORDER BY avg_salary DESC;


-- ============================================================================================================================
-- [S8]  STATISTICAL ANALYSIS
-- ============================================================================================================================

-- ------------------------------------------------------------
-- Q : What statistical functions does MySQL support natively?
-- A : AVG, VARIANCE, STDDEV (and STDDEV_POP, STDDEV_SAMP).
-- ------------------------------------------------------------

-- Complete salary statistics
SELECT
    COUNT(*)                          AS total_records,
    ROUND(AVG(Salary), 2)             AS mean_salary,
    ROUND(VARIANCE(Salary), 2)        AS variance,
    ROUND(STDDEV(Salary), 2)          AS std_deviation,
    MAX(Salary) - MIN(Salary)         AS salary_range,
    MAX(Salary)                       AS maximum,
    MIN(Salary)                       AS minimum
FROM salary;

-- Statistics per city
SELECT   c.City,
         COUNT(*)                    AS count,
         ROUND(AVG(s.Salary), 2)     AS avg_sal,
         ROUND(STDDEV(s.Salary), 2)  AS std_dev,
         MIN(s.Salary)               AS min_sal,
         MAX(s.Salary)               AS max_sal
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
GROUP BY c.City
ORDER BY avg_sal DESC;

-- ------------------------------------------------------------
-- Q : How do you calculate variance manually (for understanding)?
-- A : Variance = SUM((value - mean)²) / (n - 1)  for sample variance.
-- ------------------------------------------------------------

SELECT
    SUM((Salary - AVG(Salary) OVER()) * (Salary - AVG(Salary) OVER())) /
    (COUNT(*) OVER() - 1) AS sample_variance
FROM   salary
LIMIT  1;

-- Find salaries that are more than 1 standard deviation above the mean
SELECT c.FirstName, s.Salary
FROM   customer_info c
JOIN   salary s ON c.CustomerId = s.CustomerId
WHERE  s.Salary > (SELECT AVG(Salary) + STDDEV(Salary) FROM salary)
ORDER BY s.Salary DESC;


-- ============================================================================================================================
-- [S9]  STORED PROCEDURES
-- ============================================================================================================================

-- ------------------------------------------------------------
-- Q : What is a stored procedure and why use DELIMITER?
-- A : A named, saved SQL routine called by CALL.
--     DELIMITER changes the end-of-statement marker so MySQL doesn't
--     interpret semicolons inside the procedure as the end of the CREATE.
-- ------------------------------------------------------------

-- Basic procedure: get customer info by ID
DELIMITER //
CREATE PROCEDURE GetCustInfo (IN Customer_Id INT)
BEGIN
    SELECT * FROM customer_info
    WHERE  CustomerId = Customer_Id;
END //
DELIMITER ;

CALL GetCustInfo(7);
CALL GetCustInfo(12);

-- ------------------------------------------------------------
-- Q : How do you pass multiple input parameters?
-- A : List them in the parameter list separated by commas.
-- ------------------------------------------------------------

-- Filter customers by city with a minimum salary
DELIMITER //
CREATE PROCEDURE GetCustomersByCity (
    IN p_city       VARCHAR(50),
    IN p_min_salary DECIMAL(10, 2)
)
BEGIN
    SELECT   c.FirstName, c.LastName, c.City, s.Salary
    FROM     customer_info c
    JOIN     salary s ON c.CustomerId = s.CustomerId
    WHERE    c.City     = p_city
    AND      s.Salary  >= p_min_salary
    ORDER BY s.Salary DESC;
END //
DELIMITER ;

CALL GetCustomersByCity('New York', 70000);
CALL GetCustomersByCity('Miami',     50000);

-- ------------------------------------------------------------
-- Q : How do you use an OUT parameter to return a value?
-- A : Declare with OUT, use SELECT ... INTO variable inside the procedure.
-- ------------------------------------------------------------

DELIMITER //
CREATE PROCEDURE GetAvgSalary (OUT avg_result DECIMAL(10, 2))
BEGIN
    SELECT AVG(Salary) INTO avg_result FROM salary;
END //
DELIMITER ;

CALL GetAvgSalary(@result);
SELECT @result AS company_average_salary;

-- Salary grade procedure with CASE WHEN logic
DELIMITER //
CREATE PROCEDURE GetSalaryGrade (IN cust_id INT, OUT grade VARCHAR(20))
BEGIN
    DECLARE cust_salary DECIMAL(10, 2);
    SELECT Salary INTO cust_salary FROM salary WHERE CustomerId = cust_id;

    SET grade = CASE
        WHEN cust_salary >= 90000 THEN 'Executive'
        WHEN cust_salary >= 70000 THEN 'Senior'
        WHEN cust_salary >= 55000 THEN 'Mid Level'
        ELSE                           'Entry Level'
    END;
END //
DELIMITER ;

CALL GetSalaryGrade(6, @grade);
SELECT @grade AS salary_grade;    -- David Wilson, $95k → Executive


-- ============================================================================================================================
-- [S10]  WORKSHOP — All 16 Slide Deck Questions with Answers
-- ============================================================================================================================

-- ── LEVEL 1 : BASIC ─────────────────────────────────────────────────────────

-- W1 : Average salary of customers grouped by their age
SELECT   c.Age,
         ROUND(AVG(s.Salary), 2) AS avg_salary
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
GROUP BY c.Age
ORDER BY c.Age;

-- W2 : First 5 customers ordered by last name ascending
SELECT * FROM customer_info ORDER BY LastName ASC LIMIT 5;

-- W3 : All customers ordered by last name ascending
SELECT * FROM customer_info ORDER BY LastName ASC;

-- W4 : Number of customers in each city — only cities with more than 1
SELECT   City, COUNT(*) AS count
FROM     customer_info
GROUP BY City
HAVING   COUNT(*) > 1
ORDER BY count DESC;

-- W5 : All customers along with their salaries (JOIN)
SELECT   c.CustomerId,
         CONCAT(c.FirstName, ' ', c.LastName) AS full_name,
         c.City, c.Age,
         s.Salary
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
ORDER BY s.Salary DESC;

-- ── LEVEL 2 : FILTERING & SUBQUERIES ────────────────────────────────────────

-- W6 : Customers who earn more than the average salary
SELECT   c.FirstName, c.City, s.Salary
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
WHERE    s.Salary > (SELECT AVG(Salary) FROM salary)
ORDER BY s.Salary DESC;

-- W7 : Total salary by city — only cities where total > $100,000
SELECT   c.City,
         SUM(s.Salary) AS total_salary
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
GROUP BY c.City
HAVING   SUM(s.Salary) > 100000
ORDER BY total_salary DESC;

-- W8 : Customers in "New York" OR "Miami" AND older than 30
SELECT * FROM customer_info
WHERE  City IN ('New York', 'Miami') AND Age > 30;

-- W9 : Customers whose last name starts with 'D'
SELECT * FROM customer_info WHERE LastName LIKE 'D%';

-- W10 : Customers whose city is "Chicago", "Houston", or "Seattle"
SELECT * FROM customer_info
WHERE  City IN ('Chicago', 'Houston', 'Seattle');

-- W11 : Customers aged between 25 and 35 (inclusive)
SELECT * FROM customer_info WHERE Age BETWEEN 25 AND 35;

-- ── LEVEL 3 : CHALLENGE ──────────────────────────────────────────────────────

-- W12 : Customers whose first name contains the letter 'a'
SELECT * FROM customer_info WHERE FirstName LIKE '%a%';

-- W13 : Customers younger than 30 OR salary greater than $70,000
SELECT   c.FirstName, c.Age, s.Salary
FROM     customer_info c
JOIN     salary s ON c.CustomerId = s.CustomerId
WHERE    c.Age < 30 OR s.Salary > 70000
ORDER BY c.Age;

-- W14 : Customers NOT living in "Los Angeles"
SELECT * FROM customer_info WHERE City NOT IN ('Los Angeles');

-- W15 : From "Miami" AND older than 30, OR from "Chicago" AND younger than 28
SELECT * FROM customer_info
WHERE  (City = 'Miami'   AND Age > 30)
    OR (City = 'Chicago' AND Age < 28);

-- W16 : Next 3 customers (rows 6-8) ordered by age descending
SELECT * FROM customer_info ORDER BY Age DESC LIMIT 3 OFFSET 5;


-- ============================================================================================================================
-- END OF FILE
-- ============================================================================================================================
--
--  Summary of all sections:
--  [S0]  Setup          — CREATE TABLE with FK, INSERT data
--  [S1]  ORDER BY       — Single/multi-col, alias, expression, CASE, LIMIT+OFFSET
--  [S2]  Filtering      — IN, NOT IN, AND, OR, NOT, BETWEEN, LIKE, NULL
--  [S3]  GROUP BY       — Aggregate per group, HAVING, math, conditional aggregation
--  [S4]  JOINs          — INNER, LEFT, RIGHT, FULL OUTER via UNION, self join
--  [S5]  Subqueries     — Scalar, derived table, correlated, IN, EXISTS
--  [S6]  Window Fns     — RANK, DENSE_RANK, ROW_NUMBER, PARTITION BY, LEAD, LAG, NTILE, SUM OVER
--  [S7]  ETL            — LOAD DATA INFILE, transform with CASE/TRIM, INSERT...SELECT
--  [S8]  Statistics     — VARIANCE, STDDEV, manual variance, outlier detection
--  [S9]  Stored Procs   — IN param, multi param, OUT param, CASE logic inside proc
--  [S10] Workshop       — All 16 hands-on questions from Day 2 slides
--
-- ============================================================================================================================
