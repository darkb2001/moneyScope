# Bank Connector (AWS Lambda) - Detailed

## Responsibility
- Receive webhook from aggregator (SePay) or mock sender
- Validate signature (HMAC-SHA256) with shared secret
- Normalize payload into internal `TransactionEvent` shape
- Produce event to Kafka topic `transaction.created` (or to EventBridge which bridges to Kafka)

## Sample normalized payload
```json
{
  "event": "transaction.created",
  "data": {
    "transaction_id": "tx-20251107-0001",
    "account_number": "9704xxxxx",
    "bank_code": "VTB",
    "amount": -250000,
    "currency": "VND",
    "description": "POS - Highland Coffee",
    "transaction_date": "2025-11-07T10:42:00Z",
    "metadata": { "raw": {...} }
  }
}
```

## Lambda design
- Runtime: Node.js 18.x or Python3.11
- Timeout: 10s
- Processing: Validate sig -> map fields -> push to Kafka via MSK Proxy or produce to EventBridge

## HMAC verification (pseudo)
- Header: `X-Signature: sha256=<hex>`
- Compute `hmac = HMAC_SHA256(shared_secret, JSON.stringify(body))`
- Timing-safe compare with header

## Local dev
- Use `ngrok` to expose local webhook endpoint when testing against SePay dev portal
- Provide `mock_sender.js` to send fake events for integration tests
