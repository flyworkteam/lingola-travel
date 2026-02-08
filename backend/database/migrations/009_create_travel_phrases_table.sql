-- Migration: 009_create_travel_phrases_table.sql
-- Description: Common travel phrases with translations
-- Date: 2026-02-08
-- Dependencies: None

CREATE TABLE IF NOT EXISTS travel_phrases (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  category VARCHAR(100) NOT NULL,
  phrase_type ENUM('question', 'statement', 'response') DEFAULT 'question',
  english_text TEXT NOT NULL,
  translation TEXT NOT NULL,
  audio_url VARCHAR(500),
  display_order INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_category (category),
  FULLTEXT idx_phrase_search (english_text, translation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
