# Saga Pattern Design

We use Saga for multi-step business processes that span multiple microservices and resources, for example:
- Importing a bulk statement and reconciling balances across accounts
- Cross-account transfers (if simulated in-app)
- Multi-step onboarding (provision account, sync history, notify user)

## Two approaches

### 1) Choreography (event-driven)
- Each service listens to events and reacts.
- Example flow:
  - BankConnector -> publish `transaction.created`
  - TransactionService -> persist -> publish `transaction.processed`
  - AnalyticsService -> update aggregates
  - NotificationService -> notify user

Pros: simple, decoupled
Cons: harder to reason about complex rollback

### 2) Orchestration (central coordinator)
- A Saga orchestrator (Temporal/Camunda/Custom) drives the workflow.
- Steps are explicit; orchestrator triggers compensating actions on failure.

Pros: clearer compensations and error handling
Cons: extra infrastructure & learning curve

## Recommendation for MoneyScope
- **Start with choreography** for simple flows.
- For critical multi-step flows (like simulated transfers or reconciling imports), use **Temporal** as Saga orchestrator and store saga state in its DB.
