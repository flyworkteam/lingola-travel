-- Migration: 008_create_dictionary_words_table.sql
-- Description: Dictionary word entries
-- Date: 2026-02-08
-- Dependencies: 007_create_dictionary_categories_table.sql

CREATE TABLE IF NOT EXISTS dictionary_words (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  category_id VARCHAR(36) NOT NULL,
  word VARCHAR(255) NOT NULL,
  translation VARCHAR(255) NOT NULL,
  definition TEXT,
  image_url VARCHAR(500),
  audio_url VARCHAR(500),
  usage_examples JSON,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (category_id) REFERENCES dictionary_categories(id) ON DELETE CASCADE,
  INDEX idx_category_id (category_id),
  INDEX idx_word (word),
  FULLTEXT idx_word_search (word, translation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
