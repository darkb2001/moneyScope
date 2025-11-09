# Eventing & Kafka

## Topics
- `transaction.created` - raw normalized event from BankConnector
- `transaction.processed` - after persistence and basic validation
- `transaction.failed` - when processing fails
- `category.request` / `category.response` - for async categorization
- `saga.{sagaType}.commands` - saga orchestration channel

## Consumer groups
- `transaction-service-group` consumes `transaction.created`
- `analytics-service-group` consumes `transaction.processed`
- `notification-group` consumes `transaction.processed`

## Kafka setup options
- **AWS MSK** - managed Kafka (recommended for production)
- **Self-hosted Kafka** on EC2 or local Docker for dev/test
- **Redpanda** as modern Kafka-compatible alternative (single binary)

## Schema registry
- Use Avro/Schema Registry for stable event schemas (Confluent Schema Registry or Apicurio)
