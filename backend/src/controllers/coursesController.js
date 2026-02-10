const { query } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * GET /api/v1/courses
 * Get all courses (with optional filters)
 */
const getAllCourses = async (req, res, next) => {
  try {
    const { category, is_free, limit = 100, offset = 0 } = req.query;
    const userId = req.user?.id;

    let sql, params;

    if (userId) {
      sql = `
        SELECT 
          c.id,
          c.category,
          c.title,
          c.description,
          c.image_url,
          c.total_lessons,
          c.is_free,
          c.display_order,
          IFNULL(ucp.lessons_completed, 0) as lessons_completed,
          IFNULL(ucp.progress_percentage, 0) as progress_percentage
        FROM courses c
        LEFT JOIN user_course_progress ucp ON c.id = ucp.course_id AND ucp.user_id = ?
        WHERE 1=1
      `;
      params = [userId];
    } else {
      sql = `
        SELECT 
          c.id,
          c.category,
          c.title,
          c.description,
          c.image_url,
          c.total_lessons,
          c.is_free,
          c.display_order,
          0 as lessons_completed,
          0 as progress_percentage
        FROM courses c
        WHERE 1=1
      `;
      params = [];
    }

    if (category) {
      sql += ' AND c.category = ?';
      params.push(category);
    }

    if (is_free !== undefined) {
      sql += ' AND c.is_free = ?';
      params.push(is_free === 'true' || is_free === '1' ? 1 : 0);
    }

    sql += ' ORDER BY c.display_order ASC, c.created_at DESC';
    
    // Add LIMIT and OFFSET without placeholders (MySQL doesn't handle them well in prepared statements)
    const safeLimit = Math.max(1, Math.min(parseInt(limit) || 100, 1000));
    const safeOffset = Math.max(0, parseInt(offset) || 0);
    sql += ` LIMIT ${safeLimit} OFFSET ${safeOffset}`;

    const courses = await query(sql, params);

    res.json(successResponse({
      courses,
      total: courses.length,
      limit: parseInt(limit),
      offset: parseInt(offset)
    }));
  } catch (error) {
    console.error('Get all courses error:', error);
    next(error);
  }
};

/**
 * GET /api/v1/courses/:id
 * Get single course with lessons
 */
const getCourseById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user?.id;

    // Get course details
    let courseSql, courseParams;
    
    if (userId) {
      courseSql = `
        SELECT 
          c.*,
          IFNULL(ucp.lessons_completed, 0) as lessons_completed,
          IFNULL(ucp.progress_percentage, 0) as progress_percentage,
          IFNULL(ucp.last_accessed_at, NULL) as last_accessed_at
        FROM courses c
        LEFT JOIN user_course_progress ucp ON c.id = ucp.course_id AND ucp.user_id = ?
        WHERE c.id = ?
      `;
      courseParams = [userId, id];
    } else {
      courseSql = `
        SELECT 
          c.*,
          0 as lessons_completed,
          0 as progress_percentage,
          NULL as last_accessed_at
        FROM courses c
        WHERE c.id = ?
      `;
      courseParams = [id];
    }

    const courseResult = await query(courseSql, courseParams);

    if (courseResult.length === 0) {
      return res.status(404).json(errorResponse('NOT_FOUND', 'Kurs bulunamadı'));
    }

    const course = courseResult[0];

    // Get lessons for this course
    let lessonsSql, lessonsParams;
    
    if (userId) {
      lessonsSql = `
        SELECT 
          l.id,
          l.title,
          l.description,
          l.lesson_order,
          l.image_url,
          l.audio_url,
          IFNULL(ulp.status, 'not_started') as status,
          IFNULL(ulp.progress_percentage, 0) as progress_percentage,
          IFNULL(ulp.completed_at, NULL) as completed_at
        FROM lessons l
        LEFT JOIN user_lesson_progress ulp ON l.id = ulp.lesson_id AND ulp.user_id = ?
        WHERE l.course_id = ?
        ORDER BY l.lesson_order ASC
      `;
      lessonsParams = [userId, id];
    } else {
      lessonsSql = `
        SELECT 
          l.id,
          l.title,
          l.description,
          l.lesson_order,
          l.image_url,
          l.audio_url,
          'not_started' as status,
          0 as progress_percentage,
          NULL as completed_at
        FROM lessons l
        WHERE l.course_id = ?
        ORDER BY l.lesson_order ASC
      `;
      lessonsParams = [id];
    }

    const lessons = await query(lessonsSql, lessonsParams);

    res.json(successResponse({
      course: {
        ...course,
        lessons
      }
    }));
  } catch (error) {
    console.error('Get course by ID error:', error);
    next(error);
  }
};

