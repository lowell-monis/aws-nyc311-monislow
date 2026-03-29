-- The following query can be used to count the total number of complaints recorded with the nyc311 database.
-- The query can be ammended to be used for alternative counts.
-- For example, the query can be amended for agencies, as well as with constraints for specific counts.
-- The expected result for a count query for the total number of complaints is a single-cell table declaring 200,000 complaints.
SELECT COUNT(*) AS n_complaints
FROM nyc311_db.complaints;

-- The following query can be used to provide the date range of the recorded data. In other words, it specifies for which range of dates complaint data is available.
-- The query can be amended to add constraints for specific types of data from the complaints table.
-- The expected result for this version of the query without any constraints is a 1x2 table with columns earliest and latest containing a date and time each.
-- The earliest complaint available was recorded on 2026-01-29 at 08:18:28 and the latest complaint available was recorded on 2026-03-21 at 02:24:50.
SELECT 
  MIN(created_date) AS earliest,
  MAX(created_date) AS latest
FROM nyc311_db.complaints;

-- The following query can be used to provide the number of complaitns received per agency.
-- This specific query has been constrained to provide these grouped values in descending order to show the top few agencies with the most complaints.
-- It has also been limited to 10 rows to preserve compute, but that value can be modified as per need.
-- The expected result is a 10x2 table with the name of the agency and its complaint count n. The NYPD has the most at 71,182 311 calls.
SELECT agency, COUNT(*) AS n
FROM nyc311_db.complaints
GROUP BY agency
ORDER BY n DESC
LIMIT 10;

-- The following query provides a distribution of the different types of problems reported in each of the five boroughs in NYC, along with the number of complaints.
-- Specifically, it groups by borough, followed by the reported problem, and then orders it by the descending number of complaints.
-- It aims to provided the biggest problems in each individual borough and reports the counts such that the result may not necessarily have all boroughs or problem types clustered together.
-- The expected result is a 20x3 table with the name of the borough, the type of problem, and the number of complaints reported.
-- The output has been limited to 20 rows but that can be modified by need and available compute.
-- The biggest problem in NYC for the given date range is illegal parking in Brooklyn with 11,565 reported instances to the 311 line.
SELECT borough, problem, COUNT(*) AS n
FROM nyc311_db.complaints
GROUP BY borough, problem
ORDER BY n DESC
LIMIT 20;

-- The following query gives a framework to execute a join of the complaints table on the agencies table.
-- The expected output contains the agency specification, a full name of the agency, and the number of complaints reported to each agency in descending order.
-- The final joined table result can be modified as per need. The table returned is 15x3 for the 15 city agencies.
-- It should be similar to the agency count table but in pretty-print.
SELECT 
  c.agency,
  a.agency_name,
  COUNT(*) AS n
FROM nyc311_db.complaints AS c
JOIN nyc311_db.agencies AS a
  ON c.agency = a.agency
GROUP BY c.agency, a.agency_name
ORDER BY n DESC;