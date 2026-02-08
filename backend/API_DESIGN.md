# API DESIGN SPECIFICATION
**Version:** 1.0  
**Base URL:** `http://localhost:3000/api/v1` (development)  
**Production URL:** `https://api.lingolatravel.com/api/v1` (TODO: Update after deployment)

---

## TABLE OF CONTENTS
1. [API Standards](#1-api-standards)
2. [Authentication Endpoints](#2-authentication-endpoints)
3. [User Management Endpoints](#3-user-management-endpoints)
4. [Content Endpoints](#4-content-endpoints)
5. [Progress Tracking Endpoints](#5-progress-tracking-endpoints)
6. [Library & Bookmarks Endpoints](#6-library--bookmarks-endpoints)
7. [Notification Endpoints](#7-notification-endpoints)
8. [Error Codes](#8-error-codes)

---

## 1. API STANDARDS

### Standard Response Format
All API responses follow this structure:

**Success Response:**
```json
{
  "success": true,
  "data": { /* response data */ },
  "error": null
}
```

**Error Response:**
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message"
  }
}
```

### Authentication
- **Authorization Header:** `Authorization: Bearer <access_token>`
- **Token Type:** JWT (JSON Web Token)
- **Access Token Expiry:** 15 minutes
- **Refresh Token Expiry:** 7 days

### Rate Limiting
| Endpoint Category | Limit |
|------------------|-------|
| Authentication | 5 requests per 15 minutes per IP |
| Content (GET) | 100 requests per minute per user |
| User Actions (POST/PUT/DELETE) | 30 requests per minute per user |

### HTTP Status Codes
| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Resource created successfully |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Invalid or missing token |
| 403 | Forbidden - No permission (e.g., premium content for free user) |
| 404 | Not Found - Resource doesn't exist |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |

---

## 2. AUTHENTICATION ENDPOINTS

### 2.1 Email/Password Login
**POST** `/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "photoUrl": null,
      "phoneNumber": null,
      "isAnonymous": false,
      "isPremium": false,
      "premiumExpiresAt": null,
      "trialStartedAt": "2026-02-08T10:00:00Z",
      "createdAt": "2026-02-08T10:00:00Z",
      "updatedAt": "2026-02-08T10:00:00Z"
    },
    "accessToken": "jwt_access_token",
    "refreshToken": "jwt_refresh_token"
  },
  "error": null
}
```

**Errors:**
- `INVALID_CREDENTIALS` - Email or password incorrect
- `ACCOUNT_NOT_FOUND` - Email not registered
- `VALIDATION_ERROR` - Missing required fields

---

### 2.2 Google Sign-In
**POST** `/auth/google`

**Request Body:**
```json
{
  "idToken": "google_id_token_from_flutter"
}
```

**Response (200):** Same as email login

**Server-Side Logic:**
1. Verify `idToken` with Google API
2. Extract user info (email, name, photoUrl, sub)
3. Check if user exists by `external_auth_id` (Google's `sub`)
4. If new user:
   - Create user with `auth_provider='google'`
   - Set `trial_started_at = NOW()`
   - Auto-generate `user_stats` record
5. Generate JWT tokens
6. Log in `audit_logs`

---

### 2.3 Apple Sign-In
**POST** `/auth/apple`

**Request Body:**
```json
{
  "identityToken": "apple_identity_token_from_flutter",
  "authorizationCode": "apple_authorization_code",
  "email": "user@privaterelay.appleid.com", // May be hidden
  "name": "John Doe" // Only provided on first sign-in
}
```

**Response (200):** Same as email login

**Server-Side Logic:**
1. Verify `identityToken` with Apple's public keys
2. Extract `sub` (unique user ID)
3. If new user: Store email/name (may be null after first login)
4. Same flow as Google

---

### 2.4 Facebook Login
**POST** `/auth/facebook`

**Request Body:**
```json
{
  "accessToken": "facebook_access_token_from_flutter"
}
```

**Response (200):** Same as email login

**Server-Side Logic:**
1. Verify `accessToken` with Facebook Graph API (`/me` endpoint)
2. Extract user info
3. Same flow as Google

---

### 2.5 Anonymous Login
**POST** `/auth/anonymous`

**Request Body:**
```json
{
  "deviceId": "unique_device_identifier"
}
```

**Response (200):** Same as email login (user `isAnonymous=true`)

**Server-Side Logic:**
1. Check if `deviceId` already exists
2. If exists: Return existing user + new tokens
3. If new: Create anonymous user with `auth_provider='anonymous'`
4. Set `trial_started_at = NOW()`

**Important:** Anonymous users can later upgrade to social login.

---

### 2.6 Refresh Token
**POST** `/auth/refresh`

**Request Body:**
```json
{
  "refreshToken": "current_refresh_token"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "new_jwt_access_token",
    "refreshToken": "new_jwt_refresh_token"
  },
  "error": null
}
```

**Server-Side Logic:**
1. Verify refresh token signature
2. Check hash exists in `refresh_tokens` table
3. If valid: Generate new access + refresh tokens
4. Delete old refresh token, insert new hashed token
5. Return new tokens

**Errors:**
- `INVALID_TOKEN` - Token invalid or expired
- `TOKEN_NOT_FOUND` - Token not in database (possibly revoked)

---

### 2.7 Logout
**POST** `/auth/logout`

**Request Body:**
```json
{
  "refreshToken": "current_refresh_token"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Logged out successfully"
  },
  "error": null
}
```

**Server-Side Logic:**
1. Delete refresh token from `refresh_tokens` table
2. Log in `audit_logs`

---

## 3. USER MANAGEMENT ENDPOINTS

### 3.1 Submit Onboarding Data
**POST** `/user/onboarding`

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "targetLanguage": "en",
  "profession": "Technology",
  "englishLevel": "Intermediate",
  "dailyGoal": "Regular",
  "dailyGoalMinutes": 15
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Onboarding completed successfully"
  },
  "error": null
}
```

**Server-Side Logic:**
1. Insert into `user_onboarding` table
2. Update `users.updated_at`

---

### 3.2 Get User Profile
**GET** `/user/profile`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "photoUrl": "https://...",
      "phoneNumber": null,
      "isAnonymous": false,
      "isPremium": false,
      "premiumExpiresAt": null,
      "trialStartedAt": "2026-02-08T10:00:00Z",
      "isTrialActive": true,
      "hasPremiumAccess": true,
      "createdAt": "2026-02-08T10:00:00Z",
      "updatedAt": "2026-02-08T10:00:00Z"
    },
    "onboarding": {
      "targetLanguage": "en",
      "profession": "Technology",
      "englishLevel": "Intermediate",
      "dailyGoal": "Regular",
      "dailyGoalMinutes": 15,
      "completedAt": "2026-02-08T10:05:00Z"
    }
  },
  "error": null
}
```

---

### 3.3 Update User Profile
**PATCH** `/user/profile`

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "name": "John Updated",
  "phoneNumber": "+1234567890"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": { /* updated user object */ }
  },
  "error": null
}
```