/**
 * GET /api/v1/courses/:id/lessons
 * Get all lessons for a specific course
 */
const getCourseLessons = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user?.id;

    // Check if course exists
    const courseSql = 'SELECT id, title FROM courses WHERE id = ?';
    const courseResult = await query(courseSql, [id]);

    if (courseResult.length === 0) {
      return res.status(404).json(errorResponse('NOT_FOUND', 'Kurs bulunamadı'));
    }

    // Get lessons for this course
    let lessonsSql, lessonsParams;
    
    if (userId) {
      lessonsSql = `
        SELECT 
          l.id,
          l.title,
          l.description,
          l.lesson_order,
          l.image_url,
          l.audio_url,
          IFNULL(ulp.status, 'not_started') as status,
          IFNULL(ulp.progress_percentage, 0) as progress_percentage,
          IFNULL(ulp.completed_at, NULL) as completed_at
        FROM lessons l
        LEFT JOIN user_lesson_progress ulp ON l.id = ulp.lesson_id AND ulp.user_id = ?
        WHERE l.course_id = ?
        ORDER BY l.lesson_order ASC
      `;
      lessonsParams = [userId, id];
    } else {
      lessonsSql = `
        SELECT 
          l.id,
          l.title,
          l.description,
          l.lesson_order,
          l.image_url,
          l.audio_url,
          'not_started' as status,
          0 as progress_percentage,
          NULL as completed_at
        FROM lessons l
        WHERE l.course_id = ?
        ORDER BY l.lesson_order ASC
      `;
      lessonsParams = [id];
    }

    const lessons = await query(lessonsSql, lessonsParams);

    res.json(successResponse({
      course_id: id,
      course_title: courseResult[0].title,
      lessons,
      total: lessons.length
    }));
  } catch (error) {
    console.error('Get course lessons error:', error);
    next(error);
  }
};

/**
 * GET /api/v1/courses/categories
 * Get all unique categories
 */
const getCategories = async (req, res, next) => {
  try {
    const sql = `
      SELECT 
        category,
        COUNT(*) as course_count,
        SUM(CASE WHEN is_free = 1 THEN 1 ELSE 0 END) as free_course_count
      FROM courses
      GROUP BY category
      ORDER BY category ASC
    `;

    const categories = await query(sql);

    res.json(successResponse({ categories }));
  } catch (error) {
    console.error('Get categories error:', error);
    next(error);
  }
};

/**
 * POST /api/v1/courses/:id/start
 * Mark course as started for user
 */
const startCourse = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check if course exists
    const courseSql = 'SELECT id, total_lessons FROM courses WHERE id = ?';
    const courses = await query(courseSql, [id]);

    if (courses.length === 0) {
      return res.status(404).json(errorResponse('NOT_FOUND', 'Kurs bulunamadı'));
    }

    // Check if already started
    const progressSql = 'SELECT id FROM user_course_progress WHERE user_id = ? AND course_id = ?';
    const existing = await query(progressSql, [userId, id]);

    if (existing.length > 0) {
      return res.json(successResponse({ message: 'Kurs daha önce başlatılmış' }));
    }

    // Create progress record
    const insertSql = `
      INSERT INTO user_course_progress (user_id, course_id, lessons_completed, progress_percentage, last_accessed_at)
      VALUES (?, ?, 0, 0, NOW())
    `;

    await query(insertSql, [userId, id]);

    res.json(successResponse({ message: 'Kurs başlatıldı' }));
  } catch (error) {
    console.error('Start course error:', error);
    next(error);
  }
};

module.exports = {
  getAllCourses,
  getCourseById,
  getCourseLessons,
  getCategories,
  startCourse
};
