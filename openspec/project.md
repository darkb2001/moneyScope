# Project Context

## Purpose
MoneyScope là một nền tảng theo dõi ngân hàng cá nhân giúp người dùng tổng hợp giao dịch từ các ngân hàng khác nhau, lưu trữ sổ cái, phân loại giao dịch và cung cấp phân tích và cảnh báo tài chính.

## Tech Stack
- **Backend**: Spring Boot 3 + Java 17
- **Frontend**: Next.js Dashboard
- **Database**: PostgreSQL 14 (Aurora hoặc RDS trong production)
- **Cache & Auth**: Redis 7
- **Event Bus**: Apache Kafka (MSK hoặc self-hosted)
- **Serverless**: AWS Lambda cho Bank Connector và Analytics
- **Infrastructure**: Terraform cho IaC
- **Containerization**: Docker Compose cho môi trường phát triển local
- **CI/CD**: GitHub Actions

## Project Conventions

### Code Style
- Sử dụng Java 17 features (records, sealed classes, pattern matching)
- Tuân thủ Spring Boot best practices
- Sử dụng Domain-Driven Design với cấu trúc: application, domain, infrastructure, presentation
- Sử dụng RESTful API design với OpenAPI documentation
- Sử dụng reactive programming với Spring WebFlux khi cần thiết

### Architecture Patterns
- **Microservices Architecture**: Các dịch vụ độc lập với trách nhiệm rõ ràng
- **Event-Driven Architecture**: Sử dụng Kafka cho giao tiếp giữa các dịch vụ
- **Saga Pattern**: Quản lý các giao dịch phân tán qua choreography hoặc orchestrator
- **CQRS**: Command Query Responsibility Segregation khi cần thiết
- **OAuth2 Authorization Server**: Xác thực và ủy quyền tập trung

### Testing Strategy
- Unit tests với JUnit 5 và Mockito
- Integration tests với @SpringBootTest và Testcontainers
- Contract tests với Pact
- E2E tests với Cypress cho frontend
- Performance tests với JMeter

### Git Workflow
- **Main Branch**: main (production-ready code)
- **Development Branch**: develop (integration branch)
- **Feature Branches**: feature/<feature-name>
- **Pull Request**: Yêu cầu review trước khi merge vào develop
- **Semantic Versioning**: MAJOR.MINOR.PATCH

## Domain Context

### Core Entities
- **User**: Người dùng cuối của hệ thống
- **Account**: Tài khoản ngân hàng của người dùng
- **Transaction**: Giao dịch tài chính
- **Category**: Phân loại giao dịch
- **Analytics**: Phân tích và báo cáo tài chính

### Business Rules
- Mỗi người dùng có thể có nhiều tài khoản ngân hàng
- Giao dịch phải được phân loại tự động hoặc thủ công
- Số dư tài khoản phải được cập nhật sau mỗi giao dịch
- Người dùng chỉ có thể truy cập dữ liệu của chính mình

## Important Constraints
- **Security**: Mọi API phải được xác thực và ủy quyền
- **Performance**: Hệ thống phải xử lý 1000 giao dịch/giây
- **Scalability**: Hỗ trợ 10,000 người dùng đồng thời
- **Availability**: 99.9% uptime
- **Data Privacy**: Tuân thủ GDPR và các quy định về bảo mật dữ liệu
- **Audit Trail**: Mọi thay đổi dữ liệu phải được ghi lại

## External Dependencies
- **SePay API**: Để lấy dữ liệu giao dịch từ ngân hàng
- **AWS Services**: Lambda, MSK, RDS, Secrets Manager
- **OAuth2 Providers**: Google, Facebook cho social login
- **Email Service**: AWS SES cho thông báo
- **Monitoring**: CloudWatch, Prometheus, Grafana
