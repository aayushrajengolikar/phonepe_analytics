CREATE TABLE map_insurance (
    state VARCHAR(100),
    year INT,
    quarter INT,
    district VARCHAR(100),
    insurance_count BIGINT,
    insurance_amount DOUBLE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/map_insurance.csv'
INTO TABLE map_insurance
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM map_insurance LIMIT 10;

SELECT COUNT(*) FROM map_insurance;

-- 🔹 District-wise Insurance Amount
SELECT district, SUM(insurance_amount) AS total_amount
FROM map_insurance
GROUP BY district
ORDER BY total_amount DESC;

-- 🔹 State-wise Insurance Amount
SELECT state, SUM(insurance_amount) AS total_amount
FROM map_insurance
GROUP BY state
ORDER BY total_amount DESC;

-- 🔹 Year-wise Insurance Trend
SELECT year, SUM(insurance_amount) AS total_amount
FROM map_insurance
GROUP BY year
ORDER BY year;

-- 🔹 Quarter-wise Trend
SELECT year, quarter, SUM(insurance_amount) AS total_amount
FROM map_insurance
GROUP BY year, quarter
ORDER BY year, quarter;

-- 🔹 Top 10 Districts by Insurance Amount
SELECT district, SUM(insurance_amount) AS total_amount
FROM map_insurance
GROUP BY district
ORDER BY total_amount DESC
LIMIT 10;

-- ================== ADVANCED ANALYSIS ==================

-- 🔥 Year-wise Growth Rate (%)
SELECT year,
       SUM(insurance_amount) AS total_amount,
       LAG(SUM(insurance_amount)) OVER (ORDER BY year) AS prev_year,
       ((SUM(insurance_amount) - LAG(SUM(insurance_amount)) OVER (ORDER BY year))
        / LAG(SUM(insurance_amount)) OVER (ORDER BY year)) * 100 AS growth_percentage
FROM map_insurance
GROUP BY year;

-- 🔥 Top Performing District Each Year
SELECT year, district, total_amount
FROM (
    SELECT year, district,
           SUM(insurance_amount) AS total_amount,
           RANK() OVER (PARTITION BY year ORDER BY SUM(insurance_amount) DESC) AS rnk
    FROM map_insurance
    GROUP BY year, district
) t
WHERE rnk = 1;

-- 🔥 Top Performing District per State
SELECT state, district, total_amount
FROM (
    SELECT state, district,
           SUM(insurance_amount) AS total_amount,
           RANK() OVER (PARTITION BY state ORDER BY SUM(insurance_amount) DESC) AS rnk
    FROM map_insurance
    GROUP BY state, district
) t
WHERE rnk = 1;

-- 🔥 Contribution % of Each District within State
SELECT state, district,
       SUM(insurance_amount) AS total,
       (SUM(insurance_amount) /
        SUM(SUM(insurance_amount)) OVER (PARTITION BY state)) * 100 AS percentage
FROM map_insurance
GROUP BY state, district
ORDER BY state, percentage DESC;

-- 🔥 Top 3 Districts per State
SELECT state, district, total_amount
FROM (
    SELECT state, district,
           SUM(insurance_amount) AS total_amount,
           RANK() OVER (PARTITION BY state ORDER BY SUM(insurance_amount) DESC) AS rnk
    FROM map_insurance
    GROUP BY state, district
) t
WHERE rnk <= 3;

-- 🔥 District with Highest Insurance Count
SELECT district, SUM(insurance_count) AS total_count
FROM map_insurance
GROUP BY district
ORDER BY total_count DESC
LIMIT 1;

-- 🔥 Quarter with Highest Insurance Amount
SELECT year, quarter, SUM(insurance_amount) AS total_amount
FROM map_insurance
GROUP BY year, quarter
ORDER BY total_amount DESC
LIMIT 1;