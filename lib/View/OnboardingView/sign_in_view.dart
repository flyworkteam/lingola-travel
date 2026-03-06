import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_travel/Core/Routes/app_routes.dart';
import 'package:lingola_travel/Core/Utils/future_extensions.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Core/Theme/my_colors.dart';
import '../../Models/user_model.dart';
import '../../Repositories/auth_repository.dart';
import '../../Repositories/notification_repository.dart';
import '../../Services/auth_service.dart';
import '../../Services/onesignal_service.dart';
import '../../Services/secure_storage_service.dart';

class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  final AuthRepository _authRepository = AuthRepository();
  final SecureStorageService _secureStorage = SecureStorageService();
  final AuthService _authService = AuthService();
  final NotificationRepository _notificationRepository =
      NotificationRepository();

  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  // final bool _isFacebookLoading = false;
  bool _isGuestLoading = false;

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        final Uri url = Uri.parse('https://fly-work.com/lingolatravel/terms/');
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          debugPrint('Could not launch $url');
        }
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        final Uri url = Uri.parse(
          'https://fly-work.com/lingolatravel/privacy-policy/',
        );
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          debugPrint('Could not launch $url');
        }
      };
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _registerUserDevice(String userId) async {
    try {
      await OneSignalService().setExternalUserId(userId);
      final playerId = await OneSignalService().getPlayerId();

      if (playerId != null && playerId.isNotEmpty) {
        await _notificationRepository.registerDevice(
          playerId: playerId,
          platform: Platform.isIOS ? 'ios' : 'android',
        );
        debugPrint('✅ Device registered for push notifications');
      }
    } catch (e) {
      debugPrint('⚠️ Device registration error: $e');
    }
  }

  /// Ortak yönlendirme fonksiyonu: Kullanıcının kaydı varsa Home'a, yoksa Onboarding'e atar.
  void _routeBasedOnUserStatus(BuildContext context, UserModel user) {
    // Tüm onboarding alanlarını kontrol ediyoruz
    final bool hasLanguage =
        user.targetLanguage != null &&
        user.targetLanguage != 'null' &&
        user.targetLanguage!.trim().isNotEmpty;
    final bool hasLevel =
        user.englishLevel != null &&
        user.englishLevel != 'null' &&
        user.englishLevel!.trim().isNotEmpty;
    final bool hasGoal =
        user.dailyGoal != null &&
        user.dailyGoal != 'null' &&
        user.dailyGoal!.trim().isNotEmpty;
    final bool hasProfession =
        user.profession != null &&
        user.profession != 'null' &&
        user.profession!.trim().isNotEmpty;

    // Herhangi bir onboarding verisi varsa süreç tamamlanmış sayılır
    final bool hasCompletedOnboarding =
        hasLanguage || hasLevel || hasGoal || hasProfession;

    debugPrint(
      '✅ Onboarding Status: $hasCompletedOnboarding | Lang: $hasLanguage, Level: $hasLevel, Goal: $hasGoal, Prof: $hasProfession',
    );

    if (!context.mounted) return;

    if (hasCompletedOnboarding) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.languageSelection);
    }
  }

  Future<UserModel?> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return null;
    setState(() => _isGoogleLoading = true);

    try {
      final googleResult = await _authService.signInWithGoogle();
      if (!mounted) return null;

      if (!googleResult.success) {
        if (googleResult.errorMessage != null) {
          _showErrorMessage(googleResult.errorMessage!);
        }
        setState(() => _isGoogleLoading = false);
        return null;
      }

      final authResult = await _authRepository.loginWithGoogle(
        googleResult.idToken!,
      );

      if (!mounted) return null;

      if (authResult.success &&
          authResult.accessToken != null &&
          authResult.user != null) {
        await _secureStorage.saveAccessToken(authResult.accessToken!);
        if (authResult.refreshToken != null) {
          await _secureStorage.saveRefreshToken(authResult.refreshToken!);
        }
        await _secureStorage.saveUserId(authResult.user!.id);
        await _registerUserDevice(authResult.user!.id);

        return authResult.user;
      } else {
        _showErrorMessage(
          authResult.errorMessage ?? LocaleKeys.login_failed.tr(),
        );
        return null;
      }
    } catch (e) {
      if (mounted) _showErrorMessage('${LocaleKeys.error_occurred.tr()}: $e');
      return null;
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<UserModel?> _handleAppleSignIn() async {
    if (_isAppleLoading) return null;
    setState(() => _isAppleLoading = true);

    try {
      final appleResult = await _authService.signInWithApple();
      if (!mounted) return null;

      if (!appleResult.success) {
        if (appleResult.errorMessage != null) {
          _showErrorMessage(appleResult.errorMessage!);
        }
        setState(() => _isAppleLoading = false);
        return null;
      }

      final authResult = await _authRepository.loginWithApple(
        appleResult.identityToken!,
      );

      if (!mounted) return null;

      if (authResult.success &&
          authResult.accessToken != null &&
          authResult.user != null) {
        await _secureStorage.saveAccessToken(authResult.accessToken!);
        if (authResult.refreshToken != null) {
          await _secureStorage.saveRefreshToken(authResult.refreshToken!);
        }
        await _secureStorage.saveUserId(authResult.user!.id);
        await _registerUserDevice(authResult.user!.id);

        return authResult.user;
      } else {
        _showErrorMessage(
          authResult.errorMessage ?? LocaleKeys.login_failed.tr(),
        );
        return null;
      }
    } catch (e) {
      if (mounted) _showErrorMessage('${LocaleKeys.error_occurred.tr()}: $e');
      return null;
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  // Future<UserModel?> _handleFacebookSignIn() async {
  //   if (_isFacebookLoading) return null;
  //   setState(() => _isFacebookLoading = true);

  //   try {
  //     final facebookResult = await _authService.signInWithFacebook();
  //     if (!mounted) return null;

  //     if (!facebookResult.success) {
  //       if (facebookResult.errorMessage != null) {
  //         _showErrorMessage(facebookResult.errorMessage!);
  //       }
  //       setState(() => _isFacebookLoading = false);
  //       return null;
  //     }

  //     final authResult = await _authRepository.loginWithFacebook(
  //       facebookResult.accessToken!,
  //     );

  //     if (!mounted) return null;

  //     if (authResult.success &&
  //         authResult.accessToken != null &&
  //         authResult.user != null) {
  //       await _secureStorage.saveAccessToken(authResult.accessToken!);
  //       if (authResult.refreshToken != null) {
  //         await _secureStorage.saveRefreshToken(authResult.refreshToken!);
  //       }
  //       await _secureStorage.saveUserId(authResult.user!.id);
  //       await _registerUserDevice(authResult.user!.id);

  //       return authResult.user;
  //     } else {
  //       _showErrorMessage(
  //         authResult.errorMessage ?? LocaleKeys.login_failed.tr(),
  //       );
  //       return null;
  //     }
  //   } catch (e) {
  //     if (mounted)
  //       _showErrorMessage('${LocaleKeys.error_occurred.tr()} (Facebook): $e');
  //     return null;
  //   } finally {
  //     if (mounted) setState(() => _isFacebookLoading = false);
  //   }
  // }

  Future<UserModel?> _handleGuestLogin() async {
    if (_isGuestLoading) return null;
    setState(() => _isGuestLoading = true);

    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceId;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown-ios-device';
      } else {
        deviceId = 'unknown-device';
      }

      final result = await _authRepository.loginAnonymously(deviceId);
      if (!mounted) return null;

      if (result.success && result.accessToken != null && result.user != null) {
        await _secureStorage.saveAccessToken(result.accessToken!);
        if (result.refreshToken != null) {
          await _secureStorage.saveRefreshToken(result.refreshToken!);
        }
        await _secureStorage.saveUserId(result.user!.id);
        await _registerUserDevice(result.user!.id);

        return result.user;
      } else {
        _showErrorMessage(result.errorMessage ?? LocaleKeys.login_failed.tr());
        return null;
      }
    } catch (e) {
      if (mounted) _showErrorMessage('${LocaleKeys.error_occurred.tr()}: $e');
      return null;
    } finally {
      if (mounted) setState(() => _isGuestLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat(fontSize: 14.sp)),
        backgroundColor: MyColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final String termsTemplate = LocaleKeys.terms_privacy_note.tr();
    final List<String> textParts = termsTemplate.split('{}');

    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 28.w,
                    height: 28.h,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Lingola Travel',
                    style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: MyColors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.asset(
                  'assets/images/loginperson.png',
                  width: 280.w,
                  height: 180.h,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              SizedBox(height: 28.h),
              Text(
                LocaleKeys.sign_in_title.tr(),
                style: GoogleFonts.montserrat(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: MyColors.black,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                LocaleKeys.sign_in_subtitle.tr(),
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: MyColors.black,
                  letterSpacing: -0.5,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              isIOS
                  ? _SocialButton(
                      onPressed: () async {
                        final UserModel? user = await _handleAppleSignIn()
                            .withLoading(context);
                        if (user != null && mounted) {
                          _routeBasedOnUserStatus(context, user);
                        }
                      },
                      backgroundColor: MyColors.black,
                      textColor: MyColors.white,
                      icon: 'assets/icons/applelogo.svg',
                      text: LocaleKeys.continue_with_apple.tr(),
                      isLoading: _isAppleLoading,
                    )
                  : _SocialButton(
                      onPressed: () async {
                        final UserModel? user = await _handleGoogleSignIn()
                            .withLoading(context);
                        if (user != null && mounted) {
                          _routeBasedOnUserStatus(context, user);
                        }
                      },
                      backgroundColor: MyColors.white,
                      textColor: MyColors.black,
                      icon: 'assets/icons/googlelogo.svg',
                      text: LocaleKeys.continue_with_gmail.tr(),
                      hasBorder: true,
                      isLoading: _isGoogleLoading,
                    ),

              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: MyColors.grey300, thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      LocaleKeys.or_divider.tr(),
                      style: GoogleFonts.montserrat(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: MyColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: MyColors.grey300, thickness: 1),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              isIOS
                  ? _SocialButton(
                      onPressed: () async {
                        final UserModel? user = await _handleGoogleSignIn()
                            .withLoading(context);
                        if (user != null && mounted) {
                          _routeBasedOnUserStatus(context, user);
                        }
                      },
                      backgroundColor: MyColors.white,
                      textColor: MyColors.black,
                      icon: 'assets/icons/googlelogo.svg',
                      text: LocaleKeys.continue_with_gmail.tr(),
                      hasBorder: true,
                      isLoading: _isGoogleLoading,
                    )
                  : _SocialButton(
                      onPressed: () async {
                        final UserModel? user = await _handleAppleSignIn()
                            .withLoading(context);
                        if (user != null && mounted) {
                          _routeBasedOnUserStatus(context, user);
                        }
                      },
                      backgroundColor: MyColors.black,
                      textColor: MyColors.white,
                      icon: 'assets/icons/applelogo.svg',
                      text: LocaleKeys.continue_with_apple.tr(),
                      isLoading: _isAppleLoading,
                    ),

              // SizedBox(height: 14.h),
              // _SocialButton(
              //   onPressed: () async {
              //     final UserModel? user = await _handleFacebookSignIn()
              //         .withLoading(context);
              //     if (user != null && mounted) {
              //       _routeBasedOnUserStatus(context, user);
              //     }
              //   },
              //   backgroundColor: const Color(0xFF1877F2),
              //   textColor: MyColors.white,
              //   icon: 'assets/icons/facebooklogo.svg',
              //   text: LocaleKeys.continue_with_facebook.tr(),
              //   isLoading: _isFacebookLoading,
              // ),
              SizedBox(height: 20.h),

              GestureDetector(
                onTap: () async {
                  final UserModel? user = await _handleGuestLogin().withLoading(
                    context,
                  );
                  if (user != null && mounted) {
                    _routeBasedOnUserStatus(context, user);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/userlogo.svg',
                      width: 18.w,
                      height: 18.h,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF2EC4B6),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      LocaleKeys.continue_as_guest.tr(),
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2EC4B6),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.montserrat(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.4,
                    ),
                    children: [
                      if (textParts.isNotEmpty) TextSpan(text: textParts[0]),
                      TextSpan(
                        text: LocaleKeys.terms_of_service.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _termsRecognizer,
                      ),
                      if (textParts.length > 1) TextSpan(text: textParts[1]),
                      TextSpan(
                        text: LocaleKeys.privacy_policy.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _privacyRecognizer,
                      ),
                      if (textParts.length > 2) TextSpan(text: textParts[2]),
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
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final String icon;
  final String text;
  final bool hasBorder;
  final bool isLoading;

  const _SocialButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.text,
    this.hasBorder = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: hasBorder
                ? BorderSide(color: MyColors.grey300, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, width: 18.w, height: 18.h),
            SizedBox(width: 10.w),
            Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
