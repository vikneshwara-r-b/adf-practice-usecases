/*
1. Create source and target SQL tables
2. Create a stored procedure to pass start and end dates
3. Create a pipeline and add 2 parameters - startdate, enddate
4. Add a copy activity - Under the "Source" section => select stored procedure, import parameters
and map them to the pipeline parameters
5. Under "Sink" section - add destination and select Target dataset
6. Add Trigger - select tumbling window and give
    start date
    recurrence - window time (12hrs, 24hrs)
7. Add the below parameters in trigger and then publish
    start_date - @trigger().outputs.windowStartTime
    end_date - @trigger().outputs.windowEndTime
*/


CREATE TABLE sales_tumbling (
    id INT PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    product_type NVARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    sold_items INT NOT NULL,
    sale_date DATETIME NOT NULL
);

INSERT INTO sales_tumbling 
(id, name, product_type, quantity, sold_items, sale_date)
VALUES
(1, 'Rahul', 'electricals', 1200, 10, '2026-01-01 11:30:00'),
(2, 'Ajay', 'hardware', 1050, 9, '2026-01-01 22:40:00'),
(3, 'Sunil', 'software', 900, 8, '2026-01-01 07:20:00'),
(4, 'Ayan', 'electricals', 950, 9, '2026-01-02 09:50:00'),
(5, 'Vijay', 'devices', 800, 7, '2026-01-02 11:30:00'),
(6, 'Shiva', 'logistics', 700, 10, '2026-01-02 21:40:00'),
(7, 'Akshay', 'electricals', 1200, 10, '2026-01-03 08:30:00'),
(8, 'Ravi', 'hardware', 1050, 9, '2026-01-03 13:40:00'),
(9, 'John', 'software', 900, 8, '2026-01-03 06:20:00'),
(10, 'Vivan', 'electricals', 950, 9, '2026-01-04 08:50:00'),
(11, 'Kumar', 'devices', 800, 7, '2026-01-04 11:30:00'),
(12, 'Suresh', 'logistics', 700, 10, '2026-01-04 21:40:00'),
(13, 'Watson', 'electricals', 1200, 10, '2026-01-05 09:30:00'),
(14, 'Hrithik', 'hardware', 1050, 9, '2026-01-05 15:40:00'),
(15, 'Sunil', 'software', 900, 8, '2026-01-05 19:20:00'),
(16, 'Mayan', 'electricals', 950, 9, '2026-01-06 10:50:00'),
(17, 'Vishnu', 'devices', 800, 7, '2026-01-06 11:30:00'),
(18, 'Manoj', 'logistics', 700, 10, '2026-01-06 16:40:00'),
(19, 'Sharva', 'electricals', 1200, 10, '2026-01-07 08:30:00'),
(20, 'Jeeva', 'hardware', 1050, 9, '2026-01-07 15:40:00'),
(21, 'Abhi', 'software', 900, 8, '2026-01-07 22:20:00');

SELECT * FROM sales_tumbling;

TRUNCATE TABLE sales_tumbling;
DROP TABLE sales_tumbling;

CREATE PROCEDURE [dbo].[usp_for_sales_tumbling]
    @startdate VARCHAR(100),
    @enddate   VARCHAR(100)
AS
BEGIN
    SELECT *
    FROM sales_tumbling
    WHERE sale_date >= @startdate
      AND sale_date <= @enddate;
END;

EXEC dbo.usp_for_sales_tumbling
    @startdate = '2026-01-01 00:00:00',
    @enddate   = '2026-01-01 23:59:59';

