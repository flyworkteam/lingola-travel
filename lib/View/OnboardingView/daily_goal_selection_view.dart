import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';

import '../../Core/Routes/app_routes.dart';
import '../../Core/Theme/my_colors.dart';
import '../../Riverpod/Controllers/OnboardingController/onboarding_controller.dart';

/// Step 4 of 4 - Daily Goal Selection View
class DailyGoalSelectionView extends ConsumerStatefulWidget {
  const DailyGoalSelectionView({super.key});

  @override
  ConsumerState<DailyGoalSelectionView> createState() =>
      _DailyGoalSelectionViewState();
}

class _DailyGoalSelectionViewState
    extends ConsumerState<DailyGoalSelectionView> {
  String? _selectedGoal;

  // Hedef datalarını ve dinamik dakikaları içeren liste
  final List<Map<String, dynamic>> _goalsData = [
    {
      'id': 'casual',
      'title': LocaleKeys.goal_casual_title,
      'duration': LocaleKeys.goal_casual_desc,
      'minutes': 5,
      'icon': 'assets/icons/hafif.svg',
    },
    {
      'id': 'regular',
      'title': LocaleKeys.goal_regular_title,
      'duration': LocaleKeys.goal_regular_desc,
      'minutes': 15,
      'icon': 'assets/icons/normal.svg',
    },
    {
      'id': 'serious',
      'title': LocaleKeys.goal_serious_title,
      'duration': LocaleKeys.goal_serious_desc,
      'minutes': 30,
      'icon': 'assets/icons/ciddili.svg',
    },
  ];

  void _onGoalSelected(String goalId) {
    setState(() {
      _selectedGoal = goalId;
    });
  }

  void _onContinue() {
    if (_selectedGoal != null) {
      // Seçilen ID'ye göre listeden dakika değerini dinamik olarak çekiyoruz
      final selectedData = _goalsData.firstWhere(
        (goal) => goal['id'] == _selectedGoal,
      );
      final int dailyGoalMinutes = selectedData['minutes'] as int;

      ref
          .read(onboardingControllerProvider.notifier)
          .setDailyGoal(_selectedGoal!, dailyGoalMinutes);
      ref.read(onboardingControllerProvider.notifier).saveOnboarding();

      Navigator.pushNamed(context, AppRoutes.creatingPlan);
    }
  }

  void _onBack() => Navigator.pop(context);

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
              SizedBox(height: 20.h),

              // Progress Bar (Step 4 of 4)
              Text(
                LocaleKeys.step_4_of_4.tr(),
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
                  return Expanded(
                    child: Container(
                      height: 4.h,
                      margin: EdgeInsets.only(right: index == 3 ? 0 : 8.w),
                      decoration: BoxDecoration(
                        color: MyColors.lingolaPrimaryColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 24.h),

              // Title
              Text(
                LocaleKeys.goal_title.tr(),
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
                LocaleKeys.goal_subtitle.tr(),
                style: GoogleFonts.montserrat(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  letterSpacing: 15.sp * -0.05,
                  decorationColor: MyColors.lingolaPrimaryColor,
                ),
              ),

              SizedBox(height: 20.h),

              // Goal Cards
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _goalsData.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final goal = _goalsData[index];
                    final isSelected = _selectedGoal == goal['id'];
                    return _buildGoalCard(
                      goal: goal,
                      isSelected: isSelected,
                      onTap: () => _onGoalSelected(goal['id'] as String),
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
                        onPressed: _selectedGoal != null ? _onContinue : null,
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

  Widget _buildGoalCard({
    required Map<String, dynamic> goal,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7F5) : MyColors.white,
          border: Border.all(
            color: isSelected
                ? MyColors.lingolaPrimaryColor
                : Colors.transparent,
            width: isSelected ? 1.5.w : 0,
          ),
          borderRadius: BorderRadius.circular(10.r), // Radius: 10px
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF303030,
              ).withOpacity(0.25), // #303030 %25 opacity
              offset: const Offset(0, 2), // X:0, Y:2
              blurRadius: 4, // Blur 4
              spreadRadius: 0, // Spread 0
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5ABCB2)
                    : const Color(0xFFD6EBE9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: SvgPicture.asset(
                goal['icon'] as String,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (goal['title'] as String).tr(),
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: MyColors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    (goal['duration'] as String).tr(),
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: MyColors.black,
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
