-- ============================================================
-- DPD ANALYSIS
-- Determine whether recovery changes are driven by portfolio mix
-- ============================================================

SELECT
    month,

    CASE
        WHEN dpd BETWEEN 1 AND 30 THEN '01-30'
        WHEN dpd BETWEEN 31 AND 60 THEN '31-60'
        WHEN dpd BETWEEN 61 AND 90 THEN '61-90'
        WHEN dpd BETWEEN 91 AND 120 THEN '91-120'
        WHEN dpd BETWEEN 121 AND 180 THEN '121-180'
        ELSE 'OTHER'
    END AS dpd_bucket,

    COUNT(DISTINCT account_id) AS accounts,

    SUM(outstanding_amount) AS outstanding,

    SUM(recovered_amount) AS recovered,

    CASE
        WHEN SUM(outstanding_amount) > 0
        THEN SUM(recovered_amount)
             / SUM(outstanding_amount) * 100
        ELSE 0
    END AS recovery_rate

FROM golden_account_month

GROUP BY
    month,
    dpd_bucket

ORDER BY
    month,
    dpd_bucket;