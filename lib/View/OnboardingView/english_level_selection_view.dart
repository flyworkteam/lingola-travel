import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Core/Theme/my_colors.dart';
import '../../Core/Routes/app_routes.dart';

/// Step 3 of 4 - English Level Selection View
/// Pixel-perfect implementation from Figma
class EnglishLevelSelectionView extends StatefulWidget {
  final String? selectedLanguage;
  
  const EnglishLevelSelectionView({
    super.key,
    this.selectedLanguage,
  });

  @override
  State<EnglishLevelSelectionView> createState() =>
      _EnglishLevelSelectionViewState();
}

class _EnglishLevelSelectionViewState
    extends State<EnglishLevelSelectionView> {
  String? _selectedLevel;

  final List<Map<String, String>> _levels = [
    {
      'id': 'beginner',
      'title': 'Beginner',
      'description': 'Can understand and use familiar every day expressions.',
      'icon': 'assets/images/beginner.svg',
    },
    {
      'id': 'elementary',
      'title': 'Elementary',
      'description': 'Can communicate in simple and routine tasks',
      'icon': 'assets/images/elementary.svg',
    },
    {
      'id': 'intermediate',
      'title': 'Intermediate',
      'description': 'Can deal with most situations likely to arise whilst traveling.',
      'icon': 'assets/images/intermediate.svg',
    },
    {
      'id': 'upper-intermediate',
      'title': 'Upper-Intermediate',
      'description': 'Can lead business meetings comfortably',
      'icon': 'assets/images/upperintermediate.svg',
    },
  ];

  void _onLevelSelected(String levelId) {
    setState(() {
      _selectedLevel = levelId;
    });
  }

  void _onContinue() {
    if (_selectedLevel != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.dailyGoalSelection,
      );
    }
  }

  void _onBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              SizedBox(height: 20.h),
              _buildProgressBar(),

              SizedBox(height: 28.h),

              // Title
              Text(
                'What is your ${widget.selectedLanguage ?? 'English'}\nlevel?',
                style: GoogleFonts.montserrat(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: MyColors.black,
                  height: 1.2,
                ),
              ),

              SizedBox(height: 10.h),

              // Subtitle
              Text(
                'We\'ll tailor your language journey\nbased on your background',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: MyColors.grey600,
                  height: 1.3,
                ),
              ),

              SizedBox(height: 24.h),

              // Level Cards - Fixed height, no scroll
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _levels.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final level = _levels[index];
                    final isSelected = _selectedLevel == level['id'];
                    return _buildLevelCard(
                      level: level,
                      isSelected: isSelected,
                      onTap: () => _onLevelSelected(level['id']!),
                    );
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // Bottom Buttons
              Row(
                children: [
                  // Back Button
                  _buildBackButton(),

                  SizedBox(width: 12.w),

                  // Continue Button
                  Expanded(
                    child: _buildContinueButton(),
                  ),
                ],
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP 3 OF 4',
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: MyColors.lingolaPrimaryColor,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            // Step 1 - Completed
            Expanded(
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: MyColors.lingolaPrimaryColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Step 2 - Completed
            Expanded(
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: MyColors.lingolaPrimaryColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Step 3 - Current
            Expanded(
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: MyColors.lingolaPrimaryColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Step 4 - Not completed
            Expanded(
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: MyColors.grey300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelCard({
    required Map<String, String> level,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected
              ? MyColors.lingolaPrimaryColor.withOpacity(0.1)
              : MyColors.white,
          border: Border.all(
            color: isSelected
                ? MyColors.lingolaPrimaryColor
                : MyColors.grey300,
            width: isSelected ? 2.w : 1.w,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: MyColors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.w,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? MyColors.lingolaPrimaryColor
                    : MyColors.grey200,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: SvgPicture.asset(
                level['icon']!,
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  isSelected ? MyColors.white : MyColors.grey600,
                  BlendMode.srcIn,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level['title']!,
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: MyColors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    level['description']!,
                    style: GoogleFonts.montserrat(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: MyColors.grey600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: _onBack,
      child: Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: MyColors.grey200,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(
          Icons.arrow_back,
          color: MyColors.grey700,
          size: 22.w,
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isEnabled = _selectedLevel != null;

    return GestureDetector(
      onTap: isEnabled ? _onContinue : null,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: isEnabled
              ? MyColors.lingolaPrimaryColor
              : MyColors.grey300,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: MyColors.white,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.arrow_forward,
              color: MyColors.white,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}
