/*
  Copying data between tables (Microsoft SQL Server / T-SQL)

  Two ways to copy rows from one table into another:
    - INSERT INTO ... SELECT  -> the target table must already exist; you control its design.
    - SELECT ... INTO         -> SQL Server creates the target table for you from the result.

  Each example below is self-contained and can be run on its own.
*/


/* ------------------------------------------------------------------
   1. Build a VIP list from customers who spent over $1,000
      Technique: INSERT INTO ... SELECT, CONCAT, WHERE
   ------------------------------------------------------------------ */

CREATE TABLE Customers (
    customer_id  INT PRIMARY KEY,
    first_name   VARCHAR(50),
    last_name    VARCHAR(50),
    total_spent  DECIMAL(10,2)
);

INSERT INTO Customers (customer_id, first_name, last_name, total_spent)
VALUES
    (1, 'Alice',   'Johnson', 1500.00),
    (2, 'Bob',     'Smith',    400.00),
    (3, 'Charlie', 'Davis',   1200.00),
    (4, 'Diana',   'White',   2500.00);

CREATE TABLE VIP_Customers (
    customer_id  INT PRIMARY KEY,
    full_name    VARCHAR(100),
    total_spent  DECIMAL(10,2)
);

-- Combine first and last name into one column while copying
INSERT INTO VIP_Customers (customer_id, full_name, total_spent)
SELECT customer_id,
       CONCAT(first_name, ' ', last_name) AS full_name,
       total_spent
FROM Customers
WHERE total_spent > 1000;

SELECT customer_id, full_name, total_spent
FROM VIP_Customers
ORDER BY total_spent DESC;   -- Expected: Diana, Alice, Charlie
GO


/* ------------------------------------------------------------------
   2. Archive orders placed before 2021
      Technique: INSERT INTO ... SELECT with a date filter, then DELETE
   ------------------------------------------------------------------ */

CREATE TABLE Orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT,
    product_name  VARCHAR(50),
    quantity      INT,
    order_date    DATE
);

CREATE TABLE Old_Orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT,
    product_name  VARCHAR(50),
    quantity      INT,
    order_date    DATE
);

INSERT INTO Orders (order_id, customer_id, product_name, quantity, order_date)
VALUES
    (1, 1, 'Laptop',   1, '2022-01-10'),
    (2, 2, 'Mouse',    2, '2019-05-10'),
    (3, 3, 'Keyboard', 1, '2020-11-22'),
    (4, 1, 'Monitor',  1, '2018-07-15');

-- Copy old orders into the archive...
INSERT INTO Old_Orders (order_id, customer_id, product_name, quantity, order_date)
SELECT order_id, customer_id, product_name, quantity, order_date
FROM Orders
WHERE order_date < '2021-01-01';

-- ...then remove them from the active table, so they are moved, not duplicated
DELETE FROM Orders
WHERE order_date < '2021-01-01';

SELECT order_id, product_name, order_date FROM Old_Orders ORDER BY order_date;  -- Expected: 3 archived orders
SELECT order_id, product_name, order_date FROM Orders;                          -- Expected: only the 2022 laptop order
GO

DROP TABLE Orders;   -- Cleared so the next example can reuse the name
GO


/* ------------------------------------------------------------------
   3. Pull high-value orders (over $500) into their own table
      Technique: SELECT ... INTO
   ------------------------------------------------------------------ */

CREATE TABLE Orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT,
    product_name  VARCHAR(50),
    quantity      INT,
    total_price   DECIMAL(10,2),
    order_date    DATE
);

INSERT INTO Orders (order_id, customer_id, product_name, quantity, total_price, order_date)
VALUES
    (1, 101, 'Laptop',      2, 2400.00, '2023-01-15'),
    (2, 102, 'Smartphone',  1,  800.00, '2023-01-20'),
    (3, 103, 'Desk Chair',  4,  600.00, '2023-02-05'),
    (4, 104, 'Monitor',     2,  400.00, '2023-02-10'),
    (5, 105, 'Keyboard',    3,  150.00, '2023-02-15'),
    (6, 106, 'Office Desk', 1,  700.00, '2023-03-01'),
    (7, 107, 'Headphones',  2,  300.00, '2023-03-10'),
    (8, 108, 'Printer',     1,  550.00, '2023-03-20');

-- SQL Server creates High_Value_Orders automatically from this result
SELECT order_id, customer_id, product_name, quantity, total_price, order_date
INTO High_Value_Orders
FROM Orders
WHERE total_price > 500;

SELECT order_id, product_name, total_price
FROM High_Value_Orders
ORDER BY total_price DESC;   -- Expected: 5 orders, Laptop through Printer
GO


/* ------------------------------------------------------------------
   4. Separate completed projects from the full project list
      Technique: SELECT ... INTO with a text filter
   ------------------------------------------------------------------ */

CREATE TABLE Projects (
    ProjectID    INT PRIMARY KEY,
    ProjectName  VARCHAR(100),
    Status       VARCHAR(50),
    Budget       DECIMAL(10,2)
);

INSERT INTO Projects (ProjectID, ProjectName, Status, Budget)
VALUES
    (1, 'Website Redesign',       'completed',   15000.00),
    (2, 'Mobile App Development', 'in progress', 25000.00),
    (3, 'SEO Optimization',       'completed',    8000.00),
    (4, 'Cloud Migration',        'planned',     30000.00),
    (5, 'CRM Integration',        'completed',   18000.00),
    (6, 'Data Analytics Setup',   'in progress', 27000.00),
    (7, 'Marketing Automation',   'completed',   22000.00),
    (8, 'Security Audit',         'planned',     12000.00);

SELECT ProjectID, ProjectName, Status, Budget
INTO Completed_Projects
FROM Projects
WHERE Status = 'completed';

SELECT ProjectID, ProjectName, Budget
FROM Completed_Projects
ORDER BY Budget DESC;   -- Expected: 4 completed projects
GO


/* ------------------------------------------------------------------
   5. Back up a whole table before making changes
      Technique: SELECT ... INTO with no filter (full copy)
   ------------------------------------------------------------------ */

CREATE TABLE Employees (
    employee_id    INT PRIMARY KEY,
    first_name     VARCHAR(50),
    last_name      VARCHAR(50),
    department_id  INT,
    hire_date      DATE
);

INSERT INTO Employees (employee_id, first_name, last_name, department_id, hire_date)
VALUES
    (1, 'James',  'Smith', 1, '2015-12-01'),
    (2, 'Amelia', 'King',  2, '2017-03-06'),
    (3, 'Robert', 'Brown', 3, '2018-07-20');

SELECT employee_id, first_name, last_name, department_id, hire_date
INTO Employees_Backup
FROM Employees;

SELECT employee_id, first_name, last_name, hire_date
FROM Employees_Backup;   -- Expected: all 3 employees
GO
