CREATE TABLE top_insurance (
    state VARCHAR(100),
    year INT,
    quarter INT,
    entity_name VARCHAR(100),
    insurance_amount DOUBLE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/top_insurance.csv'
INTO TABLE top_insurance
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM top_insurance LIMIT 10;

SELECT COUNT(*) FROM top_insurance;

-- 🔹 Entity-wise Insurance Amount
SELECT entity_name, SUM(insurance_amount) AS total_amount
FROM top_insurance
GROUP BY entity_name
ORDER BY total_amount DESC;

-- 🔹 State-wise Insurance Amount
SELECT state, SUM(insurance_amount) AS total_amount
FROM top_insurance
GROUP BY state
ORDER BY total_amount DESC;

-- 🔹 Year-wise Insurance Trend
SELECT year, SUM(insurance_amount) AS total_amount
FROM top_insurance
GROUP BY year
ORDER BY year;

-- 🔹 Quarter-wise Trend
SELECT year, quarter, SUM(insurance_amount) AS total_amount
FROM top_insurance
GROUP BY year, quarter
ORDER BY year, quarter;

-- 🔹 Top 10 Entities by Insurance Amount
SELECT entity_name, SUM(insurance_amount) AS total_amount
FROM top_insurance
GROUP BY entity_name
ORDER BY total_amount DESC
LIMIT 10;

-- ================== ADVANCED ANALYSIS ==================

-- 🔥 Year-wise Growth Rate (%)
SELECT year,
       SUM(insurance_amount) AS total_amount,
       LAG(SUM(insurance_amount)) OVER (ORDER BY year) AS prev_year,
       ((SUM(insurance_amount) - LAG(SUM(insurance_amount)) OVER (ORDER BY year))
        / LAG(SUM(insurance_amount)) OVER (ORDER BY year)) * 100 AS growth_percentage
FROM top_insurance
GROUP BY year;

-- 🔥 Top Performing Entity Each Year
SELECT year, entity_name, total_amount
FROM (
    SELECT year, entity_name,
           SUM(insurance_amount) AS total_amount,
           RANK() OVER (PARTITION BY year ORDER BY SUM(insurance_amount) DESC) AS rnk
    FROM top_insurance
    GROUP BY year, entity_name
) t
WHERE rnk = 1;

-- 🔥 Top Performing Entity per State
SELECT state, entity_name, total_amount
FROM (
    SELECT state, entity_name,
           SUM(insurance_amount) AS total_amount,
           RANK() OVER (PARTITION BY state ORDER BY SUM(insurance_amount) DESC) AS rnk
    FROM top_insurance
    GROUP BY state, entity_name
) t
WHERE rnk = 1;

-- 🔥 Contribution % of Each Entity within State
SELECT state, entity_name,
       SUM(insurance_amount) AS total,
       (SUM(insurance_amount) /
        SUM(SUM(insurance_amount)) OVER (PARTITION BY state)) * 100 AS percentage
FROM top_insurance
GROUP BY state, entity_name
ORDER BY state, percentage DESC;

-- 🔥 Top 3 Entities per State
SELECT state, entity_name, total_amount
FROM (
    SELECT state, entity_name,
           SUM(insurance_amount) AS total_amount,
           RANK() OVER (PARTITION BY state ORDER BY SUM(insurance_amount) DESC) AS rnk
    FROM top_insurance
    GROUP BY state, entity_name
) t
WHERE rnk <= 3;

-- 🔥 Entity with Maximum Insurance Amount Overall
SELECT entity_name, SUM(insurance_amount) AS total_amount
FROM top_insurance
GROUP BY entity_name
ORDER BY total_amount DESC
LIMIT 1;

-- 🔥 Quarter with Highest Insurance Activity
SELECT year, quarter, SUM(insurance_amount) AS total_amount
FROM top_insurance
GROUP BY year, quarter
ORDER BY total_amount DESC
LIMIT 1;