/*
  Updating and deleting data (Microsoft SQL Server / T-SQL)

  UPDATE changes values in existing rows; DELETE removes rows.
  Both use WHERE to target only the rows that should change.
  Without a WHERE clause, every row in the table is affected.

  Each example below is self-contained and can be run on its own.
*/


/* ------------------------------------------------------------------
   1. Remove cancelled orders
      Technique: DELETE with a text filter
   ------------------------------------------------------------------ */

CREATE TABLE Orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT,
    product_name  VARCHAR(50),
    quantity      INT,
    status        VARCHAR(20)
);

INSERT INTO Orders (order_id, customer_id, product_name, quantity, status)
VALUES
    (1, 1, 'Laptop',   1, 'completed'),
    (2, 2, 'Mouse',    2, 'cancelled'),
    (3, 3, 'Keyboard', 1, 'completed'),
    (4, 2, 'Monitor',  1, 'cancelled');

DELETE FROM Orders
WHERE status = 'cancelled';

SELECT order_id, product_name, status
FROM Orders;   -- Expected: only the 2 completed orders remain
GO


/* ------------------------------------------------------------------
   2. Remove customers who haven't purchased since before 2021
      Technique: DELETE with a date filter
   ------------------------------------------------------------------ */

CREATE TABLE Customers (
    customer_id         INT PRIMARY KEY,
    first_name          VARCHAR(50),
    last_name           VARCHAR(50),
    email               VARCHAR(100),
    last_purchase_date  DATE
);

INSERT INTO Customers (customer_id, first_name, last_name, email, last_purchase_date)
VALUES
    (1, 'Alice',   'Johnson', 'alice@example.com',   '2023-01-15'),
    (2, 'Bob',     'Smith',   'bob@example.com',     '2020-05-10'),
    (3, 'Charlie', 'Davis',   'charlie@example.com', '2019-11-22');

DELETE FROM Customers
WHERE last_purchase_date < '2021-01-01';

SELECT customer_id, first_name, last_name, last_purchase_date
FROM Customers;   -- Expected: only Alice remains
GO


/* ------------------------------------------------------------------
   3. Reduce stock after a sale
      Technique: UPDATE using the column's current value
   ------------------------------------------------------------------ */

CREATE TABLE Shop (
    product_id  INT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    price       DECIMAL(7,2),
    stock       INT
);

INSERT INTO Shop (product_id, name, price, stock)
VALUES
    (1, 'Laptop',   1200.00, 10),
    (2, 'Mouse',      25.50, 50),
    (3, 'Keyboard',   45.00, 30);

-- Sold 5 mice: subtract from the existing stock instead of overwriting it
UPDATE Shop
SET stock = stock - 5
WHERE name = 'Mouse';

SELECT product_id, name, stock
FROM Shop;   -- Expected: Mouse stock goes from 50 to 45
GO


/* ------------------------------------------------------------------
   4. Add copies of older books to the library
      Technique: UPDATE with a numeric range filter
   ------------------------------------------------------------------ */

CREATE TABLE Library (
    book_id           INT PRIMARY KEY,
    title             VARCHAR(100) NOT NULL,
    author            VARCHAR(50),
    publication_year  INT,
    copies_available  INT
);

INSERT INTO Library (book_id, title, author, publication_year, copies_available)
VALUES
    (1, '1984',                  'George Orwell',       1949, 5),
    (2, 'To Kill a Mockingbird', 'Harper Lee',          1960, 3),
    (3, 'The Great Gatsby',      'F. Scott Fitzgerald', 1925, 2);

-- Add 3 copies to every book published before 1950
UPDATE Library
SET copies_available = copies_available + 3
WHERE publication_year < 1950;

SELECT title, publication_year, copies_available
FROM Library
ORDER BY publication_year;   -- Expected: Gatsby 5, 1984 8, Mockingbird unchanged at 3
GO
