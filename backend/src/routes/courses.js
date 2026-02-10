const express = require('express');
const router = express.Router();
const coursesController = require('../controllers/coursesController');
const { authenticateToken, optionalAuth } = require('../middleware/auth');

// GET /api/v1/courses - Get all courses (optional auth for progress)
router.get('/', optionalAuth, coursesController.getAllCourses);

// GET /api/v1/courses/categories - Get all categories
router.get('/categories', coursesController.getCategories);

// GET /api/v1/courses/:id - Get single course with lessons
router.get('/:id', optionalAuth, coursesController.getCourseById);

// GET /api/v1/courses/:id/lessons - Get lessons for a specific course
router.get('/:id/lessons', optionalAuth, coursesController.getCourseLessons);

// POST /api/v1/courses/:id/start - Start a course (requires auth)
router.post('/:id/start', authenticateToken, coursesController.startCourse);

module.exports = router;
