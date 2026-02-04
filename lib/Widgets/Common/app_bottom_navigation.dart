import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Core/Theme/my_colors.dart';
import '../../View/HomeView/premium_home_view.dart';
import '../../View/VocabularyView/travel_vocabulary_view.dart';
import '../../View/CourseView/course_view.dart';
import '../../View/HomeView/home_view.dart';

/// Standardized Bottom Navigation Bar for the app
/// Used across all main screens to ensure consistency
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final bool isPremium;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
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
              offset: const Offset(0, 4),
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
                      _buildNavItem(
                        context: context,
                        icon: Icons.grid_view_rounded,
                        index: 0,
                      ),
                      _buildNavItem(
                        context: context,
                        icon: Icons.flight_takeoff_rounded,
                        index: 1,
                      ),
                      _buildNavItem(
                        context: context,
                        icon: Icons.account_balance_rounded,
                        index: 2,
                      ),
                      _buildNavItem(
                        context: context,
                        icon: Icons.person_rounded,
                        index: 3,
                      ),
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
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required int index,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavigationItemTapped(context, index),
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

  /// Handle navigation between main screens
  void _onNavigationItemTapped(BuildContext context, int index) {
    // Don't navigate if already on the same screen
    if (index == currentIndex) return;

    // Remove all routes and navigate to the target screen
    switch (index) {
      case 0: // Home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                isPremium ? const PremiumHomeView() : const HomeView(),
          ),
          (route) => false,
        );
        break;

      case 1: // Travel Vocabulary (plane icon)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => TravelVocabularyView(isPremium: isPremium),
          ),
          (route) => false,
        );
        break;

      case 2: // Courses (building icon)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => CourseView(isPremium: isPremium),
          ),
          (route) => false,
        );
        break;

      case 3: // Profile (person icon)
        // TODO: Navigate to Profile screen when implemented
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile screen coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
    }
  }
}
