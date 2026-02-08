// Rate Limiting Middleware
const rateLimit = require('express-rate-limit');
const { errorResponse, ErrorCodes } = require('../utils/response');

/**
 * Auth Endpoints Rate Limiter (Strict)
 */
const authLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_AUTH) || 5,
  message: errorResponse(
    ErrorCodes.RATE_LIMIT_EXCEEDED,
    'Çok fazla giriş denemesi. 15 dakika sonra tekrar deneyin.'
  ),
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json(
      errorResponse(
        ErrorCodes.RATE_LIMIT_EXCEEDED,
        'Çok fazla giriş denemesi. 15 dakika sonra tekrar deneyin.'
      )
    );
  }
});

/**
 * General API Rate Limiter
 */
const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: parseInt(process.env.RATE_LIMIT_MAX_API) || 100,
  message: errorResponse(
    ErrorCodes.RATE_LIMIT_EXCEEDED,
    'Çok fazla istek. Lütfen bir dakika sonra tekrar deneyin.'
  ),
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json(
      errorResponse(
        ErrorCodes.RATE_LIMIT_EXCEEDED,
        'Çok fazla istek. Lütfen bir dakika sonra tekrar deneyin.'
      )
    );
  }
});

module.exports = {
  authLimiter,
  apiLimiter
};
