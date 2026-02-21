import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import '../../Riverpod/Controllers/course_controller.dart';
import '../../Models/course_model.dart';
import '../../Repositories/profile_repository.dart';
import 'course_detail_view.dart';

class CourseView extends ConsumerStatefulWidget {
  final bool isPremium;
  const CourseView({super.key, this.isPremium = false});

  @override
  ConsumerState<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends ConsumerState<CourseView> {
  final TextEditingController _searchController = TextEditingController();
  final ProfileRepository _profileRepository = ProfileRepository();
  int _selectedFilterIndex = 0;
  String? _userTargetLanguage; // User's selected language from onboarding

  final List<String> _filters = [
    'All Courses',
    'Popular',
    'Beginner',
    'Intermediate',
  ];

  @override
  void initState() {
    super.initState();
    // Load user profile and courses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfileAndCourses();
    });
  }

  /// Load user profile to get target language, then load courses
  Future<void> _loadUserProfileAndCourses() async {
    try {
      final response = await _profileRepository.getProfile();
      if (response.success && response.data != null) {
        final userData = response.data['user'];
        final targetLanguage = userData['target_language'] as String?;

        if (mounted) {
          setState(() {
            _userTargetLanguage = targetLanguage ?? 'en';
          });

          // Load courses with user's target language
          ref
              .read(courseControllerProvider.notifier)
              .init(targetLanguage: _userTargetLanguage);

          print('✅ Loaded courses for language: $_userTargetLanguage');
        }
      } else {
        // Fallback to English if profile fetch fails
        if (mounted) {
          setState(() {
            _userTargetLanguage = 'en';
          });
          ref
              .read(courseControllerProvider.notifier)
              .init(targetLanguage: 'en');
          print('⚠️ Profile fetch failed, using default language: en');
        }
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
      // Fallback to English on error
      if (mounted) {
        setState(() {
          _userTargetLanguage = 'en';
        });
        ref.read(courseControllerProvider.notifier).init(targetLanguage: 'en');
      }
    }
  }

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
        bottom: false,
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
              bottom: 0,
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
    final courseState = ref.watch(courseControllerProvider);

    if (courseState.isLoading && courseState.courses.isEmpty) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4)));
    }

    if (courseState.errorMessage != null && courseState.courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              courseState.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () =>
                  ref.read(courseControllerProvider.notifier).refresh(),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (courseState.courses.isEmpty) {
      return Center(
        child: Text(
          'No courses available',
          style: TextStyle(fontSize: 16.sp, color: MyColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(courseControllerProvider.notifier).refresh(),
      color: Color(0xFF4ECDC4),
      child: ListView.builder(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
        itemCount: courseState.courses.length,
        itemBuilder: (context, index) {
          final course = courseState.courses[index];
          return _buildCourseCard(course);
        },
      ),
    );
  }

  /// Course card
  Widget _buildCourseCard(CourseModel course) {
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
                course.imageUrl,
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

            // Progress badge (top-right) — her zaman göster
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: course.progressPercentage >= 100
                      ? Color(0xFF2ECC71) // Tamamlandı → yeşil
                      : Color(
                          0xFF4ECDC4,
                        ), // Devam ediyor veya başlanmadı → turkuaz
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  course.progressPercentage >= 100
                      ? 'COMPLETED ✓'
                      : 'IN PROGRESS  ${course.progressPercentage}%',
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
                                '${course.category}:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  color: MyColors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                course.title,
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
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF4ECDC4),
                                      BlendMode.srcIn,
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${course.totalLessons} Lessons',
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
                          onTap: () async {
                            final isUnlocked =
                                course.isFree || widget.isPremium;
                            if (isUnlocked) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailView(
                                    courseData: {
                                      'id': course.id,
                                      'title': course.title,
                                      'category': course.category,
                                      'description': course.description,
                                      'total_lessons': course.totalLessons,
                                      'lessons_completed':
                                          course.lessonsCompleted,
                                      'progress_percentage':
                                          course.progressPercentage,
                                      'image_url': course.imageUrl,
                                      'is_free': course.isFree,
                                      'level': 'Intermediate',
                                    },
                                    isPremium: widget.isPremium,
                                  ),
                                ),
                              );
                              // Geri dönünce progress badge'lerini yenile
                              if (mounted) {
                                ref
                                    .read(courseControllerProvider.notifier)
                                    .init(targetLanguage: _userTargetLanguage);
                              }
                            } else {
                              print('Course locked: ${course.title}');
                              // TODO: Show premium dialog
                            }
                          },
                          child: Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: (course.isFree || widget.isPremium)
                                  ? Color(0xFF4ECDC4)
                                  : MyColors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: (course.isFree || widget.isPremium)
                                ? Icon(
                                    Icons.play_arrow,
                                    color: MyColors.white,
                                    size: 28.sp,
                                  )
                                : Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/chooseyourdestkilit.svg',
                                      width: 28.w,
                                      height: 28.w,
                                      colorFilter: ColorFilter.mode(
                                        MyColors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
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
