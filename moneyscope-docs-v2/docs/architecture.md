# Architecture

## High-level diagram

```mermaid
flowchart LR
  subgraph Frontend
    A[Next.js Dashboard]
  end

  subgraph AuthCluster
    AS[Auth Service (Spring Boot - OAuth2)]
  end

  subgraph Core
    TS[Transaction Service (Spring Boot)]
    NS[Notification Service (Spring Boot)]
  end

  subgraph EventLayer
    K[Kafka Cluster (MSK or self-hosted)]
    SAGA[Saga Coordinator (optional - Temporal/Camunda)]
  end

  subgraph AWS_Serverless
    BC[Bank Connector (AWS Lambda)]
    AL[Analytics (AWS Lambda - scheduled)]
  end

  A --> AS
  BC -->|transaction.created| K
  K --> TS
  TS --> K
  K --> AL
  TS --> NS
  AS --> TS
```

## Components & responsibilities

- **Auth Service (Spring Boot)**  
  OAuth2 Authorization Server (Authorization Code + PKCE), issues JWT access tokens, stores opaque refresh tokens in Redis, handles client registration and consent.

- **Transaction Service (Spring Boot)**  
  Core domain service: accepts transaction events, writes ledger, enforces business rules, exposes REST APIs for querying transactions and balances.

- **Bank Connector (AWS Lambda)**  
  Receives SePay webhook, validates HMAC, normalizes payload, publishes `transaction.created` to Kafka (or EventBridge → Kafka bridge).

- **Analytics Lambda**  
  Daily scheduled aggregation jobs or incremental stream processing for derived metrics.

- **Kafka**  
  Topics for event-driven architecture: `transaction.created`, `transaction.processed`, `transaction.failed`, `category.changed`, `saga.*` etc.

- **Saga Coordinator**  
  Optional: use Temporal or Camunda for orchestrated sagas; otherwise implement choreography via Kafka events.

- **Redis**  
  Used by Auth service for refresh tokens and by Transaction service for hot caches (recent transactions, user summaries).

- **Postgres (Aurora or RDS)**  
  Primary persistent store for ledger, users, clients, audit logs.

