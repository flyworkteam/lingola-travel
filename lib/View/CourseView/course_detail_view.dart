import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import '../LessonView/lesson_detail_view.dart';
import '../VocabularyView/travel_vocabulary_view.dart';
import '../DictionaryView/visual_dictionary_view.dart';
import '../ProfileView/profile_view.dart';

class CourseDetailView extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const CourseDetailView({super.key, required this.courseData});

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> {
  int _selectedNavIndex = 1; // Course is index 1 (plane icon)

  // Mock lesson data
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
    return Scaffold(
      backgroundColor: MyColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header with background image
              _buildHeader(),

              // Course info and lesson list
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course info card
                    _buildCourseInfoCard(),

                    SizedBox(height: 24.h),

                    // Course content section
                    _buildCourseContentSection(),

                    SizedBox(height: 24.h),

                    // Resume button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: _buildResumeButton(),
                    ),

                    SizedBox(height: 100.h), // Space for bottom nav
                  ],
                ),
              ),
            ],
          ),

          // Floating bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 20.h,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  /// Header with background image
  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 250.h,
      pinned: true,
      backgroundColor: MyColors.lingolaPrimaryColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: MyColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              widget.courseData['image'],
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
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

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Course info card
  Widget _buildCourseInfoCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '${widget.courseData['category']}: ${widget.courseData['title']}',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              color: MyColors.textPrimary,
              height: 1.2,
            ),
          ),

          SizedBox(height: 16.h),

          // Stats row
          Row(
            children: [
              _buildStatItem(
                Icons.book_outlined,
                '${widget.courseData['lessons']} Lessons',
              ),
              SizedBox(width: 20.w),
              _buildStatItem(Icons.access_time, '45 Mins'),
              SizedBox(width: 20.w),
              _buildStatItem(Icons.bar_chart, 'Intermediate'),
            ],
          ),

          SizedBox(height: 16.h),

          // Description
          Text(
            'Master the essential English phrases you\'ll need from the moment you step off the plane. Focus on vocabulary used in real-world airport scenarios.',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
              color: MyColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Single stat item
  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Color(0xFF4ECDC4)),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
            color: MyColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Course content section
  Widget _buildCourseContentSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Content',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),
              Text(
                '${widget.courseData['progress']}% Completed',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF4ECDC4),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Lesson list
          ..._lessons.map((lesson) => _buildLessonCard(lesson)).toList(),
        ],
      ),
    );
  }

  /// Single lesson card
  Widget _buildLessonCard(Map<String, dynamic> lesson) {
    final status = lesson['status'];
    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';
    final isLocked = status == 'locked';

    Color bgColor;
    Color iconColor;
    IconData icon;
    Color? borderColor;

    if (isCompleted) {
      bgColor = Color(0xFFE8F5E9); // Light green
      iconColor = Color(0xFF4CAF50); // Green
      icon = Icons.check_circle;
      borderColor = null;
    } else if (isInProgress) {
      bgColor = Color(0xFFE0F7F4); // Light turquoise
      iconColor = Color(0xFF4ECDC4); // Turquoise
      icon = Icons.play_circle_filled;
      borderColor = Color(0xFF4ECDC4);
    } else {
      bgColor = Color(0xFFF5F5F5); // Light gray
      iconColor = MyColors.grey400;
      icon = Icons.lock;
      borderColor = null;
    }

    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          // Navigate to lesson detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonDetailView(lessonData: lesson),
            ),
          );
        } else {
          print('Lesson locked: ${lesson['title']}');
          // TODO: Show premium dialog
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),

            SizedBox(width: 12.w),

            // Lesson info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${lesson['number']}. ${lesson['title']}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: MyColors.textPrimary,
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
                      color: MyColors.textSecondary,
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

  /// Resume button
  Widget _buildResumeButton() {
    return GestureDetector(
      onTap: () {
        // Navigate to lesson 2 detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonDetailView(
              lessonData: _lessons[1], // Lesson 2 (in progress)
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
              color: Color(0xFF4ECDC4).withOpacity(0.4),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_filled, color: MyColors.white, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'RESUME LESSON 2',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: MyColors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        height: 65.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35.r),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/home/altmenuarkaplan.png',
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: MyColors.white,
                        borderRadius: BorderRadius.circular(35.r),
                      ),
                    );
                  },
                ),
              ),

              // Navigation items - centered
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(icon: Icons.grid_view_rounded, index: 0),
                      _buildNavItem(
                        icon: Icons.flight_takeoff_rounded,
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.account_balance_rounded,
                        index: 2,
                      ),
                      _buildNavItem(icon: Icons.person_rounded, index: 3),
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

  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool isActive = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Navigate back to home
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 2) {
          // Navigate to Dictionary
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const VisualDictionaryView(),
            ),
            (route) => route.isFirst,
          );
        } else if (index == 3) {
          // Navigate to Profile
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProfileView()),
            (route) => route.isFirst,
          );
        } else {
          setState(() {
            _selectedNavIndex = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color: isActive ? MyColors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 26.sp,
          color: isActive ? MyColors.lingolaPrimaryColor : MyColors.grey400,
        ),
      ),
    );
  }
}
