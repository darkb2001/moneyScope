#!/bin/bash

echo "Starting MoneyScope development environment..."

# Start infrastructure services
echo "Starting Kafka and Zookeeper..."
docker-compose up -d zookeeper kafka

echo "Starting PostgreSQL..."
docker-compose up -d postgres

echo "Starting Redis..."
docker-compose up -d redis

echo "Waiting for services to be ready..."
sleep 30

echo "Starting backend services..."
cd moneyScope-backend/auth-service && mvn spring-boot:run &
cd moneyScope-backend/transaction-service && mvn spring-boot:run &
cd moneyScope-backend/notification-service && mvn spring-boot:run &

echo "Development environment is ready!"
echo "Auth Service: http://localhost:8080"
echo "Transaction Service: http://localhost:8081"
echo "Notification Service: http://localhost:8082"
echo "Kafka: localhost:9092"
echo "PostgreSQL: localhost:5432"
echo "Redis: localhost:6379"