---

### 3.4 Get User Stats
**GET** `/user/stats`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "currentStreak": 5,
    "longestStreak": 12,
    "totalLessonsCompleted": 8,
    "totalXP": 420,
    "lastActivityDate": "2026-02-08"
  },
  "error": null
}
```

---

### 3.5 Change Password
**POST** `/user/change-password`

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "currentPassword": "oldPassword123",
  "newPassword": "newSecurePassword456"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Password changed successfully"
  },
  "error": null
}
```

**Errors:**
- `INVALID_PASSWORD` - Current password incorrect
- `WEAK_PASSWORD` - New password doesn't meet requirements

---

## 4. CONTENT ENDPOINTS

### 4.1 Get All Courses
**GET** `/courses`

**Headers:** `Authorization: Bearer <access_token>`

**Query Parameters:**
- `language` (optional): Filter by target language (future use)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "courses": [
      {
        "id": "uuid",
        "category": "General",
        "title": "Daily Conversation",
        "description": "Master everyday expressions...",
        "imageUrl": "https://cdn.example.com/courses/general.png",
        "displayOrder": 1,
        "isFree": true,
        "totalLessons": 12,
        "userProgress": {
          "progressPercentage": 100,
          "lessonsCompleted": 12,
          "lastAccessedAt": "2026-02-07T15:30:00Z"
        },
        "isUnlocked": true // Based on user's premium status
      },
      {
        "id": "uuid",
        "category": "Trip",
        "title": "Terminal Talk",
        "description": "Essential phrases for airports...",
        "imageUrl": "https://...",
        "displayOrder": 2,
        "isFree": false,
        "totalLessons": 12,
        "userProgress": {
          "progressPercentage": 65,
          "lessonsCompleted": 8,
          "lastAccessedAt": "2026-02-08T09:00:00Z"
        },
        "isUnlocked": true
      }
      // ... more courses
    ]
  },
  "error": null
}
```

**Server-Side Logic:**
1. Fetch all courses ordered by `display_order`
2. Join with `user_course_progress` for current user
3. Calculate `isUnlocked`:
   - `isFree = true` → Always unlocked
   - `isFree = false` → Unlocked if user `hasPremiumAccess`
4. Return courses with embedded progress

---

### 4.2 Get Course Details
**GET** `/courses/:courseId`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "course": {
      "id": "uuid",
      "category": "General",
      "title": "Daily Conversation",
      "description": "...",
      "imageUrl": "...",
      "totalLessons": 12,
      "isFree": true
    },
    "lessons": [
      {
        "id": "uuid",
        "title": "Greetings & Introductions",
        "description": "Learn to greet people...",
        "lessonOrder": 1,
        "totalSteps": 10,
        "imageUrl": "...",
        "audioUrl": "...",
        "userProgress": {
          "currentStep": 10,
          "completed": true,
          "score": 95,
          "xpEarned": 50,
          "completedAt": "2026-02-07T14:00:00Z"
        }
      }
      // ... more lessons
    ],
    "userProgress": {
      "progressPercentage": 100,
      "lessonsCompleted": 12
    }
  },
  "error": null
}
```

