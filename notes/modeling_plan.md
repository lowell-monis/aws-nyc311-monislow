# NYC 311 Modeling Plan

**Date created:** April 1, 2026

## Business question
Predict [YOUR QUESTION, e.g., high-volume complaint agencies by borough]

## Data source
- **S3 path:** [YOUR S3 PATH]
- **Records:** [number from df.shape[0]]
- **Athena query:** sql/athena_to_modeling.sql

## Features (update/expand based on your query)
- agency (string)
- borough (string)
- n_complaints (numeric, count of complaints)
- avg_days_to_close (numeric, average resolution time)
- ... (other features)

## Target
- **Name:** [YOUR TARGET VARIABLE, e.g., volume_quartile]
- **Type:** [MODEL TYPE, e.g., Classification (1=high volume, 2-4=lower volume)]
- **Balance/Distribution:** [paste results from your target variable distribution check]

## Modeling approach (update based on your question and data)
- **Baseline:** Logistic regression (interpretable, fast to train)
- **Metrics:** Accuracy, precision, recall
- **Train/test split:** 80/20

## Data quality notes
- [Any missing values, outliers, or issues to watch for]

## Next steps (What you'll work on in the next class period; update/modify based on your plan)
- Train/test split
- Fit baseline logistic regression
- Evaluate and interpret results