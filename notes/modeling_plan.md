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
- `incident_zip` (integer)
- `day_of_week` (integer)
- `hour_of_day` (integer)
- `problem_category` (string, convert to categorical)

## Target
- **Name:** `resolved_quickly`
- **Type:** Classification; yes = 1, no = 0
- **Balance/Distribution:** The number of complaints resolved quickly, or within three days, in this sample is 146158, which is 84.06% of the data. The number of complaints that take longer is 27712, which is 15.94%.

## Modeling approach
- **Baseline:** Logistic regression (interpretable, fast to train)
- **Metrics:** Accuracy, precision, recall
- **Train/test split:** 80/20 with stratified sampling for classes

## Data quality notes
- The data has a class imbalance problem.
- For future work, an agency-by-agency definition for resolution speed would be beneficial. For example, the NYPD might need a definition of less than a day instead of 3 if 95% of their complaints are resolved in so little time. This is temporarily outside the scope of the project.
- 1768 rows have a missing zip code. I have decided to drop the zip codes for this reason, along with the wider reasoning that it is difficult to do one-hot encoding with more than 200 unique codes. It would be nonsensical to use them as a numerical feature.
- Upon the application of the IQR method for all continuous features, no outliers have been detected. I.e., no data falls outside $Q_1 - 1.5(Q_3-Q_1)$.

## Baseline Model Results

- **Model:** Logistic Regression
- **Features used:**  `agency`, `borough`, `problem_category`, `day_of_week`, `hour_of_day`
- **Target:** `resolved_quickly
- **Train/test split:** 80/20, `random_state=492`, stratified sampling

### Metrics
- Accuracy:  0.847
- Precision: 0.853
- Recall:    0.988

### Interpretation
The model achieves an overall accuracy of 85%, but this is largely driven by the 84-16 class imbalance, as the confusion matrix shows the model almost exclusively predicts the majority class (Class 1, resolved quickly). While recall for Class 1 is 99%, the model struggles significantly to identify slow resolutions, with a recall of only 10% for Class 0. For stakeholders, precision for Class 0 is likely more important to avoid "false alarms" when flagging slow resolutions, yet the current model is effectively a majority-class classifier that offers little predictive power for the minority group. Recall for Class 1 is also important, since one does not need missing cases of urgent resolution problems that do not get all the resources they need. The agency that the problem is being assigned to is highly predictive of the resolution speed, as well as which hour of the day. The problem being associated with traffic also makes it more likely to be resolved quickly. However, none of the other features match the influence of whether the problem was assigned to the NYPD or not.

### Limitation
A primary limitation is the imbalance-driven bias, where the model achieves high accuracy simply by predicting that nearly every complaint will be resolved quickly. Because the model has a recall of only 0.10 for the "slow" class, it fails to meet the business objective of flagging projected slow resolutions. Furthermore, the high positive coefficients for specific agencies (like `agency_NYPD`) suggest the model may be relying on agency-level shortcuts rather than capturing the actual complexity of the problems, potentially overlooking neighborhood or temporal variations that are more actionable for stakeholders. I was unable to provide reasonable data for regionality beyond the borough, like the zip code in the current framing of the model, or a more specific problem classification, due to computational constraints and missing values. While it does not look like the borough where the problem is taking place is highly predictive, it is possible that including the zip code may have provided more information.

## Comparison with SageMaker models

I used the Linear Learner built-in model to conduct this binary classification. The results were exactly the same in terms of accuracy, precision, and recall. I do not recommend the computational cost of using the built-in SageMaker workflow for this project, as there is no significant positive effect of using it on the magnitude of data we currently have. This may change if we switch to a computationally expensive model like XGBoost that may need more compute and may end up being faster to use on SageMaker's built-in network rather than our local installations.

## Next steps
- Look into alternative sampling methods to manage class balance, or amending thresholds for quick resolution
- Look into dimensionality reduction