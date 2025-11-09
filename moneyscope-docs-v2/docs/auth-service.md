# Auth Service (detailed)

## Overview
Auth Service is a self-hosted OAuth2 Authorization Server that supports:
- Authorization Code Grant with PKCE (for SPA/Next.js)
- Refresh token rotation + revocation
- Client Credentials grant for service-to-service
- JWT access tokens (RS256) with public JWKS endpoint
- Redis-backed refresh tokens and blacklists

## Key decisions
- **Framework**: Spring Boot 3 + Spring Authorization Server
- **JWT signing**: RS256 (private key stored in AWS Secrets Manager / local keystore)
- **Refresh tokens**: opaque random strings stored in Redis with TTL
- **Rotation**: on refresh, issue new refresh token and mark old one revoked (atomic swap)
- **Revocation**: support `/revoke` endpoint. Revoked JTIs stored in Redis blacklist with TTL equal to remaining token lifetime.

## Endpoints (OpenAPI style)
- `GET /authorize`
  - Params: `response_type=code`, `client_id`, `redirect_uri`, `scope`, `state`, `code_challenge`, `code_challenge_method`
  - Flow: render login & consent; on success, redirect with `?code=...&state=...`

- `POST /token`
  - `grant_type=authorization_code`
    - body: `code`, `redirect_uri`, `client_id`, `code_verifier`
  - `grant_type=refresh_token`
    - body: `refresh_token`, `client_id`
  - `grant_type=client_credentials`
    - body: `client_id`, `client_secret`, `scope`
  - Response: `{ access_token, token_type, expires_in, refresh_token?, scope }`

- `POST /revoke`  
  - body: `token`, `token_type_hint` (access|refresh)
  - Action: delete refresh key if present; add jti to blacklist

- `POST /introspect`
  - body: `token`
  - Return active + claims (for services to validate opaque tokens if needed)

- `GET /.well-known/jwks.json`  
  - Returns JWKS for verifying access JWTs

## Redis Schema
- `refresh:<token>` => JSON `{ userId, clientId, scope, jti, exp }`
- `blacklist:access:<jti>` => true (TTL set to token remaining lifetime)
- `blacklist:refresh:<jti>` => true
- `session:<userId>:<clientId>` => set of active refresh jtis

## Refresh rotation (pseudo)
Use atomic Lua script:
1. GET `refresh:<old>`
2. If not exists -> possible replay attack -> revoke all sessions
3. CREATE `refresh:<new>` with metadata (TTL)
4. DEL `refresh:<old>`
5. Add `blacklist:refresh:<old_jti>` with TTL
6. Return new token to client

## Spring stack & libs
- `spring-boot-starter-webflux` (optional for reactive endpoints)
- `spring-authorization-server`
- `spring-boot-starter-data-jpa` + PostgreSQL
- `lettuce` or `jedis` for Redis client
- `spring-security-oauth2` support
- `jjwt` or `nimbus-jose-jwt` for JWKS support

## Security practices
- Store private key in AWS Secrets Manager / Hashicorp Vault
- Enforce HTTPS only
- Rate-limit /token and /authorize endpoints
- Logging and alerting for refresh reuse attempts
