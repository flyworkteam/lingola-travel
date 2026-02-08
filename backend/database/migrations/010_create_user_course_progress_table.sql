-- Migration: 010_create_user_course_progress_table.sql
-- Description: Track user progress per course
-- Date: 2026-02-08
-- Dependencies: 001_create_users_table.sql, 004_create_courses_table.sql

CREATE TABLE IF NOT EXISTS user_course_progress (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36) NOT NULL,
  course_id VARCHAR(36) NOT NULL,
  progress_percentage INT DEFAULT 0,
  lessons_completed INT DEFAULT 0,
  last_accessed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_user_course (user_id, course_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_last_accessed (user_id, last_accessed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