---

### 4.3 Get Lesson Details
**GET** `/lessons/:lessonId`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "lesson": {
      "id": "uuid",
      "courseId": "uuid",
      "title": "Greetings & Introductions",
      "description": "...",
      "lessonOrder": 1,
      "totalSteps": 10,
      "imageUrl": "...",
      "audioUrl": "..."
    },
    "vocabulary": [
      {
        "id": "uuid",
        "term": "Boarding Pass",
        "definition": "A document provided by an airline...",
        "iconPath": "assets/icons/boardingpass.svg",
        "iconColor": "#4ECDC4",
        "audioUrl": "https://...",
        "displayOrder": 1
      }
      // ... more vocabulary
    ],
    "userProgress": {
      "currentStep": 5,
      "completed": false,
      "score": null,
      "xpEarned": 0
    }
  },
  "error": null
}
```

---

### 4.4 Get Dictionary Categories
**GET** `/dictionary/categories`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "id": "uuid",
        "name": "Airport",
        "iconPath": "assets/icons/airport.png",
        "color": "#2E48F0",
        "itemCount": 1240,
        "displayOrder": 1
      }
      // ... more categories
    ]
  },
  "error": null
}
```

---

### 4.5 Get Dictionary Words by Category
**GET** `/dictionary/categories/:categoryId/words`

**Headers:** `Authorization: Bearer <access_token>`

**Query Parameters:**
- `page` (default: 1): Pagination
- `limit` (default: 50, max: 100): Results per page
- `search` (optional): Search query

**Response (200):**
```json
{
  "success": true,
  "data": {
    "words": [
      {
        "id": "uuid",
        "word": "Boarding Pass",
        "translation": "Biniş Kartı",
        "definition": "A document...",
        "imageUrl": "https://...",
        "audioUrl": "https://...",
        "usageExamples": [
          "Can I see your boarding pass?"
        ]
      }
      // ... more words
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 25,
      "totalItems": 1240,
      "itemsPerPage": 50
    }
  },
  "error": null
}
```

---

### 4.6 Search Dictionary
**GET** `/dictionary/search`

**Headers:** `Authorization: Bearer <access_token>`

**Query Parameters:**
- `q`: Search query (required)
- `limit` (default: 20): Max results

**Response (200):**
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "id": "uuid",
        "word": "Boarding Pass",
        "translation": "Biniş Kartı",
        "categoryName": "Airport",
        "imageUrl": "...",
        "audioUrl": "..."
      }
      // ... more results
    ]
  },
  "error": null
}
```

**Server-Side Logic:**
- Use FULLTEXT search on `word` and `translation` columns
- Record search in `recent_searches` table

---

### 4.7 Get Travel Phrases
**GET** `/vocabulary/phrases`

**Headers:** `Authorization: Bearer <access_token>`

**Query Parameters:**
- `category` (optional): Filter by category (Airport, Hotel, Taxi, etc.)
- `type` (optional): Filter by phrase_type (question, statement, response)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "phrases": [
      {
        "id": "uuid",
        "category": "Airport",
        "phraseType": "question",
        "englishText": "Where is the check-in counter for British Airways?",
        "translation": "British Airways check-in kontuarı nerede?",
        "audioUrl": "https://...",
        "displayOrder": 1
      }
      // ... more phrases
    ]
  },
  "error": null
}
```

