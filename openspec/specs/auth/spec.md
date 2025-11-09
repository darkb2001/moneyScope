# Auth Service Specification

## Purpose
Xử lý xác thực và ủy quyền người dùng cho hệ thống MoneyScope thông qua OAuth2 Authorization Server.

## Requirements

### Requirement: OAuth2 Authorization Server
Hệ thống SHALL cung cấp OAuth2 Authorization Server tuân thủ RFC 6749.

#### Scenario: Authorization Code Flow with PKCE
- **WHEN** người dùng truy cập ứng dụng frontend
- **THEN** hệ thống SHALL chuyển hướng đến trang đăng nhập
- **WHEN** người dùng nhập thông tin đăng nhập hợp lệ
- **THEN** hệ thống SHALL xác thực và chuyển hướng với authorization code
- **WHEN** frontend trao đổi authorization code với token
- **THEN** hệ thống SHALL trả về JWT access token và refresh token

#### Scenario: Refresh Token Rotation
- **WHEN** refresh token được sử dụng
- **THEN** hệ thống SHALL phát hành refresh token mới và vô hiệu hóa token cũ
- **WHEN** refresh token cũ được sử dụng lại
- **THEN** hệ thống SHALL từ chối và vô hiệu hóa tất cả session của người dùng

#### Scenario: Client Credentials Grant
- **WHEN** dịch vụ cần xác thực service-to-service
- **THEN** hệ thống SHALL hỗ trợ Client Credentials Grant
- **WHEN** client credentials hợp lệ
- **THEN** hệ thống SHALL trả về JWT access token

### Requirement: JWT Access Tokens
Hệ thống SHALL sử dụng JWT RS256 cho access tokens.

#### Scenario: Token Verification
- **WHEN** dịch vụ nhận được JWT access token
- **THEN** hệ thống SHALL cung cấp JWKS endpoint để xác minh token
- **WHEN** token hết hạn
- **THEN** hệ thống SHALL từ chối token

#### Scenario: Token Revocation
- **WHEN** người dùng đăng xuất
- **THEN** hệ thống SHALL thêm token JTI vào blacklist trong Redis
- **WHEN** token bị thu hồi được sử dụng
- **THEN** hệ thống SHALL từ chối token

### Requirement: User Authentication
Hệ thống SHALL xác thực người dùng thông qua email và mật khẩu.

#### Scenario: User Registration
- **WHEN** người dùng mới đăng ký
- **THEN** hệ thống SHALL tạo user record với mật khẩu đã hash
- **WHEN** email đã tồn tại
- **THEN** hệ thống SHALL trả về lỗi

#### Scenario: User Login
- **WHEN** người dùng nhập email và mật khẩu hợp lệ
- **THEN** hệ thống SHALL xác thực và tạo session
- **WHEN** thông tin đăng nhập không hợp lệ
- **THEN** hệ thống SHALL trả về lỗi

### Requirement: Session Management
Hệ thống SHALL quản lý session người dùng thông qua Redis.

#### Scenario: Active Sessions
- **WHEN** người dùng có nhiều session hoạt động
- **THEN** hệ thống SHALL theo dõi tất cả session trong Redis
- **WHEN** người dùng yêu cầu đăng xuất tất cả thiết bị
- **THEN** hệ thống SHALL vô hiệu hóa tất cả session

#### Scenario: Session Expiration
- **WHEN** session không hoạt động quá thời gian quy định
- **THEN** hệ thống SHALL tự động xóa session khỏi Redis

### Requirement: Security
Hệ thống SHALL đảm bảo bảo mật cho quá trình xác thực và ủy quyền.

#### Scenario: Rate Limiting
- **WHEN** có nhiều yêu cầu đăng nhập thất bại từ cùng một IP
- **THEN** hệ thống SHALL áp dụng rate limiting
- **WHEN** rate limit bị vượt quá
- **THEN** hệ thống SHALL trả về HTTP 429

#### Scenario: Secure Headers
- **WHEN** trả về response
- **THEN** hệ thống SHALL bao gồm các security headers (HSTS, CSP, etc.)

#### Scenario: Key Management
- **WHEN** hệ thống khởi động
- **THEN** hệ thống SHALL tải RSA private key từ AWS Secrets Manager
- **WHEN** cần rotation key
- **THEN** hệ thống SHALL hỗ trợ key rotation mà không cần restart

#### Scenario: Credential Storage
- **WHEN** lưu trữ thông tin xác thực
- **THEN** hệ thống SHALL sử dụng AWS Secrets Manager cho database credentials
- **WHEN** lưu trữ Redis password
- **THEN** hệ thống SHALL sử dụng Secrets Manager hoặc environment variables

## Design Considerations

### Token Storage
- Access tokens: JWT stateless
- Refresh tokens: Opaque strings stored in Redis with TTL
- Blacklist: JTIs stored in Redis with TTL

### Key Management
- Private key stored in AWS Secrets Manager or local keystore
- Public key exposed via JWKS endpoint
- Key rotation support

### Error Handling
- Standard OAuth2 error responses
- Detailed error messages for developers
- Generic messages for end users

### Security Measures
- Short-lived access tokens (5-15 minutes)
- Refresh token rotation with reuse detection
- IP-based rate limiting for authentication endpoints
- Secure storage of all credentials in AWS Secrets Manager

## Integration Points

### External Dependencies
- Redis for token storage and caching
- PostgreSQL for user and client data
- AWS Secrets Manager for key storage

### Internal Services
- Transaction Service (validates tokens)
- Bank Connector Service (validates tokens)
- Analytics Service (validates tokens)
- Notification Service (validates tokens)
