# SQL Practice

SQL practice queries I wrote while learning Microsoft SQL Server (T-SQL). Each file covers one topic and has short, labeled examples with sample data and the expected result, so any example can be copied and run as it is.

## Files

| File | Topic | What it shows |
| --- | --- | --- |
| [01_copying_data_between_tables.sql](01_copying_data_between_tables.sql) | Copying data | `INSERT INTO ... SELECT` and `SELECT ... INTO`, filtering by amount, date and status, archiving old orders, backing up a table |
| [02_updating_and_deleting_data.sql](02_updating_and_deleting_data.sql) | Changing data | `UPDATE` based on a column's current value (inventory, library copies), `DELETE` by status and by date |
| [03_table_design_and_constraints.sql](03_table_design_and_constraints.sql) | Table design | `PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `CHECK` and `DEFAULT`, with examples of inserts each constraint rejects |

## How to run

Paste any example into a SQL Server environment, such as [OneCompiler's SQL Server editor](https://onecompiler.com/sqlserver), SQL Server Management Studio or Azure Data Studio, and run it. Each example creates its own tables, so no setup is needed.

## Skills practiced

- Creating tables with data types and constraints
- Inserting, updating and deleting rows with targeted `WHERE` filters
- Copying and archiving data between tables
- String and date functions: `CONCAT`, `GETDATE`, `CAST`
- Sorting results with `ORDER BY`

## Next up

Joins across related tables, and aggregate queries with `GROUP BY`, `COUNT`, `SUM` and `AVG`.
