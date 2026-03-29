# NYC 311 Service Requests Data Dictionary (2026 Q1)

**Source**: NYC Open Data, Jan 29–Mar 21, 2026  
**Prepared by**: Devin Silvia, 2026-03-21  
**Rows**: complaints (200k random sample), agencies (unique agencies in sample)  
**Files**: `complaints.csv` (~50 MB), `agencies.csv` (~1 KB)

## complaints.csv (200k rows)

| Column | Type | Description | Example Value | Notes |
| :-- | :-- | :-- | :-- | :-- |
| unique_key | int | Unique request ID | 67760908 | Primary key, sequential |
| created_date | string | When request opened | "2026-01-29 08:18:28" | Format: YYYY-MM-DD HH:MM:SS |
| closed_date | string | When request closed | "2026-01-29 20:34:05" or empty | Empty/null = open/unresolved requests |
| agency | string | Agency code | "HPD" | Join key to agencies.agency |
| agency_name | string | Full agency name | "Department of Housing Preservation and Development" | Denormalized for convenience |
| problem | string | Type of service request | "HEAT/HOT WATER" | ~150 unique values |
| problem_detail | string | Details/subtype | "ENTIRE BUILDING" | Free text, some empty |
| incident_zip | int/str | ZIP code of incident | 10458 | May contain some missing/out-of-range values |
| status | string | Current status | "Open" | e.g., Open/Closed; may contain other values |
| resolution_description | string | How it was resolved | "The following complaint conditions..." | Free text, verbose, some empty |
| borough | string | NYC borough | "BRONX" | BRONX, MANHATTAN, QUEENS, etc. |

## agencies.csv (unique agencies in sample)

| Column | Type | Description | Example Value |
| :-- | :-- | :-- | :-- |
| agency | string | Agency code | "DCWP" |
| agency_name | string | Full agency name | "Department of Consumer and Worker Protection" |

## Key Stats

**complaints**: 200k rows × 11 cols (~100 MB)  
**agencies**: [12] rows × 2 cols (~1 KB)  
**Date range**: 2026-01-29 to 2026-03-21  



## Usage Notes

- **Primary join**: `complaints.agency = agencies.agency`
- **Common analyses**:
    - Daily request volume by borough/agency
    - Average resolution time by problem type
    - Top complaint types per borough
    - Predict resolution status (Open/Closed)
- **Known issues**:
    - `closed_date`: Empty strings = open requests
    - `incident_zip`: Some 0/null/out-of-range values
    - String dates: Use `DATE_PARSE(created_date, '%Y-%m-%d %H:%M:%S')` in Athena
    - `resolution_description`: Long text, some empty

**S3 structure example**:

```
s3://cmse492-monislow-nyc311-975049958391-us-east-1-an/raw/
├── complaints/
│   └── complaints.csv
└── agencies/
    └── agencies.csv
```