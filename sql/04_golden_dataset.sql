-- ============================================================
-- COLLECTIONS RECOVERY ANALYSIS
-- 04_GOLDEN_DATASET.SQL
-- Grain: One row per account per month
-- ============================================================

CREATE OR REPLACE TABLE golden_account_month AS

WITH account_base AS (

    SELECT
        a.account_id,
        a.borrower_id,
        a.client,
        a.dpd,
        a.outstanding_amount,
        a.account_open_date,
        a.status AS account_status,

        b.geography,
        b.language,
        b.borrower_segment,
        b.income_band

    FROM clean_accounts a

    LEFT JOIN clean_borrowers b
        ON a.borrower_id = b.borrower_id
),


-- ============================================================
-- CALL ACTIVITY
-- ============================================================

call_activity AS (

    SELECT
        DATE_TRUNC('month', call_timestamp) AS month,
        account_id,

        COUNT(DISTINCT call_id) AS total_calls

    FROM clean_calls

    GROUP BY 1, 2
),


-- ============================================================
-- CALL ATTEMPTS
-- ============================================================

attempt_activity AS (

    SELECT
        DATE_TRUNC('month', attempt_timestamp) AS month,
        account_id,

        COUNT(DISTINCT attempt_id) AS total_attempts

    FROM clean_call_attempts

    GROUP BY 1, 2
),


-- ============================================================
-- CONTACTS / DISPOSITIONS
-- ============================================================

disposition_activity AS (

    SELECT
        DATE_TRUNC('month', d.disposition_timestamp) AS month,
        c.account_id,

        COUNT(*) AS total_dispositions,

        SUM(
            CASE
                WHEN d.standard_code = 'CONTACT'
                THEN 1
                ELSE 0
            END
        ) AS contacts,

        SUM(
            CASE
                WHEN d.standard_code = 'PTP'
                THEN 1
                ELSE 0
            END
        ) AS disposition_ptps

    FROM clean_call_dispositions d

    LEFT JOIN clean_calls c
        ON d.call_id = c.call_id

    GROUP BY 1, 2
),


-- ============================================================
-- PTP ACTIVITY
-- ============================================================

ptp_activity AS (

    SELECT
        DATE_TRUNC('month', ptp_created_at) AS month,
        account_id,

        COUNT(DISTINCT ptp_id) AS ptps,

        SUM(
            CASE
                WHEN ptp_status = 'KEPT'
                THEN 1
                ELSE 0
            END
        ) AS ptps_kept,

        SUM(promised_amount) AS promised_amount

    FROM clean_promises_to_pay

    GROUP BY 1, 2
),


-- ============================================================
-- PAYMENT ACTIVITY
-- ============================================================

payment_activity AS (

    SELECT
        DATE_TRUNC('month', payment_timestamp) AS month,
        account_id,

        COUNT(DISTINCT payment_id) AS successful_payments,

        SUM(amount) AS recovered_amount

    FROM clean_payments

    WHERE payment_status = 'SUCCESS'

    GROUP BY 1, 2
),


-- ============================================================
-- TARGETING ACTIVITY
-- ============================================================

targeting_activity AS (

    SELECT
        DATE_TRUNC('month', target_date) AS month,
        account_id,

        MAX(campaign_id) AS campaign_id,
        MAX(strategy) AS targeting_strategy,
        MAX(priority_band) AS priority_band,
        MAX(propensity_score) AS propensity_score

    FROM clean_daily_targeting

    GROUP BY 1, 2
),


-- ============================================================
-- COMBINE ALL MONTHLY ACTIVITY
-- ============================================================

combined AS (

    SELECT
        COALESCE(c.month, a.month, d.month, p.month, pay.month, t.month)
            AS month,

        COALESCE(
            c.account_id,
            a.account_id,
            d.account_id,
            p.account_id,
            pay.account_id,
            t.account_id
        ) AS account_id,

        COALESCE(c.total_calls, 0) AS total_calls,
        COALESCE(a.total_attempts, 0) AS total_attempts,
        COALESCE(d.total_dispositions, 0) AS total_dispositions,
        COALESCE(d.contacts, 0) AS contacts,
        COALESCE(d.disposition_ptps, 0) AS disposition_ptps,

        COALESCE(p.ptps, 0) AS ptps,
        COALESCE(p.ptps_kept, 0) AS ptps_kept,
        COALESCE(p.promised_amount, 0) AS promised_amount,

        COALESCE(pay.successful_payments, 0) AS successful_payments,
        COALESCE(pay.recovered_amount, 0) AS recovered_amount,

        t.campaign_id,
        t.targeting_strategy,
        t.priority_band,
        t.propensity_score

    FROM call_activity c

    FULL OUTER JOIN attempt_activity a
        ON c.account_id = a.account_id
       AND c.month = a.month

    FULL OUTER JOIN disposition_activity d
        ON COALESCE(c.account_id, a.account_id) = d.account_id
       AND COALESCE(c.month, a.month) = d.month

    FULL OUTER JOIN ptp_activity p
        ON COALESCE(
            c.account_id,
            a.account_id,
            d.account_id
        ) = p.account_id

       AND COALESCE(
            c.month,
            a.month,
            d.month
        ) = p.month

    FULL OUTER JOIN payment_activity pay
        ON COALESCE(
            c.account_id,
            a.account_id,
            d.account_id,
            p.account_id
        ) = pay.account_id

       AND COALESCE(
            c.month,
            a.month,
            d.month,
            p.month
        ) = pay.month

    FULL OUTER JOIN targeting_activity t
        ON COALESCE(
            c.account_id,
            a.account_id,
            d.account_id,
            p.account_id,
            pay.account_id
        ) = t.account_id

       AND COALESCE(
            c.month,
            a.month,
            d.month,
            p.month,
            pay.month
        ) = t.month
)


-- ============================================================
-- FINAL GOLDEN DATASET
-- ============================================================

SELECT

    x.month,

    ab.account_id,
    ab.borrower_id,

    ab.client,
    ab.geography,
    ab.language,
    ab.borrower_segment,
    ab.income_band,

    ab.dpd,
    ab.outstanding_amount,
    ab.account_status,

    x.campaign_id,
    x.targeting_strategy,
    x.priority_band,
    x.propensity_score,

    x.total_calls,
    x.total_attempts,
    x.total_dispositions,
    x.contacts,
    x.disposition_ptps,

    x.ptps,
    x.ptps_kept,
    x.promised_amount,

    x.successful_payments,
    x.recovered_amount

FROM combined x

LEFT JOIN account_base ab
    ON x.account_id = ab.account_id;


-- ============================================================
-- GOLDEN DATASET VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS golden_rows,
    COUNT(DISTINCT account_id) AS unique_accounts,
    COUNT(DISTINCT month) AS months
FROM golden_account_month;


-- ============================================================
-- CHECK FOR DUPLICATE GRAIN
-- Expected: ZERO rows
-- ============================================================

SELECT
    month,
    account_id,
    COUNT(*) AS occurrences
FROM golden_account_month
GROUP BY
    month,
    account_id
HAVING COUNT(*) > 1
LIMIT 20;