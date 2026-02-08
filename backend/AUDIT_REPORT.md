# BACKEND ARCHITECTURE & DATABASE DESIGN

## CRITICAL AUDIT REPORT
**Generated:** February 8, 2026  
**Source:** Flutter Repository Analysis  
**Method:** Systematic screen/repository/service/model scanning

---

## PART A: FLUTTER APP AUDIT - SCREENS INVENTORY

### 1. SPLASH & ONBOARDING FLOW
| File Path | Screen Purpose | Data Captured |
|-----------|---------------|---------------|
| `lib/View/SplashView/splash_view.dart` | Initial app loading | None |
| `lib/View/SplashView/splash_page_view.dart` | Intro carousel (3 slides) | None (UI only) |
| `lib/View/OnboardingView/sign_in_view.dart` | Social login/guest entry | Auth provider selection |
| `lib/View/OnboardingView/language_selection_view.dart` | Target language selection (Step 1/4) | `target_language` (11 options: en, de, it, fr, ja, es, ru, tr, ko, hi, pt) |
| `lib/View/OnboardingView/profession_selection_view.dart` | User profession (Step 2/4) | `profession` (Student, Professional, Technology, Healthcare, Arts & Media, Other) |
| `lib/View/OnboardingView/profession_detail_view.dart` | Detailed profession info | Optional: `profession_details` |
| `lib/View/OnboardingView/english_level_selection_view.dart` | Language proficiency (Step 3/4) | `english_level` (Beginner, Elementary, Intermediate, Upper-Intermediate) |
| `lib/View/OnboardingView/daily_goal_selection_view.dart` | Daily study goal (Step 4/4) | `daily_goal` (Casual: 5min, Regular: 15min, Serious: 30min) |
| `lib/View/OnboardingView/creating_plan_view.dart` | Loading/plan generation | None (transition screen) |

### 2. HOME & NAVIGATION
| File Path | Screen Purpose | Data Displayed |
|-----------|---------------|----------------|
| `lib/View/HomeView/home_view.dart` | Main dashboard | User greeting, quick phrasebook, features, course cards, premium status |
| `lib/View/HomeView/premium_home_view.dart` | Premium variant | Same as above but unlocked content |
| `lib/Widgets/Common/custom_bottom_nav_bar.dart` | Bottom navigation | 5 tabs: Home, Travel Vocab, Dictionary, Library, Profile |

### 3. COURSE SYSTEM
| File Path | Screen Purpose | Data Displayed/Modified |
|-----------|---------------|------------------------|
| `lib/View/CourseView/course_view.dart` | Course listing | 11 course categories with progress, isUnlocked status |
| `lib/View/CourseView/course_detail_view.dart` | Course details & lessons | Lesson list, prerequisites, completion % |
| `lib/View/LessonView/lesson_detail_view.dart` | Interactive lesson | Step progress, vocabulary terms, audio controls, bookmarks, recording |
| `lib/View/LessonView/lesson_result_view.dart` | Lesson completion | Score, XP earned, next lesson |

**Course Categories (hardcoded in UI):**
- General: Daily Conversation (12 lessons, unlocked)
- Trip: Terminal Talk (12 lessons, 65% progress)
- Food & Drink: Place an order (12 lessons, locked)
- Accommodation: I have a reservation (12 lessons, locked)
- Culture: How can I get there? (12 lessons, locked)
- Shopping: How much is this? (12 lessons, locked)
- Direction & Navigation (12 lessons, locked)
- Sport: Is there a gym? (12 lessons, locked)
- Health: Where is the pharmacy? (12 lessons, locked)
- Business: We have a meeting (12 lessons, locked)
- Emergency: Call the police (12 lessons, locked)

### 4. DICTIONARY & VOCABULARY
| File Path | Screen Purpose | Data Displayed/Modified |
|-----------|---------------|------------------------|
| `lib/View/DictionaryView/visual_dictionary_view.dart` | Dictionary home | 10 categories, recent searches |
| `lib/View/DictionaryView/dictionary_category_view.dart` | Category words | Word list with images/audio |
| `lib/View/VocabularyView/travel_vocabulary_view.dart` | Travel phrases | Words/Phrases tabs, bookmarks, category filters (11 categories) |