---

## 5. PROGRESS TRACKING ENDPOINTS

### 5.1 Update Lesson Progress
**POST** `/progress/lesson`

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "lessonId": "uuid",
  "currentStep": 7,
  "completed": false
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "progress": {
      "lessonId": "uuid",
      "currentStep": 7,
      "completed": false,
      "score": null,
      "xpEarned": 0
    }
  },
  "error": null
}
```

---

### 5.2 Complete Lesson
**POST** `/progress/lesson/complete`

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "lessonId": "uuid",
  "score": 95
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "progress": {
      "lessonId": "uuid",
      "currentStep": 10,
      "completed": true,
      "score": 95,
      "xpEarned": 50,
      "completedAt": "2026-02-08T12:00:00Z"
    },
    "courseProgress": {
      "courseId": "uuid",
      "progressPercentage": 75,
      "lessonsCompleted": 9
    },
    "stats": {
      "totalXP": 470,
      "currentStreak": 6
    }
  },
  "error": null
}
```

**Server-Side Logic:**
1. Update `user_lesson_progress` (set completed=true, score, xp_earned)
2. Calculate XP: Base 50 + bonus for score > 90
3. Update `user_course_progress` (recalculate progress_percentage)
4. Update `user_stats` (increment total_lessons_completed, add XP, update streak)
5. Check streak: If last_activity_date was yesterday, increment; else reset to 1

---

### 5.3 Get User Progress Summary
**GET** `/progress/summary`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "courses": [
      {
        "courseId": "uuid",
        "courseTitle": "Daily Conversation",
        "progressPercentage": 100,
        "lessonsCompleted": 12,
        "lastAccessedAt": "2026-02-07T15:30:00Z"
      }
      // ... more courses
    ],
    "stats": {
      "currentStreak": 6,
      "totalLessonsCompleted": 18,
      "totalXP": 900
    }
  },
  "error": null
}
```

---

## 6. LIBRARY & BOOKMARKS ENDPOINTS

### 6.1 Get Bookmarks
**GET** `/library/bookmarks`

**Headers:** `Authorization: Bearer <access_token>`

**Query Parameters:**
- `type` (optional): Filter by item_type (lesson_vocabulary, dictionary_word, travel_phrase)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "bookmarks": [
      {
        "id": 123,
        "itemType": "dictionary_word",
        "itemId": "uuid",
        "item": {
          "word": "Boarding Pass",
          "translation": "Biniş Kartı",
          "audioUrl": "..."
        },
        "createdAt": "2026-02-08T10:00:00Z"
      }
      // ... more bookmarks
    ]
  },
  "error": null
}
```

---

### 6.2 Add Bookmark
**POST** `/library/bookmarks`

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "itemType": "dictionary_word",
  "itemId": "uuid"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "bookmark": {
      "id": 123,
      "itemType": "dictionary_word",
      "itemId": "uuid",
      "createdAt": "2026-02-08T12:00:00Z"
    }
  },
  "error": null
}
```

---

### 6.3 Remove Bookmark
**DELETE** `/library/bookmarks/:bookmarkId`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Bookmark removed successfully"
  },
  "error": null
}
```

---

### 6.4 Get Library Folders
**GET** `/library/folders`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "folders": [
      {
        "id": "uuid",
        "name": "My Airport Essentials",
        "icon": "assets/icons/airport.png",
        "color": "#E3F2FD",
        "itemCount": 12,
        "createdAt": "2026-02-08T10:00:00Z"
      }
      // ... more folders
    ]
  },
  "error": null
}
```

---

### 6.5 Create Library Folder
**POST** `/library/folders`

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "name": "My Custom Phrases",
  "icon": "📚",
  "color": "#FFE4CC"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "folder": {
      "id": "uuid",
      "name": "My Custom Phrases",
      "icon": "📚",
      "color": "#FFE4CC",
      "itemCount": 0,
      "createdAt": "2026-02-08T12:00:00Z"
    }
  },
  "error": null
}
```

---

