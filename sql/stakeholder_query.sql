-- The NYC Mayor's Office of Operations is concerned about response inequity.
-- They suspect that certain agencies are slower at resolving high-priority issues in specific boroughs compared to the citywide average.
-- The Office wants to indentify these lagging sectors, i.e., specific combinations of agencies and boroughs where the resolution time is poorly performing. 
-- For each agency, which boroughs are underperforming in resolution speed for their most common complaints,
-- and how does each borough's average resolution time compare to the agency's citywide benchmark?

WITH cleaned_data AS (
    SELECT 
        unique_key,
        agency,
        borough,
        date_parse(created_date, '%Y-%m-%d %H:%i:%s') AS start_ts,
        date_parse(closed_date, '%Y-%m-%d %H:%i:%s') AS end_ts
    FROM nyc311_db.complaints
    WHERE created_date LIKE '2026-%' 
    -- Drops ongoing complaints to not skew the results.
      AND closed_date IS NOT NULL 
      AND closed_date <> '' 
),

resolution_metrics AS (
    SELECT
        *,
        DATE_DIFF('minute', start_ts, end_ts) AS resolution_minutes
    FROM cleaned_data
    -- Sanity check to remove any noise/error entries where created date is after resolution
    WHERE DATE_DIFF('minute', start_ts, end_ts) >= 0
),

borough_benchmarks AS (
    SELECT 
        agency,
        borough,
        AVG(resolution_minutes) as avg_borough
    FROM resolution_metrics
    GROUP BY agency, borough
),

city_benchmarks AS (
    SELECT 
        agency,
        AVG(resolution_minutes) as avg_citywide
    FROM resolution_metrics
    GROUP BY agency
)

SELECT 
    a.agency_name,
    b.borough,
    ROUND(b.avg_borough, 1) AS borough_avg,
    ROUND(c.avg_citywide, 1) AS city_avg,
    ROUND(b.avg_borough - c.avg_citywide, 1) AS efficiency_gap,
    CASE 
        WHEN (b.avg_borough - c.avg_citywide) > 1440 THEN 'CRITICAL LAG (>24hr)'
        WHEN (b.avg_borough - c.avg_citywide) > 480 THEN 'MODERATE LAG (>8hr)'
        WHEN (b.avg_borough - c.avg_citywide) > 0 THEN 'Slightly Slower'
        ELSE 'Above Average'
    END AS performance_status
FROM borough_benchmarks b
JOIN city_benchmarks c ON b.agency = c.agency
JOIN nyc311_db.agencies a ON b.agency = a.agency
ORDER BY efficiency_gap DESC;