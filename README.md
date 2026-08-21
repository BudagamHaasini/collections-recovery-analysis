# Collections Recovery Analysis

## Overview

This project analyzes approximately 12 months of collections and recovery data to determine whether the business claim:

> "Recovery has improved significantly."

is supported by the underlying data.

The analysis works with multiple operational datasets covering borrowers, accounts, agents, campaigns, calls, call attempts, call dispositions, digital interactions, field visits, promises-to-pay, payments, complaints, and account status history.

The project focuses on identifying data-quality issues, creating a reliable analytical dataset, calculating recovery metrics, analyzing month-on-month performance, and evaluating the impact of targeting strategies.

The final result is an interactive Streamlit dashboard that presents the major findings.

---

## Business Objective

The business currently reports an improvement in recovery performance.

The objective of this project is to determine:

- Whether recovery performance actually improved
- Whether the improvement was sustained over time
- How recovery varies across DPD buckets
- Whether the new targeting strategy performed better than the old strategy
- Which borrower segments perform better
- Which clients generate stronger recovery performance
- Whether the reported improvement can reasonably be attributed to the new targeting strategy

The analysis deliberately separates observed trends from causal claims.

---

## Dataset

The project contains the following datasets:

- Borrowers
- Accounts
- Agents
- Agent Sessions
- Campaigns
- Daily Targeting
- Calls
- Call Attempts
- Call Dispositions
- WhatsApp Events
- SMS Events
- Field Visits
- Promises to Pay
- Payments
- Vendor Telephony
- Complaints
- Account Status History

The data covers approximately 12 months from September 2025 through August 2026.

---

## Technology Stack

### Data Processing and Analysis

- Python
- DuckDB
- SQL
- Pandas

### Dashboard

- Streamlit
- Plotly

### Development

- Visual Studio Code
- Git
- GitHub

---

## Project Architecture

