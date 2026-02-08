# Lingola Travel Backend

Backend API server for Lingola Travel language learning application.

## 🚀 Quick Start

### Prerequisites
- Node.js >= 18.0.0
- MySQL >= 8.0
- npm >= 9.0.0

### Installation

1. **Install Dependencies**
```bash
cd backend
npm install
```

2. **Configure Environment**
```bash
cp .env.example .env
# Edit .env with your MySQL credentials and API keys
```

3. **Create Database**
```bash
mysql -u root -p
```
```sql
CREATE DATABASE lingola_travel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

4. **Run Migrations**
```bash
# Execute all migration files in order
mysql -u root -p lingola_travel < database/migrations/001_create_users_table.sql
mysql -u root -p lingola_travel < database/migrations/002_create_refresh_tokens_table.sql
# ... continue with all migrations in order
```

Or use the migration script:
```bash
node src/utils/migrate.js
```

5. **Seed Database**
```bash
mysql -u root -p lingola_travel < database/migrations/020_seed_courses.sql
mysql -u root -p lingola_travel < database/migrations/021_seed_dictionary_categories.sql
mysql -u root -p lingola_travel < database/migrations/022_seed_app_settings.sql
```

6. **Start Development Server**
```bash
npm run dev
```

The server will start at `http://localhost:3000`

---

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/
│   │   └── database.js          # MySQL connection pool
│   ├── controllers/
│   │   └── authController.js    # Authentication logic
│   ├── middleware/
│   │   ├── auth.js              # JWT verification
│   │   ├── validator.js         # Request validation
│   │   └── rateLimiter.js       # Rate limiting
│   ├── routes/
│   │   └── auth.js              # Authentication routes
│   ├── utils/
│   │   ├── jwt.js               # JWT utilities
│   │   ├── response.js          # Standard responses
│   │   └── socialAuth.js        # Social login verification
│   └── server.js                # Express app entry point
├── database/
│   └── migrations/              # SQL migration files
├── .env.example                 # Environment template
├── package.json
└── README.md
```

---

## 🔧 Configuration

### Required Environment Variables

Edit `.env` file:

```bash
# Database
DB_HOST=localhost
DB_PORT=3306
DB_NAME=lingola_travel
DB_USER=root
DB_PASSWORD=your_mysql_password

# JWT Tokens
JWT_SECRET=your_secure_random_string
JWT_REFRESH_SECRET=another_secure_random_string

# Google OAuth (optional)
GOOGLE_CLIENT_ID_IOS=your_google_client_id
GOOGLE_CLIENT_ID_ANDROID=your_google_client_id
```

Generate secure secrets:
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

---

## 📡 API Endpoints

### Authentication

All endpoints return standard format:
```json
{
  "success": true/false,
  "data": { /* response data */ },
  "error": { "code": "ERROR_CODE", "message": "..." }
}
```

#### POST `/api/v1/auth/login`
Email/password login

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": { /* user object */ },
    "accessToken": "jwt_token",
    "refreshToken": "refresh_token"
  }
}
```

#### POST `/api/v1/auth/google`
Google Sign-In

**Request:**
```json
{
  "idToken": "google_id_token"
}
```

#### POST `/api/v1/auth/anonymous`
Anonymous/Guest login

**Request:**
```json
{
  "deviceId": "unique_device_identifier"
}
```

#### POST `/api/v1/auth/refresh`
Refresh access token

**Request:**
```json
{
  "refreshToken": "current_refresh_token"
}
```

#### POST `/api/v1/auth/logout`
Logout (invalidate tokens)

**Request:**
```json
{
  "refreshToken": "current_refresh_token"
}
```

---

## 🔒 Security Features

- ✅ JWT access tokens (15 min expiry)
- ✅ Refresh token rotation (7 day expiry)
- ✅ Bcrypt password hashing (cost: 12)
- ✅ Refresh tokens hashed in database
- ✅ Rate limiting (5 auth attempts / 15 min)
- ✅ Helmet.js security headers
- ✅ CORS configuration
- ✅ SQL injection prevention (parameterized queries)
- ✅ Audit logging

---

## 🗄️ Database Schema

See [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) for complete schema documentation.

**Core Tables:**
- `users` - User accounts
- `refresh_tokens` - JWT refresh tokens (hashed)
- `user_onboarding` - Onboarding preferences
- `courses` - Language courses
- `lessons` - Course lessons
- `dictionary_words` - Dictionary entries
- `user_course_progress` - Progress tracking
- `bookmarks` - User bookmarks
- `library_folders` - User collections

---

## 🧪 Testing

```bash
npm test
```

---

## 📝 API Documentation

Full API documentation available at:
- [API_DESIGN.md](./API_DESIGN.md) - Complete endpoint reference
- [AUDIT_REPORT.md](./AUDIT_REPORT.md) - Requirements analysis

---

## 🚨 Troubleshooting

### Database Connection Failed
```bash
# Check MySQL is running
mysql --version

# Test connection
mysql -u root -p

# Verify .env credentials
cat .env | grep DB_
```

### Port Already in Use
```bash
# Change PORT in .env
PORT=3001
```

### JWT Token Errors
Ensure `JWT_SECRET` and `JWT_REFRESH_SECRET` are set in `.env`

---

## 📦 Deployment

### Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Configure production database
- [ ] Set secure CORS_ORIGINS
- [ ] Enable HTTPS
- [ ] Configure reverse proxy (nginx)
- [ ] Set up process manager (PM2)
- [ ] Configure backup strategy
- [ ] Set up monitoring (logs, errors)
- [ ] Review rate limits
- [ ] Test all social auth providers

---

## 🔐 Security & Privacy

See [SECURITY_PRIVACY.md](./SECURITY_PRIVACY.md) for:
- Password requirements
- Token management
- PII handling
- Logging policies
- Compliance guidelines

---

## 📄 License

PROPRIETARY - All rights reserved

---

## 👥 Support

For technical issues, contact: dev@lingolatravel.com

---

**Last Updated:** February 8, 2026
