/*
Parameter name: table_list
Datatype: array
Value:
[
  {
    "tableName": "iplteams",
    "tableSchemaName": "dbo",
    "Watermark_Column": "last_updated"
  },
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

/* Table creation statements and initial data load statements*/

CREATE TABLE employees (
    id INT PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    dep NVARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    last_updated DATETIME NOT NULL
);

INSERT INTO employees (id, name, dep, salary, last_updated)
VALUES
(1, 'Rahul', 'HR', 55000.00, '2019-05-05 11:30:00'),
(2, 'Ajay', 'Finance', 65000.00, '2020-04-03 22:40:00'),
(3, 'Sunil', 'Marketing', 48000.00, '2021-01-25 22:40:00'),
(4, 'Ayan', 'Operations', 72000.00, '2022-01-13 22:40:00'),
(5, 'Vijay', 'IT', 60000.00, '2023-11-15 22:40:00'),
(6, 'Shiva', 'IT', 58000.00, '2024-02-07 22:40:00');

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
(1, 'Laptop', 'Ravi Kumar', 'Hyderabad', 10, '2017-06-22 12:30:00'),
(2, 'Monitor', 'Sneha Gupta', 'Bangalore', 9, '2008-01-01 20:40:00'),
(3, 'Keyboard', 'Vikram Sharma', 'Chennai', 8, '2010-09-08 17:20:00'),
(4, 'Mouse', 'Priya Patel', 'Mumbai', 9, '2019-12-18 07:40:00'),
(5, 'Printer', 'Amit Singh', 'Delhi', 7, '2020-07-01 11:30:00'),
(6, 'Router', 'Deepika Rajput', 'Goa', 10, '2024-03-02 21:40:00');

SELECT * FROM dbo.salesitems;

TRUNCATE TABLE dbo.salesitems;

CREATE TABLE dbo.iplteams (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    team VARCHAR(100),
    score BIGINT,
    matches_played INT,
    last_updated DATETIME2
);

INSERT INTO dbo.iplteams (id, name, team, score, matches_played, last_updated)
VALUES
(1, 'Virat Kohli', 'Royal Challengers Bangalore', 6200, 230, '2025-01-15 10:30:00'),
(2, 'MS Dhoni', 'Chennai Super Kings', 5082, 250, '2025-01-15 10:35:00'),
(3, 'Rohit Sharma', 'Mumbai Indians', 5879, 243, '2025-01-15 10:40:00'),
(4, 'KL Rahul', 'Lucknow Super Giants', 4163, 132, '2025-01-15 10:45:00'),
(5, 'Shubman Gill', 'Gujarat Titans', 2790, 104, '2025-01-15 10:50:00'),
(6, 'David Warner', 'Delhi Capitals', 6565, 184, '2025-01-15 10:55:00'),
(7, 'Andre Russell', 'Kolkata Knight Riders', 2262, 113, '2025-01-15 11:00:00'),
(8, 'Jos Buttler', 'Rajasthan Royals', 3900, 107, '2025-01-15 11:05:00'),
(9, 'Hardik Pandya', 'Mumbai Indians', 2525, 137, '2025-01-15 11:10:00'),
(10, 'Rashid Khan', 'Gujarat Titans', 1390, 109, '2025-01-15 11:15:00');

SELECT * FROM dbo.iplteams;

TRUNCATE TABLE dbo.iplteams;

CREATE TABLE dbo.watermarktable (
    SchemaName VARCHAR(100),
    TableName VARCHAR(100),
    WatermarkValue DATETIME
);


INSERT INTO dbo.watermarktable (SchemaName, TableName, WatermarkValue)
VALUES
('dbo' ,'iplteams', '2000-01-01 11:10:00'),
('dbo' ,'employees', '2000-01-01 21:40:00'),
('dbo' ,'salesitems', '2000-01-01 21:40:00');

SELECT * FROM dbo.watermarktable;

TRUNCATE TABLE dbo.watermarktable;

/* Logic for Lookup Activity, Copy Activity*/

-- Old Watermark logic ADF Expression
SELECT WatermarkValue FROM dbo.watermarktable
WHERE TableName = '@{item().tableName}';

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

/* Inserting incremental data*/
INSERT INTO dbo.salesitems (id, item, salesman, location, solditems, last_updated)
VALUES
(7, 'Laptop', 'Aditya Sharma', 'Hyderabad', 15, '2024-12-15 12:30:00');

UPDATE dbo.salesitems SET location='Coimbatore',
last_updated = '2025-01-01 04:00:00'
WHERE id=3;