```text
Raw CSV Data
     |
     v
Data Profiling
     |
     v
Data Quality Checks
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
     +----------------------+
     |                      |
     v                      v
Monthly / DPD /        Targeting /
Segment Analysis       Client Analysis
     |                      |
     +----------+-----------+
                |
                v
       Streamlit Dashboard

Project Structure
collections-recovery-analysis/
│
├── app.py
├── check_schema.py
├── export_dashboard.py
│
├── run_sql.py
├── run_cleaning.py
├── run_golden.py
├── run_validation.py
├── run_metrics.py
├── run_mom.py
├── run_dpd.py
├── run_final_analysis.py
└── run_targeting_monthly.py
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
├── .gitignore
└── README.md
Data Profiling

The first stage profiles the raw datasets to understand:

Number of records
Number of unique identifiers
Duplicate records
Missing values
Invalid monetary values
Referential integrity
Status distributions
Basic dataset structure

For example, the payment dataset contained:

10,005 payment records
10,000 unique payment IDs
Duplicate payment records were identified
No invalid payment amounts
No missing values in the checked payment fields
No orphan payment records

The analysis therefore does not blindly trust raw totals.

Data Quality Findings

Several data-quality issues were identified during profiling.

The payment dataset contained duplicate payment IDs.

The raw payment data contained:

10,005 payment records
10,000 unique payments

Duplicates affected both successful and failed payment records.

The duplicated successful payment amount was approximately:

79,738.18

Therefore, counting raw payment rows would overstate recovery.

The cleaning process removes these duplicate records before calculating recovery metrics.

Data Cleaning

The cleaning layer creates standardized DuckDB tables such as:

clean_borrowers
clean_accounts
clean_agents
clean_agent_sessions
clean_campaigns
clean_daily_targeting
clean_calls
clean_call_attempts
clean_call_dispositions
clean_whatsapp_events
clean_sms_events
clean_field_visits
clean_promises_to_pay
clean_payments
clean_vendor_telephony
clean_complaints
clean_account_status_history

The cleaning process handles:

Duplicate records
Standardized identifiers
Data types
Status values
Date and timestamp fields
Monetary values
Referential integrity
Golden Dataset

A monthly account-level analytical dataset is created with the grain:

One row per account per month

The Golden Dataset combines:

Account information
Borrower information
DPD
Outstanding amount
Call activity
Call attempts
Contacts
Promises-to-pay
Kept promises-to-pay
Successful payments
Recovered amount
Targeting strategy
Priority band
Propensity score

The final Golden Dataset contains:

33,362 rows
4,200 unique accounts
12 months
Golden Dataset Validation

The Golden Dataset was validated against the cleaned source data.

Recovered Amount
Clean Payments:    61,638,872.27
Golden Dataset:    61,638,872.27
Successful Payments
Clean Payments:    7,504
Golden Dataset:    7,504
Promises to Pay
Clean PTP:         6,500
Golden Dataset:    6,500
Calls
Clean Calls:       30,000
Golden Dataset:    30,000

Additional validation confirmed:

Missing borrower-account relationships: 0
Negative recovery rows:                0
Recovery Metrics

The main recovery metric is:

Recovery Rate =
Recovered Amount / Outstanding Amount

Additional metrics include:

Recovery per account
Recovery per attempt
Contact rate
PTP rate
PTP kept rate
Total attempts
Total contacts
Total recovered amount
Key Findings
1. Recovery improvement was not sustained

Monthly recovery rates were:

Month	Recovery Rate
Sep 2025	7.52%
Oct 2025	7.21%
Nov 2025	6.69%
Dec 2025	6.64%
Jan 2026	6.75%
Feb 2026	7.49%
Mar 2026	7.44%
Apr 2026	6.89%
May 2026	6.72%
Jun 2026	6.70%
Jul 2026	6.69%
Aug 2026	7.14%

The largest month-on-month increase occurred from January to February 2026:

Recovery Rate:
6.75% → 7.49%


Month-on-month improvement:
+10.99%

However, the improvement was not sustained in subsequent months.

Therefore, the data does not support a claim of sustained recovery improvement.

2. NEW_TARGETING did not demonstrate superior recovery

The overall targeting analysis produced:

Targeting Strategy	Recovery Rate
OLD_TARGETING	4.68%
NEW_TARGETING	4.61%

The monthly targeting analysis also shows that NEW_TARGETING was introduced in March 2026.

The February 2026 recovery increase occurred before the introduction of NEW_TARGETING.

Therefore, the February improvement cannot reasonably be attributed to the new targeting strategy based on this dataset alone.

This is an important distinction between:

Correlation / timing

and

Causal impact
3. Recovery varies by borrower segment
Borrower Segment	Recovery Rate
Informal	7.43%
Salaried	7.03%
Self_Employed	6.68%

The Informal segment had the highest recovery rate among the analyzed borrower segments.

4. Recovery varies by client
Client	Recovery Rate
Client_D	7.12%
Client_B	7.11%
Client_A	6.99%
Client_C	6.71%

Client performance is relatively close but still shows measurable variation.

5. DPD affects recovery performance

Recovery was analyzed across DPD buckets:

01-30
31-60
61-90
91-120
121-180

The analysis demonstrates that recovery performance varies across delinquency stages.

This provides a basis for evaluating whether collection strategies should differ by DPD bucket.

Dashboard

The project includes an interactive Streamlit dashboard built with:

Streamlit
Plotly
Pandas

The dashboard provides:

KPI Cards
Recovery Rate
Total Recovered
Successful Payments
Accounts Analyzed
Visualizations
Monthly Recovery Rate
Recovery Rate by DPD
Old vs New Targeting
Recovery Rate by Borrower Segment
Recovery Rate by Client
Monthly Performance Table
Filters
Month
Client
Borrower Segment
Running the Project
1. Clone the repository
git clone https://github.com/BudagamHaasini/collections-recovery-analysis.git
cd collections-recovery-analysis
2. Install dependencies
python -m pip install duckdb pandas streamlit plotly
3. Run SQL analysis

The individual Python scripts execute the SQL analysis stages.

For example:

python run_sql.py
python run_cleaning.py
python run_golden.py
python run_validation.py
python run_metrics.py
python run_mom.py
python run_dpd.py
python run_final_analysis.py
python run_targeting_monthly.py
Running the Dashboard

The dashboard uses:

golden_account_month.csv

as its analytical input.

If the file needs to be regenerated, run:

python export_dashboard.py

This creates:

golden_account_month.csv

Then start Streamlit:

python -m streamlit run app.py

The dashboard will be available locally through the URL displayed by Streamlit, normally:

http://localhost:8501
Reproducibility

The project separates the analytical stages so that the workflow can be reproduced:

Profiling
    ↓
Quality Checks
    ↓
Cleaning
    ↓
Golden Dataset
    ↓
Validation
    ↓
Metrics
    ↓
Analysis
    ↓
Dashboard

Generated files such as the dashboard CSV are excluded from version control where appropriate.

Limitations

This analysis identifies associations and performance patterns but does not establish causal impact.

In particular:

The observed February 2026 improvement cannot by itself prove that a specific strategy caused the improvement.
NEW_TARGETING was introduced after the February increase.
Additional experimental design or controlled testing would be required to establish causal impact.
Recovery performance can also be affected by borrower mix, DPD composition, outstanding balances, client mix, and collection activity.
Business Recommendation

Based on the available data:

Do not report the February 2026 increase as a sustained improvement.
Do not attribute the February increase to NEW_TARGETING because the strategy was introduced afterward.
Continue monitoring recovery rate month over month.
Evaluate targeting performance by controlling for borrower segment and DPD.
Consider controlled testing of targeting strategies before making causal performance claims.
Monitor recovery per account and recovery per attempt in addition to aggregate recovery.
Skills Demonstrated

This project demonstrates practical experience with:

SQL
DuckDB
Python
Pandas
Data Cleaning
Data Quality Analysis
Data Validation
Data Modeling
Analytical Dataset Design
KPI Development
Month-on-Month Analysis
DPD Analysis
Segmentation Analysis
Targeting Strategy Analysis
Business Analysis
Streamlit
Plotly
Git
GitHub
Conclusion

The analysis shows that recovery performance fluctuated throughout the 12-month period rather than demonstrating a sustained improvement.

Although recovery increased by approximately 11% month over month from January to February 2026, the improvement was not sustained. Furthermore, NEW_TARGETING was introduced after the February increase, so the available evidence does not support attributing that increase to the new targeting strategy.

The project therefore demonstrates the importance of validating business claims against cleaned, reconciled, and properly modeled data before drawing conclusions.
