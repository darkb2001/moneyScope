CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    bank_code VARCHAR(50),
    account_number VARCHAR(50),
    balance NUMERIC(15,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'VND',
    version INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    transaction_id VARCHAR(100) UNIQUE,
    amount NUMERIC(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'VND',
    description TEXT,
    category VARCHAR(100),
    transaction_date TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);

CREATE TABLE monthly_summary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL,
    total_income NUMERIC(15,2) DEFAULT 0.00,
    total_expense NUMERIC(15,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE(user_id, year, month)
);
