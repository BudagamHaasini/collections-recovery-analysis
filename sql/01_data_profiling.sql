-- ============================================================
-- COLLECTIONS RECOVERY ANALYSIS
-- 01_DATA_PROFILING.SQL
-- Purpose: Profile all RAW source datasets
-- No data is modified in this script.
-- ============================================================


-- ============================================================
-- 1. BORROWERS
-- ============================================================

SELECT
    'borrowers' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT borrower_id) AS unique_borrowers
FROM read_csv_auto('raw/borrowers.csv');

SELECT
    borrower_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/borrowers.csv')
GROUP BY borrower_id
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(borrower_id) AS missing_borrower_id,
    COUNT(*) - COUNT(client) AS missing_client,
    COUNT(*) - COUNT(geography) AS missing_geography,
    COUNT(*) - COUNT(language) AS missing_language,
    COUNT(*) - COUNT(borrower_segment) AS missing_segment,
    COUNT(*) - COUNT(income_band) AS missing_income_band
FROM read_csv_auto('raw/borrowers.csv');


-- ============================================================
-- 2. ACCOUNTS
-- ============================================================

SELECT
    'accounts' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT account_id) AS unique_accounts
FROM read_csv_auto('raw/accounts.csv');

SELECT
    account_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/accounts.csv')
GROUP BY account_id
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(account_id) AS missing_account_id,
    COUNT(*) - COUNT(borrower_id) AS missing_borrower_id,
    COUNT(*) - COUNT(dpd) AS missing_dpd,
    COUNT(*) - COUNT(outstanding_amount) AS missing_outstanding,
    COUNT(*) - COUNT(account_open_date) AS missing_open_date,
    COUNT(*) - COUNT(status) AS missing_status
FROM read_csv_auto('raw/accounts.csv');

SELECT
    MIN(dpd) AS min_dpd,
    MAX(dpd) AS max_dpd,
    AVG(dpd) AS avg_dpd
FROM read_csv_auto('raw/accounts.csv');

SELECT
    status,
    COUNT(*) AS account_count
FROM read_csv_auto('raw/accounts.csv')
GROUP BY status
ORDER BY account_count DESC;

SELECT
    COUNT(*) AS orphan_accounts
FROM read_csv_auto('raw/accounts.csv') a
LEFT JOIN read_csv_auto('raw/borrowers.csv') b
    ON a.borrower_id = b.borrower_id
WHERE b.borrower_id IS NULL;


-- ============================================================
-- 3. AGENTS
-- ============================================================

SELECT
    'agents' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT agent_id) AS unique_agent_ids
FROM read_csv_auto('raw/agents.csv');

SELECT
    agent_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/agents.csv')
GROUP BY agent_id
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(agent_id) AS missing_agent_id,
    COUNT(*) - COUNT(agent_name) AS missing_agent_name,
    COUNT(*) - COUNT(tenure_months) AS missing_tenure,
    COUNT(*) - COUNT(vendor) AS missing_vendor
FROM read_csv_auto('raw/agents.csv');

SELECT
    vendor,
    COUNT(*) AS agent_count
FROM read_csv_auto('raw/agents.csv')
GROUP BY vendor
ORDER BY agent_count DESC;


-- ============================================================
-- 4. AGENT SESSIONS
-- ============================================================

SELECT
    'agent_sessions' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT session_id) AS unique_sessions
FROM read_csv_auto('raw/agent_sessions.csv');

SELECT
    session_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/agent_sessions.csv')
GROUP BY session_id
HAVING COUNT(*) > 1;

SELECT
    MIN(logged_hours) AS min_logged_hours,
    MAX(logged_hours) AS max_logged_hours,
    MIN(productive_hours) AS min_productive_hours,
    MAX(productive_hours) AS max_productive_hours
FROM read_csv_auto('raw/agent_sessions.csv');

SELECT
    COUNT(*) AS invalid_sessions
FROM read_csv_auto('raw/agent_sessions.csv')
WHERE logged_hours < 0
   OR productive_hours < 0
   OR productive_hours > logged_hours;


-- ============================================================
-- 5. CAMPAIGNS
-- ============================================================

SELECT
    'campaigns' AS table_name,
    COUNT(*) AS total_campaigns,
    COUNT(DISTINCT campaign_id) AS unique_campaigns
FROM read_csv_auto('raw/campaigns.csv');

SELECT
    campaign_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/campaigns.csv')
GROUP BY campaign_id
HAVING COUNT(*) > 1;

SELECT
    targeting_strategy,
    COUNT(*) AS campaigns
FROM read_csv_auto('raw/campaigns.csv')
GROUP BY targeting_strategy;


-- ============================================================
-- 6. DAILY TARGETING
-- ============================================================

SELECT
    'daily_targeting' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT targeting_id) AS unique_targeting_events
