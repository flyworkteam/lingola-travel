import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Models/course_model.dart';
import 'package:lingola_travel/Repositories/course_repository.dart';
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
  final CourseRepository _courseRepository = CourseRepository();
  double _scrollOffset = 0.0;

  List<LessonModel> _lessons = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courseId = widget.courseData['id'] as String;
      print('🔍 Loading lessons for course: $courseId');

      final response = await _courseRepository.getLessonsByCourse(courseId);

      print('📦 API Response - success: ${response.success}');
      print('📦 API Response - data length: ${response.data?.length}');
      print('📦 API Response - error: ${response.error}');

      if (response.success && response.data != null) {
        setState(() {
          _lessons = response.data!;
          _completedCount = _lessons
              .where((l) => l.userStatus == 'completed')
              .length;
          _isLoading = false;
        });
        print('✅ Loaded ${_lessons.length} lessons');
      } else {
        setState(() {
          _errorMessage = response.error?.message ?? 'Dersler yüklenemedi';
          _isLoading = false;
        });
        print('❌ Error loading lessons: $_errorMessage');
      }
    } catch (e, stackTrace) {
      print('💥 Exception in _loadLessons: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
                  widget.courseData['image_url'] as String? ??
                      'assets/images/coursegenel.png',
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
                        widget.courseData['title'] as String? ?? 'Course',
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
                            text:
                                '${widget.courseData['total_lessons'] ?? 12} Lessons',
                          ),
                          SizedBox(width: 16.w),
                          _buildStatChip(
                            iconPath: 'assets/icons/45min.svg',
                            text:
                                '${(widget.courseData['total_lessons'] as int? ?? 12) * 8} Mins',
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Level chip
                      _buildStatChip(
                        iconPath: 'assets/icons/intermediate.svg',
                        text:
                            widget.courseData['level'] as String? ??
                            'Intermediate',
                      ),

                      SizedBox(height: 20.h),

                      // Description
                      Text(
                        widget.courseData['description'] as String? ??
                            'Course description',
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
                          if (!_isLoading && _lessons.isNotEmpty)
                            Text(
                              '${((_completedCount / _lessons.length) * 100).round()}% Completed',
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

                      // Loading, error, or lessons list
                      if (_isLoading)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: CircularProgressIndicator(
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        )
                      else if (_errorMessage != null)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48.sp,
                                  color: Colors.red[300],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.red[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: _loadLessons,
                                  child: Text('Tekrar Dene'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_lessons.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Text(
                              'Bu kursta henüz ders yok',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      else
                        ..._lessons.asMap().entries.map((entry) {
                          final index = entry.key;
                          final lesson = entry.value;
                          return _buildLessonItem(lesson, index + 1);
                        }),

                      SizedBox(height: 24.h),

                      // Resume button - only show when lessons are loaded
                      if (_lessons.isNotEmpty) _buildResumeButton(),
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

          // Bottom navigation - Remove Positioned since CustomBottomNavBar handles its own positioning
          CustomBottomNavBar(currentIndex: 1, isPremium: widget.isPremium),
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

  Widget _buildLessonItem(LessonModel lesson, int displayNumber) {
    final isCompleted = lesson.userStatus == 'completed';
    final isInProgress = lesson.userStatus == 'in_progress';
    final isLocked = lesson.userStatus == 'locked';

    Color bgColor;
    Widget iconWidget;

    if (isCompleted) {
      // Completed - Checkmark with green background
      bgColor = Color(0xFFF0F9FF);
      iconWidget = Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Color(0xFFE0F7F4),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.check_circle,
            color: Color(0xFF4ECDC4),
            size: 28.sp,
          ),
        ),
      );
    } else if (isInProgress || (!isLocked && !isCompleted)) {
      // In Progress or Available - Play button with turquoise background
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
      // Locked - Lock icon with gray background
      bgColor = Color(0xFFF9F9F9);
      iconWidget = Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(Icons.lock, color: Color(0xFF9CA3AF), size: 24.sp),
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        if (!isLocked) {
          print('🎯 Opening lesson: ${lesson.id}');

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => LessonDetailView(
                lessonId: lesson.id, // Use actual lesson ID from API
                isPremium: widget.isPremium,
              ),
            ),
          );

          // If lesson was completed, refresh course data
          if (result == true) {
            print('🔄 Lesson completed, refreshing course data...');
            _loadLessons();
          }
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
                    '$displayNumber. ${lesson.title}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: Colors.black,
                    ),
                  ),
                  if (lesson.description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      lesson.description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF666666),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Duration or progress
            if (isCompleted)
              Icon(Icons.check_circle, color: Color(0xFF4ECDC4), size: 24.sp)
            else if (isInProgress && lesson.userProgress != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Color(0xFF4ECDC4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${lesson.userProgress}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF4ECDC4),
                  ),
                ),
              )
            else if (isLocked)
              Icon(Icons.lock_outline, color: Color(0xFFBDBDBD), size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeButton() {
    // Safety check - should not be called with empty lessons
    if (_lessons.isEmpty) {
      return SizedBox.shrink();
    }

    // Find first in-progress or not-started lesson
    late LessonModel resumeLesson;
    try {
      resumeLesson = _lessons.firstWhere(
        (l) => l.userStatus == 'in_progress' || l.userStatus == 'not_started',
      );
    } catch (e) {
      // If no in-progress or not-started lesson found, use first lesson
      resumeLesson = _lessons.first;
    }

    final lessonNumber = _lessons.indexOf(resumeLesson) + 1;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => LessonDetailView(
              lessonId: resumeLesson.id,
              isPremium: widget.isPremium,
            ),
          ),
        );

        // If lesson was completed, refresh course data
        if (result == true) {
          print('🔄 Lesson completed, refreshing course data...');
          _loadLessons();
        }
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
              resumeLesson.userStatus == 'in_progress'
                  ? 'RESUME LESSON $lessonNumber'
                  : 'START LESSON $lessonNumber',
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
