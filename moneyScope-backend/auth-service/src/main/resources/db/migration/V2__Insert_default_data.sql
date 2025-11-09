-- Insert default OAuth2 clients
INSERT INTO oauth_clients (client_id, client_secret_hash, redirect_uris, is_public, scopes, created_at) VALUES
('moneyscope-web', '$2a$10$...b', '["http://localhost:3000/callback", "http://localhost:3001/callback"]', true, ARRAY['read', 'write'], NOW());

-- Insert default admin user (password: admin123)
INSERT INTO users (id, email, password_hash, created_at) VALUES
('550e8400-e29b-41d4-a716-446655440', 'admin@moneyscope.com', '$2a$10$...b', NOW());
