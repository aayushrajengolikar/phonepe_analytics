CREATE TABLE map_transaction (
    state VARCHAR(100),
    year INT,
    quarter INT,
    district VARCHAR(100),
    transaction_count BIGINT,
    transaction_amount DOUBLE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/map_transaction.csv'
INTO TABLE map_transaction
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM map_transaction LIMIT 10;

SELECT COUNT(*) FROM map_transaction;

-- 🔹 District-wise Transaction Amount
SELECT district, SUM(transaction_amount) AS total_amount
FROM map_transaction
GROUP BY district
ORDER BY total_amount DESC;

-- 🔹 State-wise Transaction Amount
SELECT state, SUM(transaction_amount) AS total_amount
FROM map_transaction
GROUP BY state
ORDER BY total_amount DESC;

-- 🔹 Year-wise Transaction Trend
SELECT year, SUM(transaction_amount) AS total_amount
FROM map_transaction
GROUP BY year
ORDER BY year;

-- 🔹 Quarter-wise Trend
SELECT year, quarter, SUM(transaction_amount) AS total_amount
FROM map_transaction
GROUP BY year, quarter
ORDER BY year, quarter;

-- 🔹 Top 10 Districts by Transaction Amount
SELECT district, SUM(transaction_amount) AS total_amount
FROM map_transaction
GROUP BY district
ORDER BY total_amount DESC
LIMIT 10;

-- ================== ADVANCED ANALYSIS ==================

-- 🔥 Year-wise Growth Rate (%)
SELECT year,
       SUM(transaction_amount) AS total_amount,
       LAG(SUM(transaction_amount)) OVER (ORDER BY year) AS prev_year,
       ((SUM(transaction_amount) - LAG(SUM(transaction_amount)) OVER (ORDER BY year))
        / LAG(SUM(transaction_amount)) OVER (ORDER BY year)) * 100 AS growth_percentage
FROM map_transaction
GROUP BY year;

-- 🔥 Top Performing District Each Year
SELECT year, district, total_amount
FROM (
    SELECT year, district,
           SUM(transaction_amount) AS total_amount,
           RANK() OVER (PARTITION BY year ORDER BY SUM(transaction_amount) DESC) AS rnk
    FROM map_transaction
    GROUP BY year, district
) t
WHERE rnk = 1;

-- 🔥 Top Performing District per State
SELECT state, district, total_amount
FROM (
    SELECT state, district,
           SUM(transaction_amount) AS total_amount,
           RANK() OVER (PARTITION BY state ORDER BY SUM(transaction_amount) DESC) AS rnk
    FROM map_transaction
    GROUP BY state, district
) t
WHERE rnk = 1;

-- 🔥 Contribution % of Each District within State
SELECT state, district,
       SUM(transaction_amount) AS total,
       (SUM(transaction_amount) /
        SUM(SUM(transaction_amount)) OVER (PARTITION BY state)) * 100 AS percentage
FROM map_transaction
GROUP BY state, district
ORDER BY state, percentage DESC;

-- 🔥 Top 3 Districts per State
SELECT state, district, total_amount
FROM (
    SELECT state, district,
           SUM(transaction_amount) AS total_amount,
           RANK() OVER (PARTITION BY state ORDER BY SUM(transaction_amount) DESC) AS rnk
    FROM map_transaction
    GROUP BY state, district
) t
WHERE rnk <= 3;

-- 🔥 District with Highest Transaction Count
SELECT district, SUM(transaction_count) AS total_count
FROM map_transaction
GROUP BY district
ORDER BY total_count DESC
LIMIT 1;

-- 🔥 Quarter with Highest Transactions
SELECT year, quarter, SUM(transaction_amount) AS total_amount
FROM map_transaction
GROUP BY year, quarter
ORDER BY total_amount DESC
LIMIT 1;