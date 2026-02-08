const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');
const { authenticateToken } = require('../middleware/auth');
const { body } = require('express-validator');
const { handleValidationErrors } = require('../middleware/validator');

// GET /api/v1/profile - Get user profile
router.get('/', authenticateToken, profileController.getProfile);

// PATCH /api/v1/profile - Update profile (partial)
router.patch('/',
  authenticateToken,
  [
    body('name').optional().isString().trim().isLength({ max: 255 }),
    body('photo_url').optional().isURL(),
    body('phone_number').optional().isString().isLength({ max: 20 })
  ],
  handleValidationErrors,
  profileController.updateProfile
);

// GET /api/v1/profile/stats - Get user statistics
router.get('/stats', authenticateToken, profileController.getStats);

// PUT /api/v1/profile/onboarding - Save onboarding preferences
router.put('/onboarding',
  authenticateToken,
  [
    body('native_language').optional().isString(),
    body('target_languages').optional().isString(),
    body('learning_goal').optional().isString(),
    body('daily_study_time_minutes').optional().isInt({ min: 5, max: 480 }),
    body('notification_enabled').optional().isBoolean(),
    body('sound_enabled').optional().isBoolean()
  ],
  handleValidationErrors,
  profileController.saveOnboarding
);

// POST /api/v1/profile/change-password - Change password
router.post('/change-password',
  authenticateToken,
  [
    body('current_password').isString().isLength({ min: 6 }),
    body('new_password').isString().isLength({ min: 6, max: 128 })
  ],
  handleValidationErrors,
  profileController.changePassword
);

module.exports = router;
