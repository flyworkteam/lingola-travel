const { query } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * GET /api/v1/lessons/:id
 * Get lesson details with vocabulary
 */
const getLessonById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user?.id;

    // Get lesson details
    let lessonSql, lessonParams;
    
    if (userId) {
      lessonSql = `
        SELECT 
          l.*,
          c.title as course_title,
          c.category as course_category,
          c.is_free as course_is_free,
          IFNULL(ulp.status, 'not_started') as user_status,
          IFNULL(ulp.progress_percentage, 0) as user_progress,
          IFNULL(ulp.time_spent_seconds, 0) as time_spent,
          IFNULL(ulp.completed_at, NULL) as completed_at
        FROM lessons l
        INNER JOIN courses c ON l.course_id = c.id
        LEFT JOIN user_lesson_progress ulp ON l.id = ulp.lesson_id AND ulp.user_id = ?
        WHERE l.id = ?
      `;
      lessonParams = [userId, id];
    } else {
      lessonSql = `
        SELECT 
          l.*,
          c.title as course_title,
          c.category as course_category,
          c.is_free as course_is_free,
          'not_started' as user_status,
          0 as user_progress,
          0 as time_spent,
          NULL as completed_at
        FROM lessons l
        INNER JOIN courses c ON l.course_id = c.id
        WHERE l.id = ?
      `;
      lessonParams = [id];
    }

    const lessons = await query(lessonSql, lessonParams);

    if (lessons.length === 0) {
      return res.status(404).json(errorResponse('NOT_FOUND', 'Ders bulunamadı'));
    }

    const lesson = lessons[0];

    // Check if user has premium access (course-level check)
    if (lesson.course_is_free === 0 && userId) {
      const userSql = 'SELECT is_premium, trial_started_at FROM users WHERE id = ?';
      const users = await query(userSql, [userId]);
      
      if (users.length > 0) {
        const user = users[0];
        const trialEnded = user.trial_started_at && 
          (new Date() - new Date(user.trial_started_at)) > (24 * 60 * 60 * 1000);
        
        if (!user.is_premium && trialEnded) {
          return res.status(403).json(errorResponse('PREMIUM_REQUIRED', 'Bu ders premium üyelik gerektirir'));
        }
      }
    }

    // Get vocabulary for this lesson
    const vocabSql = `
      SELECT 
        id,
        term,
        definition,
        icon_path,
        icon_color,
        audio_url,
        display_order
      FROM lesson_vocabulary
      WHERE lesson_id = ?
      ORDER BY display_order ASC
    `;

    const vocabulary = await query(vocabSql, [id]);

    res.json(successResponse({
      lesson: {
        ...lesson,
        vocabulary
      }
    }));
  } catch (error) {
    console.error('Get lesson error:', error);
    next(error);
  }
};

/**
 * POST /api/v1/lessons/:id/progress
 * Update lesson progress
 */
const updateLessonProgress = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { progress_percentage, time_spent_seconds } = req.body;

    // Validate input
    if (progress_percentage < 0 || progress_percentage > 100) {
      return res.status(400).json(errorResponse('INVALID_INPUT', 'İlerleme 0-100 arasında olmalı'));
    }

    // Check if lesson exists
    const lessonSql = 'SELECT id, course_id FROM lessons WHERE id = ?';
    const lessons = await query(lessonSql, [id]);

    if (lessons.length === 0) {
      return res.status(404).json(errorResponse('NOT_FOUND', 'Ders bulunamadı'));
    }

    const courseId = lessons[0].course_id;

    // Check if progress record exists
    const existingSql = 'SELECT id FROM user_lesson_progress WHERE user_id = ? AND lesson_id = ?';
    const existing = await query(existingSql, [userId, id]);

    if (existing.length > 0) {
      // Update existing progress
      const updateSql = `
        UPDATE user_lesson_progress 
        SET progress_percentage = ?, 
            time_spent_seconds = time_spent_seconds + ?,
            status = CASE 
              WHEN ? >= 100 THEN 'completed'
              WHEN ? > 0 THEN 'in_progress'
              ELSE status
            END,
            completed_at = CASE WHEN ? >= 100 THEN NOW() ELSE completed_at END,
            last_accessed_at = NOW()
        WHERE id = ?
      `;
      await query(updateSql, [progress_percentage, time_spent_seconds || 0, progress_percentage, progress_percentage, progress_percentage, existing[0].id]);
    } else {
      // Insert new progress
      const insertSql = `
        INSERT INTO user_lesson_progress (user_id, lesson_id, progress_percentage, time_spent_seconds, status, last_accessed_at, completed_at)
        VALUES (?, ?, ?, ?, ?, NOW(), ?)
      `;
      const status = progress_percentage >= 100 ? 'completed' : progress_percentage > 0 ? 'in_progress' : 'not_started';
      const completedAt = progress_percentage >= 100 ? new Date() : null;
      
      await query(insertSql, [userId, id, progress_percentage, time_spent_seconds || 0, status, completedAt]);
    }

    // Update course progress
    await updateCourseProgress(userId, courseId);

    // Update user stats
    await updateUserStats(userId, time_spent_seconds || 0);

    res.json(successResponse({ message: 'İlerleme kaydedildi' }));
  } catch (error) {
    console.error('Update lesson progress error:', error);
    next(error);
  }
};

