-- Migration: 018_create_audit_logs_table.sql
-- Description: Security audit trail
-- Date: 2026-02-08
-- Dependencies: None (user_id can be NULL for unauthenticated attempts)

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36),
  action VARCHAR(100) NOT NULL,
  ip_address VARCHAR(45),
  user_agent TEXT,
  metadata JSON,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_user_id (user_id),
  INDEX idx_action (action),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
