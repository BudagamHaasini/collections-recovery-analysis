# Collections Recovery — Synthetic RAW Dataset

This is a synthetic RAW dataset created because the assignment brief did not include the operational data.

It follows the entities listed in the assignment:
borrowers, accounts, agents, agent_sessions, campaigns, daily_targeting, calls,
call_attempts, call_dispositions, whatsapp_events, sms_events, field_visits,
promises_to_pay, payments, vendor_telephony, complaints, and account_status_history.

## Important
Do NOT clean these CSVs manually.

Treat this folder as the source system. Your first task is to profile it and discover the intentional data-quality problems.

Known categories intentionally represented:
- duplicate borrower records
- duplicate account records
- duplicate call attempts
- duplicate payment events
- alternate agent identifiers
- changed telephony disposition codes
- missing activity for some entities
- historical status changes
- targeting strategy changes during the year

The exact issues must be discovered and quantified through SQL/Python rather than assumed.

## Time period
September 2025 through August 2026.

## Next step
Create a Git repository and place these files under `data/raw/`.
Then begin with data profiling and duplicate checks.
