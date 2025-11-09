# Transaction Service Specification

## Purpose
Xử lý, lưu trữ và quản lý giao dịch tài chính trong hệ thống MoneyScope.

## Requirements

### Requirement: Transaction Processing
Hệ thống SHALL xử lý các giao dịch từ Bank Connector và lưu trữ vào database.

#### Scenario: Transaction Ingestion
- **WHEN** nhận được event `transaction.created` từ Kafka
- **THEN** hệ thống SHALL xác thực và lưu trữ giao dịch vào PostgreSQL
- **WHEN** giao dịch được lưu trữ thành công
- **THEN** hệ thống SHALL phát ra event `transaction.processed`
- **WHEN** lưu trữ giao dịch thất bại
- **THEN** hệ thống SHALL phát ra event `transaction.failed`

#### Scenario: Transaction Validation
- **WHEN** nhận được giao dịch mới
- **THEN** hệ thống SHALL kiểm tra tính hợp lệ của dữ liệu
- **WHEN** giao dịch không hợp lệ
- **THEN** hệ thống SHALL từ chối và ghi log lỗi

#### Scenario: Duplicate Detection
- **WHEN** nhận được giao dịch có transaction_id trùng lặp
- **THEN** hệ thống SHALL bỏ qua và ghi log cảnh báo

### Requirement: Account Balance Management
Hệ thống SHALL cập nhật số dư tài khoản sau mỗi giao dịch.

#### Scenario: Balance Update
- **WHEN** giao dịch được xử lý thành công
- **THEN** hệ thống SHALL cập nhật số dư tài khoản tương ứng
- **WHEN** có nhiều giao dịch đồng thời
- **THEN** hệ thống SHALL sử dụng optimistic locking để tránh race condition

#### Scenario: Balance Retrieval
- **WHEN** người dùng yêu cầu số dư tài khoản
- **THEN** hệ thống SHALL trả về số dư hiện tại
- **WHEN** tài khoản không tồn tại
- **THEN** hệ thống SHALL trả về lỗi 404

### Requirement: Transaction Categorization
Hệ thống SHALL phân loại giao dịch tự động hoặc thủ công.

#### Scenario: Automatic Categorization
- **WHEN** giao dịch mới được xử lý
- **THEN** hệ thống SHALL phân loại dựa trên mô tả và quy tắc có sẵn
- **WHEN** không thể phân loại tự động
- **THEN** hệ thống SHALL gán category "Uncategorized"

#### Scenario: Manual Categorization
- **WHEN** người dùng thay đổi category của giao dịch
- **THEN** hệ thống SHALL cập nhật category và phát ra event `category.changed`
- **WHEN** category không tồn tại
- **THEN** hệ thống SHALL trả về lỗi

### Requirement: Transaction Querying
Hệ thống SHALL cung cấp API để truy vấn giao dịch.

#### Scenario: Transaction List
- **WHEN** người dùng yêu cầu danh sách giao dịch
- **THEN** hệ thống SHALL trả về danh sách theo bộ lọc (ngày, category, tài khoản)
- **WHEN** không có giao dịch nào khớp bộ lọc
- **THEN** hệ thống SHALL trả về danh sách rỗng

#### Scenario: Transaction Details
- **WHEN** người dùng yêu cầu chi tiết một giao dịch
- **THEN** hệ thống SHALL trả về thông tin chi tiết
- **WHEN** giao dịch không tồn tại
- **THEN** hệ thống SHALL trả về lỗi 404

### Requirement: Data Import
Hệ thống SHALL hỗ trợ nhập dữ liệu giao dịch từ file CSV.

#### Scenario: CSV Import
- **WHEN** người dùng upload file CSV
- **THEN** hệ thống SHALL xác thực định dạng file
- **WHEN** file hợp lệ
- **THEN** hệ thống SHALL xử lý và lưu trữ các giao dịch
- **WHEN** file không hợp lệ
- **THEN** hệ thống SHALL trả về lỗi chi tiết

### Requirement: Caching
Hệ thống SHALL sử dụng Redis để cache dữ liệu thường xuyên truy cập.

#### Scenario: Recent Transactions Cache
- **WHEN** người dùng yêu cầu giao dịch gần đây
- **THEN** hệ thống SHALL kiểm tra cache trước khi truy vấn database
- **WHEN** cache hit
- **THEN** hệ thống SHALL trả về dữ liệu từ cache
- **WHEN** cache miss
- **THEN** hệ thống SHALL truy vấn database và cập nhật cache

#### Scenario: Monthly Summary Cache
- **WHEN** người dùng yêu cầu tóm tắt tháng
- **THEN** hệ thống SHALL kiểm tra cache trước khi tính toán
- **WHEN** cache hit
- **THEN** hệ thống SHALL trả về dữ liệu từ cache
- **WHEN** cache miss
- **THEN** hệ thống SHALL tính toán và cập nhật cache

### Requirement: Saga Participation
Hệ thống SHALL tham gia vào các quy trình Saga đa bước.

#### Scenario: Transaction Import Saga
- **WHEN** nhận được event `saga.transaction-import.started`
- **THEN** hệ thống SHALL xử lý các giao dịch trong file import
- **WHEN** xử lý thành công
- **THEN** hệ thống SHALL phát ra event `saga.transaction-import.completed`
- **WHEN** xử lý thất bại
- **THEN** hệ thống SHALL phát ra event `saga.transaction-import.failed`

#### Scenario: Balance Reconciliation Saga
- **WHEN** nhận được event `saga.balance-reconciliation.started`
- **THEN** hệ thống SHALL đối chiếu số dư tài khoản
- **WHEN** đối chiếu thành công
- **THEN** hệ thống SHALL phát ra event `saga.balance-reconciliation.completed`
- **WHEN** đối chiếu thất bại
- **THEN** hệ thống SHALL phát ra event `saga.balance-reconciliation.failed`

## Design Considerations

### Transaction Processing
- Use Kafka consumer groups with manual commit on successful DB write
- Implement DLQ (Dead Letter Queue) for failed transactions
- Use ACID transactions for operations that update balance + insert ledger

### Concurrency Control
- Optimistic locking on accounts (version column)
- Idempotent operations for transaction processing
- Proper error handling and retry mechanisms

### Performance Optimization
- Database indexing on frequently queried fields
- Redis caching for hot data
- Pagination for large result sets

### Saga Implementation
- Start with choreography for simple flows
- Use Temporal for complex multi-step flows requiring explicit compensation
- Store saga state in dedicated database tables

## Integration Points

### External Dependencies
- PostgreSQL for persistent storage
- Redis for caching
- Kafka for event-driven communication

### Internal Services
- Auth Service (validates tokens)
- Bank Connector Service (receives transaction events)
- Analytics Service (consumes transaction events)
- Notification Service (receives transaction events)
