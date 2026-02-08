# DATABASE SCHEMA DESIGN
**Database:** MySQL 8.0+  
**Hosting:** phpMyAdmin  
**Design Philosophy:** Normalized, scalable, optimized for read-heavy travel app

---

## TABLE OF CONTENTS
1. [Core Tables](#1-core-tables)
2. [Content Tables](#2-content-tables)
3. [User Progress Tables](#3-user-progress-tables)
4. [User Collections Tables](#4-user-collections-tables)
5. [System Tables](#5-system-tables)
6. [Indexes & Constraints](#6-indexes--constraints)
7. [Migration Files](#7-migration-files)

---

## 1. CORE TABLES

### 1.1 `users`
**Purpose:** Central user account management

```sql
CREATE TABLE users (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255), -- NULL for social/anonymous users
  name VARCHAR(255),
  photo_url VARCHAR(500),
  phone_number VARCHAR(20),
  
  -- Account Type
  is_anonymous BOOLEAN DEFAULT FALSE,
  auth_provider ENUM('email', 'google', 'apple', 'facebook', 'anonymous') NOT NULL,
  external_auth_id VARCHAR(255), -- Provider's unique ID (sub from JWT)
  
  -- Premium Status
  is_premium BOOLEAN DEFAULT FALSE,
  premium_expires_at DATETIME NULL,
  trial_started_at DATETIME NULL,
  
  -- Device Info (for anonymous users)
  device_id VARCHAR(255), -- Unique device identifier
  
  -- Timestamps
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login_at DATETIME,
  
  -- Indexes
  INDEX idx_email (email),
  INDEX idx_device_id (device_id),
  INDEX idx_external_auth (auth_provider, external_auth_id),
  INDEX idx_premium_status (is_premium, premium_expires_at)
);
```

**Business Rules:**
- Email can be NULL for anonymous/social users without email permission
- password_hash is NULL for social/anonymous auth
- trial_started_at triggers 1-day trial countdown
- is_premium overrides trial expiration

### 1.2 `refresh_tokens`
**Purpose:** Store hashed refresh tokens for JWT rotation

```sql
CREATE TABLE refresh_tokens (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36) NOT NULL,
  token_hash VARCHAR(255) NOT NULL, -- bcrypt hash of actual token
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_token_hash (token_hash),
  INDEX idx_expires_at (expires_at)
);
```

**Security:**
- Never store raw refresh tokens
- Hash with bcrypt before storage
- Automatic cleanup of expired tokens via cron job

### 1.3 `user_onboarding`
**Purpose:** Store onboarding preferences

```sql
CREATE TABLE user_onboarding (
  user_id VARCHAR(36) PRIMARY KEY,
  target_language VARCHAR(10) NOT NULL, -- en, de, it, fr, ja, es, ru, tr, ko, hi, pt
  profession VARCHAR(50), -- Student, Professional, Technology, Healthcare, Arts & Media, Other
  english_level VARCHAR(30), -- Beginner, Elementary, Intermediate, Upper-Intermediate
  daily_goal VARCHAR(20), -- Casual, Regular, Serious
  daily_goal_minutes INT, -- 5, 15, 30
  completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_target_language (target_language)
);
```

---

## 2. CONTENT TABLES

### 2.1 `courses`
**Purpose:** Language course catalog (11 courses)

```sql
CREATE TABLE courses (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  category VARCHAR(50) NOT NULL, -- General, Trip, Food & Drink, Accommodation, Culture, Shopping, Direction & Navigation, Sport, Health, Business, Emergency
  title VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  display_order INT NOT NULL,
  is_free BOOLEAN DEFAULT FALSE, -- First course free, rest premium
  total_lessons INT DEFAULT 12,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_display_order (display_order),
  INDEX idx_is_free (is_free)
);
```

### 2.2 `lessons`
**Purpose:** Individual lessons within courses

```sql
CREATE TABLE lessons (
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
);
```

### 2.3 `lesson_vocabulary`
**Purpose:** Key vocabulary for each lesson

```sql
CREATE TABLE lesson_vocabulary (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  lesson_id VARCHAR(36) NOT NULL,
  term VARCHAR(255) NOT NULL,
  definition TEXT NOT NULL,
  icon_path VARCHAR(255), -- SVG icon asset path
  icon_color VARCHAR(10), -- Hex color code
  audio_url VARCHAR(500),
  display_order INT,
  
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
  INDEX idx_lesson_id (lesson_id)
);
```

### 2.4 `dictionary_categories`
**Purpose:** Visual dictionary categories (10 categories)

```sql
CREATE TABLE dictionary_categories (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  name VARCHAR(100) NOT NULL UNIQUE, -- Airport, Accommodation, Transportation, Food & Drink, Shopping, Culture, Meeting, Sport, Health, Business
  icon_path VARCHAR(255),
  color VARCHAR(10), -- Hex color
  item_count INT DEFAULT 0, -- Denormalized for performance
  display_order INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_name (name),
  INDEX idx_display_order (display_order)
);
```

### 2.5 `dictionary_words`
**Purpose:** Dictionary word entries

```sql
CREATE TABLE dictionary_words (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  category_id VARCHAR(36) NOT NULL,
  word VARCHAR(255) NOT NULL,
  translation VARCHAR(255) NOT NULL,
  definition TEXT,
  image_url VARCHAR(500),
  audio_url VARCHAR(500),
  usage_examples JSON, -- Array of example sentences
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (category_id) REFERENCES dictionary_categories(id) ON DELETE CASCADE,
  INDEX idx_category_id (category_id),
  INDEX idx_word (word),
  FULLTEXT idx_word_search (word, translation)
);
```

### 2.6 `travel_phrases`
**Purpose:** Common travel phrases with translations

```sql
CREATE TABLE travel_phrases (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  category VARCHAR(100) NOT NULL, -- Airport, Hotel, Taxi, Food & Drink, Shopping, Culture, Meeting, Sport, Health, Business
  phrase_type ENUM('question', 'statement', 'response') DEFAULT 'question',
  english_text TEXT NOT NULL,
  translation TEXT NOT NULL,
  audio_url VARCHAR(500),
  display_order INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_category (category),
  FULLTEXT idx_phrase_search (english_text, translation)
);
```

---

## 3. USER PROGRESS TABLES

### 3.1 `user_course_progress`
**Purpose:** Track progress per course

```sql
CREATE TABLE user_course_progress (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36) NOT NULL,
  course_id VARCHAR(36) NOT NULL,
  progress_percentage INT DEFAULT 0, -- 0-100
  lessons_completed INT DEFAULT 0,
  last_accessed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_user_course (user_id, course_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_last_accessed (user_id, last_accessed_at)
);
```

### 3.2 `user_lesson_progress`
**Purpose:** Track progress per lesson

```sql
CREATE TABLE user_lesson_progress (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36) NOT NULL,
  lesson_id VARCHAR(36) NOT NULL,
  current_step INT DEFAULT 1,
  completed BOOLEAN DEFAULT FALSE,
  score INT, -- 0-100 for completed lessons
  xp_earned INT DEFAULT 0,
  completed_at DATETIME NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_user_lesson (user_id, lesson_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_completed (user_id, completed, completed_at)
);
```

### 3.3 `user_stats`
**Purpose:** Aggregated user statistics (denormalized for performance)

```sql
CREATE TABLE user_stats (
  user_id VARCHAR(36) PRIMARY KEY,
  current_streak INT DEFAULT 0, -- Days in a row
  longest_streak INT DEFAULT 0,
  total_lessons_completed INT DEFAULT 0,
  total_xp INT DEFAULT 0,
  last_activity_date DATE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_streak (current_streak DESC),
  INDEX idx_xp (total_xp DESC)
);
```

---

## 4. USER COLLECTIONS TABLES

### 4.1 `bookmarks`
**Purpose:** User bookmarked items (vocabulary, phrases)

```sql
CREATE TABLE bookmarks (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36) NOT NULL,
  item_type ENUM('lesson_vocabulary', 'dictionary_word', 'travel_phrase') NOT NULL,
  item_id VARCHAR(36) NOT NULL, -- FK to respective table
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_user_bookmark (user_id, item_type, item_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_item (item_type, item_id)
);
```

### 4.2 `library_folders`
**Purpose:** User-created collection folders

```sql
CREATE TABLE library_folders (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id VARCHAR(36) NOT NULL,
  name VARCHAR(255) NOT NULL,
  icon VARCHAR(255), -- Icon path or emoji
  color VARCHAR(10), -- Hex color
  item_count INT DEFAULT 0, -- Denormalized
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
);
```

### 4.3 `library_items`
**Purpose:** Items within library folders

```sql
CREATE TABLE library_items (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  folder_id VARCHAR(36) NOT NULL,
  item_type ENUM('lesson_vocabulary', 'dictionary_word', 'travel_phrase') NOT NULL,
  item_id VARCHAR(36) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_folder_item (folder_id, item_type, item_id),
  FOREIGN KEY (folder_id) REFERENCES library_folders(id) ON DELETE CASCADE,
  INDEX idx_folder_id (folder_id)
);
```

### 4.4 `recent_searches`
**Purpose:** User's recent dictionary searches

```sql
CREATE TABLE recent_searches (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36) NOT NULL,
  search_query VARCHAR(255) NOT NULL,
  category VARCHAR(100), -- Dictionary category searched
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_recent (user_id, created_at DESC),
  INDEX idx_search_query (search_query)
);
```

---

## 5. SYSTEM TABLES

### 5.1 `notifications`
**Purpose:** App-specific notifications (separate from OneSignal)

```sql
CREATE TABLE notifications (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id VARCHAR(36), -- NULL for broadcast notifications
  icon VARCHAR(50), -- Emoji or icon identifier
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  is_premium_promo BOOLEAN DEFAULT FALSE, -- Sticky for free users
  is_read BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_unread (user_id, is_read, created_at DESC)
);
```

### 5.2 `audit_logs`
**Purpose:** Security audit trail

```sql
CREATE TABLE audit_logs (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(36),
  action VARCHAR(100) NOT NULL, -- login, logout, premium_purchase, trial_start, etc.
  ip_address VARCHAR(45), -- IPv4/IPv6
  user_agent TEXT,
  metadata JSON, -- Additional context
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_user_id (user_id),
  INDEX idx_action (action),
  INDEX idx_created_at (created_at)
);
```

### 5.3 `app_settings`
**Purpose:** Global app configuration (future use)

```sql
CREATE TABLE app_settings (
  setting_key VARCHAR(100) PRIMARY KEY,
  setting_value TEXT NOT NULL,
  data_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
  description TEXT,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

---

## 6. INDEXES & CONSTRAINTS

### Performance Indexes
```sql
-- User lookups
CREATE INDEX idx_users_trial ON users(trial_started_at) WHERE trial_started_at IS NOT NULL;
CREATE INDEX idx_users_premium_expires ON users(premium_expires_at) WHERE premium_expires_at IS NOT NULL;

-- Course progress queries
CREATE INDEX idx_progress_recent ON user_course_progress(user_id, last_accessed_at DESC);

-- Leaderboard queries (future)
CREATE INDEX idx_stats_leaderboard ON user_stats(total_xp DESC, current_streak DESC);

-- Search performance
CREATE FULLTEXT INDEX idx_dictionary_fulltext ON dictionary_words(word, translation, definition);
CREATE FULLTEXT INDEX idx_phrases_fulltext ON travel_phrases(english_text, translation);
```

### Foreign Key Constraints (already defined inline)
All FK constraints include `ON DELETE CASCADE` to maintain referential integrity.

---

## 7. MIGRATION FILES

### Migration Strategy
- **Numbered migrations:** `001_create_users_table.sql`, `002_create_courses_table.sql`, etc.
- **Rollback scripts:** Each migration has a corresponding `xxx_rollback.sql`
- **Idempotent:** Use `CREATE TABLE IF NOT EXISTS` for safety

### Seed Data Requirements
1. **Courses:** Insert 11 courses with category, title, order
2. **Dictionary Categories:** Insert 10 categories with icons/colors
3. **App Settings:** Insert default settings (api_version, maintenance_mode, etc.)

### Sample Migration (001_create_users_table.sql)
```sql
-- Migration: 001_create_users_table.sql
-- Description: Create users table for authentication and user management
-- Date: 2026-02-08

CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255),
  name VARCHAR(255),
  photo_url VARCHAR(500),
  phone_number VARCHAR(20),
  is_anonymous BOOLEAN DEFAULT FALSE,
  auth_provider ENUM('email', 'google', 'apple', 'facebook', 'anonymous') NOT NULL,
  external_auth_id VARCHAR(255),
  is_premium BOOLEAN DEFAULT FALSE,
  premium_expires_at DATETIME NULL,
  trial_started_at DATETIME NULL,
  device_id VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login_at DATETIME,
  
  INDEX idx_email (email),
  INDEX idx_device_id (device_id),
  INDEX idx_external_auth (auth_provider, external_auth_id),
  INDEX idx_premium_status (is_premium, premium_expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 8. DATABASE DESIGN NOTES

### Normalization
- **3NF compliance:** Minimal redundancy
- **Denormalized fields:** `item_count` in folders/categories for performance (updated via triggers)

### Scalability Considerations
- UUIDs for distributed systems compatibility
- Composite indexes for common query patterns
- No soft deletes (hard deletes with CASCADE for simplicity)

### Character Set
- **utf8mb4_unicode_ci:** Full Unicode support (emojis, multilingual content)

### Engine
- **InnoDB:** ACID compliance, foreign key support, row-level locking

---

**Next:** API endpoint design and backend implementation
