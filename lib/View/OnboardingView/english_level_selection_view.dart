import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';

import '../../Core/Routes/app_routes.dart';
import '../../Core/Theme/my_colors.dart';

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
    // Localization anahtarlarını liste içinde tanımlıyoruz
    final levels = [
      {
        'id': 'beginner',
        'title': LocaleKeys.level_beginner_title.tr(),
        'description': LocaleKeys.level_beginner_desc.tr(),
        'icon': 'assets/images/beginner.svg',
      },
      {
        'id': 'elementary',
        'title': LocaleKeys.level_elementary_title.tr(),
        'description': LocaleKeys.level_elementary_desc.tr(),
        'icon': 'assets/images/elementary.svg',
      },
      {
        'id': 'intermediate',
        'title': LocaleKeys.level_intermediate_title.tr(),
        'description': LocaleKeys.level_intermediate_desc.tr(),
        'icon': 'assets/images/intermediate.svg',
      },
      {
        'id': 'upper-intermediate',
        'title': LocaleKeys.level_upper_intermediate_title.tr(),
        'description': LocaleKeys.level_upper_intermediate_desc.tr(),
        'icon': 'assets/icons/briefcase.svg', // Briefcase ikonunu koruduk
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

              // Progress Bar (Step 3 of 4)
              Text(
                LocaleKeys.step_3_of_4.tr(),
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: MyColors.lingolaPrimaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: List.generate(4, (index) {
                  // İlk üç çubuk aktif (Step 3 olduğu için)
                  bool isActive = index < 3;
                  return Expanded(
                    child: Container(
                      height: 4.h,
                      margin: EdgeInsets.only(right: index == 3 ? 0 : 8.w),
                      decoration: BoxDecoration(
                        color: isActive
                            ? MyColors.lingolaPrimaryColor
                            : MyColors.grey200,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 24.h),

              // Title
              Text(
                LocaleKeys.level_title.tr(),
                style: GoogleFonts.montserrat(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: MyColors.black,
                  letterSpacing: 32.sp * -0.05,
                  height: 1.1,
                ),
              ),

              SizedBox(height: 8.h),

              // Subtitle
              Text(
                LocaleKeys.level_subtitle.tr(),
                style: GoogleFonts.montserrat(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  letterSpacing: 15.sp * -0.05,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 24.h),

              // Level Cards
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: levels.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
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
                  // Back Button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _onBack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.grey300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            const Spacer(),
                            Text(
                              LocaleKeys.btn_back.tr(),
                              style: GoogleFonts.montserrat(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: MyColors.white,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Continue Button
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _selectedLevel != null ? _onContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.lingolaPrimaryColor,
                          disabledBackgroundColor: MyColors.grey300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          children: [
                            const Spacer(),
                            Text(
                              LocaleKeys.continue_btn.tr(),
                              style: GoogleFonts.montserrat(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: MyColors.white,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
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
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE0F7F5)
              : MyColors.white, // Seçili durum rengini ekledik
          border: Border.all(
            color: isSelected ? MyColors.lingolaPrimaryColor : MyColors.grey200,
            width: isSelected ? 2.w : 1.5.w,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            // Gölge buraya eklendi
            BoxShadow(
              color: const Color(0xFF303030).withOpacity(0.3), // %30 Opaklık
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            level['icon']!.endsWith('.svg')
                ? SvgPicture.asset(
                    level['icon']!,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? MyColors.lingolaPrimaryColor
                          : MyColors.grey600,
                      BlendMode.srcIn,
                    ),
                  )
                : Image.asset(level['icon']!, fit: BoxFit.contain),
            SizedBox(width: 16.w),
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
                  SizedBox(height: 4.h),
                  Text(
                    level['description']!,
                    style: GoogleFonts.montserrat(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: MyColors.textSecondary,
                      height: 1.2,
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
}
