import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Added for SVG icons
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import '../../Repositories/profile_repository.dart';
import '../../Repositories/auth_repository.dart';
import '../../Repositories/notification_repository.dart';
import '../../Services/secure_storage_service.dart';
import '../../Services/auth_service.dart';
import '../../Services/onesignal_service.dart';
import 'profile_settings_view.dart';
import 'share_friend_view.dart';
import 'faq_view.dart';
import 'app_language_view.dart';
import 'premium_view.dart';

class ProfileView extends StatefulWidget {
  final bool isPremium;
  const ProfileView({super.key, this.isPremium = false});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _notificationsEnabled = true;
  String _userName = 'Guest';
  String? _userEmail;
  String? _userPhotoUrl;
  bool _isPremium = false;
  final ProfileRepository _profileRepository = ProfileRepository();
  final AuthRepository _authRepository = AuthRepository();
  final SecureStorageService _secureStorage = SecureStorageService();
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  // Stats data
  int _dayStreak = 0;
  int _wordsLearned = 0;
  int _progressPercentage = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserStats();
  }

  /// Load user profile from backend
  Future<void> _loadUserProfile() async {
    try {
      final response = await _profileRepository.getProfile();
      if (response.success && response.data != null) {
        final userData = response.data['user'];
        if (mounted) {
          setState(() {
            _userName = userData['name'] ?? 'Guest';
            _userEmail = userData['email'];
            _userPhotoUrl = userData['photo_url'];
            _isPremium =
                userData['is_premium'] == 1 || userData['is_premium'] == true;
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  /// Load user statistics from backend
  Future<void> _loadUserStats() async {
    try {
      final response = await _profileRepository.getStats();
      if (response.success && response.data != null) {
        final stats = response.data['stats'];
        if (mounted) {
          setState(() {
            // Map backend fields to frontend fields
            _dayStreak = stats['current_streak'] ?? 0;
            _wordsLearned = stats['saved_words_count'] ?? 0;

            // Calculate progress percentage based on lessons completed vs total lessons
            int lessonsCompleted = stats['total_lessons_completed'] ?? 0;
            int totalLessons = stats['total_lessons_count'] ?? 100;
            
            if (totalLessons > 0) {
              _progressPercentage = ((lessonsCompleted / totalLessons) * 100).round();
            } else {
              _progressPercentage = 0;
            }
            
            if (_progressPercentage > 100) _progressPercentage = 100;

            _isLoadingStats = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingStats = false;
          });
        }
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() => _isLoggingOut = true);

    try {
      // Unregister device from push notifications
      final playerId = await OneSignalService().getPlayerId();
      if (playerId != null && playerId.isNotEmpty) {
        await NotificationRepository().unregisterDevice(playerId);
      }

      // Remove OneSignal external user ID
      await OneSignalService().removeExternalUserId();

      // Get refresh token
      final refreshToken = await _secureStorage.getRefreshToken();

      // Logout from backend
      if (refreshToken != null) {
        await _authRepository.logout(refreshToken);
      }

      // Sign out from all social providers
      await _authService.signOutAll();

      // Clear local storage
      await _secureStorage.clearUserData();

      if (!mounted) return;

      // Navigate to sign in screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/onboarding',
        (route) => false,
      );
    } catch (e) {
      print('Logout error: $e');

      // Even if there's an error, clear local storage and navigate
      await _secureStorage.clearUserData();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/onboarding',
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: Stack(
        key: ValueKey('profile_stack'), // Unique key to force rebuild
        children: [
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: MediaQuery.of(context).padding.top + 8.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),

                  // Profile Title
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: MyColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Profile Avatar and Info
                  _buildProfileHeader(),

                  SizedBox(height: 32.h),

                  // Stats Cards
                  _buildStatsCards(),

                  SizedBox(height: 40.h),

                  // Account Settings Section
                  _buildSectionTitle('ACCOUNT SETTINGS'),

                  SizedBox(height: 16.h),

                  _buildSettingsCard([
                    _buildMenuItem(
                      iconPath: 'assets/icons/profilesetting.svg',
                      iconColor: Color(0xFF4A90E2),
                      iconBgColor: Color(0xFFE3F2FD),
                      title: 'Profile Settings',
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileSettingsView(),
                          ),
                        );

                        // If profile was updated, refresh data
                        if (result == true) {
                          _loadUserProfile();
                        }
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItemWithToggle(
                      iconPath: 'assets/icons/notification.svg',
                      iconColor: Color(0xFF9C27B0),
                      iconBgColor: Color(0xFFF3E5F5),
                      title: 'Notifications',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItemWithBadge(
                      iconPath: 'assets/icons/profilepremium.svg',
                      iconColor: Color(0xFFFFB800),
                      iconBgColor: Color(0xFFFFF9E6),
                      title: 'Premium',
                      badge: 'Passive',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PremiumView(),
                          ),
                        );
                      },
                    ),
                  ]),

                  SizedBox(height: 32.h),

                  // General Section
                  _buildSectionTitle('GENERAL'),

                  SizedBox(height: 16.h),

                  _buildSettingsCard([
                    _buildMenuItem(
                      iconPath: 'assets/icons/applanguage.svg',
                      iconColor: Color(0xFF4ECDC4),
                      iconBgColor: Color(0xFFE0F7F4),
                      title: 'App Language',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppLanguageView(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      iconPath: 'assets/icons/sharefriends.svg',
                      iconColor: Color(0xFF5C6BC0),
                      iconBgColor: Color(0xFFE8EAF6),
                      title: 'Share Friend',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShareFriendView(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      iconPath: 'assets/icons/rateus.svg',
                      iconColor: Color(0xFFFF6B6B),
                      iconBgColor: Color(0xFFFFEBEE),
                      title: 'Rate Us',
                      onTap: () {
                        _showRateUsDialog();
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      iconPath: 'assets/icons/faq.svg',
                      iconColor: Color(0xFF757575),
                      iconBgColor: Color(0xFFF5F5F5),
                      title: 'F.A.Q.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FaqView(),
                          ),
                        );
                      },
                    ),
                  ]),

                  SizedBox(height: 32.h),

                  // Logout Button
                  _buildLogoutButton(),

                  SizedBox(height: 24.h),

                  // Version
                  Center(
                    child: Text(
                      'version 1.0.0',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        color: MyColors.textSecondary,
                      ),
                    ),
                  ),

                  SizedBox(height: 110.h), // Space for bottom nav
                ],
              ),
            ),
          ),

          // Floating bottom navigation
          CustomBottomNavBar(
            key: ValueKey('bottom_nav_profile'), // Unique key
            currentIndex: 3,
            isPremium: widget.isPremium,
          ),
        ],
      ),
    );
  }

  /// Profile Header with Avatar and Name
  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Avatar with border
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF4ECDC4), width: 3),
            ),
            child: _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
                ? CircleAvatar(
                    radius: 48.w,
                    backgroundColor: Color(0xFF4ECDC4).withOpacity(0.1),
                    backgroundImage: NetworkImage(_userPhotoUrl!),
                    onBackgroundImageError: (exception, stackTrace) {
                      // If image fails to load, show default avatar
                      print('Error loading profile image: $exception');
                    },
                    child: _userPhotoUrl!.isEmpty
                        ? SvgPicture.asset(
                            'assets/icons/userlogo.svg',
                            width: 50.w,
                            height: 50.w,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF4ECDC4),
                              BlendMode.srcIn,
                            ),
                          )
                        : null,
                  )
                : CircleAvatar(
                    radius: 48.w,
                    backgroundColor: Color(0xFF4ECDC4).withOpacity(0.1),
                    child: SvgPicture.asset(
                      'assets/icons/userlogo.svg',
                      width: 50.w,
                      height: 50.w,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF4ECDC4),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
          ),

          SizedBox(height: 16.h),

          // Name
          Text(
            _userName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              color: MyColors.textPrimary,
            ),
          ),

          SizedBox(height: 4.h),

          // Email or Free Version Badge
          _userEmail != null
              ? Text(
                  _userEmail!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                )
              : Text(
                  'Free Version',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                ),

          // Premium Badge if user is premium
          if (_isPremium) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Color(0xFFFFB800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Color(0xFFFFB800), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Color(0xFFFFB800), size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: Color(0xFFFFB800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Stats Cards Row
  Widget _buildStatsCards() {
    if (_isLoadingStats) {
      return Row(
        children: [
          Expanded(child: _buildStatCard('...', 'DAY STREAK')),
          SizedBox(width: 12.w),
          Expanded(child: _buildStatCard('...', 'WORDS\nLEARNED')),
          SizedBox(width: 12.w),
          Expanded(child: _buildStatCard('...', 'PROGRESS')),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildStatCard(_dayStreak.toString(), 'DAY STREAK')),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(_formatNumber(_wordsLearned), 'WORDS\nLEARNED'),
        ),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatCard('$_progressPercentage%', 'PROGRESS')),
      ],
    );
  }

  /// Format number with comma separator (e.g., 1240 -> 1,240)
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Single Stat Card
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              color: Color(0xFF4ECDC4),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              color: MyColors.textSecondary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Section Title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
        color: MyColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Settings Card Container
  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  /// Menu Item with Arrow
  Widget _buildMenuItem({
    required String iconPath,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 20.w,
                  height: 20.w,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: MyColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Menu Item with Toggle Switch
  Widget _buildMenuItemWithToggle({
    required String iconPath,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: MyColors.textPrimary,
              ),
            ),
          ),

          // Toggle Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF4ECDC4),
          ),
        ],
      ),
    );
  }

  /// Menu Item with Badge
  Widget _buildMenuItemWithBadge({
    required String iconPath,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 20.w,
                  height: 20.w,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),
            ),

            // Badge
            Text(
              badge,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: Color(0xFFFFB800),
              ),
            ),

            SizedBox(width: 8.w),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: MyColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Divider between menu items
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: MyColors.grey200,
      indent: 68.w,
    );
  }

  /// Logout Button
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        _showLogoutDialog();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/icons/cikisyap.svg',
              width: 20.w,
              height: 20.w,
              colorFilter: const ColorFilter.mode(
                Color(0xFFF44336),
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
            ),
            SizedBox(width: 8.w),
            Text(
              'Çıkış Yap',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: Color(0xFFF44336),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 340.w,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logout Icon
                  Container(
                    width: 70.w,
                    height: 70.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(-3.5.w, 0),
                        child: SvgPicture.asset(
                          'assets/icons/cikisyap.svg',
                          width: 32.w,
                          height: 32.w,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFE57373),
                            BlendMode.srcIn,
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Title
                  Text(
                    'You are about to log out',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: MyColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Description
                  Text(
                    "See you again soon! We'll miss your\nbreathing exercises.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                      color: MyColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Log out Button
                  GestureDetector(
                    onTap: _isLoggingOut
                        ? null
                        : () {
                            Navigator.pop(context);
                            _handleLogout();
                          },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: _isLoggingOut
                            ? Color(0xFFE57373).withOpacity(0.5)
                            : Color(0xFFE57373),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: _isLoggingOut
                            ? []
                            : [
                                BoxShadow(
                                  color: Color(0xFFE57373).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                      ),
                      child: _isLoggingOut
                          ? Center(
                              child: SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    MyColors.white,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              'Log out',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                color: MyColors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Cancel Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          color: Color(0xFF4ECDC4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Rate Us Dialog
  void _showRateUsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: MyColors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: MyColors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 64.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.star_rounded,
                          size: 36.sp,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Title
                    Text(
                      'Uygulamamızı Değerlendirin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Message
                    Text(
                      'Mağaza sayfamıza yönlendirileceksiniz. Deneyiminizi paylaşarak bize destek olabilirsiniz!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Rate Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Open store page
                        // For iOS: App Store link
                        // For Android: Play Store link
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF6B6B).withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Mağazaya Git',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            color: MyColors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Cancel Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text(
                          'İptal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
