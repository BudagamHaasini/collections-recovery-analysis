SELECT
    month,
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

WHERE targeting_strategy IS NOT NULL

GROUP BY
    month,
    targeting_strategy

ORDER BY
    month,
    targeting_strategy;