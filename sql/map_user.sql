CREATE TABLE map_user (
    state VARCHAR(100),
    year INT,
    quarter INT,
    district VARCHAR(100),
    registered_users BIGINT,
    app_opens BIGINT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/map_user.csv'
INTO TABLE map_user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM map_user LIMIT 10;

SELECT COUNT(*) FROM map_user;

-- 🔹 District-wise Registered Users
SELECT district, SUM(registered_users) AS total_users
FROM map_user
GROUP BY district
ORDER BY total_users DESC;

-- 🔹 District-wise App Opens
SELECT district, SUM(app_opens) AS total_opens
FROM map_user
GROUP BY district
ORDER BY total_opens DESC;

-- 🔹 State-wise Users
SELECT state, SUM(registered_users) AS total_users
FROM map_user
GROUP BY state
ORDER BY total_users DESC;

-- 🔹 Year-wise User Growth
SELECT year, SUM(registered_users) AS total_users
FROM map_user
GROUP BY year
ORDER BY year;

-- 🔹 Quarter-wise Trend
SELECT year, quarter, SUM(registered_users) AS total_users
FROM map_user
GROUP BY year, quarter
ORDER BY year, quarter;

-- 🔹 Top 10 Districts by Users
SELECT district, SUM(registered_users) AS total_users
FROM map_user
GROUP BY district
ORDER BY total_users DESC
LIMIT 10;

-- ================== ADVANCED ANALYSIS ==================

-- 🔥 Year-wise Growth Rate (% Users)
SELECT year,
       SUM(registered_users) AS total_users,
       LAG(SUM(registered_users)) OVER (ORDER BY year) AS prev_year,
       ((SUM(registered_users) - LAG(SUM(registered_users)) OVER (ORDER BY year))
        / LAG(SUM(registered_users)) OVER (ORDER BY year)) * 100 AS growth_percentage
FROM map_user
GROUP BY year;

-- 🔥 Top Performing District Each Year (Users)
SELECT year, district, total_users
FROM (
    SELECT year, district,
           SUM(registered_users) AS total_users,
           RANK() OVER (PARTITION BY year ORDER BY SUM(registered_users) DESC) AS rnk
    FROM map_user
    GROUP BY year, district
) t
WHERE rnk = 1;

-- 🔥 Top Performing District per State
SELECT state, district, total_users
FROM (
    SELECT state, district,
           SUM(registered_users) AS total_users,
           RANK() OVER (PARTITION BY state ORDER BY SUM(registered_users) DESC) AS rnk
    FROM map_user
    GROUP BY state, district
) t
WHERE rnk = 1;

-- 🔥 App Opens to Users Ratio (District-level Engagement)
SELECT state, district,
       SUM(app_opens) AS total_opens,
       SUM(registered_users) AS total_users,
       (SUM(app_opens) / SUM(registered_users)) AS engagement_ratio
FROM map_user
GROUP BY state, district
ORDER BY engagement_ratio DESC;

-- 🔥 Contribution % of Each District within State
SELECT state, district,
       SUM(registered_users) AS total,
       (SUM(registered_users) /
        SUM(SUM(registered_users)) OVER (PARTITION BY state)) * 100 AS percentage
FROM map_user
GROUP BY state, district
ORDER BY state, percentage DESC;

-- 🔥 Top 3 Districts per State (Users)
SELECT state, district, total_users
FROM (
    SELECT state, district,
           SUM(registered_users) AS total_users,
           RANK() OVER (PARTITION BY state ORDER BY SUM(registered_users) DESC) AS rnk
    FROM map_user
    GROUP BY state, district
) t
WHERE rnk <= 3;

-- 🔥 District with Highest App Engagement
SELECT district,
       SUM(app_opens) / SUM(registered_users) AS engagement_ratio
FROM map_user
GROUP BY district
ORDER BY engagement_ratio DESC
LIMIT 1;

-- 🔥 Quarter with Highest User Activity
SELECT year, quarter, SUM(app_opens) AS total_opens
FROM map_user
GROUP BY year, quarter
ORDER BY total_opens DESC
LIMIT 1;