import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Core/Routes/app_routes.dart';
import '../../Core/Theme/my_colors.dart';
import '../../Repositories/profile_repository.dart';
import '../../Services/secure_storage_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final SecureStorageService _secureStorage = SecureStorageService();
  final ProfileRepository _profileRepository = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 1. Kullanıcı Giriş Yapmış mı?
    final isLoggedIn = await _secureStorage.isLoggedIn();

    if (isLoggedIn) {
      try {
        final profileResult = await _profileRepository.getProfile();
        if (!mounted) return;

        if (profileResult.success && profileResult.data != null) {
          final user = profileResult.data['user'];
          final hasOnboarding = user['target_language'] != null;

          if (hasOnboarding) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.languageSelection,
            );
          }
          return;
        }
      } catch (e) {
        await _secureStorage.clearUserData();
      }
    }

    // 2. GİRİŞ YAPILMAMIŞSA: İlk kez mi açıyor?
    final isFirstLaunch = await _secureStorage.isFirstTime();

    if (mounted) {
      if (isFirstLaunch) {
        // Tanıtım slider'ını göster
        Navigator.pushReplacementNamed(context, AppRoutes.splashPages);
      } else {
        // Daha önce tanıtımı görmüş, direkt Giriş Yap ekranına git
        Navigator.pushReplacementNamed(context, AppRoutes.signIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      MyColors.splashGradientStart,
                      MyColors.splashGradientEnd,
                    ],
                  ),
                ),
              ),
            ),
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
                    letterSpacing: -0.3,
                    height: 1.0,
                  ),
                ),
              ),
            ),
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
