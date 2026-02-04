import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import '../VocabularyView/travel_vocabulary_view.dart';
import '../DictionaryView/visual_dictionary_view.dart';
import '../LibraryView/library_view.dart';
import 'profile_settings_view.dart';
import 'share_friend_view.dart';
import 'faq_view.dart';
import 'app_language_view.dart';
import 'premium_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _notificationsEnabled = true;
  int _selectedNavIndex = 3; // Profile is index 3

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

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
                        icon: Icons.person_outline,
                        iconColor: Color(0xFF4A90E2),
                        iconBgColor: Color(0xFFE3F2FD),
                        title: 'Profile Settings',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileSettingsView(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItemWithToggle(
                        icon: Icons.notifications_outlined,
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
                        icon: Icons.workspace_premium_outlined,
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
                        icon: Icons.language,
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
                        icon: Icons.person_add_outlined,
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
                        icon: Icons.thumb_up_outlined,
                        iconColor: Color(0xFFFF6B6B),
                        iconBgColor: Color(0xFFFFEBEE),
                        title: 'Rate Us',
                        onTap: () {
                          // TODO: Rate app
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.help_outline,
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
                        'version 2.1.0',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                          color: MyColors.textSecondary,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 110.h,
                    ), // Space for bottom nav (65h bar + 20h bottom + 25h extra)
                  ],
                ),
              ),
            ),

            // Floating bottom navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 16.h, // SafeArea padding
              child: _buildBottomNavigationBar(),
            ),
          ],
        ),
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
            child: CircleAvatar(
              radius: 48.w,
              backgroundColor: Color(0xFF4ECDC4).withOpacity(0.1),
              child: Icon(Icons.person, size: 50.sp, color: Color(0xFF4ECDC4)),
            ),
          ),

          SizedBox(height: 16.h),

          // Name
          Text(
            'Alex Johnson',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              color: MyColors.textPrimary,
            ),
          ),

          SizedBox(height: 4.h),

          // Free Version Badge
          Text(
            'Free Version',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
              color: MyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Stats Cards Row
  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('12', 'DAY STREAK')),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatCard('1,240', 'WORDS\nLEARNED')),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatCard('84%', 'PROGRESS')),
      ],
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
    required IconData icon,
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
              child: Icon(icon, size: 20.sp, color: iconColor),
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
    required IconData icon,
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
            child: Icon(icon, size: 20.sp, color: iconColor),
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
    required IconData icon,
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
              child: Icon(icon, size: 20.sp, color: iconColor),
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
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20.sp, color: Color(0xFFF44336)),
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

  /// Bottom Navigation Bar - Floating with oval background
  Widget _buildBottomNavigationBar() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        height: 65.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35.r),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/home/altmenuarkaplan.png',
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: MyColors.white,
                        borderRadius: BorderRadius.circular(35.r),
                      ),
                    );
                  },
                ),
              ),

              // Navigation items - centered
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(icon: Icons.grid_view_rounded, index: 0),
                      _buildNavItem(
                        icon: Icons.flight_takeoff_rounded,
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.account_balance_rounded,
                        index: 2,
                      ),
                      _buildNavItem(icon: Icons.person_rounded, index: 3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Single navigation item - icon only with white circle for active
  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool isActive = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () => _onNavigationItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color: isActive ? MyColors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 26.sp,
          color: isActive ? MyColors.lingolaPrimaryColor : MyColors.grey400,
        ),
      ),
    );
  }

  /// Handle navigation bar taps
  void _onNavigationItemTapped(int index) {
    if (index == _selectedNavIndex) {
      // Already on this page
      return;
    }

    if (index == 0) {
      // Navigate back to Home (just pop current page)
      Navigator.pop(context);
    } else if (index == 1) {
      // Navigate to Vocabulary
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TravelVocabularyView()),
      );
    } else if (index == 2) {
      // Navigate to Library
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LibraryView()),
      );
    }
    // index 3 is current page (Profile), do nothing
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
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      size: 40.sp,
                      color: Color(0xFFE57373),
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
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Color(0xFFE57373),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFE57373).withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
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
}
