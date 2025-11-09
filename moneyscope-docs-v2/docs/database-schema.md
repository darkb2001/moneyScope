# Database Schema (Postgres)

## users
- id UUID PK
- email varchar UNIQUE
- password_hash varchar
- created_at timestamp

## oauth_clients
- client_id varchar PK
- client_secret_hash varchar
- redirect_uris jsonb
- is_public boolean
- scopes text[]
- created_at timestamp

## accounts
- id UUID PK
- user_id UUID FK -> users.id
- bank_code varchar
- account_number varchar
- balance numeric
- currency varchar
- version int (for optimistic locking)
- created_at timestamp

## transactions
- id UUID PK
- account_id UUID FK -> accounts.id
- transaction_id varchar UNIQUE (from bank)
- amount numeric
- currency varchar
- description text
- category varchar
- transaction_date timestamp
- status varchar (pending / processed / failed)
- created_at timestamp

## monthly_summary
- id UUID PK
- user_id UUID
- year int
- month int
- total_income numeric
- total_expense numeric
- created_at timestamp
