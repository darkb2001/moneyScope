# Bank Connector Service Specification

## Purpose
Kết nối với các ngân hàng thông qua SePay API hoặc webhook để thu thập dữ liệu giao dịch cho hệ thống MoneyScope.

## Requirements

### Requirement: Webhook Reception
Hệ thống SHALL nhận webhook từ SePay chứa dữ liệu giao dịch.

#### Scenario: Webhook Validation
- **WHEN** nhận được webhook từ SePay
- **THEN** hệ thống SHALL xác thực HMAC signature
- **WHEN** signature không hợp lệ
- **THEN** hệ thống SHALL từ chối webhook và trả về lỗi 401

#### Scenario: Webhook Processing
- **WHEN** webhook được xác thực thành công
- **THEN** hệ thống SHALL phân tích và chuẩn hóa dữ liệu giao dịch
- **WHEN** dữ liệu không hợp lệ
- **THEN** hệ thống SHALL ghi log lỗi và không xử lý tiếp

#### Scenario: IP Validation
- **WHEN** nhận được webhook
- **THEN** hệ thống SHALL kiểm tra IP nguồn nếu được cung cấp bởi aggregator
- **WHEN** IP không trong danh sách cho phép
- **THEN** hệ thống SHALL từ chối webhook

### Requirement: Transaction Normalization
Hệ thống SHALL chuẩn hóa dữ liệu giao dịch từ các ngân hàng khác nhau.

#### Scenario: Data Mapping
- **WHEN** nhận được dữ liệu giao dịch từ ngân hàng
- **THEN** hệ thống SHALL ánh xạ các trường dữ liệu theo định dạng chuẩn
- **WHEN** trường dữ liệu không tồn tại
- **THEN** hệ thống SHALL sử dụng giá trị mặc định hoặc bỏ qua

#### Scenario: Currency Conversion
- **WHEN** giao dịch có ngoại tệ khác với VND
- **THEN** hệ thống SHALL chuyển đổi sang VND sử dụng tỷ giá hiện tại
- **WHEN** không thể lấy tỷ giá
- **THEN** hệ thống SHALL ghi log cảnh báo và sử dụng tỷ giá gần nhất

### Requirement: Event Publishing
Hệ thống SHALL phát ra các sự kiện giao dịch đã được xử lý.

#### Scenario: Transaction Event
- **WHEN** giao dịch được chuẩn hóa thành công
- **THEN** hệ thống SHALL phát ra event `transaction.created` đến Kafka
- **WHEN** phát event thất bại
- **THEN** hệ thống SHALL thử lại và ghi log lỗi

#### Scenario: Error Event
- **WHEN** xử lý giao dịch thất bại
- **THEN** hệ thống SHALL phát ra event `transaction.failed` với chi tiết lỗi
- **WHEN** không thể phát event lỗi
- **THEN** hệ thống SHALL ghi log critical

### Requirement: Bank API Integration
Hệ thống SHALL tích hợp với API của các ngân hàng để lấy dữ liệu lịch sử.

#### Scenario: Historical Data Sync
- **WHEN** người dùng yêu cầu đồng bộ dữ liệu lịch sử
- **THEN** hệ thống SHALL gọi API của ngân hàng tương ứng
- **WHEN** API trả về dữ liệu
- **THEN** hệ thống SHALL xử lý và phát ra các event giao dịch
- **WHEN** API trả về lỗi
- **THEN** hệ thống SHALL ghi log và thông báo cho người dùng

#### Scenario: API Rate Limiting
- **WHEN** gọi API ngân hàng quá tần suất
- **THEN** hệ thống SHALL tôn trọng rate limit của ngân hàng
- **WHEN** đạt rate limit
- **THEN** hệ thống SHALL đợi và thử lại sau

### Requirement: Error Handling
Hệ thống SHALL xử lý lỗi một cách thích hợp.

#### Scenario: Retry Mechanism
- **WHEN** xử lý giao dịch thất bại do lỗi tạm thời
- **THEN** hệ thống SHALL thử lại với exponential backoff
- **WHEN** thử lại vượt quá số lần cho phép
- **THEN** hệ thống SHALL ghi log và phát ra event lỗi

#### Scenario: Dead Letter Queue
- **WHEN** giao dịch không thể xử lý sau nhiều lần thử
- **THEN** hệ thống SHALL đưa vào DLQ để xử lý thủ công
- **WHEN** DLQ đầy
- **THEN** hệ thống SHALL alert admin

### Requirement: Security
Hệ thống SHALL đảm bảo bảo mật cho việc kết nối với các ngân hàng.

#### Scenario: Credential Management
- **WHEN** lưu trữ API credentials
- **THEN** hệ thống SHALL sử dụng AWS Secrets Manager
- **WHEN** truy cập credentials
- **THEN** hệ thống SHALL sử dụng IAM roles với least privilege

#### Scenario: Webhook Security
- **WHEN** nhận webhook
- **THEN** hệ thống SHALL xác thực HMAC signature với shared secret
- **WHEN** webhook không hợp lệ
- **THEN** hệ thống SHALL ghi log và từ chối

## Design Considerations

### Lambda Architecture
- Stateless design for horizontal scaling
- Cold start optimization
- Proper error handling and logging
- Timeout management for external API calls

### Security
- HMAC signature validation for webhooks
- Secure storage of API credentials
- Input validation and sanitization
- Audit logging for all operations
- IP validation for webhook sources

### Performance
- Batch processing for historical data sync
- Parallel processing for multiple accounts
- Efficient memory usage for large datasets

## Integration Points

### External Dependencies
- SePay API for webhook reception
- Bank APIs for historical data
- AWS Lambda for serverless execution
- Kafka for event publishing
- AWS Secrets Manager for credential storage

### Internal Services
- Transaction Service (consumes transaction events)
- Auth Service (validates tokens for API calls)
