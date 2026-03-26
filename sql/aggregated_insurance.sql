CREATE TABLE aggregated_insurance (
    state VARCHAR(100),
    year INT,
    quarter INT,
    insurance_type VARCHAR(50),
    insurance_count BIGINT,
    insurance_amount DOUBLE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/aggregated_insurance.csv'
INTO TABLE aggregated_insurance
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM aggregated_insurance LIMIT 10;

SELECT COUNT(*) FROM aggregated_insurance;

-- 🔹 State-wise Total Policies
SELECT state, SUM(insurance_count) AS total_policies
FROM aggregated_insurance
GROUP BY state
ORDER BY total_policies DESC;

-- 🔹 State-wise Insurance Amount
SELECT state, SUM(insurance_amount) AS total_amount
FROM aggregated_insurance
GROUP BY state
ORDER BY total_amount DESC;

-- 🔹 Year-wise Insurance Growth
SELECT year, SUM(insurance_amount) AS total_amount
FROM aggregated_insurance
GROUP BY year
ORDER BY year;

-- 🔹 Quarter-wise Trend
SELECT year, quarter, SUM(insurance_amount) AS total_amount
FROM aggregated_insurance
GROUP BY year, quarter
ORDER BY year, quarter;

-- 🔹 Insurance Type Analysis
SELECT insurance_type, SUM(insurance_amount) AS total
FROM aggregated_insurance
GROUP BY insurance_type
ORDER BY total DESC;

-- 🔹 Top 10 States by Insurance Amount
SELECT state, SUM(insurance_amount) AS total_amount
FROM aggregated_insurance
GROUP BY state
ORDER BY total_amount DESC
LIMIT 10;

-- ================== ADVANCED ANALYSIS ==================

-- 🔥 Year-wise Growth Rate (%)
SELECT year,
       SUM(insurance_amount) AS total_amount,
       LAG(SUM(insurance_amount)) OVER (ORDER BY year) AS prev_year,
       ((SUM(insurance_amount) - LAG(SUM(insurance_amount)) OVER (ORDER BY year))
        / LAG(SUM(insurance_amount)) OVER (ORDER BY year)) * 100 AS growth_percentage
FROM aggregated_insurance
GROUP BY year;

-- 🔥 Top Performing State Each Year
SELECT year, state, total_amount
FROM (
    SELECT year, state,
           SUM(insurance_amount) AS total_amount,
           RANK() OVER (PARTITION BY year ORDER BY SUM(insurance_amount) DESC) AS rnk
    FROM aggregated_insurance
    GROUP BY year, state
) t
WHERE rnk = 1;

-- 🔥 Most Dominant Insurance Type per State
SELECT state, insurance_type, total
FROM (
    SELECT state, insurance_type,
           SUM(insurance_amount) AS total,
           RANK() OVER (PARTITION BY state ORDER BY SUM(insurance_amount) DESC) AS rnk
    FROM aggregated_insurance
    GROUP BY state, insurance_type
) t
WHERE rnk = 1;

-- 🔥 Quarter with Highest Insurance Amount
SELECT year, quarter, SUM(insurance_amount) AS total
FROM aggregated_insurance
GROUP BY year, quarter
ORDER BY total DESC
LIMIT 1;

-- 🔥 Contribution % of Each State
SELECT state,
       SUM(insurance_amount) AS total,
       (SUM(insurance_amount) / (SELECT SUM(insurance_amount) FROM aggregated_insurance)) * 100 AS percentage
FROM aggregated_insurance
GROUP BY state
ORDER BY percentage DESC;

-- 🔥 Top 3 States per Year
SELECT year, state, total_amount
FROM (
    SELECT year, state,
           SUM(insurance_amount) AS total_amount,
           RANK() OVER (PARTITION BY year ORDER BY SUM(insurance_amount) DESC) AS rnk
    FROM aggregated_insurance
    GROUP BY year, state
) t
WHERE rnk <= 3;