**Dictionary Categories:**
- Airport (1240 items)
- Accommodation (1000 items)
- Transportation (980 items)
- Food & Drink (1250 items)
- Shopping (1520 items)
- Culture (550 items)
- Meeting (1520 items)
- Sport (1550 items)
- Health (1520 items)
- Business (1550 items)

### 5. LIBRARY (USER COLLECTIONS)
| File Path | Screen Purpose | Data Displayed/Modified |
|-----------|---------------|------------------------|
| `lib/View/LibraryView/library_view.dart` | User's saved folders | 10 predefined folder templates, item counts |
| `lib/View/LibraryView/library_folder_detail_view.dart` | Folder contents | Saved words/phrases |

**Library Folders (user collections):**
- My Airport Essentials (12 items)
- My Hotel Essentials (20 items)
- Transport Essentials (35 items)
- My Food Essentials (8 items)
- My Shopping Essentials (21 items)
- Culture Essentials (10 items)
- Meeting Essentials (32 items)
- Sport Essentials (18 items)
- Health Essentials (8 items)
- Business Essentials (5 items)

### 6. PROFILE & SETTINGS
| File Path | Screen Purpose | Data Displayed/Modified |
|-----------|---------------|------------------------|
| `lib/View/ProfileView/profile_view.dart` | User profile | Avatar, name, stats (streak, lessons, XP), settings menu |
| `lib/View/ProfileView/profile_settings_view.dart` | Account settings | Email, name, password, account deletion |
| `lib/View/ProfileView/premium_view.dart` | Paywall/subscription | Premium features, trial status, purchase |
| `lib/View/ProfileView/app_language_view.dart` | App UI language | Language selection for app interface |
| `lib/View/ProfileView/faq_view.dart` | Help/FAQ | Static content |
| `lib/View/ProfileView/share_friend_view.dart` | Referral | Referral code generation |

### 7. NOTIFICATIONS
| File Path | Screen Purpose | Data Displayed/Modified |
|-----------|---------------|------------------------|
| `lib/View/NotificationsView/notifications_view.dart` | Notification list | Push notifications, premium prompts |

---

## PART B: REPOSITORIES & SERVICES ANALYSIS

### 1. Authentication Repository
**File:** `lib/Repositories/auth_repository.dart`

**Expected Endpoints:**
| Method | Endpoint | Request | Response |
|--------|----------|---------|----------|
| POST | `/auth/login` | `{email, password}` | `{success, user, accessToken, refreshToken}` |
| POST | `/auth/google` | `{idToken}` | `{success, user, accessToken, refreshToken}` |
| POST | `/auth/apple` | `{identityToken}` | `{success, user, accessToken, refreshToken}` |
| POST | `/auth/facebook` | `{accessToken}` | `{success, user, accessToken, refreshToken}` |
| POST | `/auth/anonymous` | `{deviceId}` | `{success, user, accessToken, refreshToken}` |
| POST | `/auth/refresh` | `{refreshToken}` | `{success, accessToken, refreshToken}` |
| POST | `/auth/logout` | `{refreshToken}` | `{success}` |
| POST | `/user/onboarding` | `{onboarding_data}` | `{success}` |

### 2. Base Repository
**File:** `lib/Repositories/base_repository.dart`

- Centralized error handling
- Standard API response format: `{success, data, error}`
- Error codes: TIMEOUT, NO_CONNECTION, UNAUTHORIZED, FORBIDDEN, NOT_FOUND, VALIDATION_ERROR, SERVER_ERROR

### 3. API Client
**File:** `lib/Services/api_client.dart`

**Configuration:**
- Base URL: `http://localhost:3000/api/v1` (from AppConfig)
- Timeout: 30 seconds
- JWT Bearer tokens in Authorization header
- Auto token refresh on 401 (TODO in code)

### 4. External Services
| Service | File | Purpose |
|---------|------|---------|
| OneSignal | `lib/Services/onesignal_service.dart` | Push notifications |
| RevenueCat | `lib/Services/revenuecat_service.dart` | Subscription management (post-approval) |
| Secure Storage | `lib/Services/secure_storage_service.dart` | Token/credential storage |

