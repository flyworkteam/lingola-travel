# SECURITY & PRIVACY DOCUMENTATION

**Application:** Lingola Travel Backend API  
**Last Updated:** February 8, 2026  
**Classification:** CONFIDENTIAL

---

## TABLE OF CONTENTS
1. [Authentication Security](#1-authentication-security)
2. [Password Management](#2-password-management)
3. [Token Security](#3-token-security)
4. [Data Encryption](#4-data-encryption)
5. [PII Handling](#5-pii-handling)
6. [Logging & Audit](#6-logging--audit)
7. [Rate Limiting & DoS Protection](#7-rate-limiting--dos-protection)
8. [Social Auth Security](#8-social-auth-security)
9. [Database Security](#9-database-security)
10. [Compliance & GDPR](#10-compliance--gdpr)

---

## 1. AUTHENTICATION SECURITY

### Multi-Provider Authentication
**Supported Methods:**
- Email/Password (bcrypt hashed)
- Google OAuth 2.0
- Apple Sign In
- Facebook Login
- Anonymous/Guest (device-based)

### Security Requirements
✅ **IMPLEMENTED:**
- JWT-based stateless authentication
- Access token expiry: 15 minutes
- Refresh token expiry: 7 days
- Token rotation on refresh
- Refresh tokens hashed in database (bcrypt, cost 10)
- Rate limiting: Max 5 login attempts per 15 minutes per IP

❌ **NOT IMPLEMENTED (TODO):**
- Two-factor authentication (2FA)
- Account lockout after failed attempts
- Email verification for email/password signup
- Password reset flow

---

## 2. PASSWORD MANAGEMENT

### Password Requirements
**Minimum Standards:**
- Length: 8 characters minimum
- Complexity: No specific requirements yet (TODO: enforce)
- History: No password reuse check (TODO)

**Current Implementation:**
```javascript
// Password hashing
const saltRounds = 12;
const hash = await bcrypt.hash(password, saltRounds);
```

### Password Storage
- ✅ Passwords NEVER stored in plaintext
- ✅ Bcrypt hashing with cost factor 12
- ✅ Password hash stored in `users.password_hash`
- ✅ Original password discarded after hashing

### Password Reset
⚠️ **NOT YET IMPLEMENTED**

**Planned Flow:**
1. User requests password reset via email
2. Generate secure one-time token (valid 1 hour)
3. Send reset link to verified email
4. User submits new password
5. Invalidate all existing refresh tokens
6. Log password change in audit_logs

---

## 3. TOKEN SECURITY

### Access Tokens (JWT)
**Structure:**
```json
{
  "userId": "uuid",
  "type": "access",
  "iat": 1234567890,
  "exp": 1234568790
}
```

**Security Measures:**
- ✅ Signed with `JWT_SECRET` (512-bit random)
- ✅ Short-lived (15 minutes)
- ✅ Stateless (no database check required)
- ✅ Transmitted via `Authorization: Bearer` header
- ✅ HTTPS-only in production

### Refresh Tokens (JWT)
**Structure:**
```json
{
  "userId": "uuid",  
  "type": "refresh",
  "jti": "unique_token_id",
  "iat": 1234567890,
  "exp": 1235172690
}
```

**Security Measures:**
- ✅ Signed with separate `JWT_REFRESH_SECRET`
- ✅ Long-lived (7 days)
- ✅ **NEVER stored in plaintext**
- ✅ Hashed with bcrypt before database storage
- ✅ One-time use (rotation on refresh)
- ✅ Revoked on logout
- ✅ Automatic expiration cleanup

**Token Rotation Flow:**
```
1. Client sends refreshToken
2. Server verifies signature
3. Server checks hash in database
4. If valid: Generate NEW access + refresh tokens
5. Delete OLD refresh token hash
6. Store NEW refresh token hash
7. Return new tokens to client
```

### Token Revocation
**Methods:**
- Logout: DELETE from `refresh_tokens` table
- Password change: DELETE all user's refresh tokens
- Suspicious activity: Manual admin revocation (TODO)

---

## 4. DATA ENCRYPTION

### In Transit
✅ **Production Requirements:**
- HTTPS/TLS 1.3 mandatory
- Valid SSL certificate
- HSTS headers enabled
- Strict CORS policy

❌ **Development:**
- HTTP allowed for localhost only

### At Rest
**Database Encryption:**
- ⚠️ Database-level encryption NOT enabled (MySQL default)
- 📋 **RECOMMENDATION:** Enable MySQL transparent data encryption (TDE) for production

**Sensitive Fields:**
| Field | Encryption Method | Notes |
|-------|------------------|-------|
| `users.password_hash` | Bcrypt (cost 12) | One-way hash |
| `refresh_tokens.token_hash` | Bcrypt (cost 10) | One-way hash |
| `users.email` | Plaintext | ⚠️ Consider encryption at rest |
| `users.external_auth_id` | Plaintext | Social provider IDs (non-sensitive) |

**File Storage:**
- Audio files: No encryption (public CDN)
- Images: No encryption (public CDN)
- User uploads: N/A (no user upload feature)

---

## 5. PII HANDLING

### Personal Information Collected
| Data Type | Required | Purpose | Retention |
|-----------|----------|---------|-----------|
| Email | Optional | Account recovery, communication | Until account deletion |
| Name | Optional | Personalization | Until account deletion |
| Photo URL | Optional | Profile display | Until removed by user |
| Phone Number | Optional | Future feature | Until removed by user |
| Device ID | Anonymous only | Anonymous account tracking | Until account deletion |
| IP Address | All | Audit logging, fraud prevention | 90 days |
| Search History | All | Personalization | Until cleared by user |
| Progress Data | All | Learning analytics | Until account deletion |

### Data Minimization
- ✅ Anonymous users: NO email, name, or phone required
- ✅ Social login: Email optional (user consent)
- ✅ Onboarding data: Preferences only, no identifiable info

### User Rights (GDPR/CCPA)
**Implemented:**
- ❌ Right to access (data export) - TODO
- ❌ Right to deletion (account removal) - TODO
- ✅ Right to rectification (profile update) - PARTIAL
- ❌ Right to portability (data export) - TODO

**Data Deletion:**
Planned implementation:
```sql
-- On account deletion request
DELETE FROM users WHERE id = ?;
-- CASCADE deletes:
-- - refresh_tokens
-- - user_onboarding
-- - user_stats
-- - user_course_progress
-- - user_lesson_progress
-- - bookmarks
-- - library_folders (+ library_items)
-- - recent_searches
-- - notifications
```

### Third-Party Data Sharing
| Service | Data Shared | Purpose |
|---------|-------------|---------|
| Google OAuth | idToken (verified server-side) | Authentication |
| Apple Sign In | identityToken (verified) | Authentication |
| Facebook Login | accessToken (verified) | Authentication |
| OneSignal | User ID, device token | Push notifications |
| RevenueCat | User ID, purchase info | Subscription management |

⚠️ **CRITICAL:** No PII shared with third parties without user consent.

---

## 6. LOGGING & AUDIT

### Audit Logging
**Table:** `audit_logs`

**Logged Events:**
```javascript
{
  user_id: 'uuid',
  action: 'login|logout|google_login|premium_purchase|trial_start',
  ip_address: '192.168.1.1',
  user_agent: 'Mozilla/5.0...',
  metadata: { /* contextual data */ },
  created_at: '2026-02-08 10:00:00'
}
```

**Logged Actions:**
- ✅ Authentication events (login, logout, signup)
- ✅ Social auth provider used
- ❌ Failed login attempts (TODO)
- ❌ Premium purchases (TODO)
- ❌ Password changes (TODO)
- ❌ Account deletions (TODO)

### What NOT to Log
❌ **NEVER log:**
- Passwords (plaintext or hashed)
- JWT tokens (access or refresh)
- Social auth tokens (idToken, accessToken)
- Credit card numbers
- Full email addresses in error messages (use masked: u***@example.com)

### Log Retention
- Audit logs: 1 year (compliance requirement)
- Application logs: 30 days
- Error logs: 90 days

### Log Access
- Restricted to: DevOps team, Security team
- Audit trail on log access (TODO)

---

## 7. RATE LIMITING & DoS PROTECTION

### Rate Limits by Endpoint Category
| Endpoint | Window | Max Requests | Action on Exceed |
|----------|--------|--------------|------------------|
| `/auth/*` | 15 min | 5 per IP | HTTP 429, retry after 15 min |
| `/api/v1/*` (general) | 1 min | 100 per user | HTTP 429, retry after 1 min |

### Implementation
```javascript
// Authentication endpoints (strict)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5,
  message: 'Too many login attempts. Try again in 15 minutes.'
});

// General API endpoints
const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute  
  max: 100
});
```

### DDoS Protection
⚠️ **Application-level only** (Express rate limiter)

📋 **RECOMMENDED for Production:**
- Cloudflare or AWS WAF
- Infrastructure-level DDoS mitigation
- IP reputation checking

---

## 8. SOCIAL AUTH SECURITY

### Google OAuth 2.0
**Verification Process:**
1. Client sends `idToken` from Google Sign-In SDK
2. Server verifies with `google-auth-library`:
   ```javascript
   const ticket = await client.verifyIdToken({
     idToken: idToken,
     audience: [IOS_CLIENT_ID, ANDROID_CLIENT_ID, WEB_CLIENT_ID]
   });
   ```
3. Extract verified user info (`sub`, `email`, `name`)
4. Check `email_verified` claim (must be true)
5. Never trust client-provided user data without verification

**Security Measures:**
- ✅ Token verified server-side (NOT trusted from client)
- ✅ Audience validation (client IDs)
- ✅ Expiration check (automatic)
- ✅ Issuer validation (Google)

### Apple Sign In
**Verification Process:**
1. Client sends `identityToken` + `authorizationCode`
2. Server verifies with Apple's public keys:
   ```javascript
   const claims = await appleSignin.verifyIdToken(identityToken, {
     audience: APPLE_CLIENT_ID
   });
   ```
3. Extract `sub` (unique Apple user ID)
4. Email may be null after first login (user privacy)

**Privacy Considerations:**
- ✅ Email may be hidden (privacy relay)
- ✅ Name only provided on first sign-in
- ✅ Subsequent logins: Only `sub` guaranteed

### Facebook Login
**Verification Process:**
1. Client sends `accessToken` from Facebook SDK
2. Server verifies with Facebook Graph API:
   ```javascript
   GET /debug_token?input_token={token}&access_token={app_token}
   ```
3. Check `is_valid` and `user_id`
4. Fetch user profile: `GET /me?fields=id,email,name,picture`

**Security Measures:**
- ✅ Token validated against Facebook servers
- ✅ App access token used for verification
- ⚠️ Facebook email may be null (user permission)

---

## 9. DATABASE SECURITY

### MySQL Configuration
**Current:**
- Database: `lingola_travel`
- Charset: `utf8mb4` (full Unicode support)
- Collation: `utf8mb4_unicode_ci`
- Engine: InnoDB (ACID compliance)

**Security Hardening (TODO):**
```sql
-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Remove remote root
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1');

-- Change root password
ALTER USER 'root'@'localhost' IDENTIFIED BY 'SecurePassword123!';

-- Create application-specific user (least privilege)
CREATE USER 'lingola_app'@'localhost' IDENTIFIED BY 'SecureAppPassword!';
GRANT SELECT, INSERT, UPDATE, DELETE ON lingola_travel.* TO 'lingola_app'@'localhost';
FLUSH PRIVILEGES;
```

### SQL Injection Prevention
✅ **All queries use parameterized statements:**
```javascript
// SAFE (parameterized)
await query('SELECT * FROM users WHERE email = ?', [email]);

// UNSAFE (never do this!)
await query(`SELECT * FROM users WHERE email = '${email}'`);
```

### Database Access Control
- Application user: `lingola_app` (SELECT, INSERT, UPDATE, DELETE only)
- Admin user: `root` (full access, local only)
- No external access: Firewall blocks port 3306 from internet

### Backup & Recovery
📋 **TODO: Implement backup strategy**
- Daily automated backups
- 30-day retention
- Encrypted backup storage
- Tested disaster recovery plan

---

## 10. COMPLIANCE & GDPR

### GDPR Requirements
**Legal Basis for Processing:**
- User consent (opt-in for marketing emails)
- Contract performance (service delivery)
- Legitimate interest (fraud prevention)

**Data Controller:**
- Lingola Travel (Company information TODO)

**Data Processors:**
- Google Cloud (Google OAuth)
- Apple (Apple Sign In)
- Meta (Facebook Login)
- OneSignal (Push notifications)
- RevenueCat (Subscriptions)

### Privacy Policy Requirements
📋 **MUST include:**
- What data is collected
- How data is used
- Third-party data sharing
- User rights (access, deletion, portability)
- Data retention periods
- Contact information for privacy inquiries

### Cookie Policy
⚠️ **No cookies used** (API-only, JWT in Authorization header)

### Children's Privacy (COPPA)
- ⚠️ Age verification NOT implemented
- 📋 **RECOMMENDATION:** Add age gate if targeting <13 year olds

### Regional Compliance
**EU (GDPR):** Partial compliance (TODO: data export, deletion)  
**California (CCPA):** Partial compliance (TODO: data sale opt-out)  
**Brazil (LGPD):** Similar to GDPR  
**Turkey (KVKK):** Turkish localization, consent forms needed

---

## SECURITY INCIDENT RESPONSE PLAN

### Reporting Security Issues
**Contact:** security@lingolatravel.com

### Incident Response Steps
1. **Detection & Analysis**
   - Monitor audit logs for suspicious activity
   - Review error logs for exploitation attempts

2. **Containment**
   - Revoke compromised tokens
   - Block malicious IPs
   - Disable affected user accounts

3. **Eradication**
   - Patch vulnerabilities
   - Rotate compromised secrets (JWT keys, DB passwords)

4. **Recovery**
   - Restore from clean backup if needed
   - Re-enable services

5. **Post-Incident**
   - Document incident
   - Notify affected users (if PII compromised)
   - Update security measures

---

## SECURITY CHECKLIST FOR PRODUCTION

### Pre-Deployment
- [ ] Set `NODE_ENV=production`
- [ ] Generate cryptographically secure JWT secrets (512-bit)
- [ ] Configure MySQL production database
- [ ] Enable HTTPS/TLS 1.3
- [ ] Set CORS_ORIGINS to app domain only
- [ ] Configure Helmet.js security headers
- [ ] Enable database connection encryption
- [ ] Review all TODO items in code
- [ ] Penetration testing
- [ ] Security audit by third party

### Post-Deployment
- [ ] Monitor audit logs daily
- [ ] Set up intrusion detection
- [ ] Configure automated backups
- [ ] Implement monitoring/alerting (error rates, failed logins)
- [ ] Regular dependency updates (npm audit)
- [ ] Quarterly security reviews

---

## KNOWN SECURITY LIMITATIONS

❌ **Current Gaps:**
1. No email verification for email/password signup
2. No password reset flow
3. No 2FA/MFA
4. No account lockout after failed attempts
5. No automated anomaly detection
6. Database encryption at rest not enabled
7. No data export/deletion endpoints (GDPR)
8. No session management (stateless JWT only)

📋 **Prioritized Roadmap:**
1. **Phase 1 (MVP):**
   - Current implementation (JWT + social auth)
2. **Phase 2 (Post-Launch):**
   - Email verification
   - Password reset
   - Account deletion
3. **Phase 3 (Premium Features):**
   - 2FA/MFA
   - Anomaly detection
   - Advanced audit reporting

---

**Document Classification:** CONFIDENTIAL - Internal Use Only  
**Next Review Date:** May 8, 2026  
**Maintained By:** Security Team
