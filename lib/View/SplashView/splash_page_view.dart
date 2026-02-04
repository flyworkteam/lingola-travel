import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Core/Theme/my_colors.dart';

/// Splash Page View - Onboarding Slider
/// Features: Auto-scroll, Manual swipe, Smooth page indicator, Crossfade animations
class SplashPageView extends StatefulWidget {
  const SplashPageView({super.key});

  @override
  State<SplashPageView> createState() => _SplashPageViewState();
}

class _SplashPageViewState extends State<SplashPageView> {
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  final List<Map<String, String>> _splashData = [
    {
      'image': 'assets/images/splash2.png',
      'title': 'English is no longer difficult when traveling',
      'description':
          'Learn the most commonly used words at the airport, hotel, restaurant, and for transportation.',
    },
    {
      'image': 'assets/images/splash3.png',
      'title': 'Real travel scenarios',
      'description':
          'Practice with words and phrases you\'ll actually need while traveling.',
    },
    {
      'image': 'assets/images/splash4.png',
      'title': 'Learn on the go, travel comfortably',
      'description':
          'Learn English words in just a few minutes, focus on your trip.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        if (_currentPage < _splashData.length - 1) {
          _currentPage++;
        } else {
          // Loop back to the first page
          _currentPage = 0;
        }
      });
    });
  }

  void _nextPage() {
    if (_currentPage < _splashData.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      // Navigate to Sign In (Onboarding)
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Image Section with CrossFade Effect
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 8.w,
                  right: 8.w,
                  top: 8.h,
                  bottom: 0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: ClipRRect(
                    key: ValueKey<int>(_currentPage),
                    borderRadius: BorderRadius.circular(28.r),
                    child: Image.asset(
                      _splashData[_currentPage]['image']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            ),

          // Content Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 32.h),

                // Progress Indicator - Match image width, thinner bars
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate available width (same as image container)
                      final totalWidth = constraints.maxWidth;
                      // Total spacing between indicators (2 gaps × 6.w each)
                      final totalSpacing = 12.w;
                      // Width for each indicator
                      final indicatorWidth = (totalWidth - totalSpacing) / _splashData.length;
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          _splashData.length,
                          (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: indicatorWidth,
                              height: 3.h,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? MyColors.lingolaPrimaryColor
                                    : MyColors.splashProgressInactive,
                                borderRadius: BorderRadius.circular(1.5.r),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 24.h),

                // Small header text (ince)
                SizedBox(
                  height: 28.h,
                  child: Text(
                    _splashData[_currentPage]['title']!,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: MyColors.splashTextSecondary,
                      height: 1,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // Main title (kalın) - Sabit yükseklik
                SizedBox(
                  height: 110.h,
                  child: Text(
                    _splashData[_currentPage]['description']!,
                    textAlign: TextAlign.left,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: MyColors.splashTextPrimary,
                      height: 1,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                // Get Started / Next Button - Sabit pozisyon
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.lingolaPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _splashData.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: GoogleFonts.montserrat(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: MyColors.white,
                      ),
                    ),
                  ),
                ),

                // Bottom spacing
                SizedBox(height: 48.h),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