/**
 * POST /api/v1/lessons/:id/complete
 * Mark lesson as completed
 */
const completeLesson = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { time_spent_seconds = 0 } = req.body;

    // Check if lesson exists
    const lessonSql = 'SELECT id, course_id FROM lessons WHERE id = ?';
    const lessons = await query(lessonSql, [id]);

    if (lessons.length === 0) {
      return res.status(404).json(errorResponse('NOT_FOUND', 'Ders bulunamadı'));
    }

    const courseId = lessons[0].course_id;

    // Check if already completed
    const existingSql = 'SELECT id, status FROM user_lesson_progress WHERE user_id = ? AND lesson_id = ?';
    const existing = await query(existingSql, [userId, id]);

    if (existing.length > 0) {
      // Update to completed
      const updateSql = `
        UPDATE user_lesson_progress 
        SET status = 'completed', 
            progress_percentage = 100,
            time_spent_seconds = time_spent_seconds + ?,
            completed_at = NOW(),
            last_accessed_at = NOW()
        WHERE id = ?
      `;
      await query(updateSql, [time_spent_seconds, existing[0].id]);
    } else {
      // Insert as completed
      const insertSql = `
        INSERT INTO user_lesson_progress (user_id, lesson_id, status, progress_percentage, time_spent_seconds, completed_at, last_accessed_at)
        VALUES (?, ?, 'completed', 100, ?, NOW(), NOW())
      `;
      await query(insertSql, [userId, id, time_spent_seconds]);
    }

    // Update course progress
    await updateCourseProgress(userId, courseId);

    // Update user stats
    await updateUserStats(userId, time_spent_seconds);

    res.json(successResponse({ message: 'Ders tamamlandı', xp_earned: 10 }));
  } catch (error) {
    console.error('Complete lesson error:', error);
    next(error);
  }
};

/**
 * Helper: Update course progress based on completed lessons
 */
async function updateCourseProgress(userId, courseId) {
  const sql = `
    SELECT COUNT(*) as total_lessons,
           SUM(CASE WHEN ulp.status = 'completed' THEN 1 ELSE 0 END) as lessons_completed
    FROM lessons l
    LEFT JOIN user_lesson_progress ulp ON l.id = ulp.lesson_id AND ulp.user_id = ?
    WHERE l.course_id = ?
  `;
  
  const results = await query(sql, [userId, courseId]);
  const { total_lessons, lessons_completed } = results[0];
  const progressPercentage = total_lessons > 0 ? (lessons_completed / total_lessons) * 100 : 0;

  const existingSql = 'SELECT id FROM user_course_progress WHERE user_id = ? AND course_id = ?';
  const existing = await query(existingSql, [userId, courseId]);

  if (existing.length > 0) {
    const updateSql = `
      UPDATE user_course_progress 
      SET lessons_completed = ?, progress_percentage = ?, last_accessed_at = NOW()
      WHERE id = ?
    `;
    await query(updateSql, [lessons_completed, progressPercentage, existing[0].id]);
  } else {
    const insertSql = `
      INSERT INTO user_course_progress (user_id, course_id, lessons_completed, progress_percentage, last_accessed_at)
      VALUES (?, ?, ?, ?, NOW())
    `;
    await query(insertSql, [userId, courseId, lessons_completed, progressPercentage]);
  }
}

/**
 * Helper: Update user stats (total time, lessons completed)
 */
async function updateUserStats(userId, timeSpentSeconds) {
  const existingSql = 'SELECT id FROM user_stats WHERE user_id = ?';
  const existing = await query(existingSql, [userId]);

  if (existing.length > 0) {
    const updateSql = `
      UPDATE user_stats 
      SET total_study_time_minutes = total_study_time_minutes + ?,
          lessons_completed = lessons_completed + 1,
          updated_at = NOW()
      WHERE id = ?
    `;
    await query(updateSql, [Math.floor(timeSpentSeconds / 60), existing[0].id]);
  } else {
    const insertSql = `
      INSERT INTO user_stats (user_id, total_study_time_minutes, lessons_completed)
      VALUES (?, ?, 1)
    `;
    await query(insertSql, [userId, Math.floor(timeSpentSeconds / 60)]);
  }
}

module.exports = {
  getLessonById,
  updateLessonProgress,
  completeLesson
};
