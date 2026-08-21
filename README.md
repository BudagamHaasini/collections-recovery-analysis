# collections-recovery-analysis
# Collections Recovery Analysis

## Overview

This project investigates a business claim that:

> "Recovery has improved by 11% month-on-month."

The objective is to independently evaluate this claim using approximately 12 months of collections data covering borrowers, accounts, agents, campaigns, calls, digital interactions, field visits, promises-to-pay, payments, complaints, and account status history.

The analysis focuses on determining whether the reported improvement is supported by the underlying data and identifying factors that may explain changes in recovery performance.

---

## Business Objective

The primary objective is to determine whether recovery performance has actually improved by 11% month-on-month.

The analysis also investigates:

- Recovery rate over time
- Month-on-month recovery changes
- DPD-level recovery performance
- Targeting strategy performance
- Borrower segment performance
- Client-level performance
- Contact and collection activity
- Data quality and attribution issues

The analysis intentionally avoids relying only on the reported business metric and instead reconstructs the key metrics independently from the underlying data.

---

## Technology Stack

### Programming and Analysis

- Python 3.13
- SQL
- DuckDB

### Development Tools

- Visual Studio Code
- PowerShell
- Git
- GitHub

### Data Processing

- DuckDB was used as the analytical SQL engine.
- Python scripts were used to execute SQL files and validate results.
- CSV files were used as the raw data source.

---

## Project Architecture

The project follows a layered analytical workflow:

