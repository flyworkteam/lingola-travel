import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Localization/localization_manager.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';

import '../../Repositories/auth_repository.dart';
import '../../Repositories/notification_repository.dart';
import '../../Repositories/profile_repository.dart';
import '../../Services/auth_service.dart';
import '../../Services/onesignal_service.dart';
import '../../Services/secure_storage_service.dart';
import 'app_language_view.dart';
import 'faq_view.dart';
import 'premium_view.dart';
import 'profile_settings_view.dart';
import 'share_friend_view.dart';

class ProfileView extends ConsumerStatefulWidget {
  final bool isPremium;
  const ProfileView({super.key, this.isPremium = false});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
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

  // Loading States
  bool _isLoadingStats = true;
  bool _isLoadingProfile = true;

  int _dayStreak = 0;
  int _wordsLearned = 0;
  int _progressPercentage = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserStats();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoadingProfile = true);
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
            _isLoadingProfile = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _loadUserStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final response = await _profileRepository.getStats();
      if (response.success && response.data != null) {
        final stats = response.data['stats'];
        if (mounted) {
          setState(() {
            _dayStreak = stats['current_streak'] ?? 0;
            _wordsLearned = stats['saved_words_count'] ?? 0;
            int lessonsCompleted = stats['total_lessons_completed'] ?? 0;
            int totalLessons = stats['total_lessons_count'] ?? 100;
            _progressPercentage = totalLessons > 0
                ? ((lessonsCompleted / totalLessons) * 100).round()
                : 0;
            if (_progressPercentage > 100) _progressPercentage = 100;
            _isLoadingStats = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      final playerId = await OneSignalService().getPlayerId();
      if (playerId != null && playerId.isNotEmpty) {
        await NotificationRepository().unregisterDevice(playerId);
      }
      await OneSignalService().removeExternalUserId();
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) await _authRepository.logout(refreshToken);
      await _authService.signOutAll();
      await _secureStorage.clearUserData();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signIn', (route) => false);
    } catch (e) {
      await _secureStorage.clearUserData();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/onboarding',
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localizationManagerProvider);

    return Scaffold(
      backgroundColor: MyColors.background,
      body: Stack(
        key: const ValueKey('profile_stack'),
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
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
                  Text(
                    LocaleKeys.profile_profile.tr(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: MyColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildProfileHeader(),
                  SizedBox(height: 16.h),
                  _buildStatsCards(),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(LocaleKeys.profile_account_settings.tr()),
                  SizedBox(height: 16.h),
                  _buildSettingsCard([
                    _buildMenuItem(
                      iconPath: 'assets/icons/profilesetting.svg',
                      iconColor: const Color(0xFF4A90E2),
                      iconBgColor: const Color(0xFFE3F2FD),
                      title: LocaleKeys.profile_profile_settings.tr(),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileSettingsView(),
                          ),
                        );
                        if (result == true) _loadUserProfile();
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItemWithToggle(
                      iconPath: 'assets/icons/notification.svg',
                      iconColor: const Color(0xFF9C27B0),
                      iconBgColor: const Color(0xFFF3E5F5),
                      title: LocaleKeys.profile_notifications.tr(),
                      value: _notificationsEnabled,
                      onChanged: (value) =>
                          setState(() => _notificationsEnabled = value),
                    ),
                    _buildDivider(),
                    _buildMenuItemWithBadge(
                      isPremium: _isPremium,
                      iconPath: 'assets/icons/profilepremium.svg',
                      iconColor: const Color(0xFFFFB800),
                      iconBgColor: const Color(0xFFFFF9E6),
                      title: LocaleKeys.profile_premium.tr(),
                      badge: LocaleKeys.home_upgradeNow.tr(),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumView(),
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(height: 32.h),
                  _buildSectionTitle(LocaleKeys.profile_general.tr()),
                  SizedBox(height: 16.h),
                  _buildSettingsCard([
                    _buildMenuItem(
                      iconPath: 'assets/icons/applanguage.svg',
                      iconColor: const Color(0xFF4ECDC4),
                      iconBgColor: const Color(0xFFE0F7F4),
                      title: LocaleKeys.profile_app_language.tr(),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppLanguageView(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      iconPath: 'assets/icons/sharefriends.svg',
                      iconColor: const Color(0xFF5C6BC0),
                      iconBgColor: const Color(0xFFE8EAF6),
                      title: LocaleKeys.profile_share_friend.tr(),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShareFriendView(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      iconPath: 'assets/icons/rateus.svg',
                      iconColor: const Color(0xFFFF6B6B),
                      iconBgColor: const Color(0xFFFFEBEE),
                      title: LocaleKeys.profile_rate_us.tr(),
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      iconPath: 'assets/icons/faq.svg',
                      iconColor: const Color(0xFF757575),
                      iconBgColor: const Color(0xFFF5F5F5),
                      title: LocaleKeys.profile_faq.tr(),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FaqView(),
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(height: 32.h),
                  _buildLogoutButton(),
                  SizedBox(height: 24.h),
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
                  SizedBox(height: 110.h),
                ],
              ),
            ),
          ),
          CustomBottomNavBar(
            key: const ValueKey('bottom_nav_profile'),
            currentIndex: 3,
            isPremium: widget.isPremium,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4ECDC4), width: 3),
            ),
            child: _isLoadingProfile
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
                  )
                : ClipOval(
                    child: _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
                        ? Image.network(
                            _userPhotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildDefaultAvatar(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF4ECDC4),
                                ),
                              );
                            },
                          )
                        : _buildDefaultAvatar(),
                  ),
          ),
          SizedBox(height: 8.h),
          if (_isLoadingProfile)
            _buildSkeletonLoader(width: 120.w, height: 20.h)
          else
            Text(
              _userName,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 22.sp * -0.05,
                fontFamily: 'Montserrat',
                color: MyColors.textPrimary,
              ),
            ),
          SizedBox(height: 4.h),
          if (_isLoadingProfile)
            _buildSkeletonLoader(width: 180.w, height: 14.h)
          else
            Text(
              _userEmail ?? LocaleKeys.profile_free_version.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w300,
                letterSpacing: 14.sp * -0.05,
                fontFamily: 'Montserrat',
                color: MyColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: 48.w,
      backgroundColor: const Color(0xFF4ECDC4).withOpacity(0.1),
      child: SvgPicture.asset(
        'assets/icons/userlogo.svg',
        width: 50.w,
        height: 50.w,
        colorFilter: const ColorFilter.mode(Color(0xFF4ECDC4), BlendMode.srcIn),
      ),
    );
  }

  Widget _buildSkeletonLoader({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            _isLoadingStats,
            _dayStreak.toString(),
            LocaleKeys.profile_day_streak.tr(),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            _isLoadingStats,
            _formatNumber(_wordsLearned),
            LocaleKeys.profile_words_learned.tr(),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            _isLoadingStats,
            '$_progressPercentage%',
            LocaleKeys.profile_progress.tr(),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildStatCard(bool isLoading, String value, String label) {
    return Container(
      height: 75.h, // Sabit yükseklik loading sırasında zıplamayı önler
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF4ECDC4),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: const Color(0xFF4ECDC4),
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

  // ... (Geri kalan Helper Widgetlar: _buildSectionTitle, _buildSettingsCard, _buildMenuItem, vb. aynı kalıyor)
  // Pratiklik için geri kalanları da ekliyorum:

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
        color: MyColors.textSecondary,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDCE1EC),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

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
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: MyColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

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
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: MyColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4ECDC4),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemWithBadge({
    required String iconPath,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String badge,
    required VoidCallback onTap,
    required bool isPremium,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
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
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),
            ),
            Text(
              isPremium ? "Active" : LocaleKeys.profile_passive.tr(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: const Color(0xFFFFB800),
              ),
            ),
            SizedBox(width: 8.w),
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

  Widget _buildDivider() =>
      Divider(height: 1, thickness: 1, color: MyColors.grey200, indent: 68.w);

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => _showLogoutDialog(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/cikisyap.svg',
              width: 20.w,
              colorFilter: const ColorFilter.mode(
                Color(0xFFF44336),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              LocaleKeys.profile_logout.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: const Color(0xFFF44336),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 320.w,
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.25),
                  offset: const Offset(0, 0),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 75.w,
                  height: 75.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEEFEF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_remove_rounded,
                      color: const Color(0xFFE63D4F),
                      size: 40.sp,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  LocaleKeys.profile_logout_title.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: const Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  LocaleKeys.profile_logout_subtitle.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 32.h),
                GestureDetector(
                  onTap: _isLoggingOut
                      ? null
                      : () {
                          Navigator.pop(context);
                          _handleLogout();
                        },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE63D4F),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: _isLoggingOut
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : Text(
                            LocaleKeys.profile_logout.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    LocaleKeys.profile_delete_dialog_cancel.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: const Color(0xFF4ECDC4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
