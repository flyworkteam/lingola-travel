-- Migration: 016_create_recent_searches_table.sql
-- Description: User's recent dictionary searches
-- Date: 2026-02-08
-- Dependencies: 001_create_users_table.sql

CREATE TABLE IF NOT EXISTS recent_searches (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36) NOT NULL,
  search_query VARCHAR(255) NOT NULL,
  category VARCHAR(100),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_recent (user_id, created_at DESC),
  INDEX idx_search_query (search_query)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
