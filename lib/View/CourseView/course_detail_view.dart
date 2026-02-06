import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import '../LessonView/lesson_detail_view.dart';

class CourseDetailView extends StatefulWidget {
  final Map<String, dynamic> courseData;
  final bool isPremium;

  const CourseDetailView({
    super.key,
    required this.courseData,
    this.isPremium = false,
  });

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _lessons = [
    {
      'number': 1,
      'title': 'At the Check-in Desk',
      'duration': 8,
      'status': 'completed',
    },
    {
      'number': 2,
      'title': 'Security Procedures',
      'duration': 12,
      'status': 'in_progress',
    },
    {
      'number': 3,
      'title': 'Finding Your Gate',
      'duration': 10,
      'status': 'locked',
    },
    {
      'number': 4,
      'title': 'Duty-Free Dialogue',
      'duration': 15,
      'status': 'locked',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate blur amount based on scroll - more aggressive
    final blurAmount = (_scrollOffset / 50).clamp(0.0, 15.0);
    final opacity = (_scrollOffset / 100).clamp(0.0, 0.7);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image with blur
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Base image
                Image.asset(
                  widget.courseData['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: MyColors.grey200,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48.sp,
                          color: MyColors.grey400,
                        ),
                      ),
                    );
                  },
                ),
                // Blur layer - always visible when scrolling
                if (_scrollOffset > 5)
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: blurAmount,
                        sigmaY: blurAmount,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(opacity),
                      ),
                    ),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Spacer for image
                SizedBox(height: 290.h),

                // White curved card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.r),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 140.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Terminal Talk:\nAirport Basics',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Stats row
                      Row(
                        children: [
                          _buildStatChip(
                            iconPath: 'assets/icons/12lesson.svg',
                            text: '12 Lessons',
                          ),
                          SizedBox(width: 16.w),
                          _buildStatChip(
                            iconPath: 'assets/icons/45min.svg',
                            text: '45 Mins',
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Level chip
                      _buildStatChip(
                        iconPath: 'assets/icons/intermediate.svg',
                        text: 'Intermediate',
                      ),

                      SizedBox(height: 20.h),

                      // Description
                      Text(
                        'Master the essential English phrases you\'ll need from the moment you step off the plane. Focus on vocabulary used in real-world airport scenarios.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                          color: Color(0xFF666666),
                          height: 1.6,
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Course Content header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Course Content',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '65% Completed',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Lessons list
                      ..._lessons.map((lesson) => _buildLessonItem(lesson)),

                      SizedBox(height: 24.h),

                      // Resume button
                      _buildResumeButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 20.h,
            child: CustomBottomNavBar(
              currentIndex: 1,
              isPremium: widget.isPremium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    IconData? icon,
    String? iconPath,
    Color? iconColor,
    required String text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconPath != null)
            SvgPicture.asset(
              iconPath,
              width: 16.w,
              height: 16.w,
              colorFilter: ColorFilter.mode(
                iconColor ?? Color(0xFF4ECDC4),
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
            )
          else if (icon != null)
            Icon(icon, size: 16.sp, color: Color(0xFF4ECDC4)),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(Map<String, dynamic> lesson) {
    final status = lesson['status'];
    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';
    final isLocked = status == 'locked';

    Color bgColor;
    Color iconBgColor;
    Widget iconWidget;

    if (isCompleted) {
      bgColor = Color(0xFFF0F9FF);
      iconWidget = Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Color(0xFFE0F7F4),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/tamamlandi.svg',
            width: 24.w,
            height: 24.w,
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (isInProgress) {
      bgColor = Color(0xFFE8F9F7);
      iconWidget = Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Color(0xFF4ECDC4),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(Icons.play_arrow, color: Colors.white, size: 28.sp),
        ),
      );
    } else {
      bgColor = Color(0xFFF9F9F9);
      iconWidget = Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/tamamlanmadi.svg',
            width: 20.w,
            height: 20.w,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonDetailView(
                lessonData: lesson,
                isPremium: widget.isPremium,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            // Icon container
            iconWidget,

            SizedBox(width: 16.w),

            // Lesson info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${lesson['number']}. ${lesson['title']}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: isLocked ? Color(0xFFBDBDBD) : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isCompleted
                        ? '${lesson['duration']} Mins • Completed'
                        : isInProgress
                        ? '${lesson['duration']} Mins • In Progress'
                        : '${lesson['duration']} Mins',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonDetailView(
              lessonData: _lessons[1],
              isPremium: widget.isPremium,
            ),
          ),
        );
      },
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
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_filled, color: Colors.white, size: 24.sp),
            SizedBox(width: 10.w),
            Text(
              'RESUME LESSON 2',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
