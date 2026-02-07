import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/View/HomeView/home_view.dart';
import 'package:lingola_travel/View/HomeView/premium_home_view.dart';
import 'package:lingola_travel/View/VocabularyView/travel_vocabulary_view.dart';
import 'package:lingola_travel/View/LibraryView/library_view.dart';
import 'package:lingola_travel/View/ProfileView/profile_view.dart';

/// Global Bottom Navigation Bar Widget
/// Used across all main screens for consistent navigation
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final bool isPremium;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.isPremium = false,
  });

  void _handleNavigation(BuildContext context, int index) {
    // If custom onTap is provided, use it
    if (onTap != null) {
      onTap!(index);
      return;
    }

    // Default navigation logic
    if (index == currentIndex) return; // Don't navigate if already on this page

    Widget destination;
    switch (index) {
      case 0:
        destination = isPremium ? const PremiumHomeView() : const HomeView();
        break;
      case 1:
        destination = TravelVocabularyView(isPremium: isPremium);
        break;
      case 2:
        destination = LibraryView(isPremium: isPremium);
        break;
      case 3:
        destination = ProfileView(isPremium: isPremium);
        break;
      default:
        return;
    }

    // Clear entire navigation stack and navigate to the selected screen
    // This prevents navigation confusion when switching between main screens
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 8.h + bottomPadding,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          height: 65.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 6),
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
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                          isSvg: true,
                          svgPath: 'assets/images/teleskop.svg',
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
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required int index,
    bool isSvg = false,
    String? svgPath,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          color: isActive ? MyColors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: MyColors.lingolaPrimaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSvg && svgPath != null
            ? Center(
                child: SvgPicture.asset(
                  svgPath,
                  width: 26.w,
                  height: 26.w,
                  colorFilter: ColorFilter.mode(
                    isActive ? MyColors.lingolaPrimaryColor : MyColors.grey400,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : Icon(
                icon,
                size: 26.sp,
                color: isActive
                    ? MyColors.lingolaPrimaryColor
                    : MyColors.grey400,
              ),
      ),
    );
  }
}
