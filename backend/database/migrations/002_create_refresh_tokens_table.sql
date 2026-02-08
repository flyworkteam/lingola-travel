-- Migration: 002_create_refresh_tokens_table.sql
-- Description: Store hashed refresh tokens for JWT rotation
-- Date: 2026-02-08
-- Dependencies: 001_create_users_table.sql

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36) NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_token_hash (token_hash),
  INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
