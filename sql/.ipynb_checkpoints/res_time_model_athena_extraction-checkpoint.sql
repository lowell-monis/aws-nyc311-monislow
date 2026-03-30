-- Athena query for model data generation
-- Motivated by stakeholder question: The mayor's office wants to know whether certain types of 311 complaints are likely to be resolved within 3 days, and if a model can be built to flag fast vs. slow resolutions at intake.
-- Features: agency, borough, problem, incident_zip, day_of_week, hour_of_day, problem_category
-- Target: resolved_quickly
CREATE TABLE nyc311_db.resolution_speed_modeling AS
SELECT
    agency,
    borough,
    problem,
    incident_zip,
    -- Time features from created_date
    day_of_week(date_parse(created_date, '%Y-%m-%d %H:%i:%s')) AS day_of_week,
    hour(date_parse(created_date, '%Y-%m-%d %H:%i:%s')) AS hour_of_day,
    -- Broad problem category (reduces high cardinality)
    CASE
        WHEN problem IN ('HEAT/HOT WATER','PLUMBING','WATER LEAK','PAINT/PLASTER',
                         'DOOR/WINDOW','ELECTRIC','GENERAL','UNSANITARY CONDITION') THEN 'housing'
        WHEN problem IN ('Noise - Residential','Noise - Street/Sidewalk',
                         'Noise - Commercial','Noise') THEN 'noise'
        WHEN problem IN ('Illegal Parking','Blocked Driveway','Traffic Signal Condition',
                         'Street Condition','Abandoned Vehicle') THEN 'traffic'
        WHEN problem IN ('Snow or Ice','Dirty Condition','Water System') THEN 'sanitation'
        ELSE 'other'
    END AS problem_category,
    -- Binary target: resolved within 3 days?
    CASE
        WHEN closed_date <> ''
         AND date_diff('day',
                date_parse(created_date, '%Y-%m-%d %H:%i:%s'),
                date_parse(closed_date,  '%Y-%m-%d %H:%i:%s')) <= 3
        THEN 1
        ELSE 0
    END AS resolved_quickly
FROM nyc311_db.complaints
WHERE closed_date <> ''
  AND borough IN ('BROOKLYN','QUEENS','BRONX','MANHATTAN','STATEN ISLAND');