# Sanity Check Log

## Query: Average resolution time by agency (2026-03-27)

- **File:** `sql/resolution_time.sql`
- **Business question:** How long does each agency take to resolve complaints?
- **What I expected:** I expected the NYPD to be the fastest agency due to their higher budget and the emergent nature of their work.
- **Issues encountered:** Query failed initially due to a false assumption of data to only include closed complaints.
- **Checks performed:** Resolved the issue by dropping open complaints to not skew average values with noisy/incomplete data. Verified via individual querying of average values for random agencies.
- **Final outcome:** As expected, the NYPD had the lowest resolution time on average at under a day, which makes sense due to the reasons mentioned above. The Economic Development Corporation takes the most time, with about 35 days on average. This made sense considering the fact that 311 complaints relating to public works may need the necessary approvals and sometimes litigation. The output is believable.
- **Confidence:** High. Would present to stakeholders.