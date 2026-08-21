-- ============================================================
-- GOLDEN DATASET VALIDATION
-- ============================================================

-- 1. Compare successful payment amount
SELECT
    'Clean Payments' AS source,
    SUM(amount) AS recovered_amount
FROM clean_payments
WHERE payment_status = 'SUCCESS'

UNION ALL

SELECT
    'Golden Dataset',
    SUM(recovered_amount)
FROM golden_account_month;


-- 2. Compare successful payment count
SELECT
    'Clean Payments' AS source,
    COUNT(DISTINCT payment_id) AS successful_payments
FROM clean_payments
WHERE payment_status = 'SUCCESS'

UNION ALL

SELECT
    'Golden Dataset',
    SUM(successful_payments)
FROM golden_account_month;


-- 3. Compare PTP count
SELECT
    'Clean PTP' AS source,
    COUNT(DISTINCT ptp_id) AS ptps
FROM clean_promises_to_pay

UNION ALL

SELECT
    'Golden Dataset',
    SUM(ptps)
FROM golden_account_month;


-- 4. Compare calls
SELECT
    'Clean Calls' AS source,
    COUNT(DISTINCT call_id) AS calls
FROM clean_calls

UNION ALL

SELECT
    'Golden Dataset',
    SUM(total_calls)
FROM golden_account_month;


-- 5. Check for accounts missing borrower information

SELECT
    COUNT(*) AS missing_borrower_accounts
FROM golden_account_month
WHERE borrower_id IS NULL;


-- 6. Check recovered amount for negative values

SELECT
    COUNT(*) AS negative_recovery_rows
FROM golden_account_month
WHERE recovered_amount < 0;