---

## PART C: DATA MODELS DISCOVERED

### 1. UserModel
**File:** `lib/Models/user_model.dart`

```dart
{
  id: String (primary key)
  email: String? (nullable)
  name: String? (nullable)
  photoUrl: String? (nullable)
  phoneNumber: String? (nullable)
  isAnonymous: Boolean (default: false)
  isPremium: Boolean (default: false)
  premiumExpiresAt: DateTime? (nullable)
  trialStartedAt: DateTime? (nullable)
  createdAt: DateTime (required)
  updatedAt: DateTime (required)
}
```

**Business Logic Methods:**
- `isTrialActive`: Trial active if < 1 day since `trialStartedAt`
- `hasPremiumAccess`: True if `isPremium` OR `isTrialActive`

### 2. Language Model
**File:** `lib/Models/language.dart`

11 supported languages with localized names (static data, client-side only)

### 3. Implicit Models (from UI screens)

**CourseModel (not found as file, derived from UI):**
```dart
{
  id: String
  category: String (11 predefined categories)
  title: String
  description: String
  lessons: Integer (always 12)
  image: String (asset path)
  order: Integer
}
```

**LessonModel (derived from UI):**
```dart
{
  id: String
  course_id: String (FK)
  title: String
  order: Integer
  total_steps: Integer (e.g., 10)
  vocabulary_items: Array<VocabularyItem>
  audio_url: String
  image_url: String
}
```

**VocabularyItem (derived from UI):**
```dart
{
  id: String
  term: String
  definition: String
  icon_path: String (SVG)
  icon_color: String (hex)
  audio_url: String
  category: String
}
```

**UserProgress (derived from UI):**
```dart
{
  user_id: String (FK)
  course_id: String (FK)
  lesson_id: String (FK)
  progress_percentage: Integer (0-100)
  current_step: Integer
  completed: Boolean
  last_accessed: DateTime
}
```

**Bookmark (derived from UI):**
```dart
{
  user_id: String (FK)
  item_type: Enum (lesson_vocabulary, dictionary_word, travel_phrase)
  item_id: String
  created_at: DateTime
}
```

**LibraryFolder (derived from UI):**
```dart
{
  id: String
  user_id: String (FK)
  name: String
  icon: String
  color: String (hex)
  item_count: Integer (computed)
}
```

**LibraryItem (derived from UI):**
```dart
{
  id: String
  folder_id: String (FK)
  vocabulary_id: String (FK) OR phrase_id: String (FK)
  created_at: DateTime
}
```

**Notification (derived from UI):**
```dart
{
  id: String
  user_id: String (FK)
  icon: String (emoji)
  title: String
  message: String
  time: DateTime
  is_premium_promo: Boolean (sticky for free users)
  is_read: Boolean
}
```

**RecentSearch (derived from UI):**
```dart
{
  user_id: String (FK)
  search_query: String
  category: String (dictionary category)
  created_at: DateTime
}
```

**OnboardingData (derived from UI):**
```dart
{
  user_id: String (FK, primary)
  target_language: String (en, de, it, fr, ja, es, ru, tr, ko, hi, pt)
  profession: String (Student, Professional, Technology, Healthcare, Arts & Media, Other)
  english_level: String (Beginner, Elementary, Intermediate, Upper-Intermediate)
  daily_goal: String (Casual, Regular, Serious) OR minutes: Integer (5, 15, 30)
  completed_at: DateTime
}
```

---

## PART D: DATA REQUIREMENTS MATRIX

