# Change: Thiết lập cấu trúc dự án cơ bản cho MoneyScope

## Why
Thiết lập cấu trúc dự án ban đầu để chuẩn bị cho việc phát triển các dịch vụ microservices theo kiến trúc đã định nghĩa trong tài liệu MoneyScope.

## What Changes
- Tạo cấu trúc thư mục cho các dịch vụ microservices
- Thiết lập Docker Compose cho môi trường phát triển local
- Tạo cấu hình Terraform cơ bản cho infrastructure
- Thiết lập GitHub Actions workflow cho CI/CD
- Tạo cấu trúc database ban đầu

## Impact
- Affected specs: auth, transaction, bank-connector, analytics, notification
- Affected code: Tất cả các dịch vụ mới
- Infrastructure: Docker Compose, Terraform, GitHub Actions
