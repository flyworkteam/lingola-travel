-- Migration: 004_create_courses_table.sql
-- Description: Language course catalog
-- Date: 2026-02-08
-- Dependencies: None

CREATE TABLE IF NOT EXISTS courses (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  category VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  display_order INT NOT NULL,
  is_free BOOLEAN DEFAULT FALSE,
  total_lessons INT DEFAULT 12,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_display_order (display_order),
  INDEX idx_is_free (is_free),
  INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
