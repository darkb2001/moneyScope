# 💳 MoneyScope – Personal Banking Tracker Platform (Detailed Docs v2)

> **Tech choices confirmed by you:** Spring Boot 3 + Java 17, Redis for Auth & caching, Kafka as internal event bus, Saga pattern, Terraform for IaC.

## Table of contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Services](#services)
  - [Auth Service](#auth-service)
  - [Transaction Service](#transaction-service)
  - [Bank Connector Service (Lambda)](#bank-connector-service-lambda)
  - [Analytics Service](#analytics-service)
- [Data model](#data-model)
- [Eventing & Kafka](#eventing--kafka)
- [Saga pattern design](#saga-pattern-design)
- [Security](#security)
- [CI/CD (GitHub Actions)](#cicd-github-actions)
- [Infrastructure (Terraform skeleton)](#infrastructure-terraform-skeleton)
- [Local dev / Docker compose](#local-dev--docker-compose)
- [Next steps](#next-steps)

---

## Overview

MoneyScope aggregates bank transactions (via SePay or mock webhooks), stores ledger data, classifies transactions, and provides analytics and alerts.
Key constraints:
- Core microservices are **Spring Boot 3 (Java 17)**.
- **Redis** is used for both Auth (refresh tokens, blacklist) and caching transaction-derived views.
- **Kafka** as internal event bus; Saga pattern used for multi-step operations (choreography or orchestrator).
- **AWS serverless** is used selectively (Lambda for webhook + optional analytics); Terraform used for provisioning.

Read detailed docs in `/docs` folder.
