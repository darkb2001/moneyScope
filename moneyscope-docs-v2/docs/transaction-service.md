# Transaction Service (detailed)

## Responsibilities
- Consume `transaction.created` events from Kafka
- Validate and persist transactions to Postgres
- Update account balances and emit `transaction.processed` or `transaction.failed`
- Provide REST APIs:
  - `GET /accounts/{id}/transactions`
  - `GET /accounts/{id}/balance`
  - `POST /transactions/import` (CSV upload)

## Database transactions & consistency
- Use ACID transactions for operations that update balance + insert ledger
- Use optimistic locking on accounts (`version` column) to avoid double-spend in concurrent writes
- For multi-step flows across services, use Saga pattern (choreography or orchestrator)

## Kafka topics
- `transaction.created` (produced by BankConnector)
- `transaction.processed` (produced after successful persistence)
- `transaction.failed`
- `transaction.category.request` / `transaction.category.response` (for async categorization)
- `saga.*` topics for saga coordination

## APIs
- `GET /transactions?userId=&from=&to=&category=&bank=`
- `GET /transactions/{id}`
- `POST /transactions/{id}/categorize` (manual override)
- `POST /accounts/{id}/reconcile`

## Caching: Redis
- Cache last N transactions per account: key `cache:recent:<accountId>` => list
- Cache monthly summary per user: `cache:summary:<userId>:<YYYY-MM>`

## Error handling & retries
- Use Kafka consumer groups with manual commit on successful DB write
- On failure, push to `transaction.failed` topic and create a retry mechanism (DLQ)
- Alert if DLQ grows