### 6.6 Get Folder Items
**GET** `/library/folders/:folderId/items`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "folder": {
      "id": "uuid",
      "name": "My Airport Essentials",
      "itemCount": 12
    },
    "items": [
      {
        "id": 456,
        "itemType": "dictionary_word",
        "itemId": "uuid",
        "item": {
          "word": "Boarding Pass",
          "translation": "Biniş Kartı",
          "audioUrl": "..."
        },
        "createdAt": "2026-02-08T10:00:00Z"
      }
      // ... more items
    ]
  },
  "error": null
}
```

---

### 6.7 Add Item to Folder
**POST** `/library/folders/:folderId/items`

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**
```json
{
  "itemType": "travel_phrase",
  "itemId": "uuid"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "item": {
      "id": 789,
      "folderId": "uuid",
      "itemType": "travel_phrase",
      "itemId": "uuid",
      "createdAt": "2026-02-08T12:00:00Z"
    }
  },
  "error": null
}
```

**Server-Side Logic:**
1. Insert into `library_items`
2. Increment `library_folders.item_count`

---

### 6.8 Remove Item from Folder
**DELETE** `/library/folders/:folderId/items/:itemId`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Item removed from folder"
  },
  "error": null
}
```

---

### 6.9 Delete Folder
**DELETE** `/library/folders/:folderId`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Folder deleted successfully"
  },
  "error": null
}
```

**Server-Side Logic:**
- CASCADE deletes all `library_items` for this folder

---

## 7. NOTIFICATION ENDPOINTS

### 7.1 Get Notifications
**GET** `/notifications`

**Headers:** `Authorization: Bearer <access_token>`

**Query Parameters:**
- `unread` (optional): `true` to filter only unread

**Response (200):**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "uuid",
        "icon": "☕",
        "title": "Daily reminder",
        "message": "Continue your learning streak!",
        "isPremiumPromo": false,
        "isRead": false,
        "createdAt": "2026-02-08T10:00:00Z"
      }
      // ... more notifications
    ]
  },
  "error": null
}
```

---

### 7.2 Mark Notification as Read
**PATCH** `/notifications/:notificationId/read`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Notification marked as read"
  },
  "error": null
}
```

---

### 7.3 Delete Notification
**DELETE** `/notifications/:notificationId`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Notification deleted"
  },
  "error": null
}
```

**Business Rule:**
- If `isPremiumPromo = true` AND user is not premium: Return 403 Forbidden

---

### 7.4 Delete All Notifications
**DELETE** `/notifications`

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "All notifications deleted",
    "deletedCount": 8
  },
  "error": null
}
```

---

## 8. ERROR CODES

| Error Code | HTTP Status | Description |
|-----------|------------|-------------|
| `INVALID_CREDENTIALS` | 401 | Login failed - wrong email/password |
| `ACCOUNT_NOT_FOUND` | 404 | Email not registered |
| `VALIDATION_ERROR` | 400 | Request body validation failed |
| `INVALID_TOKEN` | 401 | JWT token invalid or expired |
| `TOKEN_NOT_FOUND` | 401 | Refresh token not in database |
| `UNAUTHORIZED` | 401 | Missing or invalid Authorization header |
| `FORBIDDEN` | 403 | No permission (e.g., premium content for free user) |
| `NOT_FOUND` | 404 | Resource doesn't exist |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `WEAK_PASSWORD` | 400 | Password doesn't meet security requirements |
| `INVALID_PASSWORD` | 400 | Current password incorrect |
| `DUPLICATE_ENTRY` | 400 | Resource already exists (e.g., bookmark) |
| `SERVER_ERROR` | 500 | Unexpected server error |

---

## APPENDIX: Authentication Flow Diagram

```
[Flutter App]
      |
      | 1. POST /auth/login (email/password)
      |    OR POST /auth/google (idToken)
      |    OR POST /auth/apple (identityToken)
      |    OR POST /auth/facebook (accessToken)
      |    OR POST /auth/anonymous (deviceId)
      v
[Backend]
      |
      | 2. Verify credentials/token with provider
      | 3. Create/fetch user
      | 4. Set trial_started_at if new user
      | 5. Generate JWT access + refresh tokens
      | 6. Hash refresh token, store in DB
      | 7. Log in audit_logs
      v
[Return tokens to app]
      |
      | 8. App stores tokens in FlutterSecureStorage
      | 9. Include access token in Authorization header for all requests
      |
      | ... 15 minutes later (access token expires) ...
      |
      | 10. API returns 401 Unauthorized
      | 11. App auto-calls POST /auth/refresh with refresh token
      v
[Backend]
      |
      | 12. Verify refresh token hash in DB
      | 13. Generate new access + refresh tokens
      | 14. Delete old refresh token hash
      | 15. Insert new refresh token hash
      v
[Return new tokens]
      |
      | 16. App updates stored tokens
      | 17. Retry failed request with new access token
```

---

**Next:** Backend implementation, security documentation, and deployment guide
