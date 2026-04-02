# NYC 311 Service Request Analysis Project

## Data Source and Provenance
- **Source**: [NYC Open Data 311 Service Requests](https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2020-to-Present/erm2-nwe9/)
- **Time period**: Jan 29–Mar 21, 2026 (Q1 2026)
- **Prep**: Instructor-generated random sample of 200k complaints from 15 agencies
- **Files**: 
  - `raw/complaints.csv` (200k rows, main requests table)
  - `raw/agencies.csv` (unique agencies lookup table)
- **S3 paths**:
  - `s3://cmse492-monislow-nyc311-975049958391-us-east-1-an/raw/complaints.csv`
  - `s3://cmse492-monislow-nyc311-975049958391-us-east-1-an/raw/agencies.csv`

## Project Structure

```
aws-nyc311-monislow/
├── README.md                 # Data source, S3 paths, assumptions
├── DATA_DICTIONARY.md        # Column details
├── data/                     # Local copies of S3 uploads. Files will be recreated when reproduced.
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
│   ├── modeling_plan.md
│   └── sanity_check_log.md
├── notebooks/                # Jupyter notebooks for output replication
│   ├── data_extraction_athena.ipynb (TBD)
│   ├── data_extraction_local.ipynb (TBD)
│   └── data_load_verify.ipynb
└── reports/                  # Stakeholder outputs
```

## Data Summary
See [`DATA_DICTIONARY.md`](DATA_DICTIONARY.md) for full schema.

**Key relationships**: Join `complaints.agency = agencies.agency`

**Stakeholder questions**:
- The NYC Mayor's Office of Operations is concerned about response inequity. They suspect that certain agencies are slower at resolving high-priority issues in specific boroughs compared to the citywide average. The Office wants to indentify these lagging sectors, i.e., specific combinations of agencies and boroughs where the resolution time is poorly performing. For each agency, which boroughs are underperforming in resolution speed for their most common complaints, and how does each borough's average resolution time compare to the agency's citywide benchmark?
- The mayor's office also wants to know whether certain types of 311 complaints are likely to be resolved within 3 days, and if a model can be built to flag fast vs. slow resolutions at intake.

## Assumptions and Known Issues
- Empty `closed_date` = open/unresolved requests
- Some `incident_zip` values are 0 or missing
- String dates need parsing in Athena/SQL