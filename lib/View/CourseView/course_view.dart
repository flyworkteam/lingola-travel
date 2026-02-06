import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'course_detail_view.dart';

class CourseView extends StatefulWidget {
  final bool isPremium;
  const CourseView({super.key, this.isPremium = false});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'All Courses',
    'Popular',
    'Beginner',
    'Intermediate',
  ];

  // Course data
  final List<Map<String, dynamic>> _courses = [
    {
      'category': 'General',
      'title': 'Daily Conversation',
      'lessons': 12,
      'progress': 100,
      'isUnlocked': true,
      'image': 'assets/images/coursegenel.png',
    },
    {
      'category': 'Trip',
      'title': 'Terminal Talk',
      'lessons': 12,
      'progress': 65,
      'isUnlocked': true,
      'image': 'assets/images/courseairport.png',
    },
    {
      'category': 'Food & Drink',
      'title': 'Place an order',
      'lessons': 12,
      'progress': 0,
      'isUnlocked': false,
      'image': 'assets/images/courseyemeicme.png',
    },
    {
      'category': 'Accommodation',
      'title': 'I have a reservation',
      'lessons': 12,
      'progress': 0,
      'isUnlocked': false,
      'image': 'assets/images/coursekonaklama.png',
    },
    {
      'category': 'Culture',
      'title': 'How can I get there?',
      'lessons': 12,
      'progress': 0,
      'isUnlocked': false,
      'image': 'assets/images/coursekultur.png',
    },
    {
      'category': 'Shopping',
      'title': 'How much is this?',
      'lessons': 12,
      'progress': 0,
      'isUnlocked': false,
      'image': 'assets/images/courseshoping.png',
    },
    {
      'category': 'Direction & Navigation',
      'title': 'How can I get there?',
      'lessons': 12,
      'progress': 0,
      'isUnlocked': false,
      'image': 'assets/images/coursenavigation.png',
    },
    {
      'category': 'Sport',
      'title': 'Is there a gym?',
      'lessons': 12,
      'progress': 0,
      'isUnlocked': false,
      'image': 'assets/images/coursesport.png',
    },
    {
      'category': 'Health',
      'title': 'Where is the pharmacy?',
      'lessons': 12,
      'progress': 0,
      'isUnlocked': false,
      'image': 'assets/images/coursehealth.png',
    },
    {
      'category': 'Business',
      'title': 'We have a meeting',
      'lessons': 12,
      'progress': 0,
      'isUnlocked': false,
      'image': 'assets/images/coursebusiness.png',
    },
    {
      'category': 'Emergency',
      'title': 'Call the police',
      'lessons': 12,
      'progress': 0,
      'isUnlocked': false,
      'image': 'assets/images/courseemergency.png',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // Title
                _buildTitle(),

                SizedBox(height: 20.h),

                // Search bar
                _buildSearchBar(),

                SizedBox(height: 20.h),

                // Filter tabs
                _buildFilterTabs(),

                SizedBox(height: 20.h),

                // Course list
                Expanded(child: _buildCourseList()),
              ],
            ),

            // Floating bottom navigation
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
      ),
    );
  }

  /// Title
  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text(
        'Choose Your\nDestination',
        style: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w800,
          fontFamily: 'Montserrat',
          color: MyColors.textPrimary,
          height: 1.2,
        ),
      ),
    );
  }

  /// Search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: MyColors.border, width: 1),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Color(0xFF4ECDC4),
              selectionColor: Color(0xFF4ECDC4).withOpacity(0.3),
              selectionHandleColor: Color(0xFF4ECDC4),
            ),
          ),
          child: TextField(
            controller: _searchController,
            cursorColor: Color(0xFF4ECDC4),
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              color: MyColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search words or phrases...',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Montserrat',
                color: MyColors.textSecondary,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: MyColors.textSecondary,
                size: 20.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  /// Filter tabs
  Widget _buildFilterTabs() {
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          return _buildFilterTab(_filters[index], index);
        },
      ),
    );
  }

  /// Single filter tab
  Widget _buildFilterTab(String label, int index) {
    final isActive = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF4ECDC4) : MyColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? Color(0xFF4ECDC4) : MyColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              color: isActive ? MyColors.white : MyColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  /// Course list
  Widget _buildCourseList() {
    return ListView.builder(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        return _buildCourseCard(_courses[index]);
      },
    );
  }

  /// Course card
  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      height: 200.h,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                course['image'],
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
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),

            // Progress badge (top-right)
            if (course['progress'] > 0)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF4ECDC4),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'IN PROGRESS (${course['progress']}%)',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: MyColors.white,
                    ),
                  ),
                ),
              ),

            // Content (bottom) with glassmorphism
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Category + Title + Lessons
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${course['category']}:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  color: MyColors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                course['title'],
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                  color: MyColors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/12lesson.svg',
                                    width: 16.w,
                                    height: 16.w,
                                    colorFilter: const ColorFilter.mode(Color(0xFF2EC4B6), BlendMode.srcIn),
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${course['lessons']} Lessons',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Montserrat',
                                      color: MyColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // Play/Lock button
                        GestureDetector(
                          onTap: () {
                            if (course['isUnlocked']) {
                              // Navigate to course detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailView(
                                    courseData: course,
                                    isPremium: widget.isPremium,
                                  ),
                                ),
                              );
                            } else {
                              print('Course locked: ${course['title']}');
                              // TODO: Show premium dialog
                            }
                          },
                          child: Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: course['isUnlocked']
                                  ? Color(0xFF4ECDC4)
                                  : MyColors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              course['isUnlocked']
                                  ? Icons.play_arrow
                                  : Icons.lock,
                              color: MyColors.white,
                              size: 28.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
