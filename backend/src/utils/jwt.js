// JWT Token Utilities
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const crypto = require('crypto');

/**
 * Generate Access Token (Short-lived)
 */
function generateAccessToken(userId) {
  const payload = {
    userId,
    type: 'access'
  };
  
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '15m'
  });
}

/**
 * Generate Refresh Token (Long-lived)
 */
function generateRefreshToken(userId) {
  const payload = {
    userId,
    type: 'refresh',
    jti: crypto.randomBytes(16).toString('hex') // JWT ID for revocation
  };
  
  return jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d'
  });
}

/**
 * Verify Access Token
 */
function verifyAccessToken(token) {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.type !== 'access') {
      throw new Error('Invalid token type');
    }
    return decoded;
  } catch (error) {
    throw error;
  }
}

/**
 * Verify Refresh Token
 */
function verifyRefreshToken(token) {
  try {
    const decoded = jwt.verify(token, process.env.JWT_REFRESH_SECRET);
    if (decoded.type !== 'refresh') {
      throw new Error('Invalid token type');
    }
    return decoded;
  } catch (error) {
    throw error;
  }
}

/**
 * Hash Refresh Token for Database Storage
 */
async function hashRefreshToken(token) {
  const saltRounds = 10;
  return bcrypt.hash(token, saltRounds);
}

/**
 * Compare Refresh Token with Hash
 */
async function compareRefreshToken(token, hash) {
  return bcrypt.compare(token, hash);
}

/**
 * Hash Password
 */
async function hashPassword(password) {
  const saltRounds = 12; // Higher security for passwords
  return bcrypt.hash(password, saltRounds);
}

/**
 * Compare Password with Hash
 */
async function comparePassword(password, hash) {
  return bcrypt.compare(password, hash);
}

/**
 * Calculate Token Expiration Date
 */
function getRefreshTokenExpiry() {
  const days = parseInt(process.env.JWT_REFRESH_EXPIRES_IN) || 7;
  const expiryDate = new Date();
  expiryDate.setDate(expiryDate.getDate() + days);
  return expiryDate;
}

module.exports = {
  generateAccessToken,
  generateRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  hashRefreshToken,
  compareRefreshToken,
  hashPassword,
  comparePassword,
  getRefreshTokenExpiry
};