FROM read_csv_auto('raw/daily_targeting.csv');

SELECT
    targeting_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/daily_targeting.csv')
GROUP BY targeting_id
HAVING COUNT(*) > 1;

SELECT
    MIN(propensity_score) AS min_score,
    MAX(propensity_score) AS max_score
FROM read_csv_auto('raw/daily_targeting.csv');

SELECT
    COUNT(*) AS invalid_scores
FROM read_csv_auto('raw/daily_targeting.csv')
WHERE propensity_score < 0
   OR propensity_score > 1;


-- ============================================================
-- 7. CALLS
-- ============================================================

SELECT
    'calls' AS table_name,
    COUNT(*) AS total_calls,
    COUNT(DISTINCT call_id) AS unique_calls
FROM read_csv_auto('raw/calls.csv');

SELECT
    call_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/calls.csv')
GROUP BY call_id
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS missing_key_fields
FROM read_csv_auto('raw/calls.csv')
WHERE account_id IS NULL
   OR agent_id IS NULL
   OR call_timestamp IS NULL;

SELECT
    channel,
    COUNT(*) AS calls
FROM read_csv_auto('raw/calls.csv')
GROUP BY channel
ORDER BY calls DESC;


-- ============================================================
-- 8. CALL ATTEMPTS
-- ============================================================

SELECT
    'call_attempts' AS table_name,
    COUNT(*) AS total_attempts,
    COUNT(DISTINCT attempt_id) AS unique_attempts
FROM read_csv_auto('raw/call_attempts.csv');

SELECT
    attempt_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/call_attempts.csv')
GROUP BY attempt_id
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS orphan_attempts
FROM read_csv_auto('raw/call_attempts.csv') ca
LEFT JOIN read_csv_auto('raw/calls.csv') c
    ON ca.call_id = c.call_id
WHERE c.call_id IS NULL;


-- ============================================================
-- 9. CALL DISPOSITIONS
-- ============================================================

SELECT
    'call_dispositions' AS table_name,
    COUNT(*) AS total_dispositions,
    COUNT(DISTINCT disposition_id) AS unique_dispositions
FROM read_csv_auto('raw/call_dispositions.csv');

SELECT
    raw_disposition_code,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/call_dispositions.csv')
GROUP BY raw_disposition_code
ORDER BY occurrences DESC;

SELECT
    MIN(disposition_timestamp) AS first_disposition,
    MAX(disposition_timestamp) AS last_disposition
FROM read_csv_auto('raw/call_dispositions.csv');

-- Look specifically for the vendor-code change around April 2026
SELECT
    DATE_TRUNC('month', disposition_timestamp) AS month,
    raw_disposition_code,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/call_dispositions.csv')
GROUP BY month, raw_disposition_code
ORDER BY month, raw_disposition_code;


-- ============================================================
-- 10. WHATSAPP EVENTS
-- ============================================================

SELECT
    'whatsapp_events' AS table_name,
    COUNT(*) AS total_events,
    COUNT(DISTINCT event_id) AS unique_events
FROM read_csv_auto('raw/whatsapp_events.csv');

SELECT
    event_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/whatsapp_events.csv')
GROUP BY event_id
HAVING COUNT(*) > 1;

SELECT
    event_type,
    COUNT(*) AS events
FROM read_csv_auto('raw/whatsapp_events.csv')
GROUP BY event_type
ORDER BY events DESC;


-- ============================================================
-- 11. SMS EVENTS
-- ============================================================

SELECT
    'sms_events' AS table_name,
    COUNT(*) AS total_events,
    COUNT(DISTINCT sms_id) AS unique_events
FROM read_csv_auto('raw/sms_events.csv');

SELECT
    sms_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/sms_events.csv')
GROUP BY sms_id
HAVING COUNT(*) > 1;

SELECT
    event_type,
    COUNT(*) AS events
FROM read_csv_auto('raw/sms_events.csv')
GROUP BY event_type
ORDER BY events DESC;


-- ============================================================
-- 12. FIELD VISITS
-- ============================================================

SELECT
    'field_visits' AS table_name,
    COUNT(*) AS total_visits,
    COUNT(DISTINCT visit_id) AS unique_visits
FROM read_csv_auto('raw/field_visits.csv');

SELECT
    visit_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/field_visits.csv')
GROUP BY visit_id
HAVING COUNT(*) > 1;

SELECT
    visit_status,
    COUNT(*) AS visits
FROM read_csv_auto('raw/field_visits.csv')
GROUP BY visit_status
ORDER BY visits DESC;


-- ============================================================
-- 13. PROMISES TO PAY
-- ============================================================

SELECT
    'promises_to_pay' AS table_name,
    COUNT(*) AS total_ptps,
    COUNT(DISTINCT ptp_id) AS unique_ptps
