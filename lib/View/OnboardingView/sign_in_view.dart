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
import 'package:lingola_travel/main.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Core/Theme/my_colors.dart';
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

  // Separate loading states for each button
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isFacebookLoading = false;
  bool _isGuestLoading = false;

  // Gesture recognizers for policy links
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

  /// Register user device for push notifications
  Future<void> _registerUserDevice(String userId) async {
    try {
      // Set OneSignal external user ID
      await OneSignalService().setExternalUserId(userId);

      // Get OneSignal player ID
      final playerId = await OneSignalService().getPlayerId();

      if (playerId != null && playerId.isNotEmpty) {
        // Register device to backend
        await _notificationRepository.registerDevice(
          playerId: playerId,
          platform: Platform.isIOS ? 'ios' : 'android',
        );
        print('✅ Device registered for push notifications');
      }
    } catch (e) {
      print('⚠️ Device registration error: $e');
    }
  }

  /// Handle Google Sign In
  // DİKKAT: Future<void> yerine Future<bool> döndürüyoruz ki success durumunu bilelim
  Future<bool> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return false;

    setState(() => _isGoogleLoading = true);

    try {
      // Sign in with Google
      final googleResult = await _authService.signInWithGoogle();

      if (!mounted) return false;

      if (!googleResult.success) {
        if (googleResult.errorMessage != null) {
          _showErrorMessage(googleResult.errorMessage!);
        }
        setState(() => _isGoogleLoading = false);
        return false;
      }

      // Login to backend with Google ID token
      final authResult = await _authRepository.loginWithGoogle(
        googleResult.idToken!,
      );

      if (!mounted) return false;

      if (authResult.success && authResult.accessToken != null) {
        // Save tokens and user data
        await _secureStorage.saveAccessToken(authResult.accessToken!);
        if (authResult.refreshToken != null) {
          await _secureStorage.saveRefreshToken(authResult.refreshToken!);
        }
        if (authResult.user?.id != null) {
          await _secureStorage.saveUserId(authResult.user!.id);
          // Register device for push notifications
          await _registerUserDevice(authResult.user!.id);
        }

        // Başarılı olduğunu söylüyoruz, yönlendirmeyi butonda yapacağız
        return true;
      } else {
        _showErrorMessage(
          authResult.errorMessage ?? LocaleKeys.login_failed.tr(),
        );
        return false;
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('${LocaleKeys.error_occurred.tr()}: $e');
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  /// Handle Apple Sign In
  Future<bool> _handleAppleSignIn() async {
    if (_isAppleLoading) return false;

    setState(() => _isAppleLoading = true);

    try {
      // Sign in with Apple
      final appleResult = await _authService.signInWithApple();

      if (!mounted) return false;

      if (!appleResult.success) {
        if (appleResult.errorMessage != null) {
          _showErrorMessage(appleResult.errorMessage!);
        }
        setState(() => _isAppleLoading = false);
        return false;
      }

      // Login to backend with Apple identity token
      final authResult = await _authRepository.loginWithApple(
        appleResult.identityToken!,
      );

      if (!mounted) return false;

      if (authResult.success && authResult.accessToken != null) {
        // Save tokens and user data
        await _secureStorage.saveAccessToken(authResult.accessToken!);
        if (authResult.refreshToken != null) {
          await _secureStorage.saveRefreshToken(authResult.refreshToken!);
        }
        if (authResult.user?.id != null) {
          await _secureStorage.saveUserId(authResult.user!.id);
          // Register device for push notifications
          await _registerUserDevice(authResult.user!.id);
        }

        return true;
      } else {
        _showErrorMessage(
          authResult.errorMessage ?? LocaleKeys.login_failed.tr(),
        );
        return false;
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('${LocaleKeys.error_occurred.tr()}: $e');
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  /// Handle Facebook Sign In
  Future<bool> _handleFacebookSignIn() async {
    if (_isFacebookLoading) return false;

    setState(() => _isFacebookLoading = true);

    try {
      // Sign in with Facebook
      final facebookResult = await _authService.signInWithFacebook();

      if (!mounted) return false;

      if (!facebookResult.success) {
        if (facebookResult.errorMessage != null) {
          _showErrorMessage(facebookResult.errorMessage!);
        }
        setState(() => _isFacebookLoading = false);
        return false;
      }

      // Login to backend with Facebook access token
      final authResult = await _authRepository.loginWithFacebook(
        facebookResult.accessToken!,
      );

      if (!mounted) return false;

      if (authResult.success && authResult.accessToken != null) {
        // Save tokens and user data
        await _secureStorage.saveAccessToken(authResult.accessToken!);
        if (authResult.refreshToken != null) {
          await _secureStorage.saveRefreshToken(authResult.refreshToken!);
        }
        if (authResult.user?.id != null) {
          await _secureStorage.saveUserId(authResult.user!.id);
          // Register device for push notifications
          await _registerUserDevice(authResult.user!.id);
        }

        return true;
      } else {
        _showErrorMessage(
          authResult.errorMessage ?? LocaleKeys.login_failed.tr(),
        );
        return false;
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('${LocaleKeys.error_occurred.tr()} (Facebook): $e');
        print('❌ Facebook auth error: $e');
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isFacebookLoading = false);
      }
    }
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat(fontSize: 14.sp)),
        backgroundColor: MyColors.error,
      ),
    );
  }

  /// Handle guest login
 Future<bool> _handleGuestLogin() async {
    if (_isGuestLoading) return false;
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

      // Backend isteği
      final result = await _authRepository.loginAnonymously(deviceId);

      if (!mounted) return false;

      if (result.success && result.accessToken != null) {
        // Bilgileri kaydet
        await _secureStorage.saveAccessToken(result.accessToken!);
        if (result.refreshToken != null) {
          await _secureStorage.saveRefreshToken(result.refreshToken!);
        }
        if (result.user?.id != null) {
          await _secureStorage.saveUserId(result.user!.id);
          await _registerUserDevice(result.user!.id);
        }

        // --- KRİTİK NOKTA ---
        // Eğer backend'den gelen user objesinde 'target_language' gibi
        // daha önce doldurulmuş bir alan varsa onboarding'i atla.
        // Not: Backend modelinde bu alanların olduğunu varsayıyorum.
        final bool hasCompletedOnboarding = result.user?.targetLanguage != null;

        if (hasCompletedOnboarding) {
          navigatorKey.currentState?.pushReplacementNamed(AppRoutes.home);
        } else {
          navigatorKey.currentState?.pushReplacementNamed(
            AppRoutes.languageSelection,
          );
        }

        return true;
      } else {
        _showErrorMessage(result.errorMessage ?? LocaleKeys.login_failed.tr());
        return false;
      }
    } catch (e) {
      if (mounted) _showErrorMessage('${LocaleKeys.error_occurred.tr()}: $e');
      return false;
    } finally {
      if (mounted) setState(() => _isGuestLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    // Platform detection
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    // Metni "{}" işaretlerinden bölüyoruz
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
                        // BURADA YÖNLENDİRME .withLoading() SONRASI YAPILIYOR
                        final success = await _handleAppleSignIn().withLoading(
                          context,
                        );
                        if (success) {
                          navigatorKey.currentState?.pushReplacementNamed(
                            AppRoutes.languageSelection,
                          );
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
                        final success = await _handleGoogleSignIn().withLoading(
                          context,
                        );
                        if (success) {
                          navigatorKey.currentState?.pushReplacementNamed(
                            AppRoutes.languageSelection,
                          );
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
                        final success = await _handleGoogleSignIn().withLoading(
                          context,
                        );
                        if (success) {
                          navigatorKey.currentState?.pushReplacementNamed(
                            AppRoutes.languageSelection,
                          );
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
                        final success = await _handleAppleSignIn().withLoading(
                          context,
                        );
                        if (success) {
                          navigatorKey.currentState?.pushReplacementNamed(
                            AppRoutes.languageSelection,
                          );
                        }
                      },
                      backgroundColor: MyColors.black,
                      textColor: MyColors.white,
                      icon: 'assets/icons/applelogo.svg',
                      text: LocaleKeys.continue_with_apple.tr(),
                      isLoading: _isAppleLoading,
                    ),

              SizedBox(height: 14.h),

              _SocialButton(
                onPressed: () async {
                  final success = await _handleFacebookSignIn().withLoading(
                    context,
                  );
                  if (success) {
                    navigatorKey.currentState?.pushReplacementNamed(
                      AppRoutes.languageSelection,
                    );
                  }
                },
                backgroundColor: const Color(0xFF1877F2),
                textColor: MyColors.white,
                icon: 'assets/icons/facebooklogo.svg',
                text: LocaleKeys.continue_with_facebook.tr(),
                isLoading: _isFacebookLoading,
              ),

              SizedBox(height: 20.h),

              GestureDetector(
                onTap: () async {
                  final success = await _handleGuestLogin().withLoading(
                    context,
                  );
                  if (success) {
                    navigatorKey.currentState?.pushReplacementNamed(
                      AppRoutes.languageSelection,
                    );
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

              // Terms and Privacy
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
                      if (textParts.isNotEmpty)
                        TextSpan(text: textParts[0]), // "Devam ederek, " vb.

                      TextSpan(
                        text: LocaleKeys.terms_of_service.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _termsRecognizer,
                      ),

                      if (textParts.length > 1)
                        TextSpan(text: textParts[1]), // " ve " vb.

                      TextSpan(
                        text: LocaleKeys.privacy_policy.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _privacyRecognizer,
                      ),

                      if (textParts.length > 2)
                        TextSpan(text: textParts[2]), // " metinlerini..." vb.
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

/// Social Sign In Button Widget
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
        child: isLoading
            ? SizedBox(
                width: 18.w,
                height: 18.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
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
