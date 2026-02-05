import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Core/Theme/my_colors.dart';
import '../../Core/Routes/app_routes.dart';

/// Splash View - First Screen (Complete Implementation)
/// All 4 SVGs + Gradient + Text
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.splashPages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            // ========================================
            // LAYER 1: GRADIENT BACKGROUND (FULL SCREEN)
            // ========================================
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      MyColors.splashGradientStart, // #2EC4B6
                      MyColors.splashGradientEnd, // #145C71
                    ],
                  ),
                ),
              ),
            ),

            // ========================================
            // LAYER 2: WORLD MAP 1 (SOL ÜST) - Tam Kapsama
            // ========================================
            Positioned(
              top: 20.h,
              left: -80.w,
              child: Opacity(
                opacity: 0.15,
                child: SvgPicture.asset(
                  'assets/images/world_map_1.svg',
                  width: 320.w,
                  height: 520.h,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    MyColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            // ========================================
            // LAYER 3: WORLD MAP 2 (SAĞ ÜST) - Tam Kapsama
            // ========================================
            Positioned(
              top: 0.h,
              right: -60.w,
              child: Opacity(
                opacity: 0.15,
                child: SvgPicture.asset(
                  'assets/images/world_map_2.svg',
                  width: 180.w,
                  height: 240.h,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    MyColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            // ========================================
            // LAYER 4: WORLD MAP 3 (SAĞ ALT) - Tam Kapsama
            // ========================================
            Positioned(
              bottom: 80.h,
              right: -60.w,
              child: Opacity(
                opacity: 0.15,
                child: SvgPicture.asset(
                  'assets/images/world_map_3.svg',
                  width: 450.w,
                  height: 410.h,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    MyColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            // ========================================
            // LAYER 5: TITLE TEXT "Lingola Travel" - Responsive Centered
            // ========================================
            Positioned(
              left: 0,
              right: 0,
              top: 0.4.sh,
              child: Center(
                child: Text(
                  'Lingola Travel',
                  style: GoogleFonts.montserrat(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w700,
                    color: MyColors.white,
                    letterSpacing: -2.0,
                    height: 1.0,
                  ),
                ),
              ),
            ),

            // ========================================
            // LAYER 6: AIRPLANE SHAPE - Sol Alt Köşe (Responsive)
            // ========================================
            Positioned(
              bottom: 0,
              left: 0,
              child: SvgPicture.asset(
                'assets/images/splash_airplane.svg',
                width: 340.w,
                height: 392.h,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  MyColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
