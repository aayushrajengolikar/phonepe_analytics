CREATE TABLE aggregated_user (
    state VARCHAR(100),
    year INT,
    quarter INT,
    registered_users BIGINT,
    app_opens BIGINT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/aggregated_user.csv'
INTO TABLE aggregated_user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM aggregated_user LIMIT 10;

SELECT COUNT(*) FROM aggregated_user;

-- 🔹 State-wise Registered Users
SELECT state, SUM(registered_users) AS total_users
FROM aggregated_user
GROUP BY state
ORDER BY total_users DESC;

-- 🔹 State-wise App Opens
SELECT state, SUM(app_opens) AS total_opens
FROM aggregated_user
GROUP BY state
ORDER BY total_opens DESC;

-- 🔹 Year-wise User Growth
SELECT year, SUM(registered_users) AS total_users
FROM aggregated_user
GROUP BY year
ORDER BY year;

-- 🔹 Year-wise App Opens Trend
SELECT year, SUM(app_opens) AS total_opens
FROM aggregated_user
GROUP BY year
ORDER BY year;

-- 🔹 Quarter-wise User Trend
SELECT year, quarter, SUM(registered_users) AS total_users
FROM aggregated_user
GROUP BY year, quarter
ORDER BY year, quarter;

-- 🔹 Top 10 States by Users
SELECT state, SUM(registered_users) AS total_users
FROM aggregated_user
GROUP BY state
ORDER BY total_users DESC
LIMIT 10;

-- ================== ADVANCED ANALYSIS ==================

-- 🔥 Year-wise Growth Rate (% Users)
SELECT year,
       SUM(registered_users) AS total_users,
       LAG(SUM(registered_users)) OVER (ORDER BY year) AS prev_year,
       ((SUM(registered_users) - LAG(SUM(registered_users)) OVER (ORDER BY year))
        / LAG(SUM(registered_users)) OVER (ORDER BY year)) * 100 AS growth_percentage
FROM aggregated_user
GROUP BY year;

-- 🔥 Top Performing State Each Year (Users)
SELECT year, state, total_users
FROM (
    SELECT year, state,
           SUM(registered_users) AS total_users,
           RANK() OVER (PARTITION BY year ORDER BY SUM(registered_users) DESC) AS rnk
    FROM aggregated_user
    GROUP BY year, state
) t
WHERE rnk = 1;

-- 🔥 State with Highest App Engagement (App Opens)
SELECT state, total_opens
FROM (
    SELECT state,
           SUM(app_opens) AS total_opens,
           RANK() OVER (ORDER BY SUM(app_opens) DESC) AS rnk
    FROM aggregated_user
    GROUP BY state
) t
WHERE rnk = 1;

-- 🔥 App Opens to Users Ratio (Engagement Metric)
SELECT state,
       SUM(app_opens) AS total_opens,
       SUM(registered_users) AS total_users,
       (SUM(app_opens) / SUM(registered_users)) AS engagement_ratio
FROM aggregated_user
GROUP BY state
ORDER BY engagement_ratio DESC;

-- 🔥 Contribution % of Each State (Users)
SELECT state,
       SUM(registered_users) AS total_users,
       (SUM(registered_users) / (SELECT SUM(registered_users) FROM aggregated_user)) * 100 AS percentage
FROM aggregated_user
GROUP BY state
ORDER BY percentage DESC;

-- 🔥 Top 3 States per Year (Users)
SELECT year, state, total_users
FROM (
    SELECT year, state,
           SUM(registered_users) AS total_users,
           RANK() OVER (PARTITION BY year ORDER BY SUM(registered_users) DESC) AS rnk
    FROM aggregated_user
    GROUP BY year, state
) t
WHERE rnk <= 3;

-- 🔥 Quarter with Highest User Growth
SELECT year, quarter, SUM(registered_users) AS total_users
FROM aggregated_user
GROUP BY year, quarter
ORDER BY total_users DESC
LIMIT 1;