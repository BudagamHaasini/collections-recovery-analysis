-- ============================================================
-- 09_FINAL_ANALYSIS.SQL
-- Simple business analysis
-- ============================================================


-- ============================================================
-- 1. TARGETING STRATEGY
-- ============================================================

SELECT
    targeting_strategy,
    COUNT(DISTINCT account_id) AS accounts,
    SUM(recovered_amount) AS recovered,
    SUM(outstanding_amount) AS outstanding,

    ROUND(
        SUM(recovered_amount)
        / NULLIF(SUM(outstanding_amount), 0) * 100,
        2
    ) AS recovery_rate

FROM golden_account_month

GROUP BY targeting_strategy

ORDER BY recovery_rate DESC;


-- ============================================================
-- 2. CHANNEL PERFORMANCE
-- ============================================================

SELECT
    targeting_strategy,
    COUNT(DISTINCT account_id) AS accounts,
    SUM(total_attempts) AS attempts,
    SUM(contacts) AS contacts,
    SUM(recovered_amount) AS recovered,

    ROUND(
        SUM(contacts)
        / NULLIF(SUM(total_attempts), 0) * 100,
        2
    ) AS contact_rate

FROM golden_account_month

GROUP BY targeting_strategy

ORDER BY contact_rate DESC;


-- ============================================================
-- 3. BORROWER SEGMENT
-- ============================================================

SELECT
    borrower_segment,
    COUNT(DISTINCT account_id) AS accounts,
    SUM(outstanding_amount) AS outstanding,
    SUM(recovered_amount) AS recovered,

    ROUND(
        SUM(recovered_amount)
        / NULLIF(SUM(outstanding_amount), 0) * 100,
        2
    ) AS recovery_rate

FROM golden_account_month

GROUP BY borrower_segment

ORDER BY recovery_rate DESC;


-- ============================================================
-- 4. CLIENT PERFORMANCE
-- ============================================================

SELECT
    client,
    COUNT(DISTINCT account_id) AS accounts,
    SUM(outstanding_amount) AS outstanding,
    SUM(recovered_amount) AS recovered,

    ROUND(
        SUM(recovered_amount)
        / NULLIF(SUM(outstanding_amount), 0) * 100,
        2
    ) AS recovery_rate

FROM golden_account_month

GROUP BY client

ORDER BY recovery_rate DESC;


-- ============================================================
-- 5. FINAL MONTHLY PERFORMANCE
-- ============================================================

SELECT
    month,

    COUNT(DISTINCT account_id) AS accounts,

    SUM(outstanding_amount) AS outstanding,

    SUM(recovered_amount) AS recovered,

    ROUND(
        SUM(recovered_amount)
        / NULLIF(SUM(outstanding_amount), 0) * 100,
        2
    ) AS recovery_rate,

    SUM(total_attempts) AS attempts,

    SUM(contacts) AS contacts,

    ROUND(
        SUM(contacts)
        / NULLIF(SUM(total_attempts), 0) * 100,
        2
    ) AS contact_rate

FROM golden_account_month

GROUP BY month

ORDER BY month;