-- Migration: 003_create_user_onboarding_table.sql
-- Description: Store user onboarding preferences
-- Date: 2026-02-08
-- Dependencies: 001_create_users_table.sql

CREATE TABLE IF NOT EXISTS user_onboarding (
  user_id VARCHAR(36) PRIMARY KEY,
  target_language VARCHAR(10) NOT NULL,
  profession VARCHAR(50),
  english_level VARCHAR(30),
  daily_goal VARCHAR(20),
  daily_goal_minutes INT,
  completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_target_language (target_language)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