FROM read_csv_auto('raw/promises_to_pay.csv');

SELECT
    ptp_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/promises_to_pay.csv')
GROUP BY ptp_id
HAVING COUNT(*) > 1;

SELECT
    ptp_status,
    COUNT(*) AS ptps,
    SUM(promised_amount) AS promised_amount
FROM read_csv_auto('raw/promises_to_pay.csv')
GROUP BY ptp_status;

SELECT
    COUNT(*) AS invalid_ptps
FROM read_csv_auto('raw/promises_to_pay.csv')
WHERE promised_amount <= 0
   OR promised_due_date < CAST(ptp_created_at AS DATE);


-- ============================================================
-- 14. PAYMENTS
-- ============================================================

SELECT
    'payments' AS table_name,
    COUNT(*) AS total_records,
    COUNT(DISTINCT payment_id) AS unique_payment_ids
FROM read_csv_auto('raw/payments.csv');

SELECT
    payment_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/payments.csv')
GROUP BY payment_id
HAVING COUNT(*) > 1;

SELECT
    payment_status,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT payment_id) AS unique_payments,
    SUM(amount) AS total_amount
FROM read_csv_auto('raw/payments.csv')
GROUP BY payment_status;

SELECT
    COUNT(*) AS invalid_amount_records,
    SUM(amount) AS invalid_amount_total
FROM read_csv_auto('raw/payments.csv')
WHERE amount <= 0;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(payment_id) AS missing_payment_id,
    COUNT(*) - COUNT(account_id) AS missing_account_id,
    COUNT(*) - COUNT(payment_timestamp) AS missing_timestamp,
    COUNT(*) - COUNT(amount) AS missing_amount,
    COUNT(*) - COUNT(payment_status) AS missing_status,
    COUNT(*) - COUNT(payment_method) AS missing_method,
    COUNT(*) - COUNT(reported_channel) AS missing_channel
FROM read_csv_auto('raw/payments.csv');

SELECT
    COUNT(*) AS orphan_payment_records
FROM read_csv_auto('raw/payments.csv') p
LEFT JOIN read_csv_auto('raw/accounts.csv') a
    ON p.account_id = a.account_id
WHERE a.account_id IS NULL;


-- ============================================================
-- 15. VENDOR TELEPHONY
-- ============================================================

SELECT
    vendor,
    raw_code,
    standard_code,
    effective_from
FROM read_csv_auto('raw/vendor_telephony.csv')
ORDER BY vendor, effective_from, raw_code;

SELECT
    vendor,
    raw_code,
    COUNT(*) AS mappings
FROM read_csv_auto('raw/vendor_telephony.csv')
GROUP BY vendor, raw_code
HAVING COUNT(*) > 1;


-- ============================================================
-- 16. COMPLAINTS
-- ============================================================

SELECT
    'complaints' AS table_name,
    COUNT(*) AS total_complaints,
    COUNT(DISTINCT complaint_id) AS unique_complaints
FROM read_csv_auto('raw/complaints.csv');

SELECT
    complaint_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/complaints.csv')
GROUP BY complaint_id
HAVING COUNT(*) > 1;

SELECT
    complaint_type,
    COUNT(*) AS complaints
FROM read_csv_auto('raw/complaints.csv')
GROUP BY complaint_type
ORDER BY complaints DESC;


-- ============================================================
-- 17. ACCOUNT STATUS HISTORY
-- ============================================================

SELECT
    'account_status_history' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT history_id) AS unique_history_ids
FROM read_csv_auto('raw/account_status_history.csv');

SELECT
    history_id,
    COUNT(*) AS occurrences
FROM read_csv_auto('raw/account_status_history.csv')
GROUP BY history_id
HAVING COUNT(*) > 1;

SELECT
    status,
    COUNT(*) AS history_events
FROM read_csv_auto('raw/account_status_history.csv')
GROUP BY status
ORDER BY history_events DESC;

SELECT
    COUNT(*) AS orphan_history_records
FROM read_csv_auto('raw/account_status_history.csv') h
LEFT JOIN read_csv_auto('raw/accounts.csv') a
    ON h.account_id = a.account_id
WHERE a.account_id IS NULL;
SELECT *
FROM read_csv_auto('raw/borrowers.csv')
WHERE borrower_id = 'B00016';

SELECT *
FROM read_csv_auto('raw/accounts.csv')
WHERE account_id = 'A000026';

SELECT *
FROM read_csv_auto('raw/agent_sessions.csv')
WHERE logged_hours < 0
   OR productive_hours < 0
   OR productive_hours > logged_hours
LIMIT 20;

SELECT *
FROM read_csv_auto('raw/call_attempts.csv')
WHERE attempt_id = 'ATT000000021';
