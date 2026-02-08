const { query } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * GET /api/v1/profile
 * Get user profile
 */
const getProfile = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const sql = `
      SELECT 
        u.id,
        u.email,
        u.name,
        u.photo_url,
        u.phone_number,
        u.is_premium,
        u.premium_expires_at,
        u.trial_started_at,
        u.is_anonymous,
        u.auth_provider,
        u.created_at,
        u.last_login_at,
        uo.target_language,
        uo.profession,
        uo.english_level,
        uo.daily_goal,
        uo.daily_goal_minutes
      FROM users u
      LEFT JOIN user_onboarding uo ON u.id = uo.user_id
      WHERE u.id = ?
    `;

    const users = await query(sql, [userId]);

    if (users.length === 0) {
      return res.status(404).json(errorResponse('NOT_FOUND', 'Kullanıcı bulunamadı'));
    }

    const user = users[0];

    // Calculate trial status
    const trialEnded = user.trial_started_at && 
      (new Date() - new Date(user.trial_started_at)) > (24 * 60 * 60 * 1000);

    res.json(successResponse({
      user: {
        ...user,
        trial_active: !trialEnded && !user.is_premium,
        trial_ended: trialEnded
      }
    }));
  } catch (error) {
    console.error('Get profile error:', error);
    next(error);
  }
};

/**
 * PATCH /api/v1/profile
 * Update user profile
 */
const updateProfile = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { name, photo_url, phone_number } = req.body;

    const updates = [];
    const params = [];

    if (name !== undefined) {
      updates.push('name = ?');
      params.push(name);
    }
    if (photo_url !== undefined) {
      updates.push('photo_url = ?');
      params.push(photo_url);
    }
    if (phone_number !== undefined) {
      updates.push('phone_number = ?');
      params.push(phone_number);
    }

    if (updates.length === 0) {
      return res.status(400).json(errorResponse('INVALID_INPUT', 'Güncellenecek alan belirtilmedi'));
    }

    params.push(userId);

    const sql = `UPDATE users SET ${updates.join(', ')}, updated_at = NOW() WHERE id = ?`;
    await query(sql, params);

    res.json(successResponse({ message: 'Profil güncellendi' }));
  } catch (error) {
    console.error('Update profile error:', error);
    next(error);
  }
};

/**
 * GET /api/v1/profile/stats
 * Get user statistics
 */
const getStats = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const sql = `
      SELECT 
        us.current_streak,
        us.longest_streak,
        us.total_lessons_completed,
        us.total_xp,
        us.last_activity_date,
        (SELECT COUNT(*) FROM user_course_progress WHERE user_id = ? AND progress_percentage >= 100) as courses_completed,
        (SELECT COUNT(*) FROM bookmarks WHERE user_id = ?) as saved_words_count
      FROM user_stats us
      WHERE us.user_id = ?
    `;

    const stats = await query(sql, [userId, userId, userId]);

    if (stats.length === 0) {
      // Create default stats if not exists
      const createSql = 'INSERT INTO user_stats (user_id) VALUES (?)';
      await query(createSql, [userId]);
      
      return res.json(successResponse({
        stats: {
          current_streak: 0,
          longest_streak: 0,
          total_lessons_completed: 0,
          total_xp: 0,
          last_activity_date: null,
          courses_completed: 0,
          saved_words_count: 0
        }
      }));
    }

    res.json(successResponse({ stats: stats[0] }));
  } catch (error) {
    console.error('Get stats error:', error);
    next(error);
  }
};

/**
 * PUT /api/v1/profile/onboarding
 * Save or update onboarding preferences
 */
const saveOnboarding = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const {
      target_language,
      profession,
      english_level,
      daily_goal,
      daily_goal_minutes
    } = req.body;

    // Use INSERT ... ON DUPLICATE KEY UPDATE
    const sql = `
      INSERT INTO user_onboarding (
        user_id, target_language, profession, english_level, daily_goal, daily_goal_minutes
      ) VALUES (?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        target_language = VALUES(target_language),
        profession = VALUES(profession),
        english_level = VALUES(english_level),
        daily_goal = VALUES(daily_goal),
        daily_goal_minutes = VALUES(daily_goal_minutes)
    `;
    
    await query(sql, [
      userId,
      target_language,
      profession,
      english_level,
      daily_goal,
      daily_goal_minutes
    ]);

    res.json(successResponse({ message: 'Tercihler kaydedildi' }));
  } catch (error) {
    console.error('Save onboarding error:', error);
    next(error);
  }
};

/**
 * POST /api/v1/profile/change-password
 * Change user password
 */
const changePassword = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { current_password, new_password } = req.body;
    const bcrypt = require('bcrypt');

    // Get user
    const userSql = 'SELECT password_hash, auth_provider FROM users WHERE id = ?';
    const users = await query(userSql, [userId]);

    if (users.length === 0) {
      return res.status(404).json(errorResponse('NOT_FOUND', 'Kullanıcı bulunamadı'));
    }

    const user = users[0];

    if (user.auth_provider !== 'email') {
      return res.status(400).json(errorResponse('INVALID_OPERATION', 'Sosyal giriş kullanıcıları şifre değiştiremez'));
    }

    // Verify current password
    const isValid = await bcrypt.compare(current_password, user.password_hash);
    if (!isValid) {
      return res.status(401).json(errorResponse('INVALID_CREDENTIALS', 'Mevcut şifre hatalı'));
    }

    // Hash new password
    const newHash = await bcrypt.hash(new_password, 12);

    // Update password
    const updateSql = 'UPDATE users SET password_hash = ?, updated_at = NOW() WHERE id = ?';
    await query(updateSql, [newHash, userId]);

    // Revoke all refresh tokens
    const revokeSql = 'DELETE FROM refresh_tokens WHERE user_id = ?';
    await query(revokeSql, [userId]);

    res.json(successResponse({ message: 'Şifre değiştirildi. Lütfen tekrar giriş yapın.' }));
  } catch (error) {
    console.error('Change password error:', error);
    next(error);
  }
};

module.exports = {
  getProfile,
  updateProfile,
  getStats,
  saveOnboarding,
  changePassword
};
