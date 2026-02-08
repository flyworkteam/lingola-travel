-- Migration: 001_create_users_table.sql
-- Description: Create users table for authentication and user management
-- Date: 2026-02-08
-- Dependencies: None

CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255),
  name VARCHAR(255),
  photo_url VARCHAR(500),
  phone_number VARCHAR(20),
  
  -- Account Type
  is_anonymous BOOLEAN DEFAULT FALSE,
  auth_provider ENUM('email', 'google', 'apple', 'facebook', 'anonymous') NOT NULL,
  external_auth_id VARCHAR(255),
  
  -- Premium Status
  is_premium BOOLEAN DEFAULT FALSE,
  premium_expires_at DATETIME NULL,
  trial_started_at DATETIME NULL,
  
  -- Device Info (for anonymous users)
  device_id VARCHAR(255),
  
  -- Timestamps
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login_at DATETIME,
  
  -- Indexes
  INDEX idx_email (email),
  INDEX idx_device_id (device_id),
  INDEX idx_external_auth (auth_provider, external_auth_id),
  INDEX idx_premium_status (is_premium, premium_expires_at),
  INDEX idx_trial (trial_started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
