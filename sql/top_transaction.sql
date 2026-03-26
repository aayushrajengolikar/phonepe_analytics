CREATE TABLE top_transaction (
    state VARCHAR(100),
    year INT,
    quarter INT,
    entity_name VARCHAR(100),
    transaction_count BIGINT,
    transaction_amount DOUBLE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/top_transaction.csv'
INTO TABLE top_transaction
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM top_transaction LIMIT 10;

SELECT COUNT(*) FROM top_transaction;

-- 🔹 Entity-wise Transaction Amount
SELECT entity_name, SUM(transaction_amount) AS total_amount
FROM top_transaction
GROUP BY entity_name
ORDER BY total_amount DESC;

-- 🔹 State-wise Transaction Amount
SELECT state, SUM(transaction_amount) AS total_amount
FROM top_transaction
GROUP BY state
ORDER BY total_amount DESC;

-- 🔹 Year-wise Transaction Trend
SELECT year, SUM(transaction_amount) AS total_amount
FROM top_transaction
GROUP BY year
ORDER BY year;

-- 🔹 Quarter-wise Trend
SELECT year, quarter, SUM(transaction_amount) AS total_amount
FROM top_transaction
GROUP BY year, quarter
ORDER BY year, quarter;

-- 🔹 Top 10 Entities by Transaction Amount
SELECT entity_name, SUM(transaction_amount) AS total_amount
FROM top_transaction
GROUP BY entity_name
ORDER BY total_amount DESC
LIMIT 10;

-- ================== ADVANCED ANALYSIS ==================

-- 🔥 Year-wise Growth Rate (%)
SELECT year,
       SUM(transaction_amount) AS total_amount,
       LAG(SUM(transaction_amount)) OVER (ORDER BY year) AS prev_year,
       ((SUM(transaction_amount) - LAG(SUM(transaction_amount)) OVER (ORDER BY year))
        / LAG(SUM(transaction_amount)) OVER (ORDER BY year)) * 100 AS growth_percentage
FROM top_transaction
GROUP BY year;

-- 🔥 Top Performing Entity Each Year
SELECT year, entity_name, total_amount
FROM (
    SELECT year, entity_name,
           SUM(transaction_amount) AS total_amount,
           RANK() OVER (PARTITION BY year ORDER BY SUM(transaction_amount) DESC) AS rnk
    FROM top_transaction
    GROUP BY year, entity_name
) t
WHERE rnk = 1;

-- 🔥 Top Performing Entity per State
SELECT state, entity_name, total_amount
FROM (
    SELECT state, entity_name,
           SUM(transaction_amount) AS total_amount,
           RANK() OVER (PARTITION BY state ORDER BY SUM(transaction_amount) DESC) AS rnk
    FROM top_transaction
    GROUP BY state, entity_name
) t
WHERE rnk = 1;

-- 🔥 Contribution % of Each Entity within State
SELECT state, entity_name,
       SUM(transaction_amount) AS total,
       (SUM(transaction_amount) /
        SUM(SUM(transaction_amount)) OVER (PARTITION BY state)) * 100 AS percentage
FROM top_transaction
GROUP BY state, entity_name
ORDER BY state, percentage DESC;

-- 🔥 Top 3 Entities per State
SELECT state, entity_name, total_amount
FROM (
    SELECT state, entity_name,
           SUM(transaction_amount) AS total_amount,
           RANK() OVER (PARTITION BY state ORDER BY SUM(transaction_amount) DESC) AS rnk
    FROM top_transaction
    GROUP BY state, entity_name
) t
WHERE rnk <= 3;

-- 🔥 Entity with Highest Transaction Count
SELECT entity_name, SUM(transaction_count) AS total_count
FROM top_transaction
GROUP BY entity_name
ORDER BY total_count DESC
LIMIT 1;

-- 🔥 Quarter with Highest Transaction Amount
SELECT year, quarter, SUM(transaction_amount) AS total_amount
FROM top_transaction
GROUP BY year, quarter
ORDER BY total_amount DESC
LIMIT 1;