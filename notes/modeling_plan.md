# NYC 311 Modeling Plan

**Date created:** April 1, 2026

## Business question
Predict if a complaint will be resolved quickly (defined as within 3 days) upon intake, flagging projected slow resolutions, and infer  whether certain types of 311 complaints are likely to be resolved within 3 days.

## Data source
- **S3 path:** `s3://cmse492-monislow-nyc311-975049958391-us-east-1-an/modeling/data_resolution_time.csv`
- **Records:** 173870 entries
- **Athena query:** [`~/sql/res_time_model_athena_extraction.sql`](../sql/res_time_model_athena_extraction.sql)

## Features
- `agency` (string, convert to categorical)
- `borough` (string, convert to categorical)
- `problem` (string, convert to categorical)
- `incident_zip` (string, convert to integer)
- `day_of_week` (string, convert to integer)
- `hour_of_day` (string, convert to integer)
- `problem_category` (string, convert to categorical)

## Target
- **Name:** `resolved_quickly`
- **Type:** Classification; yes = 1, no = 0
- **Balance/Distribution:** The number of complaints resolved quickly, or within three days in this sample is 146158, which is 84.06% of the data. The number of complaints that take longer is 27712, which is 15.94%.

## Modeling approach
- **Baseline:** Logistic regression (interpretable, fast to train)
- **Metrics:** Accuracy, precision, recall
- **Train/test split:** 80/20

## Data quality notes
- [Any missing values, outliers, or issues to watch for]

## Next steps (What you'll work on in the next class period; update/modify based on your plan)
- Train/test split
- Fit baseline logistic regression
- Evaluate and interpret results