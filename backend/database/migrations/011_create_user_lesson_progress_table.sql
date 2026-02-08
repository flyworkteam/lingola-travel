-- Migration: 011_create_user_lesson_progress_table.sql
-- Description: Track user progress per lesson
-- Date: 2026-02-08
-- Dependencies: 001_create_users_table.sql, 005_create_lessons_table.sql

CREATE TABLE IF NOT EXISTS user_lesson_progress (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36) NOT NULL,
  lesson_id VARCHAR(36) NOT NULL,
  current_step INT DEFAULT 1,
  completed BOOLEAN DEFAULT FALSE,
  score INT,
  xp_earned INT DEFAULT 0,
  completed_at DATETIME NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_user_lesson (user_id, lesson_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_completed (user_id, completed, completed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
