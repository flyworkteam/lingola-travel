import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/icons/gerigelmeiconu.svg',
                      width: 13.w,
                      height: 13.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Share with Friend',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
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
                      'Share with Friend',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Subtitle
                    Text(
                      'Invite your friends and enjoy\nlearning together',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF6B7280),
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
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // LINK label
                          Text(
                            'LINK',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              color: Color(0xFF9CA3AF),
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
                              color: Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'https://lingolatravel.app/invite?frie...',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF1A1A1A),
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
                              gradient: LinearGradient(
                                colors: [Color(0xFF4ECDC4), Color(0xFF2EC4B6)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF4ECDC4).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text:
                                          'https://lingolatravel.app/invite?friend=123',
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Link copied to clipboard!',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: Color(0xFF4ECDC4),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      margin: EdgeInsets.all(16.w),
                                      duration: Duration(seconds: 2),
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
                                      colorFilter: ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      'Copy the link',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Montserrat',
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
