const { query } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * GET /api/v1/library
 * Get library overview (bookmarks and folders)
 */
const getLibraryItems = async (req, res, next) => {
  try {
    const userId = req.user?.id;

    // If not authenticated, return empty library
    if (!userId) {
      return res.json(successResponse({
        bookmarks: [],
        folders: [],
        stats: {
          total_bookmarks: 0,
          dictionary_count: 0,
          phrases_count: 0,
          vocabulary_count: 0
        },
        message: 'Kitaplığınızı görmek için giriş yapın'
      }));
    }

    // Get recent bookmarks
    const bookmarksSql = `
      SELECT 
        b.id as bookmark_id,
        b.item_type,
        b.item_id,
        b.created_at as bookmarked_at,
        CASE 
          WHEN b.item_type = 'dictionary_word' THEN dw.word
          WHEN b.item_type = 'travel_phrase' THEN tp.english_text
          WHEN b.item_type = 'lesson_vocabulary' THEN lv.term
        END as word,
        CASE 
          WHEN b.item_type = 'dictionary_word' THEN dw.translation
          WHEN b.item_type = 'travel_phrase' THEN tp.translation
          WHEN b.item_type = 'lesson_vocabulary' THEN lv.definition
        END as translation
      FROM bookmarks b
      LEFT JOIN dictionary_words dw ON b.item_id = dw.id AND b.item_type = 'dictionary_word'
      LEFT JOIN travel_phrases tp ON b.item_id = tp.id AND b.item_type = 'travel_phrase'
      LEFT JOIN lesson_vocabulary lv ON b.item_id = lv.id AND b.item_type = 'lesson_vocabulary'
      WHERE b.user_id = ?
      ORDER BY b.created_at DESC
      LIMIT 20
    `;

    const bookmarks = await query(bookmarksSql, [userId]);

    // Get folders
    const foldersSql = `
      SELECT 
        f.id,
        f.name,
        f.color,
        f.created_at,
        COUNT(b.id) as item_count
      FROM library_folders f
      LEFT JOIN bookmarks b ON b.folder_id = f.id
      WHERE f.user_id = ?
      GROUP BY f.id
      ORDER BY f.created_at DESC
    `;

    const folders = await query(foldersSql, [userId]);

    // Get stats
    const statsSql = `
      SELECT 
        COUNT(*) as total_bookmarks,
        COUNT(DISTINCT CASE WHEN item_type = 'dictionary_word' THEN 1 END) as dictionary_count,
        COUNT(DISTINCT CASE WHEN item_type = 'travel_phrase' THEN 1 END) as phrases_count,
        COUNT(DISTINCT CASE WHEN item_type = 'lesson_vocabulary' THEN 1 END) as vocabulary_count
      FROM bookmarks
      WHERE user_id = ?
    `;

    const stats = await query(statsSql, [userId]);

    res.json(successResponse({
      bookmarks,
      folders,
      stats: stats[0] || {
        total_bookmarks: 0,
        dictionary_count: 0,
        phrases_count: 0,
        vocabulary_count: 0
      }
    }));
  } catch (error) {
    console.error('Get library items error:', error);
    next(error);
  }
};

/**
 * GET /api/v1/library/bookmarks
 * Get all bookmarked words and phrases
 */
const getBookmarks = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { type, limit = 50, offset = 0 } = req.query;

    let sql = `
      SELECT 
        b.id as bookmark_id,
        b.item_type,
        b.item_id,
        b.created_at as bookmarked_at,
        CASE 
          WHEN b.item_type = 'dictionary_word' THEN dw.word
          WHEN b.item_type = 'travel_phrase' THEN tp.english_text
          WHEN b.item_type = 'lesson_vocabulary' THEN lv.term
        END as word,
        CASE 
          WHEN b.item_type = 'dictionary_word' THEN dw.translation
          WHEN b.item_type = 'travel_phrase' THEN tp.translation
          WHEN b.item_type = 'lesson_vocabulary' THEN lv.definition
        END as translation,
        CASE 
          WHEN b.item_type = 'dictionary_word' THEN dc.name
          WHEN b.item_type = 'travel_phrase' THEN tp.category
          ELSE NULL
        END as category
      FROM bookmarks b
      LEFT JOIN dictionary_words dw ON b.item_id = dw.id AND b.item_type = 'dictionary_word'
      LEFT JOIN dictionary_categories dc ON dw.category_id = dc.id
      LEFT JOIN travel_phrases tp ON b.item_id = tp.id AND b.item_type = 'travel_phrase'
      LEFT JOIN lesson_vocabulary lv ON b.item_id = lv.id AND b.item_type = 'lesson_vocabulary'
      WHERE b.user_id = ?
    `;

    const params = [userId];

    if (type) {
      sql += ' AND b.item_type = ?';
      params.push(type);
    }

    const safeLimit = Math.max(1, Math.min(parseInt(limit) || 50, 1000));
    const safeOffset = Math.max(0, parseInt(offset) || 0);
    sql += ` ORDER BY b.created_at DESC LIMIT ${safeLimit} OFFSET ${safeOffset}`;

    const bookmarks = await query(sql, params);

    res.json(successResponse({
      bookmarks,
      total: bookmarks.length
    }));
  } catch (error) {
    console.error('Get bookmarks error:', error);
    next(error);
  }
};

