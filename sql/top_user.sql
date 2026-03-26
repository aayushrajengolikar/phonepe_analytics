CREATE TABLE top_user (
    state VARCHAR(100),
    year INT,
    quarter INT,
    entity_name VARCHAR(100),
    registered_users BIGINT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/top_user.csv'
INTO TABLE top_user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM top_user LIMIT 10;

SELECT COUNT(*) FROM top_user;

-- 🔹 Entity-wise Registered Users
SELECT entity_name, SUM(registered_users) AS total_users
FROM top_user
GROUP BY entity_name
ORDER BY total_users DESC;

-- 🔹 State-wise Registered Users
SELECT state, SUM(registered_users) AS total_users
FROM top_user
GROUP BY state
ORDER BY total_users DESC;

-- 🔹 Year-wise User Growth
SELECT year, SUM(registered_users) AS total_users
FROM top_user
GROUP BY year
ORDER BY year;

-- 🔹 Quarter-wise Trend
SELECT year, quarter, SUM(registered_users) AS total_users
FROM top_user
GROUP BY year, quarter
ORDER BY year, quarter;

-- 🔹 Top 10 Entities by Users
SELECT entity_name, SUM(registered_users) AS total_users
FROM top_user
GROUP BY entity_name
ORDER BY total_users DESC
LIMIT 10;

-- ================== ADVANCED ANALYSIS ==================

-- 🔥 Year-wise Growth Rate (% Users)
SELECT year,
       SUM(registered_users) AS total_users,
       LAG(SUM(registered_users)) OVER (ORDER BY year) AS prev_year,
       ((SUM(registered_users) - LAG(SUM(registered_users)) OVER (ORDER BY year))
        / LAG(SUM(registered_users)) OVER (ORDER BY year)) * 100 AS growth_percentage
FROM top_user
GROUP BY year;

-- 🔥 Top Performing Entity Each Year
SELECT year, entity_name, total_users
FROM (
    SELECT year, entity_name,
           SUM(registered_users) AS total_users,
           RANK() OVER (PARTITION BY year ORDER BY SUM(registered_users) DESC) AS rnk
    FROM top_user
    GROUP BY year, entity_name
) t
WHERE rnk = 1;

-- 🔥 Top Performing Entity per State
SELECT state, entity_name, total_users
FROM (
    SELECT state, entity_name,
           SUM(registered_users) AS total_users,
           RANK() OVER (PARTITION BY state ORDER BY SUM(registered_users) DESC) AS rnk
    FROM top_user
    GROUP BY state, entity_name
) t
WHERE rnk = 1;

-- 🔥 Contribution % of Each Entity within State
SELECT state, entity_name,
       SUM(registered_users) AS total,
       (SUM(registered_users) /
        SUM(SUM(registered_users)) OVER (PARTITION BY state)) * 100 AS percentage
FROM top_user
GROUP BY state, entity_name
ORDER BY state, percentage DESC;

-- 🔥 Top 3 Entities per State
SELECT state, entity_name, total_users
FROM (
    SELECT state, entity_name,
           SUM(registered_users) AS total_users,
           RANK() OVER (PARTITION BY state ORDER BY SUM(registered_users) DESC) AS rnk
    FROM top_user
    GROUP BY state, entity_name
) t
WHERE rnk <= 3;

-- 🔥 Entity with Maximum Users Overall
SELECT entity_name, SUM(registered_users) AS total_users
FROM top_user
GROUP BY entity_name
ORDER BY total_users DESC
LIMIT 1;

-- 🔥 Quarter with Highest User Growth
SELECT year, quarter, SUM(registered_users) AS total_users
FROM top_user
GROUP BY year, quarter
ORDER BY total_users DESC
LIMIT 1;