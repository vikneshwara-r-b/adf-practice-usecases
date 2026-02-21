/*
Parameter name: table_list
Datatype: array
Value:
[
  {
    "tableName": "employees",
    "tableSchemaName": "dbo",
    "Watermark_Column": "last_updated"
  },
  {
    "tableName": "salesitems",
    "tableSchemaName": "dbo",
    "Watermark_Column": "last_updated"
  }
]
*/

/* 
Source server - sql_prod_source,sql_prod_intermediate
Target server - sql_prod_target
1. Create table in sql_prod_source, sql_prod_intermediate and sql_prod_target database
2. Insert data only in sql_prod_source 
*/

/* Execute the following in source SQL server*/
CREATE DATABASE sql_prod_source;
CREATE DATABASE sql_prod_intermediate;

/* Execute the following in target SQL server*/
CREATE DATABASE sql_prod_target;


CREATE TABLE employees (
    id INT PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    dep NVARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    last_updated DATETIME NOT NULL
);

INSERT INTO employees (id, name, dep, salary, last_updated)
VALUES
(1,'Amit','IT',65000,'2026-02-10'),
(2,'Neha','HR',52000,'2026-02-05'),
(3,'Ravi','Finance',72000,'2026-02-01'),
(4,'Pooja','Marketing',58000,'2026-01-28'),
(5,'Suresh','IT',69000,'2026-01-25'),
(6,'Anita','HR',51000,'2026-01-22'),
(7,'Rahul','Finance',75000,'2026-01-18'),
(8,'Kiran','Marketing',60000,'2026-01-15'),
(9,'Vikram','IT',70000,'2026-01-12'),
(10,'Meena','HR',53000,'2026-01-08'),
(11,'Arjun','Finance',77000,'2026-01-04'),
(12,'Divya','Marketing',61000,'2025-12-30'),
(13,'Manoj','IT',68000,'2025-12-26'),
(14,'Sneha','HR',54000,'2025-12-22'),
(15,'Nikhil','Finance',74000,'2025-12-18'),
(16,'Ritika','Marketing',59000,'2025-12-14'),
(17,'Karthik','IT',71000,'2025-12-10'),
(18,'Pankaj','HR',52000,'2025-12-05'),
(19,'Sonal','Finance',76000,'2025-11-25'),
(20,'Isha','Marketing',60500,'2025-11-15');

SELECT * FROM dbo.employees;

TRUNCATE TABLE dbo.employees;

CREATE TABLE salesitems (
    id INT PRIMARY KEY,
    item NVARCHAR(100) NOT NULL,
    salesman NVARCHAR(50) NOT NULL,
    location NVARCHAR(50) NOT NULL,
    solditems INT NOT NULL,
    last_updated DATETIME NOT NULL
);

INSERT INTO salesitems (id, item, salesman, location, solditems, last_updated)
VALUES
(1,'Laptop','Ravi','Hyderabad',12,'2026-02-10'),
(2,'Mouse','Neha','Delhi',25,'2026-02-07'),
(3,'Keyboard','Amit','Mumbai',18,'2026-02-04'),
(4,'Monitor','Sneha','Chennai',10,'2026-02-01'),
(5,'Printer','Rahul','Bangalore',7,'2026-01-28'),
(6,'Router','Kiran','Pune',14,'2026-01-25'),
(7,'Tablet','Vikram','Hyderabad',9,'2026-01-22'),
(8,'Scanner','Pooja','Delhi',6,'2026-01-18'),
(9,'Webcam','Arjun','Mumbai',20,'2026-01-15'),
(10,'Headset','Divya','Chennai',22,'2026-01-12'),
(11,'Laptop','Manoj','Bangalore',11,'2026-01-08'),
(12,'Mouse','Sneha','Pune',30,'2026-01-04'),
(13,'Keyboard','Karthik','Hyderabad',16,'2025-12-30'),
(14,'Monitor','Ritika','Delhi',8,'2025-12-26'),
(15,'Printer','Pankaj','Mumbai',5,'2025-12-22'),
(16,'Router','Sonal','Chennai',13,'2025-12-18'),
(17,'Tablet','Isha','Bangalore',7,'2025-12-14'),
(18,'Scanner','Amit','Pune',4,'2025-12-10'),
(19,'Webcam','Neha','Hyderabad',21,'2025-11-25'),
(20,'Headset','Rahul','Delhi',19,'2025-11-15');


