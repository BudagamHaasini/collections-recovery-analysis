-- ============================================================
-- COLLECTIONS RECOVERY ANALYSIS
-- 03_CLEANING.SQL
-- Purpose: Create cleaned analytical layer from RAW data
-- RAW files are never modified.
-- ============================================================


-- ============================================================
-- 1. CLEAN BORROWERS
-- Remove exact duplicate borrower records
-- ============================================================

CREATE OR REPLACE TABLE clean_borrowers AS
SELECT DISTINCT *
FROM read_csv_auto('raw/borrowers.csv');


-- ============================================================
-- 2. CLEAN ACCOUNTS
-- Remove exact duplicate account records
-- ============================================================

CREATE OR REPLACE TABLE clean_accounts AS
SELECT DISTINCT *
FROM read_csv_auto('raw/accounts.csv');


-- ============================================================
-- 3. CLEAN AGENTS
-- No duplicate IDs or missing key fields detected
-- ============================================================

CREATE OR REPLACE TABLE clean_agents AS
SELECT *
FROM read_csv_auto('raw/agents.csv');


-- ============================================================
-- 4. CLEAN AGENT SESSIONS
--
-- Preserve all records.
-- Create a quality flag instead of deleting anomalous sessions.
-- ============================================================

CREATE OR REPLACE TABLE clean_agent_sessions AS
SELECT
    *,
    CASE
        WHEN logged_hours < 0
          OR productive_hours < 0
          OR productive_hours > logged_hours
        THEN TRUE
        ELSE FALSE
    END AS session_quality_issue
FROM read_csv_auto('raw/agent_sessions.csv');


-- ============================================================
-- 5. CLEAN CAMPAIGNS
-- No duplicate campaign IDs detected.
-- ============================================================

CREATE OR REPLACE TABLE clean_campaigns AS
SELECT *
FROM read_csv_auto('raw/campaigns.csv');


-- ============================================================
-- 6. CLEAN DAILY TARGETING
-- ============================================================

CREATE OR REPLACE TABLE clean_daily_targeting AS
SELECT
    *,
    CASE
        WHEN propensity_score BETWEEN 0 AND 1
        THEN TRUE
        ELSE FALSE
    END AS valid_propensity_score
FROM read_csv_auto('raw/daily_targeting.csv');


-- ============================================================
-- 7. CLEAN CALLS
-- ============================================================

CREATE OR REPLACE TABLE clean_calls AS
SELECT *
FROM read_csv_auto('raw/calls.csv');


-- ============================================================
-- 8. CLEAN CALL ATTEMPTS
-- Remove exact duplicate attempt records
-- ============================================================

CREATE OR REPLACE TABLE clean_call_attempts AS
SELECT DISTINCT *
FROM read_csv_auto('raw/call_attempts.csv');


-- ============================================================
-- 9. CLEAN CALL DISPOSITIONS
--
-- Standardize historical and new vendor codes.
-- Raw code is preserved.
-- ============================================================

CREATE OR REPLACE TABLE clean_call_dispositions AS
SELECT
    d.*,
    CASE
        WHEN d.raw_disposition_code IN ('ANSWERED', 'CONNECTED')
            THEN 'CONTACT'

        WHEN d.raw_disposition_code IN ('BUSY', 'NO_ANSWER', 'NA')
            THEN 'NO_CONTACT'

        WHEN d.raw_disposition_code IN ('PTP', 'PROMISE')
            THEN 'PTP'

        WHEN d.raw_disposition_code IN ('WRONG_PARTY', 'WRONG_NUMBER')
            THEN 'WRONG_PARTY'

        ELSE 'UNKNOWN'
    END AS standard_code
FROM read_csv_auto('raw/call_dispositions.csv') d;

-- ============================================================
-- 10. CLEAN WHATSAPP
-- ============================================================

CREATE OR REPLACE TABLE clean_whatsapp_events AS
SELECT DISTINCT *
FROM read_csv_auto('raw/whatsapp_events.csv');


-- ============================================================
-- 11. CLEAN SMS
-- ============================================================

CREATE OR REPLACE TABLE clean_sms_events AS
SELECT DISTINCT *
FROM read_csv_auto('raw/sms_events.csv');


-- ============================================================
-- 12. CLEAN FIELD VISITS
-- ============================================================

CREATE OR REPLACE TABLE clean_field_visits AS
SELECT DISTINCT *
FROM read_csv_auto('raw/field_visits.csv');


-- ============================================================
-- 13. CLEAN PTP
-- ============================================================

CREATE OR REPLACE TABLE clean_promises_to_pay AS
SELECT DISTINCT *
FROM read_csv_auto('raw/promises_to_pay.csv');


-- ============================================================
-- 14. CLEAN PAYMENTS
--
-- Exact duplicate payment records are removed.
-- One row per payment_id.
-- ============================================================

CREATE OR REPLACE TABLE clean_payments AS
SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY payment_id
            ORDER BY payment_timestamp
        ) AS rn
    FROM read_csv_auto('raw/payments.csv')
)
WHERE rn = 1;


-- ============================================================
-- 15. VENDOR TELEPHONY
-- Mapping table itself is retained.
-- ============================================================

CREATE OR REPLACE TABLE clean_vendor_telephony AS
SELECT DISTINCT *
FROM read_csv_auto('raw/vendor_telephony.csv');


-- ============================================================
-- 16. COMPLAINTS
-- ============================================================

CREATE OR REPLACE TABLE clean_complaints AS
SELECT DISTINCT *
FROM read_csv_auto('raw/complaints.csv');


-- ============================================================
-- 17. ACCOUNT STATUS HISTORY
--
-- History events are not deduplicated by account_id.
-- history_id is the event-level key.
-- ============================================================

CREATE OR REPLACE TABLE clean_account_status_history AS
SELECT DISTINCT *
FROM read_csv_auto('raw/account_status_history.csv');


-- ============================================================
-- CLEANING SUMMARY
-- ============================================================

SELECT 'borrowers' AS dataset, COUNT(*) AS clean_rows
FROM clean_borrowers

UNION ALL

SELECT 'accounts', COUNT(*)
FROM clean_accounts

UNION ALL

SELECT 'agents', COUNT(*)
FROM clean_agents

UNION ALL

SELECT 'agent_sessions', COUNT(*)
FROM clean_agent_sessions

UNION ALL

SELECT 'campaigns', COUNT(*)
FROM clean_campaigns

UNION ALL

SELECT 'daily_targeting', COUNT(*)
FROM clean_daily_targeting

UNION ALL

SELECT 'calls', COUNT(*)
FROM clean_calls

UNION ALL

SELECT 'call_attempts', COUNT(*)
FROM clean_call_attempts

UNION ALL

SELECT 'call_dispositions', COUNT(*)
FROM clean_call_dispositions

UNION ALL

SELECT 'whatsapp_events', COUNT(*)
FROM clean_whatsapp_events

UNION ALL

SELECT 'sms_events', COUNT(*)
FROM clean_sms_events

UNION ALL

SELECT 'field_visits', COUNT(*)
FROM clean_field_visits

UNION ALL

SELECT 'promises_to_pay', COUNT(*)
FROM clean_promises_to_pay

UNION ALL

SELECT 'payments', COUNT(*)
FROM clean_payments

UNION ALL

SELECT 'vendor_telephony', COUNT(*)
FROM clean_vendor_telephony

UNION ALL

SELECT 'complaints', COUNT(*)
FROM clean_complaints

UNION ALL

SELECT 'account_status_history', COUNT(*)
FROM clean_account_status_history;