# Analytics Service (detailed)

## Responsibility
- Produce aggregated metrics for dashboard: monthly spend, category breakdown, cashflow trends
- Two modes:
  - Stream processing: consume `transaction.processed` and update incremental aggregates in Redis/DynamoDB
  - Batch processing: scheduled Lambda runs daily to compute heavy aggregates

## Outputs
- `monthly_summary` table (Postgres) or `cache:summary:<userId>:<YYYY-MM>` in Redis
- Alerts if spending > thresholds (published to SNS)

## Implementation notes
- For near real-time, update Redis counters on `transaction.processed`
- For accurate historical reports, run nightly job to recompute from Postgres (to account for corrections)