SELECT * FROM dbo.salesitems;

TRUNCATE TABLE dbo.salesitems;


/* Creating watermark table and necessary stored procedures to perform custom incremental data load*/
CREATE TABLE dbo.watermarktable (
    SchemaName VARCHAR(100),
    TableName VARCHAR(100),
    WatermarkValue DATETIME
);


INSERT INTO dbo.watermarktable (SchemaName, TableName, WatermarkValue)
VALUES
('dbo' ,'employees', '2024-01-01 00:00:00'),
('dbo' ,'salesitems', '2024-01-01 00:00:00');

SELECT * FROM dbo.watermarktable;

TRUNCATE TABLE dbo.watermarktable;

DROP TABLE dbo.watermarktable;

/* Logic for Lookup Activity, Copy Activity*/

-- Old Watermark logic ADF Expression
SELECT WatermarkValue FROM dbo.watermarktable
WHERE SchemaName = '@{item().tableSchemaName}' AND TableName = '@{item().tableName}';

-- New Watermark logic ADF Expression
SELECT MAX(@{item().Watermark_Column}) AS NewWatermarkValue
FROM @{item().tableName};

-- Copy Activity logic
SELECT * FROM dbo.salesitems
WHERE last_updated > WatermarkValue
and last_updated < NewWatermarkValue;

-- Copy Activity logic in ADF expression
SELECT * FROM @{item().tableSchemaName}.@{item().tableName}
WHERE @{item().Watermark_Column} > '@{formatDateTime(activity('Get Old Watermark Value').output.firstRow.WatermarkValue,'yyyy-MM-ddTHH:mm:ss')}' 
AND @{item().Watermark_Column} <= '@{formatDateTime(activity('Get New Watermark Value').output.firstRow.NewWatermarkValue,'yyyy-MM-ddTHH:mm:ss')}'


-- To update latest watermark value in target audit table
CREATE PROCEDURE [dbo].[usp_write_watermark]
    @SchemaName VARCHAR(100),
    @last_updated DATETIME,
    @tableName VARCHAR(100)
AS
BEGIN
    UPDATE watermarktable
    SET WatermarkValue = @last_updated
    WHERE TableName = @tableName
    AND SchemaName = @SchemaName;
END;

DROP PROCEDURE [dbo].[usp_write_watermark];



/*Update few records in existing data*/
UPDATE employees
SET salary = salary + 3000,
    last_updated = '2026-02-12'
WHERE last_updated >= '2025-12-10';

/* Inserting incremental data*/
INSERT INTO employees (id, name, dep, salary, last_updated)
VALUES
(21,'Harish','IT',72000,'2026-02-10'),
(22,'Kavya','HR',56000,'2026-02-09'),
(23,'Mohan','Finance',78000,'2026-02-08'),
(24,'Ramesh','Marketing',62000,'2026-02-07'),
(25,'Nandini','IT',70500,'2026-02-06');

/*Update few records in existing data*/
UPDATE salesitems
SET solditems = solditems + 5,
    last_updated = '2026-02-12'
WHERE last_updated >= '2025-12-10';

/* Inserting incremental data*/
INSERT INTO salesitems (id, item, salesman, location, solditems, last_updated)
VALUES
(21,'Smartphone','Harish','Hyderabad',15,'2026-02-10'),
(22,'Power Bank','Kavya','Delhi',20,'2026-02-09'),
(23,'USB Cable','Mohan','Mumbai',35,'2026-02-08'),
(24,'External HDD','Ramesh','Chennai',8,'2026-02-07'),
(25,'Bluetooth Speaker','Nandini','Bangalore',12,'2026-02-06');


