// Authentication Controller
const { body } = require('express-validator');
const { v4: uuidv4 } = require('uuid');
const { query, transaction } = require('../config/database');
const { 
  generateAccessToken, 
  generateRefreshToken, 
  verifyRefreshToken,
  hashRefreshToken,
  compareRefreshToken,
  hashPassword,
  comparePassword,
  getRefreshTokenExpiry
} = require('../utils/jwt');
const { successResponse, errorResponse, ErrorCodes } = require('../utils/response');
const { verifyGoogleToken } = require('../utils/socialAuth');

/**
 * Email/Password Login
 */
async function login(req, res) {
  try {
    const { email, password } = req.body;
    
    // Find user by email
    const users = await query(
      'SELECT * FROM users WHERE email = ? AND auth_provider = ?',
      [email, 'email']
    );
    
    if (users.length === 0) {
      return res.status(401).json(
        errorResponse(ErrorCodes.ACCOUNT_NOT_FOUND, 'Email kayıtlı değil')
      );
    }
    
    const user = users[0];
    
    // Verify password
    const isValidPassword = await comparePassword(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json(
        errorResponse(ErrorCodes.INVALID_CREDENTIALS, 'Şifre hatalı')
      );
    }
    
    // Generate tokens
    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);
    
    // Store hashed refresh token
    const tokenHash = await hashRefreshToken(refreshToken);
    const expiresAt = getRefreshTokenExpiry();
    
    await query(
      'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)',
      [user.id, tokenHash, expiresAt]
    );
    
    // Update last login
    await query(
      'UPDATE users SET last_login_at = NOW() WHERE id = ?',
      [user.id]
    );
    
    // Log audit
    await query(
      'INSERT INTO audit_logs (user_id, action, ip_address, user_agent) VALUES (?, ?, ?, ?)',
      [user.id, 'login', req.ip, req.get('user-agent')]
    );
    
    // Remove sensitive data
    delete user.password_hash;
    
    res.json(successResponse({
      user,
      accessToken,
      refreshToken
    }));
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json(
      errorResponse(ErrorCodes.SERVER_ERROR, 'Giriş yapılamadı')
    );
  }
}

/**
 * Google Sign-In
 */
async function googleLogin(req, res) {
  try {
    const { idToken } = req.body;
    
    // Verify Google ID token
    const googleUser = await verifyGoogleToken(idToken);
    
    if (!googleUser) {
      return res.status(401).json(
        errorResponse(ErrorCodes.INVALID_CREDENTIALS, 'Google token doğrulanamadı')
      );
    }
    
    // Check if user exists
    let users = await query(
      'SELECT * FROM users WHERE auth_provider = ? AND external_auth_id = ?',
      ['google', googleUser.sub]
    );
    
    let user;
    let isNewUser = false;
    
    if (users.length === 0) {
      // Create new user
      isNewUser = true;
      const userId = uuidv4();
      
      await query(
        `INSERT INTO users (id, email, name, photo_url, auth_provider, external_auth_id, trial_started_at) 
         VALUES (?, ?, ?, ?, ?, ?, NOW())`,
        [userId, googleUser.email, googleUser.name, googleUser.picture, 'google', googleUser.sub]
      );
      
      // Create user stats
      await query(
        'INSERT INTO user_stats (user_id) VALUES (?)',
        [userId]
      );
      
      user = {
        id: userId,
        email: googleUser.email,
        name: googleUser.name,
        photo_url: googleUser.picture,
        auth_provider: 'google',
        is_premium: false,
        is_anonymous: false,
        trial_started_at: new Date()
      };
    } else {
      user = users[0];
    }
    
    // Generate tokens
    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);
    
    // Store refresh token
    const tokenHash = await hashRefreshToken(refreshToken);
    const expiresAt = getRefreshTokenExpiry();
    
    await query(
      'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)',
      [user.id, tokenHash, expiresAt]
    );
    
    // Update last login
    await query(
      'UPDATE users SET last_login_at = NOW() WHERE id = ?',
      [user.id]
    );
    
    // Log audit
    await query(
      'INSERT INTO audit_logs (user_id, action, ip_address, user_agent, metadata) VALUES (?, ?, ?, ?, ?)',
      [user.id, isNewUser ? 'google_signup' : 'google_login', req.ip, req.get('user-agent'), JSON.stringify({ isNewUser })]
    );
    
    delete user.password_hash;
    
    res.json(successResponse({
      user,
      accessToken,
      refreshToken
    }));
  } catch (error) {
    console.error('Google login error:', error);
    res.status(500).json(
      errorResponse(ErrorCodes.SERVER_ERROR, 'Google girişi başarısız')
    );
  }
}

/**
 * Anonymous Login
 */
