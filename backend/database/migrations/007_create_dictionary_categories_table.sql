-- Migration: 007_create_dictionary_categories_table.sql
-- Description: Visual dictionary categories
-- Date: 2026-02-08
-- Dependencies: None

CREATE TABLE IF NOT EXISTS dictionary_categories (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  name VARCHAR(100) NOT NULL UNIQUE,
  icon_path VARCHAR(255),
  color VARCHAR(10),
  item_count INT DEFAULT 0,
  display_order INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_name (name),
  INDEX idx_display_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