/**
 * POST /api/v1/library/bookmarks
 * Add a bookmark
 */
const addBookmark = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { item_type, item_id } = req.body;

    // Validate type
    if (!['dictionary_word', 'travel_phrase', 'lesson_vocabulary'].includes(item_type)) {
      return res.status(400).json(errorResponse('INVALID_INPUT', 'Geçersiz bookmark tipi'));
    }

    if (!item_id) {
      return res.status(400).json(errorResponse('INVALID_INPUT', 'Item ID gerekli'));
    }

    // Check if already bookmarked
    const checkSql = 'SELECT id FROM bookmarks WHERE user_id = ? AND item_type = ? AND item_id = ?';
    const existing = await query(checkSql, [userId, item_type, item_id]);

    if (existing.length > 0) {
      return res.status(409).json(errorResponse('ALREADY_EXISTS', 'Zaten kaydedilmiş'));
    }

    // Insert bookmark
    const insertSql = `
      INSERT INTO bookmarks (user_id, item_type, item_id)
      VALUES (?, ?, ?)
    `;

    await query(insertSql, [userId, item_type, item_id]);

    res.json(successResponse({ message: 'Kaydedildi' }));
  } catch (error) {
    console.error('Add bookmark error:', error);
    next(error);
  }
};

/**
 * DELETE /api/v1/library/bookmarks/:id
 * Remove a bookmark
 */
const removeBookmark = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const sql = 'DELETE FROM bookmarks WHERE id = ? AND user_id = ?';
    const result = await query(sql, [id, userId]);

    if (result.affectedRows === 0) {
      return res.status(404).json(errorResponse('NOT_FOUND', 'Bookmark bulunamadı'));
    }

    res.json(successResponse({ message: 'Silindi' }));
  } catch (error) {
    console.error('Remove bookmark error:', error);
    next(error);
  }
};

/**
 * GET /api/v1/library/folders
 * Get user's library folders
 */
const getFolders = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const sql = `
      SELECT 
        lf.id,
        lf.name,
        lf.color,
        lf.created_at,
        COUNT(li.id) as item_count
      FROM library_folders lf
      LEFT JOIN library_items li ON lf.id = li.folder_id
      WHERE lf.user_id = ?
      GROUP BY lf.id, lf.name, lf.color, lf.created_at
      ORDER BY lf.created_at DESC
    `;

    const folders = await query(sql, [userId]);

    res.json(successResponse({ folders }));
  } catch (error) {
    console.error('Get folders error:', error);
    next(error);
  }
};

/**
 * POST /api/v1/library/folders
 * Create a new folder
 */
const createFolder = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { name, color = '#3B82F6' } = req.body;

    const sql = 'INSERT INTO library_folders (user_id, name, color) VALUES (?, ?, ?)';
    const result = await query(sql, [userId, name, color]);

    res.json(successResponse({
      folder: {
        id: result.insertId,
        name,
        color
      }
    }));
  } catch (error) {
    console.error('Create folder error:', error);
    next(error);
  }
};

/**
 * DELETE /api/v1/library/folders/:id
 * Delete a folder (and its items)
 */
const deleteFolder = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const sql = 'DELETE FROM library_folders WHERE id = ? AND user_id = ?';
    const result = await query(sql, [id, userId]);

    if (result.affectedRows === 0) {
      return res.status(404).json(errorResponse('NOT_FOUND', 'Klasör bulunamadı'));
    }

    res.json(successResponse({ message: 'Klasör silindi' }));
  } catch (error) {
    console.error('Delete folder error:', error);
    next(error);
  }
};

module.exports = {
  getLibraryItems,
  getBookmarks,
  addBookmark,
  removeBookmark,
  getFolders,
  createFolder,
  deleteFolder
};
