-- Migration: 012_create_user_stats_table.sql
-- Description: Aggregated user statistics
-- Date: 2026-02-08
-- Dependencies: 001_create_users_table.sql

CREATE TABLE IF NOT EXISTS user_stats (
  user_id VARCHAR(36) PRIMARY KEY,
  current_streak INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  total_lessons_completed INT DEFAULT 0,
  total_xp INT DEFAULT 0,
  last_activity_date DATE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_streak (current_streak DESC),
  INDEX idx_xp (total_xp DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