async function anonymousLogin(req, res) {
  try {
    const { deviceId } = req.body;
    
    if (!deviceId) {
      return res.status(400).json(
        errorResponse(ErrorCodes.VALIDATION_ERROR, 'Device ID gerekli')
      );
    }
    
    // Check if device already has an account
    let users = await query(
      'SELECT * FROM users WHERE device_id = ? AND is_anonymous = true',
      [deviceId]
    );
    
    let user;
    let isNewUser = false;
    
    if (users.length === 0) {
      // Create anonymous user
      isNewUser = true;
      const userId = uuidv4();
      
      await query(
        `INSERT INTO users (id, device_id, auth_provider, is_anonymous, trial_started_at) 
         VALUES (?, ?, ?, true, NOW())`,
        [userId, deviceId, 'anonymous']
      );
      
      // Create user stats
      await query(
        'INSERT INTO user_stats (user_id) VALUES (?)',
        [userId]
      );
      
      user = {
        id: userId,
        device_id: deviceId,
        auth_provider: 'anonymous',
        is_anonymous: true,
        is_premium: false,
        trial_started_at: new Date()
      };
    } else {
      user = users[0];
    }
    
    // Generate tokens
    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);
    
    // Store refresh token
    const tokenHash = await hashRefreshToken(refreshToken);
    const expiresAt = getRefreshTokenExpiry();
    
    await query(
      'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)',
      [user.id, tokenHash, expiresAt]
    );
    
    // Update last login
    await query(
      'UPDATE users SET last_login_at = NOW() WHERE id = ?',
      [user.id]
    );
    
    // Log audit
    await query(
      'INSERT INTO audit_logs (user_id, action, ip_address, user_agent, metadata) VALUES (?, ?, ?, ?, ?)',
      [user.id, isNewUser ? 'anonymous_signup' : 'anonymous_login', req.ip, req.get('user-agent'), JSON.stringify({ deviceId })]
    );
    
    res.json(successResponse({
      user,
      accessToken,
      refreshToken
    }));
  } catch (error) {
    console.error('Anonymous login error:', error);
    res.status(500).json(
      errorResponse(ErrorCodes.SERVER_ERROR, 'Anonim giriş başarısız')
    );
  }
}

/**
 * Refresh Token
 */
async function refreshToken(req, res) {
  try {
    const { refreshToken: token } = req.body;
    
    if (!token) {
      return res.status(401).json(
        errorResponse(ErrorCodes.INVALID_TOKEN, 'Refresh token gerekli')
      );
    }
    
    // Verify token structure
    const decoded = verifyRefreshToken(token);
    
    // Find token in database
    const tokens = await query(
      'SELECT * FROM refresh_tokens WHERE user_id = ? AND expires_at > NOW()',
      [decoded.userId]
    );
    
    if (tokens.length === 0) {
      return res.status(401).json(
        errorResponse(ErrorCodes.TOKEN_NOT_FOUND, 'Token bulunamadı veya süresi doldu')
      );
    }
    
    // Verify token hash
    let validToken = null;
    for (const t of tokens) {
      if (await compareRefreshToken(token, t.token_hash)) {
        validToken = t;
        break;
      }
    }
    
    if (!validToken) {
      return res.status(401).json(
        errorResponse(ErrorCodes.INVALID_TOKEN, 'Geçersiz refresh token')
      );
    }
    
    // Generate new tokens
    const newAccessToken = generateAccessToken(decoded.userId);
    const newRefreshToken = generateRefreshToken(decoded.userId);
    
    // Delete old token and store new one
    const newTokenHash = await hashRefreshToken(newRefreshToken);
    const expiresAt = getRefreshTokenExpiry();
    
    await transaction(async (conn) => {
      await conn.execute(
        'DELETE FROM refresh_tokens WHERE id = ?',
        [validToken.id]
      );
      
      await conn.execute(
        'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)',
        [decoded.userId, newTokenHash, expiresAt]
      );
    });
    
    res.json(successResponse({
      accessToken: newAccessToken,
      refreshToken: newRefreshToken
    }));
  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(401).json(
      errorResponse(ErrorCodes.INVALID_TOKEN, 'Token yenileneme hatası')
    );
  }
}

/**
 * Logout
 */
async function logout(req, res) {
  try {
    const { refreshToken: token } = req.body;
    
    if (!token) {
      return res.json(successResponse({ message: 'Çıkış yapıldı' }));
    }
    
    // Verify and decode token
    const decoded = verifyRefreshToken(token);
    
    // Delete all refresh tokens for this user (optional: only delete this specific token)
    await query(
      'DELETE FROM refresh_tokens WHERE user_id = ?',
      [decoded.userId]
    );
    
    // Log audit
    await query(
      'INSERT INTO audit_logs (user_id, action, ip_address, user_agent) VALUES (?, ?, ?, ?)',
      [decoded.userId, 'logout', req.ip, req.get('user-agent')]
    );
    
    res.json(successResponse({ message: 'Çıkış yapıldı' }));
  } catch (error) {
    console.error('Logout error:', error);
    // Return success even on error (best practice for logout)
    res.json(successResponse({ message: 'Çıkış yapıldı' }));
  }
}

module.exports = {
  login,
  googleLogin,
  anonymousLogin,
  refreshToken,
  logout
};
