-- ============================================================
-- 06_RECOVERY_METRICS.SQL
-- Independent recovery performance metrics
-- ============================================================

SELECT
    month,

    COUNT(DISTINCT account_id) AS active_accounts,

    SUM(outstanding_amount) AS total_outstanding,

    SUM(total_attempts) AS total_attempts,

    SUM(contacts) AS total_contacts,

    SUM(ptps) AS total_ptps,

    SUM(ptps_kept) AS total_ptps_kept,

    SUM(recovered_amount) AS total_recovered,

    -- Contact Rate
    CASE
        WHEN SUM(total_attempts) > 0
        THEN SUM(contacts) * 1.0 / SUM(total_attempts)
        ELSE 0
    END AS contact_rate,

    -- PTP Rate among contacts
    CASE
        WHEN SUM(contacts) > 0
        THEN SUM(ptps) * 1.0 / SUM(contacts)
        ELSE 0
    END AS ptp_rate,

    -- PTP Kept Rate
    CASE
        WHEN SUM(ptps) > 0
        THEN SUM(ptps_kept) * 1.0 / SUM(ptps)
        ELSE 0
    END AS ptp_kept_rate,

    -- Recovery Rate
    CASE
        WHEN SUM(outstanding_amount) > 0
        THEN SUM(recovered_amount) * 1.0
             / SUM(outstanding_amount)
        ELSE 0
    END AS recovery_rate,

    -- Recovery per account
    CASE
        WHEN COUNT(DISTINCT account_id) > 0
        THEN SUM(recovered_amount) * 1.0
             / COUNT(DISTINCT account_id)
        ELSE 0
    END AS recovery_per_account,

    -- Recovery per attempt
    CASE
        WHEN SUM(total_attempts) > 0
        THEN SUM(recovered_amount) * 1.0
             / SUM(total_attempts)
        ELSE 0
    END AS recovery_per_attempt

FROM golden_account_month

GROUP BY month

ORDER BY month;