import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';

class LessonResultView extends StatelessWidget {
  final bool isSuccess;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  const LessonResultView({
    super.key,
    required this.isSuccess,
    required this.onContinue,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Airport image
          Container(
            width: double.infinity,
            height: 200.h,
            margin: EdgeInsets.symmetric(horizontal: 40.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              image: DecorationImage(
                image: AssetImage('assets/images/airport_terminal.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.1),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          SizedBox(height: 40.h),

          // Success or Try Again icon
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: isSuccess
                  ? Color(0xFF4ECDC4).withOpacity(0.1)
                  : Color(0xFFFF6B6B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Badge shape
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: isSuccess ? Color(0xFF4ECDC4) : Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Center(
                    child: Icon(
                      isSuccess ? Icons.check : Icons.close,
                      size: 60.sp,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Small X badge for Try Again
                if (!isSuccess)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Success or Try Again text
          Text(
            isSuccess ? 'Successful!' : 'Try Again!',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              color: isSuccess ? Color(0xFF4ECDC4) : Color(0xFFFF6B6B),
            ),
          ),

          SizedBox(height: 40.h),

          // Current step indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 24.sp, color: Color(0xFF4ECDC4)),
              SizedBox(width: 8.w),
              Text(
                '3/10',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 40.h),

          // Scoring cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              children: [
                _buildScoreCard(
                  icon: Icons.check_circle,
                  color: Color(0xFF4ECDC4),
                  title: 'Correct',
                  score: isSuccess ? '+20' : '0',
                ),
                SizedBox(height: 12.h),
                _buildScoreCard(
                  icon: Icons.star,
                  color: Color(0xFFFFB800),
                  title: 'Combo',
                  score: isSuccess ? '+10' : '0',
                ),
              ],
            ),
          ),

          Spacer(),

          // Continue or Retry button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
            child: GestureDetector(
              onTap: isSuccess ? onContinue : onRetry,
              child: Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  color: Color(0xFF4ECDC4),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4ECDC4).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isSuccess ? 'Continue Learning' : 'Try Again',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard({
    required IconData icon,
    required Color color,
    required String title,
    required String score,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: MyColors.grey200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: color),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              color: MyColors.textPrimary,
            ),
          ),
          Spacer(),
          Text(
            score,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
