# Security

## Secrets & Keys
- RSA private key: store in AWS Secrets Manager
- DB credentials: Secrets Manager
- Redis password: Secrets Manager / environment
- Use IAM roles for services (least privilege)

## Webhook security
- HMAC verify with shared secret
- Validate source IP ranges if provided by aggregator

## Token security
- Short lived access tokens (5-15m)
- Refresh token rotation & reuse detection
- Blacklist compromised JTIs in Redis

## Network security
- VPC for RDS/Redis/Kafka (MSK)
- Use security groups & subnet design
