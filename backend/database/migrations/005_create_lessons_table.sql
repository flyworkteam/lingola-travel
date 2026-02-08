-- Migration: 005_create_lessons_table.sql
-- Description: Individual lessons within courses
-- Date: 2026-02-08
-- Dependencies: 004_create_courses_table.sql

CREATE TABLE IF NOT EXISTS lessons (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  course_id VARCHAR(36) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  lesson_order INT NOT NULL,
  total_steps INT DEFAULT 10,
  image_url VARCHAR(500),
  audio_url VARCHAR(500),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  INDEX idx_course_lesson (course_id, lesson_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
