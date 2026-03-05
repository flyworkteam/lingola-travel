import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart'; // Eklendi
import 'package:lingola_travel/generated/locale_keys.g.dart'; // Eklendi

class ShareFriendView extends StatelessWidget {
  const ShareFriendView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/icons/gerigelmeiconu.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    LocaleKeys.profile_share_title.tr(), // Yerelleştirildi
                    style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),

                    // Illustration
                    SvgPicture.asset(
                      'assets/images/sharewithfriend.svg',
                      width: 320.w,
                      height: 240.h,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: 40.h),

                    // Title
                    Text(
                      LocaleKeys.profile_share_title.tr(), // Yerelleştirildi
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Subtitle
                    Text(
                      LocaleKeys.profile_share_subtitle.tr(), // Yerelleştirildi
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Link Container
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // LINK label
                          Text(
                            LocaleKeys.profile_share_link_label
                                .tr(), // Yerelleştirildi
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF9CA3AF),
                              letterSpacing: 1.2,
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Link text box
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'https://lingolatravel.app/invite?friend=alex',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Copy the link button
                          Container(
                            width: double.infinity,
                            height: 54.h,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4ECDC4), Color(0xFF2EC4B6)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4ECDC4,
                                  ).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    const ClipboardData(
                                      text:
                                          'https://lingolatravel.app/invite?friend=alex',
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        LocaleKeys.profile_share_link_copied.tr(),
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF4ECDC4),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      margin: EdgeInsets.all(16.w),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(14.r),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/sharewithfirendkopya.svg',
                                      width: 24.w,
                                      height: 24.w,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      LocaleKeys.profile_share_copy_button.tr(),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
