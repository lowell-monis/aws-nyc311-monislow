-- This query finds the average resolution time of a complaint per agency.
-- The problem when it comes to this data is that there are many complaints that are still open.
-- The original query does not take this into consideration nd assumes that all the complaints are closed.
-- The correction I made to find the resolution time adds a WHERE clause that drops null and empty string dates.
-- This ensures that ongoing complaints aren't considered.
SELECT
  agency,
  AVG(
    DATE_DIFF(
      'day',
      DATE_PARSE(created_date, '%Y-%m-%d %H:%i:%s'),
      DATE_PARSE(closed_date,  '%Y-%m-%d %H:%i:%s')
    )
  ) AS avg_days_to_close
FROM nyc311_db.complaints
WHERE closed_date IS NOT NULL 
  AND closed_date <> ''
GROUP BY agency
ORDER BY avg_days_to_close DESC;

-- Alternatively, one can use the timestamp at the time of running the query.
-- This fix uses COALESCE() to convert null values into the current time stamp.
-- However, this is not advised for data collected at a time in the past,
-- since which complaints could have been resolved and thus not included.
-- This will also end up reporting an inaccurate average and individual resolution time.
-- This fix is ideal for data that is being updated regularly.
SELECT
  agency,
  AVG(
    DATE_DIFF(
      'day',
      DATE_PARSE(created_date, '%Y-%m-%d %H:%i:%s'),
      COALESCE(
        TRY(DATE_PARSE(closed_date, '%Y-%m-%d %H:%i:%s')), 
        CURRENT_TIMESTAMP
      )
    )
  ) AS avg_days_to_close
FROM nyc311_db.complaints
GROUP BY agency
ORDER BY avg_days_to_close DESC;