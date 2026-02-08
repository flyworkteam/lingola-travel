const express = require('express');
const router = express.Router();
const lessonsController = require('../controllers/lessonsController');
const { authenticateToken, optionalAuth } = require('../middleware/auth');
const { body } = require('express-validator');
const { handleValidationErrors } = require('../middleware/validator');

// GET /api/v1/lessons/:id - Get lesson details
router.get('/:id', optionalAuth, lessonsController.getLessonById);

// POST /api/v1/lessons/:id/progress - Update lesson progress
router.post('/:id/progress',
  authenticateToken,
  [
    body('progress_percentage').isInt({ min: 0, max: 100 }),
    body('time_spent_seconds').optional().isInt({ min: 0 })
  ],
  handleValidationErrors,
  lessonsController.updateLessonProgress
);

// POST /api/v1/lessons/:id/complete - Mark as completed
router.post('/:id/complete',
  authenticateToken,
  [
    body('time_spent_seconds').optional().isInt({ min: 0 })
  ],
  handleValidationErrors,
  lessonsController.completeLesson
);

module.exports = router;
