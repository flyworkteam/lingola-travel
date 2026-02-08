const express = require('express');
const router = express.Router();
const dictionaryController = require('../controllers/dictionaryController');
const { optionalAuth } = require('../middleware/auth');

// GET /api/v1/dictionary/categories
router.get('/categories', dictionaryController.getCategories);

// GET /api/v1/dictionary/categories/:id/words
router.get('/categories/:id/words', optionalAuth, dictionaryController.getWordsByCategory);

// GET /api/v1/dictionary/search
router.get('/search', optionalAuth, dictionaryController.searchWords);

// GET /api/v1/dictionary/phrases (travel phrases)
router.get('/phrases', optionalAuth, dictionaryController.getTravelPhrases);

module.exports = router;
