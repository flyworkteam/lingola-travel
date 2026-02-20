import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../Core/Theme/my_colors.dart';
import '../../Repositories/auth_repository.dart';
import '../../Repositories/notification_repository.dart';
import '../../Services/secure_storage_service.dart';
import '../../Services/auth_service.dart';
import '../../Services/onesignal_service.dart';
import '../PolicyView/policy_detail_view.dart';

/// Sign In View - Onboarding First Screen
/// Social login options: Apple, Google, Facebook, Guest
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
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PolicyDetailView(policyType: 'terms'),
          ),
        );
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PolicyDetailView(policyType: 'privacy'),
          ),
        );
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
  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);

    try {
      // Sign in with Google
      final googleResult = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (!googleResult.success) {
        // Only show error if there's an error message (user didn't cancel)
        if (googleResult.errorMessage != null) {
          _showErrorMessage(googleResult.errorMessage!);
        }
        setState(() => _isGoogleLoading = false);
        return;
      }

      // Login to backend with Google ID token
      final authResult = await _authRepository.loginWithGoogle(
        googleResult.idToken!,
      );

      if (!mounted) return;

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

        // Navigate to language selection or home based on onboarding status
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/language-selection');
        }
      } else {
        _showErrorMessage(authResult.errorMessage ?? 'Giriş başarısız');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Bir hata oluştu: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  /// Handle Apple Sign In
  Future<void> _handleAppleSignIn() async {
    if (_isAppleLoading) return;

    setState(() => _isAppleLoading = true);

    try {
      // Sign in with Apple
      final appleResult = await _authService.signInWithApple();

      if (!mounted) return;

      if (!appleResult.success) {
        // Only show error if there's an error message (user didn't cancel)
        if (appleResult.errorMessage != null) {
          _showErrorMessage(appleResult.errorMessage!);
        }
        setState(() => _isAppleLoading = false);
        return;
      }

      // Login to backend with Apple identity token
      final authResult = await _authRepository.loginWithApple(
        appleResult.identityToken!,
      );

      if (!mounted) return;

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

        // Navigate to language selection or home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/language-selection');
        }
      } else {
        _showErrorMessage(authResult.errorMessage ?? 'Giriş başarısız');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Bir hata oluştu: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  /// Handle Facebook Sign In
  Future<void> _handleFacebookSignIn() async {
    if (_isFacebookLoading) return;

    setState(() => _isFacebookLoading = true);

    try {
      // Sign in with Facebook
      final facebookResult = await _authService.signInWithFacebook();

      if (!mounted) return;

      if (!facebookResult.success) {
        // Only show error if there's an error message (user didn't cancel)
        if (facebookResult.errorMessage != null) {
          _showErrorMessage(facebookResult.errorMessage!);
        }
        setState(() => _isFacebookLoading = false);
        return;
      }

      // Login to backend with Facebook access token
      final authResult = await _authRepository.loginWithFacebook(
        facebookResult.accessToken!,
      );

      if (!mounted) return;

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

        // Navigate to language selection or home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/language-selection');
        }
      } else {
        _showErrorMessage(authResult.errorMessage ?? 'Giriş başarısız');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Facebook ile giriş şu anda kullanılamıyor');
        print('❌ Facebook auth error: $e');
      }
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
  Future<void> _handleGuestLogin() async {
    if (_isGuestLoading) return;

    setState(() => _isGuestLoading = true);

    try {
      // Get device ID
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

      // Login anonymously
      final result = await _authRepository.loginAnonymously(deviceId);

      if (!mounted) return;

      if (result.success && result.accessToken != null) {
        // Save tokens
        print('✅ Guest login successful!');
        print('🔑 Access token: ${result.accessToken!.substring(0, 20)}...');
        print('🔑 Refresh token: ${result.refreshToken?.substring(0, 20)}...');

        await _secureStorage.saveAccessToken(result.accessToken!);
        if (result.refreshToken != null) {
          await _secureStorage.saveRefreshToken(result.refreshToken!);
        }
        if (result.user?.id != null) {
          await _secureStorage.saveUserId(result.user!.id);
          print('👤 User ID saved: ${result.user!.id}');
          // Register device for push notifications
          await _registerUserDevice(result.user!.id);
        }

        // Verify token was saved
        final savedToken = await _secureStorage.getAccessToken();
        print(
          '✅ Token verification: ${savedToken != null ? "Token saved successfully" : "⚠️ Token not saved!"}',
        );

        // Navigate to language selection
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/language-selection');
        }
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.errorMessage ?? 'Giriş başarısız. Lütfen tekrar deneyin.',
              style: GoogleFonts.montserrat(fontSize: 14.sp),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bir hata oluştu: $e',
            style: GoogleFonts.montserrat(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGuestLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Platform detection
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              // Top spacing - KÜÇÜLTÜLDÜ
              SizedBox(height: 24.h),

              // Logo and Title - KÜÇÜLTÜLDÜ
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
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Main Image - KÜÇÜLTÜLDÜ
              SvgPicture.asset(
                'assets/icons/loginphotohd.svg',
                width: 280.w,
                height: 180.h,
                fit: BoxFit.cover,
              ),

              SizedBox(height: 28.h), // ARTTIRILDI: 20h -> 28h
              // Title - KÜÇÜLTÜLDÜ
              Text(
                'Start Your Journey',
                style: GoogleFonts.montserrat(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: MyColors.black,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10.h), // ARTTIRILDI: 8h -> 10h
              // Subtitle - KÜÇÜLTÜLDÜ
              Text(
                'Learn a language where it\'s actually\nspoken. Immerse yourself.',
                style: GoogleFonts.montserrat(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: MyColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h), // ARTTIRILDI: 24h -> 32h
              // ========================================
              // PLATFORM-SPECIFIC BUTTON ORDER
              // ========================================

              // First Button (Apple for iOS, Google for Android)
              isIOS
                  ? _SocialButton(
                      onPressed: _isAppleLoading ? null : _handleAppleSignIn,
                      backgroundColor: MyColors.black,
                      textColor: MyColors.white,
                      icon: 'assets/icons/applelogo.svg',
                      text: 'Continue with Apple',
                      isLoading: _isAppleLoading,
                    )
                  : _SocialButton(
                      onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                      backgroundColor: MyColors.white,
                      textColor: MyColors.black,
                      icon: 'assets/icons/googlelogo.svg',
                      text: 'Continue with Gmail',
                      hasBorder: true,
                      isLoading: _isGoogleLoading,
                    ),

              SizedBox(height: 14.h), // ARTTIRILDI: 12h -> 14h
              // "or" Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: MyColors.grey300, thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      'or',
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

              SizedBox(height: 14.h), // ARTTIRILDI: 12h -> 14h
              // Second Button (Google for iOS, Apple for Android)
              isIOS
                  ? _SocialButton(
                      onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                      backgroundColor: MyColors.white,
                      textColor: MyColors.black,
                      icon: 'assets/icons/googlelogo.svg',
                      text: 'Continue with Gmail',
                      hasBorder: true,
                      isLoading: _isGoogleLoading,
                    )
                  : _SocialButton(
                      onPressed: _isAppleLoading ? null : _handleAppleSignIn,
                      backgroundColor: MyColors.black,
                      textColor: MyColors.white,
                      icon: 'assets/icons/applelogo.svg',
                      text: 'Continue with Apple',
                      isLoading: _isAppleLoading,
                    ),

              SizedBox(height: 14.h), // ARTTIRILDI: 12h -> 14h
              // Facebook Sign In Button (same for both)
              _SocialButton(
                onPressed: _isFacebookLoading ? null : _handleFacebookSignIn,
                backgroundColor: const Color(0xFF1877F2), // Facebook blue
                textColor: MyColors.white,
                icon: 'assets/icons/facebooklogo.svg',
                text: 'Continue with Facebook',
                isLoading: _isFacebookLoading,
              ),

              SizedBox(height: 20.h), // ARTTIRILDI: 16h -> 20h
              // Continue as Guest
              GestureDetector(
                onTap: _isGuestLoading ? null : _handleGuestLogin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isGuestLoading)
                      SizedBox(
                        width: 18.w,
                        height: 18.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF2EC4B6),
                          ),
                        ),
                      )
                    else
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
                      'Continue as Guest',
                      style: GoogleFonts.montserrat(
                        fontSize: 13.sp,
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
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: MyColors.textSecondary,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: GoogleFonts.montserrat(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: MyColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _termsRecognizer,
                      ),
                      const TextSpan(text: '\nand '),
                      TextSpan(
                        text: 'Privacy Policy.',
                        style: GoogleFonts.montserrat(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: MyColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _privacyRecognizer,
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
                      fontSize: 15.sp,
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
