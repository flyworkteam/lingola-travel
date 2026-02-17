import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../Core/Theme/my_colors.dart';
import '../../Repositories/auth_repository.dart';
import '../../Services/secure_storage_service.dart';

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
  bool _isLoading = false;

  /// Show "Coming Soon" dialog for social login
  void _showComingSoonDialog(String provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: MyColors.lingolaPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  size: 32.w,
                  color: MyColors.lingolaPrimaryColor,
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                'Çok Yakında!',
                style: GoogleFonts.montserrat(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: MyColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Message
              Text(
                '$provider ile giriş özelliği çok yakında eklenecek.\n\nŞimdilik misafir kullanıcı olarak devam edebilirsiniz.',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: MyColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.lingolaPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Anladım',
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: MyColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle guest login
  Future<void> _handleGuestLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

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
        await _secureStorage.saveAccessToken(result.accessToken!);
        if (result.refreshToken != null) {
          await _secureStorage.saveRefreshToken(result.refreshToken!);
        }
        if (result.user?.id != null) {
          await _secureStorage.saveUserId(result.user!.id);
        }

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
        setState(() => _isLoading = false);
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
              Container(
                width: 280.w,
                height: 180.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/onboardinglogo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
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
                      onPressed: () => _showComingSoonDialog('Apple'),
                      backgroundColor: MyColors.black,
                      textColor: MyColors.white,
                      icon: 'assets/icons/applelogo.svg',
                      text: 'Continue with Apple',
                    )
                  : _SocialButton(
                      onPressed: () => _showComingSoonDialog('Google'),
                      backgroundColor: MyColors.white,
                      textColor: MyColors.black,
                      icon: 'assets/icons/googlelogo.svg',
                      text: 'Continue with Gmail',
                      hasBorder: true,
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
                      onPressed: () => _showComingSoonDialog('Google'),
                      backgroundColor: MyColors.white,
                      textColor: MyColors.black,
                      icon: 'assets/icons/googlelogo.svg',
                      text: 'Continue with Gmail',
                      hasBorder: true,
                    )
                  : _SocialButton(
                      onPressed: () => _showComingSoonDialog('Apple'),
                      backgroundColor: MyColors.black,
                      textColor: MyColors.white,
                      icon: 'assets/icons/applelogo.svg',
                      text: 'Continue with Apple',
                    ),

              SizedBox(height: 14.h), // ARTTIRILDI: 12h -> 14h
              // Facebook Sign In Button (same for both)
              _SocialButton(
                onPressed: () => _showComingSoonDialog('Facebook'),
                backgroundColor: const Color(0xFF1877F2), // Facebook blue
                textColor: MyColors.white,
                icon: 'assets/icons/facebooklogo.svg',
                text: 'Continue with Facebook',
              ),

              SizedBox(height: 20.h), // ARTTIRILDI: 16h -> 20h
              // Continue as Guest
              GestureDetector(
                onTap: _isLoading ? null : _handleGuestLogin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
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
                          color: MyColors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: '\nand '),
                      TextSpan(
                        text: 'Privacy Policy.',
                        style: GoogleFonts.montserrat(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: MyColors.black,
                          decoration: TextDecoration.underline,
                        ),
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
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final String icon;
  final String text;
  final bool hasBorder;

  const _SocialButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.text,
    this.hasBorder = false,
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