| Screen/Feature | Data Created | Data Read | Data Updated | Data Deleted | Server Persistence Required? |
|----------------|-------------|-----------|--------------|--------------|----------------------------|
| Sign In | User account, auth tokens | - | - | - | ✅ YES |
| Onboarding (Steps 1-4) | Onboarding preferences | - | Onboarding data | - | ✅ YES (user profile enrichment) |
| Home View | - | User profile, Course list, Progress | - | - | ✅ YES (dynamic content) |
| Course View | - | Courses, User progress | - | - | ✅ YES |
| Course Detail | - | Lessons, Progress | - | - | ✅ YES |
| Lesson Detail | Lesson progress | Lesson data, Vocabulary | Current step, Progress % | - | ✅ YES (progress tracking) |
| Lesson Result | Completion record, XP | Result data | User XP, stats | - | ✅ YES |
| Dictionary View | Recent search | Categories, Recent searches | - | Clear searches | ✅ YES (search history) |
| Dictionary Category | - | Dictionary words | - | - | ✅ YES |
| Travel Vocabulary | Bookmarks | Words, Phrases | Bookmarks toggle | Bookmarks | ✅ YES |
| Library View | Folders | User folders, Item counts | - | - | ✅ YES (user collections) |
| Library Folder Detail | Library items | Folder contents | - | Item removal | ✅ YES |
| Profile View | - | User stats (streak, lessons, XP) | - | - | ✅ YES (computed stats) |
| Profile Settings | - | User profile | Name, email, password | Account (future) | ✅ YES |
| Premium View | Subscription purchase | Trial/premium status | Premium status | - | ✅ YES (critical for trial gating) |
| Notifications | - | Notification list | Mark read | Delete notifications | ✅ YES |

---

## PART E: PREMIUM TRIAL & GATING REQUIREMENTS

⚠️ **CRITICAL BUSINESS LOGIC:**

From `lib/Models/user_model.dart`:
```dart
bool get isTrialActive {
  if (trialStartedAt == null) return false;
  final trialEnd = trialStartedAt!.add(const Duration(days: 1));
  return DateTime.now().isBefore(trialEnd);
}

bool get hasPremiumAccess {
  return isPremium || isTrialActive;
}
```

**Implementation Rules:**
1. Trial starts on user registration (`trialStartedAt = NOW`)
2. Trial lasts exactly **1 day** (24 hours)
3. After trial expires AND user is not subscribed (`isPremium = false`):
   - App must show paywall on launch
   - Locked courses remain locked
   - Dictionary/vocabulary may be limited (check UI for specifics)
4. Premium subscription sets `isPremium = true` + `premiumExpiresAt`
5. RefreshToken rotation prevents token theft during trial

---

## PART F: AUTHENTICATION FLOW REQUIREMENTS

### Social Auth Providers
| Provider | Client Integration | Backend Verification |
|----------|-------------------|---------------------|
| Google | `google_sign_in` Flutter plugin | Verify `idToken` against Google API |
| Apple | `sign_in_with_apple` Flutter plugin | Verify `identityToken` against Apple API |
| Facebook | `flutter_facebook_auth` plugin | Verify `accessToken` against Facebook Graph API |
| Anonymous | Device ID generation | Create temp user with `isAnonymous = true` |

### Token Strategy
- **Access Token:** Short-lived (15 minutes), JWT
- **Refresh Token:** Long-lived (7 days), stored hashed in DB
- **Storage:** Flutter Secure Storage (encrypted on device)
- **Rotation:** Refresh token must rotate on every refresh

---

## PART G: MISSING/AMBIGUOUS AREAS (TODO NOTES)

These areas have UI mockups but lack backend endpoints:

1. **Content Management:**
   - No repository for fetching courses/lessons/vocabulary
   - TODO: Create `ContentRepository` with endpoints for:
     - GET `/courses` (list all courses)
     - GET `/courses/:id/lessons` (lessons for a course)
     - GET `/lessons/:id` (lesson details with vocabulary)
     - GET `/dictionary/:category` (words by category)
     - GET `/vocabulary/phrases` (travel phrases)

