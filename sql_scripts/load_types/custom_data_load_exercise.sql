-- Create the following table and insert data in both source and target
CREATE TABLE iplteams_Last7days (
    id INT PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    team NVARCHAR(50) NOT NULL,
    score INT NOT NULL,
    matches_played INT NOT NULL,
    last_updated DATETIME NOT NULL
);

INSERT INTO iplteams_Last7days (id, name, team, score, matches_played, last_updated)
VALUES
(1, 'Kohli', 'RCB', 1200, 10, '2015-06-01 11:30:00'),
(2, 'Rohit', 'MI', 1050, 9, '2016-01-01 22:40:00'),
(3, 'Warner', 'SRH', 900, 8, '2017-09-08 07:20:00'),
(4, 'AB de Villiers', 'RCB', 950, 9, '2020-12-08 19:50:00'),
(5, 'Dhoni', 'CSK', 800, 7, '2023-07-01 11:30:00'),
(6, 'Gill', 'KKR', 700, 10, '2024-03-02 21:40:00'),
(7,  'Jaiswal',   'RR', 88, 2, '2026-02-10 11:30:00');

--Execute the following command in source MSSQL server
UPDATE iplteams_Last7days SET team='MI', score=95, last_updated='2026-02-10 13:30:00'
WHERE id=7;

-- Considering that today's date is 10th Feb 2026. Insert the following data into source
INSERT INTO iplteams_Last7days (id, name, team, score, matches_played, last_updated)
VALUES
(8,  'Iyer',      'KKR', 74, 2, '2026-02-09 11:30:00'),
(9,  'Gaikwad',   'CSK', 91, 2, '2026-02-08 11:30:00'),
(10, 'Samson',    'RR', 69, 2, '2026-02-07 11:30:00'),
(11, 'Head',      'SRH', 83, 2, '2026-02-06 11:30:00'),
(12, 'Maxwell',   'RCB', 77, 2, '2026-02-05 11:30:00'),
(13, 'Kishan',    'MI', 64, 1, '2026-02-04 11:30:00'),
-- Older than last 7 days
(14, 'Ashwin',    'RR', 71, 2, '2026-02-01 11:30:00');

SELECT * FROM iplteams_Last7days
WHERE CAST(last_updated as DATE) > '2026-02-03' and CAST(last_updated AS DATE) <= '2026-02-10';

SELECT * FROM iplteams_Last7days
WHERE last_updated > '2026-02-03' and last_updated <= '2026-02-10 23:59:59';

DELETE FROM iplteams_Last7days;