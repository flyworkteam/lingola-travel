const express = require('express');
const router = express.Router();
const libraryController = require('../controllers/libraryController');
const { authenticateToken, optionalAuth } = require('../middleware/auth');
const { body } = require('express-validator');
const { handleValidationErrors } = require('../middleware/validator');

// GET /api/v1/library - Get library overview
router.get('/', optionalAuth, libraryController.getLibraryItems);

// GET /api/v1/library/bookmarks - Get bookmarks
router.get('/bookmarks', authenticateToken, libraryController.getBookmarks);

// POST /api/v1/library/bookmarks - Add bookmark
router.post('/bookmarks',
  authenticateToken,
  [
    body('type').isIn(['dictionary', 'phrase', 'vocabulary']),
    body('word_id').optional().isInt(),
    body('phrase_id').optional().isInt(),
    body('vocabulary_id').optional().isInt(),
    body('folder_id').optional().isInt()
  ],
  handleValidationErrors,
  libraryController.addBookmark
);

// DELETE /api/v1/library/bookmarks/:id - Remove bookmark
router.delete('/bookmarks/:id', authenticateToken, libraryController.removeBookmark);

// GET /api/v1/library/folders - Get folders
router.get('/folders', authenticateToken, libraryController.getFolders);

// POST /api/v1/library/folders - Create folder
router.post('/folders',
  authenticateToken,
  [
    body('name').isString().trim().isLength({ min: 1, max: 100 }),
    body('color').optional().isString()
  ],
  handleValidationErrors,
  libraryController.createFolder
);

// DELETE /api/v1/library/folders/:id - Delete folder
router.delete('/folders/:id', authenticateToken, libraryController.deleteFolder);

module.exports = router;
