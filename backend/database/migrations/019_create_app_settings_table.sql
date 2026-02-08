-- Migration: 019_create_app_settings_table.sql
-- Description: Global app configuration
-- Date: 2026-02-08
-- Dependencies: None

CREATE TABLE IF NOT EXISTS app_settings (
  setting_key VARCHAR(100) PRIMARY KEY,
  setting_value TEXT NOT NULL,
  data_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
  description TEXT,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