2. **Progress Tracking:**
   - No repository for saving/fetching user progress
   - TODO: Create `ProgressRepository` with endpoints for:
     - POST `/progress/lesson` (save lesson progress)
     - GET `/progress/courses` (get user's course progress)
     - PATCH `/progress/lesson/:id` (update step/completion)

3. **Bookmarks & Library:**
   - No repository for user collections
   - TODO: Create `LibraryRepository` with endpoints for:
     - POST `/library/bookmark` (bookmark item)
     - DELETE `/library/bookmark/:id` (remove bookmark)
     - GET `/library/folders` (user folders)
     - POST `/library/folders` (create folder)
     - POST `/library/folders/:id/items` (add item to folder)
     - DELETE `/library/folders/:id/items/:itemId` (remove from folder)

4. **Notifications:**
   - OneSignal integration exists, but no custom notification management
   - TODO: Create `/notifications` endpoints if app-specific notifications needed beyond OneSignal

5. **User Profile & Stats:**
   - No repository for profile updates or stat calculation
   - TODO: Create `UserRepository` with endpoints for:
     - GET `/user/profile` (fetch user details)
     - PATCH `/user/profile` (update name, email)
     - GET `/user/stats` (compute streak, lessons completed, XP)
     - POST `/user/change-password`

6. **Search History:**
   - Recent searches in Dictionary view
   - TODO: Decide if stored server-side or local-only
   - Recommendation: Local-only (no server persistence)

---

## PART H: CONTENT SEEDING REQUIREMENTS

The UI shows these categories/courses as hardcoded. Backend must provide:

### Courses to Seed (11 courses × 12 lessons each = 132 lessons)
1. General → Daily Conversation
2. Trip → Terminal Talk
3. Food & Drink → Place an order
4. Accommodation → I have a reservation
5. Culture → Cultural phrases
6. Shopping → How much is this?
7. Direction & Navigation → How can I get there?
8. Sport → Is there a gym?
9. Health → Where is the pharmacy?
10. Business → We have a meeting
11. Emergency → Call the police

### Dictionary Categories to Seed
10 categories with ~1,000-1,500 words each (total ~13,000 words)

**TODO:** Content team must provide:
- Course/lesson JSON with translations, audio URLs, images
- Dictionary word lists with definitions, audio, images
- Phrasebook categories with question/answer pairs

---

## PART I: SECURITY & PRIVACY NOTES

From `.env.example` and code analysis:

**Sensitive Data to Protect:**
- User email, name, phone (PII)
- Social auth tokens (never store raw)
- RefreshTokens (hash with bcrypt/argon2)
- Device IDs for anonymous users
- Search history (potentially revealing)

**Required Security Measures:**
1. All passwords hashed with bcrypt (minimum cost: 12)
2. RefreshTokens hashed before DB storage
3. Social auth tokens validated server-side, never trusted from client
4. Rate limiting on `/auth/*` endpoints (max 5 attempts/15 min)
5. HTTPS only in production
6. SQL injection prevention (parameterized queries)
7. XSS prevention (sanitize user input if any UGC)
8. CORS configured for Flutter app domains only

**Logging:**
- Never log tokens, passwords, or PII
- Log auth attempts (IP, timestamp, success/fail)
- Log trial start/expiration events
- Log premium purchases for Revenue Cat reconciliation

---

## SUMMARY: BACKEND DEVELOPMENT SCOPE

### ✅ CONFIRMED REQUIREMENTS
1. Authentication API (email, Google, Apple, Facebook, anonymous)
2. User management (profile, onboarding, stats)
3. Content API (courses, lessons, dictionary, vocabulary)
4. Progress tracking (lesson completion, course progress)
5. Library/bookmarks (user collections)
6. Premium/trial enforcement (1-day trial, subscription checks)
7. Notifications (integration with OneSignal)
8. MySQL database with proper indexing
9. JWT token management with refresh rotation

### ❌ OUT OF SCOPE (Client-Side Only)
- App UI language selection (static, no server sync)
- Intro carousel slides (static assets)
- Audio playback controls (client-side only)

### 🔧 TOOLING DECISIONS
- **Backend Framework:** Node.js + Express (as specified)
- **Database ORM:** Prisma (recommended) OR mysql2 raw SQL
- **Database Hosting:** MySQL via phpMyAdmin (as specified)
- **Token Library:** jsonwebtoken (JWT)
- **Password Hashing:** bcrypt
- **Social Auth Verification:** google-auth-library, apple-signin-auth, axios (Facebook Graph API)
- **Push Notifications:** OneSignal REST API integration

---

**END OF AUDIT REPORT**

Next steps: Generate Data Requirements Matrix → Database Schema → API Design → Implementation
