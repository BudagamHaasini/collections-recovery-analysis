-- ============================================================
-- COLLECTIONS RECOVERY ANALYSIS
-- 02_DATA_QUALITY.SQL
-- Purpose: Document confirmed data-quality issues
-- Source: RAW datasets
-- ============================================================


-- ============================================================
-- ISSUE 1: DUPLICATE BORROWER
-- ============================================================

-- Finding:
-- B00016 appears twice with identical attributes.
-- Treatment: retain one record per borrower_id.

SELECT
    borrower_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/borrowers.csv')
GROUP BY borrower_id
HAVING COUNT(*) > 1;


-- ============================================================
-- ISSUE 2: DUPLICATE ACCOUNT
-- ============================================================

-- Finding:
-- A000026 appears twice with identical attributes.
-- Treatment: retain one record per account_id.

SELECT
    account_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/accounts.csv')
GROUP BY account_id
HAVING COUNT(*) > 1;


-- ============================================================
-- ISSUE 3: INVALID AGENT SESSION HOURS
-- ============================================================

-- Finding:
-- 3,332 sessions have productive_hours greater than
-- logged_hours.
--
-- We will NOT invent corrected values.
-- Treatment:
-- Exclude invalid sessions from agent-hour productivity metrics.
-- Preserve the raw records for auditability.

SELECT
    COUNT(*) AS invalid_session_count
FROM read_csv_auto('raw/agent_sessions.csv')
WHERE logged_hours < 0
   OR productive_hours < 0
   OR productive_hours > logged_hours;


-- Calculate affected hours
SELECT
    SUM(logged_hours) AS affected_logged_hours,
    SUM(productive_hours) AS affected_productive_hours
FROM read_csv_auto('raw/agent_sessions.csv')
WHERE logged_hours < 0
   OR productive_hours < 0
   OR productive_hours > logged_hours;


-- ============================================================
-- ISSUE 4: DUPLICATE CALL ATTEMPT
-- ============================================================

-- Finding:
-- ATT000000021 appears twice with identical attributes.
-- Treatment: retain one record per attempt_id.

SELECT
    attempt_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/call_attempts.csv')
GROUP BY attempt_id
HAVING COUNT(*) > 1;


-- ============================================================
-- ISSUE 5: TELEPHONY DISPOSITION CODE CHANGE
-- ============================================================

-- Finding:
-- Disposition vocabulary changes beginning April 2026.
--
-- Historical codes:
-- ANSWERED, BUSY, NO_ANSWER, PTP, WRONG_PARTY
--
-- New codes:
-- CONNECTED, NA, PROMISE, WRONG_NUMBER
--
-- Treatment:
-- Standardize raw codes using vendor_telephony mapping.
-- Preserve raw_disposition_code for auditability.

SELECT
    d.raw_disposition_code,
    v.standard_code,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/call_dispositions.csv') d
LEFT JOIN read_csv_auto('raw/vendor_telephony.csv') v
    ON d.raw_disposition_code = v.raw_code
GROUP BY
    d.raw_disposition_code,
    v.standard_code
ORDER BY occurrences DESC;


-- ============================================================
-- ISSUE 6: DUPLICATE PAYMENTS
-- ============================================================

-- Finding:
-- 5 payment IDs occur twice.
-- The duplicated records are exact copies.
--
-- Treatment:
-- Retain one record per payment_id.

SELECT
    payment_id,
    COUNT(*) AS occurrences,
    SUM(
        CASE
            WHEN payment_status = 'SUCCESS'
            THEN amount
            ELSE 0
        END
    ) AS duplicated_success_amount
FROM read_csv_auto('raw/payments.csv')
GROUP BY payment_id
HAVING COUNT(*) > 1;


-- Total potential successful amount affected by duplicates

SELECT
    SUM(amount) AS potential_duplicate_success_amount
FROM read_csv_auto('raw/payments.csv')
WHERE payment_status = 'SUCCESS'
AND payment_id IN (
    SELECT payment_id
    FROM read_csv_auto('raw/payments.csv')
    GROUP BY payment_id
    HAVING COUNT(*) > 1
);


-- ============================================================
-- ISSUE 7: TARGETING STRATEGY CHANGE
-- ============================================================

-- Finding:
-- Campaigns contain OLD_TARGETING and NEW_TARGETING.
--
-- This is NOT treated as a data error.
-- It is an analytical treatment/control variable.
--
-- It will be used later for the counterfactual analysis.

SELECT
    targeting_strategy,
    COUNT(*) AS campaign_count
FROM read_csv_auto('raw/campaigns.csv')
GROUP BY targeting_strategy;


-- ============================================================
-- ISSUE 8: ACCOUNT STATUS HISTORY
-- ============================================================

-- Finding:
-- Multiple history records per account are expected because
-- accounts can transition through multiple statuses.
--
-- Therefore these records are NOT deduplicated simply by account_id.
--
-- Unique history_id is used as the event-level key.

SELECT
    COUNT(*) AS total_history_events,
    COUNT(DISTINCT history_id) AS unique_history_events,
    COUNT(DISTINCT account_id) AS accounts_with_history
FROM read_csv_auto('raw/account_status_history.csv');


-- ============================================================
-- DATA QUALITY SUMMARY
-- ============================================================

SELECT
    'borrowers' AS dataset,
    'Duplicate borrower_id' AS issue,
    1 AS affected_records,
    'Retain one exact duplicate' AS treatment

UNION ALL

SELECT
    'accounts',
    'Duplicate account_id',
    1,
    'Retain one exact duplicate'

UNION ALL

SELECT
    'agent_sessions',
    'Invalid productive hours',
    3332,
    'Exclude from productivity metrics'

UNION ALL

SELECT
    'call_attempts',
    'Duplicate attempt_id',
    1,
    'Retain one exact duplicate'

UNION ALL

SELECT
    'call_dispositions',
    'Disposition code change',
    1,
    'Standardize using vendor mapping'

UNION ALL

SELECT
    'payments',
    'Duplicate payment IDs',
    5,
    'Retain one exact duplicate';