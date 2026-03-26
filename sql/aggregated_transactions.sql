CREATE TABLE aggregated_transaction (
    state VARCHAR(100),
    year INT,
    quarter INT,
    transaction_type VARCHAR(50),
    transaction_count BIGINT,
    transaction_amount DOUBLE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/aggregated_transaction.csv'
INTO TABLE aggregated_transaction
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM aggregated_transaction LIMIT 10;

SELECT COUNT(*) FROM aggregated_transaction;

SELECT state, SUM(transaction_count) AS total_transactions
FROM aggregated_transaction
GROUP BY state
ORDER BY total_transactions DESC;

SELECT state, SUM(transaction_amount) AS total_amount
FROM aggregated_transaction
GROUP BY state
ORDER BY total_amount DESC;

SELECT year, SUM(transaction_amount) AS total_amount
FROM aggregated_transaction
GROUP BY year
ORDER BY year;

SELECT year, quarter, SUM(transaction_amount) AS total_amount
FROM aggregated_transaction
GROUP BY year, quarter
ORDER BY year, quarter;

SELECT transaction_type, SUM(transaction_amount) AS total
FROM aggregated_transaction
GROUP BY transaction_type
ORDER BY total DESC;

SELECT state, SUM(transaction_amount) AS total_amount
FROM aggregated_transaction
GROUP BY state
ORDER BY total_amount DESC
LIMIT 10;

