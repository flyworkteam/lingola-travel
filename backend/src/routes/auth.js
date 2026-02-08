// Authentication Routes
const express = require('express');
const { body } = require('express-validator');
const router = express.Router();
const authController = require('../controllers/authController');
const { handleValidationErrors } = require('../middleware/validator');
const { authLimiter } = require('../middleware/rateLimiter');

/**
 * POST /auth/login
 * Email/Password Login
 */
router.post('/login',
  authLimiter,
  [
    body('email').isEmail().normalizeEmail().withMessage('Geçerli bir email adresi girin'),
    body('password').notEmpty().withMessage('Şifre gerekli')
  ],
  handleValidationErrors,
  authController.login
);

/**
 * POST /auth/google
 * Google Sign-In
 */
router.post('/google',
  authLimiter,
  [
    body('idToken').notEmpty().withMessage('Google ID token gerekli')
  ],
  handleValidationErrors,
  authController.googleLogin
);

/**
 * POST /auth/apple
 * Apple Sign-In
 * TODO: Implement Apple authentication controller
 */
router.post('/apple',
  authLimiter,
  [
    body('identityToken').notEmpty().withMessage('Apple identity token gerekli')
  ],
  handleValidationErrors,
  (req, res) => {
    res.status(501).json({
      success: false,
      data: null,
      error: {
        code: 'NOT_IMPLEMENTED',
        message: 'Apple login will be implemented after store approval'
      }
    });
  }
);

/**
 * POST /auth/facebook
 * Facebook Login
 * TODO: Implement Facebook authentication controller
 */
router.post('/facebook',
  authLimiter,
  [
    body('accessToken').notEmpty().withMessage('Facebook access token gerekli')
  ],
  handleValidationErrors,
  (req, res) => {
    res.status(501).json({
      success: false,
      data: null,
      error: {
        code: 'NOT_IMPLEMENTED',
        message: 'Facebook login will be implemented after store approval'
      }
    });
  }
);

/**
 * POST /auth/anonymous
 * Anonymous Login (Guest)
 */
router.post('/anonymous',
  authLimiter,
  [
    body('deviceId').notEmpty().withMessage('Device ID gerekli')
  ],
  handleValidationErrors,
  authController.anonymousLogin
);

/**
 * POST /auth/refresh
 * Refresh Access Token
 */
router.post('/refresh',
  [
    body('refreshToken').notEmpty().withMessage('Refresh token gerekli')
  ],
  handleValidationErrors,
  authController.refreshToken
);

/**
 * POST /auth/logout
 * Logout (Invalidate Refresh Token)
 */
router.post('/logout',
  authController.logout
);

module.exports = router;
