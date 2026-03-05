import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_travel/Core/Routes/app_routes.dart';
import 'package:lingola_travel/Services/secure_storage_service.dart'; // EKLENDİ
import 'package:lingola_travel/generated/locale_keys.g.dart';
import 'package:lingola_travel/main.dart';

import '../../Core/Theme/my_colors.dart';

class SplashPageView extends StatefulWidget {
  const SplashPageView({super.key});

  @override
  State<SplashPageView> createState() => _SplashPageViewState();
}

class _SplashPageViewState extends State<SplashPageView> {
  final SecureStorageService _secureStorage = SecureStorageService(); // EKLENDİ
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  final List<Map<String, String>> _splashData = [
    {
      'image': 'assets/images/splash2.png',
      'title': LocaleKeys.splash1_title.tr(),
      'description': LocaleKeys.splash1_desc.tr(),
    },
    {
      'image': 'assets/images/splash3.png',
      'title': LocaleKeys.splash2_title.tr(),
      'description': LocaleKeys.splash2_desc.tr(),
    },
    {
      'image': 'assets/images/splash4.png',
      'title': LocaleKeys.splash3_title.tr(),
      'description': LocaleKeys.splash3_desc.tr(),
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
      if (mounted) {
        setState(() {
          _currentPage = (_currentPage + 1) % _splashData.length;
        });
      }
    });
  }

  void _nextPage() async {
    // Tanıtımın görüldüğünü kaydet
    await _secureStorage.setFirstTimeCompleted();

    if (mounted) {
      navigatorKey.currentState?.pushReplacementNamed(AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(top: 10.w, left: 10.w, right: 10.w),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: ClipRRect(
                  key: ValueKey<int>(_currentPage),
                  borderRadius: BorderRadius.circular(32.r),
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
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final totalWidth = constraints.maxWidth;
                        final totalSpacing = 12.w;
                        final indicatorWidth =
                            (totalWidth - totalSpacing) / _splashData.length;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            _splashData.length,
                            (index) => GestureDetector(
                              onTap: () => setState(() => _currentPage = index),
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
                  SizedBox(height: 20.h),
                  SizedBox(
                    height: 28.h,
                    child: Text(
                      _splashData[_currentPage]['title']!,
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
                  SizedBox(
                    height: 110.h,
                    child: Text(
                      _splashData[_currentPage]['description']!,
                      style: GoogleFonts.montserrat(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: MyColors.splashTextPrimary,
                        height: 1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
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
                        LocaleKeys.get_started.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: MyColors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
