/*
  Table design and constraints (Microsoft SQL Server / T-SQL)

  Constraints are rules the database enforces on every insert and update:
    - PRIMARY KEY  -> each row has a unique, required ID
    - NOT NULL     -> the column must have a value
    - UNIQUE       -> no two rows can share the same value
    - CHECK        -> the value must pass a condition
    - DEFAULT      -> a value is filled in automatically when none is given

  Each example below is self-contained and can be run on its own.
*/


/* ------------------------------------------------------------------
   1. Library catalog
      Constraints: NOT NULL, CHECK on a year range
   ------------------------------------------------------------------ */

CREATE TABLE Library (
    BookId           INT PRIMARY KEY,
    Title            VARCHAR(150) NOT NULL,
    Author           VARCHAR(100) NOT NULL,
    PublicationYear  INT CHECK (PublicationYear > 1900),
    Copies           INT
);

-- Text values use single quotes in SQL Server
INSERT INTO Library (BookId, Title, Author, PublicationYear, Copies)
VALUES
    (1, 'Functional Skills Maths 1', 'John Doe',     2009, 5),
    (2, 'Upstream Intermediate',     'Jane Smith',   2019, 3),
    (3, 'Python Basics',             'Mike Johnson', 2021, 7);

SELECT BookId, Title, Author, PublicationYear, Copies
FROM Library;   -- Expected: 3 books

-- This insert is rejected by the CHECK constraint (1850 is not after 1900).
-- Remove the comment markers to see the error.
-- INSERT INTO Library (BookId, Title, Author, PublicationYear, Copies)
-- VALUES (4, 'Old Almanac', 'Unknown Author', 1850, 1);
GO


/* ------------------------------------------------------------------
   2. Course enrollments
      Constraint: DEFAULT to today's date
   ------------------------------------------------------------------ */

CREATE TABLE Enrollments (
    enrollment_id    INT PRIMARY KEY,
    enrollment_date  DATE DEFAULT CAST(GETDATE() AS DATE)
);

-- Only the ID is given; SQL Server fills in today's date
INSERT INTO Enrollments (enrollment_id) VALUES (1), (2);

-- A specific date can still be given when needed
INSERT INTO Enrollments (enrollment_id, enrollment_date) VALUES (3, '2026-09-01');

SELECT enrollment_id, enrollment_date
FROM Enrollments;   -- Expected: rows 1 and 2 show today's date, row 3 shows 2026-09-01
GO


/* ------------------------------------------------------------------
   3. Course catalog
      Constraints: UNIQUE, CHECK, NOT NULL
   ------------------------------------------------------------------ */

CREATE TABLE Courses (
    course_id       INT PRIMARY KEY,
    course_name     VARCHAR(100) UNIQUE,
    duration_weeks  INT CHECK (duration_weeks > 0),
    price           DECIMAL(8,2) NOT NULL
);

INSERT INTO Courses (course_id, course_name, duration_weeks, price)
VALUES
    (1, 'Intro to SQL',       6, 149.00),
    (2, 'Python Basics',      8, 199.00),
    (3, 'Cloud Fundamentals', 4,  99.00);

-- The CHECK constraint in action: a course can't last 0 weeks.
-- This insert fails on purpose. SQL Server returns:
--   Msg 547: The INSERT statement conflicted with the CHECK constraint "CK__Courses__durat..."
--   The statement has been terminated.
INSERT INTO Courses (course_id, course_name, duration_weeks, price)
VALUES (4, 'Intro to Data Science', 0, 50.00);

-- Lesson learned while testing: when this bad row was in the SAME INSERT as the
-- three valid courses, SQL Server rejected the whole statement and none of the
-- four rows were added. One invalid row cancels the entire INSERT, so the bad
-- row is kept in its own statement here and the valid courses still load.

SELECT course_id, course_name, duration_weeks, price
FROM Courses
ORDER BY price;   -- Expected: the 3 valid courses, cheapest first; course 4 is not there

-- The other two constraints reject rows the same way.
-- Remove the comment markers to see each error.
-- INSERT INTO Courses VALUES (5, 'Intro to SQL', 6, 149.00);   -- UNIQUE: duplicate course name
-- INSERT INTO Courses VALUES (6, 'Free Webinar', 1, NULL);     -- NOT NULL: price is required
GO


/* ------------------------------------------------------------------
   4. Learner records
      Constraints: NOT NULL, DEFAULT text value
   ------------------------------------------------------------------ */

CREATE TABLE Learners (
    id          INT PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    birth_date  DATE,
    city        VARCHAR(50) DEFAULT 'Unknown'
);

INSERT INTO Learners (id, first_name, last_name, birth_date, city)
VALUES (1, 'Maria', 'Lopez', '2001-04-12', 'San Antonio');

-- No city given, so the DEFAULT fills in 'Unknown'
INSERT INTO Learners (id, first_name, last_name, birth_date)
VALUES (2, 'Daniel', 'Kim', '1999-08-30');

SELECT id, first_name, last_name, city
FROM Learners;   -- Expected: Maria in San Antonio, Daniel with city 'Unknown'
GO
