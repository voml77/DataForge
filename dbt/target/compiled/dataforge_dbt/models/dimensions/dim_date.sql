

WITH RECURSIVE date_spine AS (
    SELECT DATE('2022-01-01') AS date_day
    UNION ALL
    SELECT DATE_ADD(date_day, INTERVAL 1 DAY)
    FROM date_spine
    WHERE date_day < '2023-12-31'
)

SELECT
    date_day,
    YEAR(date_day) AS year,
    MONTH(date_day) AS month,
    DAY(date_day) AS day,
    DATE_FORMAT(date_day, '%Y-%m') AS `year_month`,
    DATE_FORMAT(date_day, '%W') AS weekday_name,
    CASE 
        WHEN WEEKDAY(date_day) IN (5,6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS weekday_type,
    QUARTER(date_day) AS quarter
FROM date_spine