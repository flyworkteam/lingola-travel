-- Migration: 013_create_bookmarks_table.sql
-- Description: User bookmarked items
-- Date: 2026-02-08
-- Dependencies: 001_create_users_table.sql

CREATE TABLE IF NOT EXISTS bookmarks (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36) NOT NULL,
  item_type ENUM('lesson_vocabulary', 'dictionary_word', 'travel_phrase') NOT NULL,
  item_id VARCHAR(36) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_user_bookmark (user_id, item_type, item_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_item (item_type, item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
