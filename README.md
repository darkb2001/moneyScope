# MoneyScope

Personal Banking Tracker Platform

MoneyScope follows a microservices architecture with event-driven communication, designed for scalability and maintainability.

## Architecture
- Auth Service (OAuth2 Authorization Server)
- Transaction Service (Transaction Processing)
- Bank Connector Service (Lambda)
- Analytics Service
- Notification Service

## Getting Started
1. Clone repository
2. Run `docker-compose up`
3. Access services at:
   - Auth Service: http://localhost:8080
   - Transaction Service: http://localhost:8081
   - Notification Service: http://localhost:8082

## Development
See `openspec/` for specifications
