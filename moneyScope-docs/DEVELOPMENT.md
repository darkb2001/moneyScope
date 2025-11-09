# Development Guide

## Prerequisites
- Docker and Docker Compose
- Java 17
- Maven 3.8+
- Node.js 18+ (for frontend)

## Getting Started

1. Clone repository
\`\`\`bash
git clone <repository-url>
cd moneyScope
\`\`\`

2. Start infrastructure services
\`\`\`bash
# Start Kafka and Zookeeper
docker-compose up -d zookeeper kafka

# Start PostgreSQL and Redis
docker-compose up -d postgres redis

# Wait for services to be ready
sleep 30
\`\`\`

3. Start backend services
\`\`\`bash
# Start Auth Service
cd moneyScope-backend/auth-service
mvn spring-boot:run &

# Start Transaction Service
cd moneyScope-backend/transaction-service
mvn spring-boot:run &

# Start Notification Service
cd moneyScope-backend/notification-service
mvn spring-boot:run &
\`\`\`

4. Start frontend
\`\`\`bash
cd moneyScope-frontend
npm install
npm run dev
\`\`\`

## Service URLs

- Auth Service: http://localhost:8080
- Transaction Service: http://localhost:8081
- Notification Service: http://localhost:8082
- Kafka: localhost:9092
- PostgreSQL: localhost:5432
- Redis: localhost:6379

## Database Access

\`\`\`bash
# Connect to PostgreSQL
docker exec -it postgres psql -U moneyscope -d moneyscope -h localhost

# Connect to Redis
docker exec -it redis redis-cli -h localhost
\`\`\`

## Troubleshooting

### Service not starting
Check if port is already in use:
\`\`\`bash
lsof -i :8080
\`\`\`

### Database connection issues
Check PostgreSQL logs:
\`\`\`bash
docker logs postgres
\`\`\`

### Kafka issues
Check Kafka logs:
\`\`\`bash
docker logs kafka
\`\`\`

## Environment Variables

Create \`.env\` file for local development:
\`\`\`bash
cat > .env << EOF
SPRING_PROFILES_ACTIVE=dev
DB_HOST=localhost
DB_PORT=5432
DB_NAME=moneyscope
DB_USER=moneyscope
DB_PASSWORD=password
REDIS_HOST=localhost
REDIS_PORT=6379
KAFKA_BOOTSTRAP_SERVERS=localhost:9092