```text
Raw Data
   |
   v
Data Profiling
   |
   v
Data Quality Assessment
   |
   v
Data Cleaning
   |
   v
Golden Dataset
   |
   v
Golden Dataset Validation
   |
   v
Recovery Metrics
   |
   v
Business Analysis
   |
   v
Business Conclusion
The raw data is never directly modified. Cleaning and analytical tables are created as derived datasets.

Dataset Overview

The project contains the following raw datasets:

Dataset	Description
borrowers.csv	Borrower-level information
accounts.csv	Account and outstanding balance information
agents.csv	Collection agent information
agent_sessions.csv	Agent login and productivity information
campaigns.csv	Campaign-level information
daily_targeting.csv	Daily account targeting information
calls.csv	Collection call records
call_attempts.csv	Individual call attempts
call_dispositions.csv	Call outcome/disposition information
whatsapp_events.csv	WhatsApp interaction events
sms_events.csv	SMS interaction events
field_visits.csv	Field collection visits
promises_to_pay.csv	Promises-to-pay records
payments.csv	Payment transactions
vendor_telephony.csv	Telephony disposition mapping
complaints.csv	Customer complaints
account_status_history.csv	Account status transition history
Data Profiling

The first stage of the project was to profile the raw datasets.

The profiling process examined:

Row counts
Column structures
Missing values
Duplicate records
Unique identifiers
Invalid amounts
Referential integrity
Status distributions
Channel distributions
Disposition-code changes
Account history structure

The profiling results were used to identify data-quality issues before any cleaning or business analysis was performed.

Data Quality Findings

Several data-quality issues were identified.

Duplicate Records

The following exact duplicate records were identified:

Dataset	Issue	Treatment
borrowers	Duplicate borrower record	Removed exact duplicate
accounts	Duplicate account record	Removed exact duplicate
call_attempts	Duplicate attempt record	Removed exact duplicate
payments	Five duplicate payment records	Removed exact duplicates

The raw records were preserved. Only the derived clean layer was modified.

Agent Session Anomalies

A number of agent session records contained cases where:

productive_hours > logged_hours

These records were not deleted because the underlying cause could not be established from the available data.

Instead, a quality flag was created:

session_quality_issue

This allows the records to remain available for auditability while preventing the anomaly from being silently treated as valid productivity data.

Call Disposition Changes

The telephony disposition vocabulary changed during the analysis period.

Historical codes included:

ANSWERED
BUSY
NO_ANSWER
PTP
WRONG_PARTY

Newer codes included:

CONNECTED
NA
PROMISE
WRONG_NUMBER

These codes were standardized into common analytical categories while preserving the original raw disposition code.

For example:

ANSWERED / CONNECTED
        -> CONTACT


BUSY / NO_ANSWER / NA
        -> NO_CONTACT


PTP / PROMISE
        -> PTP


WRONG_PARTY / WRONG_NUMBER
        -> WRONG_PARTY

This prevents the change in vendor terminology from being incorrectly interpreted as a change in collection performance.

Cleaning Layer

The cleaned analytical tables were generated from the raw CSV files.

Important cleaning decisions included:

Removing exact duplicate borrower records
Removing exact duplicate account records
Removing exact duplicate call-attempt records
Removing duplicate payment transactions
Standardizing telephony disposition codes
Flagging invalid agent-session records
Preserving account status history events
Preserving raw values for auditability

The account status history was not deduplicated by account_id because multiple status transitions for the same account are legitimate business events.

Golden Dataset

A Golden Dataset was created to provide a trusted analytical layer.

Analytical Grain

The Golden Dataset uses:

One row = One account in one month

The resulting table is:

golden_account_month

It combines information from:

Borrowers
Accounts
Calls
Call attempts
Call dispositions
Promises-to-pay
Payments
Daily targeting

The Golden Dataset contains account-level attributes together with monthly collection activity and recovery information.

Important fields include:

month
account_id
borrower_id
client
geography
language
borrower_segment
income_band
dpd
outstanding_amount
account_status
campaign_id
targeting_strategy
priority_band
propensity_score
total_calls
total_attempts
contacts
ptps
ptps_kept
promised_amount
successful_payments
recovered_amount
Golden Dataset Validation

The Golden Dataset was validated against the cleaned source tables to ensure that joins did not inflate important metrics.

The validation produced the following results:

Metric	Clean Source	Golden Dataset
Successful recovery amount	61,638,872.27	61,638,872.27
Successful payments	7,504	7,504
PTP records	6,500	6,500
Calls	30,000	30,000

Additional validation showed:

No missing borrower relationships
No negative recovery amounts
No duplicate (month, account_id) combinations

This confirms that the Golden Dataset preserves the major financial and operational totals from the cleaned source data.

Recovery Metrics

The primary recovery metric was defined as:

Recovery Rate =
Recovered Amount / Outstanding Amount

Additional operational metrics were calculated:

Contact Rate =
Contacts / Attempts


PTP Rate =
PTPs / Contacts


PTP Kept Rate =
PTPs Kept / PTPs


Recovery per Account =
Recovered Amount / Active Accounts


Recovery per Attempt =
Recovered Amount / Attempts

These metrics provide a broader view of collection effectiveness instead of relying on recovery amount alone.

Month-on-Month Recovery Analysis

The calculated recovery rates were:

Month	Recovery Rate	MoM Change
Sep-2025	7.52%	—
Oct-2025	7.21%	-4.09%
Nov-2025	6.69%	-7.25%
Dec-2025	6.64%	-0.71%
Jan-2026	6.75%	+1.70%
Feb-2026	7.49%	+10.99%
Mar-2026	7.44%	-0.72%
Apr-2026	6.89%	-7.38%
May-2026	6.72%	-2.44%
Jun-2026	6.70%	-0.31%
Jul-2026	6.69%	-0.20%
Aug-2026	7.14%	+6.71%
Business Claim Assessment
Reported Claim

"Recovery has improved by 11% month-on-month."

Finding

The claim is not supported as a sustained month-on-month trend.

There was a specific increase of approximately 11% between January and February 2026:

January 2026 Recovery Rate = 6.75%


February 2026 Recovery Rate = 7.49%


MoM Change = +10.99%

However, the improvement was not sustained.

The following month showed:

February → March = -0.72%

Further declines occurred in April, May, June, and July.

Therefore, the available 12-month data does not support the statement that recovery consistently improved by 11% month-on-month.

DPD Analysis

Recovery performance was also analyzed across DPD buckets.

The January-to-February comparison showed:

DPD Bucket	Jan Recovery	Feb Recovery
01–30	8.63%	7.45%
31–60	6.11%	7.49%
61–90	6.26%	7.57%
91–120	6.72%	6.97%
121–180	6.39%	7.79%

Several DPD groups improved simultaneously, while the number of accounts within each group remained relatively stable.

This suggests that the February improvement was not obviously explained by a large change in DPD portfolio composition.

However, this analysis does not establish causation.

Targeting Strategy Analysis

The targeting strategy changed during the observation period.

The data shows:

OLD_TARGETING
September 2025 – February 2026


NEW_TARGETING
March 2026 – August 2026

Observed overall recovery rates were:

Strategy	Recovery Rate
OLD_TARGETING	4.68%
NEW_TARGETING	4.61%

The new targeting strategy therefore did not show a clear overall recovery advantage.

More importantly, the approximately 11% improvement occurred in February 2026, when OLD_TARGETING was still being used.

Therefore:

The February 2026 improvement cannot be attributed to the introduction of NEW_TARGETING.

Targeting analysis also identified a large number of records without a targeting assignment, which limits the strength of the strategy comparison.

Borrower Segment Analysis

Recovery rates differed across borrower segments:

Borrower Segment	Recovery Rate
Informal	7.43%
Salaried	7.03%
Self_Employed	6.68%

Informal borrowers had the highest observed recovery rate, while Self_Employed borrowers had the lowest.

These differences can be used to support further segmentation analysis.

Client Analysis

Recovery rates by client were:

Client	Recovery Rate
Client_D	7.12%
Client_B	7.11%
Client_A	6.99%
Client_C	6.71%

Client_D had the highest observed recovery rate and Client_C had the lowest.

The differences are relatively moderate, so these results should be treated as descriptive rather than causal.

Key Findings
The reported 11% month-on-month improvement is not supported as a sustained trend.
February 2026 experienced an approximately 11% month-on-month increase in recovery rate.
The February improvement was not maintained in subsequent months.
Multiple DPD groups improved during February, suggesting that the increase was not obviously caused by a major DPD mix shift.
The new targeting strategy cannot explain the February improvement because it was introduced in March 2026.
NEW_TARGETING had a slightly lower overall observed recovery rate than OLD_TARGETING.
Recovery performance differs across borrower segments.
Recovery performance also differs across clients.
A significant number of records have no targeting assignment, limiting the strength of targeting comparisons.
Recovery should be monitored using multiple operational metrics rather than a single headline percentage.
Recommendations
1. Avoid reporting the 11% figure as a sustained improvement

The business should report the February improvement as a specific month-level result rather than presenting it as a persistent trend.

2. Investigate the February 2026 increase

Further investigation should focus on:

Agent performance
Campaign activity
Collection channels
Payment behavior
Borrower segmentation
Operational changes
3. Improve targeting coverage

The large number of records without a targeting assignment makes it difficult to evaluate targeting effectiveness reliably.

Targeting assignment should be consistently recorded.

4. Use segmented collection strategies

Recovery rates differ by:

DPD
Borrower segment
Client

These dimensions can be used to design more targeted collection strategies.

5. Monitor a broader KPI set

Recommended monitoring metrics include:

Recovery Rate
Recovery per Account
Recovery per Attempt
Contact Rate
PTP Rate
PTP Kept Rate

This provides a more complete picture of collection effectiveness.

SQL Analysis Files

The SQL analysis is organized sequentially:

File	Purpose
01_data_profiling.sql	Profile raw datasets
02_data_quality.sql	Document data-quality issues
03_cleaning.sql	Create cleaned analytical tables
04_golden_dataset.sql	Build account-month Golden Dataset
05_golden_validation.sql	Validate Golden Dataset totals
06_recovery_metrics.sql	Calculate recovery KPIs
07_mom_analysis.sql	Calculate month-on-month changes
08_dpd_analysis.sql	Analyze recovery by DPD
09_final_analysis.sql	Analyze targeting, segments and clients
10_targeting_monthly.sql	Analyze targeting performance over time
Python Utility Scripts

Python scripts are used to execute and validate the SQL workflow through DuckDB.

Examples include:

run_sql.py
run_cleaning.py
run_golden.py
run_validation.py
run_metrics.py
run_mom.py
run_dpd.py
run_final_analysis.py
run_targeting_monthly.py
check_schema.py

The Python layer is intentionally lightweight. SQL performs the majority of the data analysis.

Repository Structure
collections-recovery-analysis/
│
├── raw/
│   ├── borrowers.csv
│   ├── accounts.csv
│   ├── agents.csv
│   ├── agent_sessions.csv
│   ├── campaigns.csv
│   ├── daily_targeting.csv
│   ├── calls.csv
│   ├── call_attempts.csv
│   ├── call_dispositions.csv
│   ├── whatsapp_events.csv
│   ├── sms_events.csv
│   ├── field_visits.csv
│   ├── promises_to_pay.csv
│   ├── payments.csv
│   ├── vendor_telephony.csv
│   ├── complaints.csv
│   └── account_status_history.csv
│
├── sql/
│   ├── 01_data_profiling.sql
│   ├── 02_data_quality.sql
│   ├── 03_cleaning.sql
│   ├── 04_golden_dataset.sql
│   ├── 05_golden_validation.sql
│   ├── 06_recovery_metrics.sql
│   ├── 07_mom_analysis.sql
│   ├── 08_dpd_analysis.sql
│   ├── 09_final_analysis.sql
│   └── 10_targeting_monthly.sql
│
├── run_sql.py
├── run_cleaning.py
├── run_golden.py
├── run_validation.py
├── run_metrics.py
├── run_mom.py
├── run_dpd.py
├── run_final_analysis.py
├── run_targeting_monthly.py
├── check_schema.py
│
├── README.md
└── .gitignore
Limitations

This analysis is primarily descriptive and does not establish causal relationships.

In particular:

Targeting groups may contain different borrower populations.
Records without targeting assignments limit targeting comparisons.
Observational recovery differences cannot by themselves prove that a strategy caused an improvement.
Agent productivity anomalies were flagged rather than corrected because their underlying cause was unknown.
The recovery metric is based on recovered amount relative to outstanding amount and should be interpreted as a portfolio-level recovery ratio.
Additional statistical or experimental analysis would be required to establish causal effects.
Final Conclusion

Based on the analyzed data, the statement that recovery has improved by 11% month-on-month is not supported as a sustained trend.

An approximately 11% improvement occurred specifically between January and February 2026, but the improvement was not maintained in subsequent months.

The analysis also shows that the February improvement occurred before the introduction of the new targeting strategy, so the improvement cannot be attributed to NEW_TARGETING.

The appropriate business conclusion is therefore to treat February 2026 as a specific period of improvement requiring further investigation rather than evidence of a sustained 11% month-on-month recovery improvement.



### Final repo check


Before committing, make sure these are **not** uploaded:


```text
collections_analysis.duckdb
__pycache__/
profiling_output.txt

Your .gitignore handles those.

Then run:

git status

If everything looks correct:

git add .
git commit -m "Complete collections recovery analysis"
git push
