WITH monthly AS (

    SELECT
        month,

        SUM(recovered_amount) AS recovered_amount,

        SUM(outstanding_amount) AS outstanding_amount,

        SUM(total_attempts) AS attempts,

        SUM(contacts) AS contacts,

        SUM(ptps) AS ptps,

        SUM(ptps_kept) AS ptps_kept,

        COUNT(DISTINCT account_id) AS accounts

    FROM golden_account_month

    GROUP BY month
),

metrics AS (

    SELECT
        month,

        recovered_amount,

        outstanding_amount,

        attempts,

        contacts,

        ptps,

        ptps_kept,

        accounts,

        recovered_amount / NULLIF(outstanding_amount, 0)
            AS recovery_rate,

        contacts / NULLIF(attempts, 0)
            AS contact_rate,

        ptps / NULLIF(contacts, 0)
            AS ptp_rate,

        ptps_kept / NULLIF(ptps, 0)
            AS ptp_kept_rate,

        recovered_amount / NULLIF(accounts, 0)
            AS recovery_per_account

    FROM monthly
),

with_previous AS (

    SELECT
        *,

        LAG(recovery_rate)
            OVER (ORDER BY month) AS previous_recovery_rate,

        LAG(recovery_per_account)
            OVER (ORDER BY month) AS previous_recovery_per_account

    FROM metrics
)

SELECT
    month,

    ROUND(recovery_rate * 100, 2)
        AS recovery_rate_pct,

    ROUND(
        (recovery_rate - previous_recovery_rate)
        / NULLIF(previous_recovery_rate, 0) * 100,
        2
    ) AS recovery_rate_mom_pct,

    ROUND(recovery_per_account, 2)
        AS recovery_per_account,

    ROUND(
        (recovery_per_account - previous_recovery_per_account)
        / NULLIF(previous_recovery_per_account, 0) * 100,
        2
    ) AS recovery_per_account_mom_pct,

    ROUND(contact_rate * 100, 2)
        AS contact_rate_pct,

    ROUND(ptp_rate * 100, 2)
        AS ptp_rate_pct,

    ROUND(ptp_kept_rate * 100, 2)
        AS ptp_kept_rate_pct

FROM with_previous

ORDER BY month;