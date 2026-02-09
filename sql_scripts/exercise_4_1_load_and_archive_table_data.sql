CREATE TABLE dbo.ipl_teams (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    team VARCHAR(100),
    score BIGINT,
    matches_played INT,
    last_updated DATETIME2
);

INSERT INTO dbo.ipl_teams (id, name, team, score, matches_played, last_updated)
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

SELECT * FROM dbo.ipl_teams;

DROP TABLE dbo.ipl_teams;