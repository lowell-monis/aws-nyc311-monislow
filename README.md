# NYC 311 Service Request Analysis Project

## Data Source and Provenance
- **Source**: [NYC Open Data 311 Service Requests](https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2020-to-Present/erm2-nwe9/)
- **Time period**: Jan 29--Mar 21, 2026 (Q1 2026)
- **Prep**: Instructor-generated random sample of 200k complaints from 15 agencies
- **Files**: 
  - `raw/complaints.csv` (200k rows, main requests table)
  - `raw/agencies.csv` (unique agencies lookup table)
- **S3 paths**:
  - `s3://cmse492-monislow-nyc311-975049958391-us-east-1-an/raw/complaints.csv`
  - `s3://cmse492-monislow-nyc311-975049958391-us-east-1-an/raw/agencies.csv`
  - `s3://cmse492-monislow-nyc311-975049958391-us-east-1-an/modeling/data_resolution_time.csv`

## Project Structure

```
aws-nyc311-monislow/
├── README.md                 # Data source, S3 paths, assumptions
├── DATA_DICTIONARY.md        # Column details
├── data/                     # Local copies of S3 uploads for reference
│   ├── processed
|   |   └── modeling_data_resolution_time.csv
│   └── raw
|       ├── agencies.csv
|       └── complaints.csv
├── sql/                      # Athena queries
│   ├── eda_reference.sql
│   ├── res_time_model_athena_extraction.sql
│   ├── resolution_time.sql
│   └── stakeholder_query.sql
├── notes/                    # Observations, decisions
│   ├── modeling_plan.md      # Detailed classification strategy and baseline results
│   └── sanity_check_log.md   # Validation of agency resolution times
├── notebooks/                # Jupyter notebooks for output replication
│   ├── data_load_verify.ipynb
│   ├── linear_learner.ipynb  # Sagemaker built-in linear learner model
│   └── model_training_eval.ipynb
└── reports/                  # Stakeholder outputs
```

## Data Summary
See [`DATA_DICTIONARY.md`](DATA_DICTIONARY.md) for full schema.

**Key relationships**: Join `complaints.agency = agencies.agency`

**Stakeholder questions**:
- **Inequity Analysis**: The NYC Mayor's Office of Operations wants to identify lagging sectors (agency/borough combinations) where resolution speed underperforms against citywide benchmarks.
- **Predictive Modeling**: Can we flag slow resolutions at the point of intake? The goal is to predict if a complaint will be resolved within **3 days**.

## Modeling Strategy & Baseline Results
A binary classification model was developed to predict "fast" (≤ 3 days) vs. "slow" (> 3 days) resolutions.

* **Dataset**: 173,870 entries.
* **Target Distribution**: Highly imbalanced (84.06% Fast, 15.94% Slow).
* **Baseline Performance**: Logistic Regression achieved **0.847 accuracy**, but struggled with the minority class (Recall for slow resolutions: 0.10).
* **Key Findings**:
    * The assigned **Agency** (specifically NYPD) and the **Hour of Day** are the strongest predictors of resolution speed.
    * Traffic-related problems are statistically more likely to be resolved quickly.
    * SageMaker Linear Learner yielded identical results to local implementations, suggesting that model architecture is less of a bottleneck than class imbalance for this specific feature set.

## Assumptions and Known Issues
- **Unresolved Requests**: Empty `closed_date` values are treated as open/unresolved and were excluded from average resolution time calculations to avoid skewing data.
- **Data Cleaning**: `incident_zip` was dropped from the predictive model due to missing values and high cardinality (> 200 unique codes) making one-hot encoding computationally expensive.
- **Outliers**: No significant outliers were detected in continuous features using the IQR method.

## AWS Environment & Setup
This project is configured for execution within an **AWS SageMaker** or **EC2** environment using the standard Python toolchain.

### Installation
Since `uv` is not available, use `pip` to manage the environment:

```bash
# Create and activate virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install required packages
pip install -r requirements.txt
```

### Working with S3
To pull data from the project S3 buckets, ensure your AWS CLI is configured or the instance has the appropriate IAM role:

```bash
# Sync data from S3 to local directory
aws s3 sync s3://cmse492-monislow-nyc311-975049958391-us-east-1-an/raw/ ./data/raw/
```

### Troubleshooting
* **S3 Access Denied**: Ensure your execution role has `s3:GetObject` and `s3:ListBucket` permissions for the `cmse492-monislow-nyc311` bucket.
* **Athena Query Failures**: If `res_time_model_athena_extraction.sql` fails, verify that the `WorkGroup` has an output location defined in S3 for query results.
* **Memory Errors**: If training fails on a `t3.medium` or similar small instance, consider using a larger SageMaker instance (e.g., `ml.m5.large`) as the one-hot encoding for `problem` categories can be memory-intensive.