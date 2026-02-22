import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Core/Localization/app_localizations.dart';
import '../../Core/Theme/my_colors.dart';
import '../../Core/Routes/app_routes.dart';

/// Step 3 of 4 - English Level Selection View
class EnglishLevelSelectionView extends ConsumerStatefulWidget {
  final String? selectedLanguage;

  const EnglishLevelSelectionView({super.key, this.selectedLanguage});

  @override
  ConsumerState<EnglishLevelSelectionView> createState() =>
      _EnglishLevelSelectionViewState();
}

class _EnglishLevelSelectionViewState
    extends ConsumerState<EnglishLevelSelectionView> {
  String? _selectedLevel;

  void _onLevelSelected(String levelId) {
    setState(() {
      _selectedLevel = levelId;
    });
  }

  void _onContinue() {
    if (_selectedLevel != null) {
      Navigator.pushNamed(context, AppRoutes.dailyGoalSelection);
    }
  }

  void _onBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    // Always use English for onboarding
    final l = AppLocalizations.of('en');

    final levels = [
      {
        'id': 'beginner',
        'title': l.levelBeginner,
        'description': l.levelBeginnerDesc,
        'icon': 'assets/images/beginner.svg',
      },
      {
        'id': 'elementary',
        'title': l.levelElementary,
        'description': l.levelElementaryDesc,
        'icon': 'assets/images/elementary.svg',
      },
      {
        'id': 'intermediate',
        'title': l.levelIntermediate,
        'description': l.levelIntermediateDesc,
        'icon': 'assets/images/intermediate.svg',
      },
      {
        'id': 'upper-intermediate',
        'title': l.levelUpperIntermediate,
        'description': l.levelUpperIntermediateDesc,
        'icon': 'assets/icons/briefcase.svg',
      },
    ];

    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              _buildProgressBar(l),
              SizedBox(height: 28.h),

              // Title
              Text(
                '${widget.selectedLanguage ?? ''}\n${l.step3Title}',
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
                l.step3Subtitle,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: MyColors.grey600,
                  height: 1.3,
                ),
              ),

              SizedBox(height: 24.h),

              // Level Cards
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: levels.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final level = levels[index];
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
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _onBack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD1D5DB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back,
                                  color: MyColors.white,
                                  size: 22.sp,
                                ),
                              ),
                            ),
                            Text(
                              l.back,
                              style: GoogleFonts.montserrat(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: MyColors.white,
                              ),
                            ),
                            SizedBox(width: 20.w),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _selectedLevel != null ? _onContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2EC4B6),
                          disabledBackgroundColor: const Color(0xFFD1D5DB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 20.w),
                            Text(
                              l.continueBtn,
                              style: GoogleFonts.montserrat(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: MyColors.white,
                              ),
                            ),
                            Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: MyColors.white,
                                  size: 22.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

  Widget _buildProgressBar(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.step3of4,
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
            color: isSelected ? MyColors.lingolaPrimaryColor : MyColors.grey300,
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
            level['icon']!.endsWith('.svg')
                ? SvgPicture.asset(
                    level['icon']!,
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.contain,
                    colorFilter: isSelected
                        ? ColorFilter.mode(
                            MyColors.lingolaPrimaryColor,
                            BlendMode.srcIn,
                          )
                        : null,
                  )
                : Image.asset(
                    level['icon']!,
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    color: isSelected ? MyColors.lingolaPrimaryColor : null,
                  ),
            SizedBox(width: 12.w),
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
}
