// Authentication Middleware
const { verifyAccessToken } = require('../utils/jwt');
const { errorResponse, ErrorCodes } = require('../utils/response');
const { query } = require('../config/database');

/**
 * Verify JWT Access Token
 */
async function authenticateToken(req, res, next) {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
    
    if (!token) {
      return res.status(401).json(
        errorResponse(ErrorCodes.UNAUTHORIZED, 'Token bulunamadı')
      );
    }
    
    // Verify token
    const decoded = verifyAccessToken(token);
    
    // Fetch user from database
    const users = await query(
      'SELECT id, email, name, is_premium, premium_expires_at, trial_started_at, is_anonymous FROM users WHERE id = ?',
      [decoded.userId]
    );
    
    if (users.length === 0) {
      return res.status(401).json(
        errorResponse(ErrorCodes.ACCOUNT_NOT_FOUND, 'Kullanıcı bulunamadı')
      );
    }
    
    // Attach user to request
    req.user = users[0];
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json(
        errorResponse(ErrorCodes.INVALID_TOKEN, 'Geçersiz token')
      );
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json(
        errorResponse(ErrorCodes.INVALID_TOKEN, 'Token süresi doldu')
      );
    }
    
    console.error('Auth middleware error:', error);
    return res.status(500).json(
      errorResponse(ErrorCodes.SERVER_ERROR, 'Sunucu hatası')
    );
  }
}

/**
 * Check if User Has Premium Access
 */
function requirePremium(req, res, next) {
  const user = req.user;
  
  // Check if premium subscription is active
  if (user.is_premium) {
    const now = new Date();
    const expiresAt = user.premium_expires_at ? new Date(user.premium_expires_at) : null;
    
    if (!expiresAt || now < expiresAt) {
      return next();
    }
  }
  
  // Check if trial is active
  if (user.trial_started_at) {
    const trialStart = new Date(user.trial_started_at);
    const trialEnd = new Date(trialStart);
    trialEnd.setDate(trialEnd.getDate() + parseInt(process.env.PREMIUM_TRIAL_DAYS || 1));
    
    const now = new Date();
    if (now < trialEnd) {
      return next();
    }
  }
  
  // No premium access
  return res.status(403).json(
    errorResponse(
      ErrorCodes.FORBIDDEN,
      'Bu içerik premium üyeler için. Lütfen premium üyeliğe geçin.'
    )
  );
}

/**
 * Optional Authentication (doesn't fail if no token)
 */
async function optionalAuth(req, res, next) {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    
    if (!token) {
      req.user = null;
      return next();
    }
    
    const decoded = verifyAccessToken(token);
    const users = await query(
      'SELECT id, email, name, is_premium, premium_expires_at, trial_started_at FROM users WHERE id = ?',
      [decoded.userId]
    );
    
    req.user = users.length > 0 ? users[0] : null;
    next();
  } catch (error) {
    req.user = null;
    next();
  }
}

module.exports = {
  authenticateToken,
  requirePremium,
  optionalAuth
};
