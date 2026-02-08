-- Migration: 015_create_library_items_table.sql
-- Description: Items within library folders
-- Date: 2026-02-08
-- Dependencies: 014_create_library_folders_table.sql

CREATE TABLE IF NOT EXISTS library_items (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  folder_id VARCHAR(36) NOT NULL,
  item_type ENUM('lesson_vocabulary', 'dictionary_word', 'travel_phrase') NOT NULL,
  item_id VARCHAR(36) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_folder_item (folder_id, item_type, item_id),
  FOREIGN KEY (folder_id) REFERENCES library_folders(id) ON DELETE CASCADE,
  INDEX idx_folder_id (folder_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
