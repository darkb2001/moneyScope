# 🧩 MoneyScope – System Architecture Overview

## High-Level Architecture

MoneyScope follows a microservices architecture with event-driven communication, designed for scalability and maintainability.

## System Components

### Frontend Layer
- **Next.js Dashboard** - User interface for financial management
- **Port**: 3000
- **Authentication**: OAuth2 flow through Auth Service

### API Gateway Layer
- **Spring Cloud Gateway** - Central entry point for all client requests
- **Load Balancer** - Distributes traffic across backend services
- **CORS & Security** - Cross-origin resource sharing and request filtering

### Backend Services
- **Auth Service** (Port 8080) - OAuth2 Authorization Server
- **Transaction Service** (Port 8081) - Core transaction processing
- **Notification Service** (Port 8082) - Multi-channel notifications
- **Bank Connector** (Lambda) - Bank integration via webhooks
- **Analytics Service** (Lambda) - Data aggregation and reporting

### Event Bus
- **Apache Kafka** - Event-driven communication between services
- **Topics**: transaction.created, transaction.processed, transaction.failed, etc.
- **Consumer Groups**: Each service has its own consumer group

### Data Layer
- **PostgreSQL** - Primary relational database for core data
  - Auth Service: User and OAuth client data
  - Transaction Service: Transaction and account data
  - Notification Service: User notification preferences only
- **Redis** - Caching and session storage
- **DynamoDB** - Analytics data storage and notification logs
- **S3** - Report storage, file uploads, and notification templates

### Infrastructure
- **AWS** - Cloud provider
- **VPC** - Isolated network environment
- **ECS** - Container orchestration
- **Lambda** - Serverless functions
- **Terraform** - Infrastructure as Code

## Service Interactions

### Authentication Flow
1. User → Frontend (Next.js)
2. Frontend → Auth Service (OAuth2 Authorization Code Flow)
3. Auth Service → JWT Token
4. Frontend → Backend Services (with JWT)
5. Backend Services → Validate JWT via Auth Service JWKS endpoint

### Transaction Processing
1. Bank Connector → Kafka (transaction.created)
2. Transaction Service → Kafka (transaction.processed/failed)
3. Transaction Service → PostgreSQL (persist)
4. Transaction Service → Kafka (balance.updated)
5. Analytics Service → Kafka (consume transaction.processed)
6. Notification Service → Kafka (consume transaction.processed)

### Notification Flow
1. Transaction Service → Kafka (transaction.processed)
2. Notification Service → Process events
3. Notification Service → Store notification logs in DynamoDB
4. Notification Service → Get templates from S3/Redis cache
5. Notification Service → Send notifications (Email, SMS, Push)
6. Notification Service → Store user preferences in PostgreSQL

## Data Flow

```
User Input → Frontend → API Gateway → Auth Service → JWT
                                                    ↓
                                              Backend Services → Database
                                                    ↓
                                              Analytics Service → DynamoDB/S3
```

## Security Model

### Authentication & Authorization
- **OAuth2 Authorization Server** with PKCE for SPAs
- **JWT Access Tokens** with 15-minute expiration
- **Refresh Token Rotation** with Redis storage
- **Rate Limiting** on authentication endpoints
- **HMAC Validation** for webhook security

### Data Security
- **Encryption at Rest** with TLS
- **Encryption in Transit** with Kafka SSL
- **PII Data Masking** for sensitive information
- **VPC Isolation** with private subnets for databases

### Infrastructure Security
- **IAM Roles** with least privilege principle
- **Security Groups** with specific port/protocol access
- **WAF** (Web Application Firewall) for API protection
- **Secrets Management** via AWS Secrets Manager

## Scalability Considerations

### Horizontal Scaling
- **Stateless Services** (Lambda) for automatic scaling
- **Container Orchestration** (ECS) for backend services
- **Load Balancing** for traffic distribution
- **Read Replicas** for database read scaling

### Performance Optimization
- **Caching Strategy** with Redis for frequently accessed data
- **Database Pooling** for connection management
- **Async Processing** with Kafka for non-blocking operations
- **CDN** for static asset delivery

## Deployment Architecture

### Development Environment
- **Docker Compose** for local development
- **Hot Reloading** with Spring Boot DevTools
- **Environment Variables** via .env files
- **Local Database** (PostgreSQL in Docker)

### Production Environment
- **AWS ECS** for container orchestration
- **AWS RDS Aurora** for managed PostgreSQL
- **AWS MSK** for managed Kafka
- **AWS ElastiCache** for managed Redis
- **AWS Lambda** for serverless functions
- **Terraform** for infrastructure as code
- **GitHub Actions** for CI/CD pipeline

## Monitoring & Observability

### Application Monitoring
- **Spring Boot Actuator** for health checks
- **Custom Metrics** for business KPIs
- **Distributed Tracing** for request tracking

### Infrastructure Monitoring
- **AWS CloudWatch** for logs and metrics
- **AWS X-Ray** for distributed tracing
- **Container Insights** for ECS monitoring

## Development Workflow

### Local Development
1. `./start-dev.sh` - Starts all infrastructure services
2. `docker-compose up -d` - Starts databases and message queue
3. `mvn spring-boot:run` - Starts backend services
4. `npm run dev` - Starts frontend

### CI/CD Pipeline
1. **GitHub Actions** for automated testing and building
2. **Docker Registry** (ECR) for container images
3. **Automated Deployment** to ECS and Lambda
4. **Environment Promotion** through stages (dev → staging → prod)

## Technology Stack

### Backend
- **Spring Boot 3.1** with Java 17
- **Spring Security** for OAuth2 and JWT
- **Spring Data JPA** with Hibernate
- **Spring Kafka** for event-driven architecture
- **Spring Cloud AWS** for Lambda integration

### Frontend
- **Next.js 18+** with React
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **AWS Amplify** for deployment and hosting

### Infrastructure
- **Terraform** for infrastructure as code
- **Docker** for containerization
- **AWS** for cloud services
- **GitHub Actions** for CI/CD

## Decision Log

### Architecture Decisions
1. **Microservices over Monolith** - For team scalability and independent deployment
2. **Event-Driven Architecture** - For loose coupling and async processing
3. **Serverless for Edge Services** - For cost optimization and automatic scaling
4. **OAuth2 Authorization Server** - For standardized authentication
5. **PostgreSQL over NoSQL** - For transactional consistency
6. **Kafka over REST** - For high-throughput event streaming

### Technology Choices
1. **Spring Boot** - For rapid development with auto-configuration
2. **Next.js** - For full-stack TypeScript development
3. **AWS** - For managed services and global infrastructure
4. **Kafka** - For proven event streaming platform
5. **PostgreSQL** - For relational data with strong consistency guarantees

This architecture supports the project's requirements for:
- 1000+ transactions/second throughput
- 10,000+ concurrent users
- 99.9% uptime availability
- Multi-region deployment capability
- GDPR compliance through data protection measures
