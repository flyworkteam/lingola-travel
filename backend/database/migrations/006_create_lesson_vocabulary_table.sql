-- Migration: 006_create_lesson_vocabulary_table.sql
-- Description: Key vocabulary for each lesson
-- Date: 2026-02-08
-- Dependencies: 005_create_lessons_table.sql

CREATE TABLE IF NOT EXISTS lesson_vocabulary (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  lesson_id VARCHAR(36) NOT NULL,
  term VARCHAR(255) NOT NULL,
  definition TEXT NOT NULL,
  icon_path VARCHAR(255),
  icon_color VARCHAR(10),
  audio_url VARCHAR(500),
  display_order INT,
  
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
  INDEX idx_lesson_id (lesson_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
