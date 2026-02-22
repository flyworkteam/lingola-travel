import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Core/Localization/app_localizations.dart';
import '../../Core/Theme/my_colors.dart';
import '../../Core/Routes/app_routes.dart';
import '../../Riverpod/Controllers/OnboardingController/onboarding_controller.dart';
import '../../Riverpod/Providers/locale_provider.dart';

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

  void _onGoalSelected(String goalId) {
    setState(() {
      _selectedGoal = goalId;
    });
  }

  void _onContinue() {
    if (_selectedGoal != null) {
      int dailyGoalMinutes = _getGoalMinutes(_selectedGoal!);
      ref
          .read(onboardingControllerProvider.notifier)
          .setDailyGoal(_selectedGoal!, dailyGoalMinutes);
      Navigator.pushNamed(context, AppRoutes.creatingPlan);
    }
  }

  int _getGoalMinutes(String goalId) {
    switch (goalId) {
      case 'casual': return 5;
      case 'regular': return 15;
      case 'serious': return 30;
      default: return 15;
    }
  }

  void _onBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final langCode = ref.watch(localeProvider);
    final l = AppLocalizations.of(langCode);

    final goals = [
      {
        'id': 'casual',
        'title': l.goalCasual,
        'duration': l.goalCasualDuration,
        'icon': 'assets/icons/hafif.svg',
      },
      {
        'id': 'regular',
        'title': l.goalRegular,
        'duration': l.goalRegularDuration,
        'icon': 'assets/icons/normal.svg',
      },
      {
        'id': 'serious',
        'title': l.goalSerious,
        'duration': l.goalSeriousDuration,
        'icon': 'assets/icons/ciddili.svg',
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
                l.step4Title,
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
                l.step4Subtitle,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: MyColors.grey600,
                  height: 1.3,
                ),
              ),

              SizedBox(height: 24.h),

              // Goal Cards
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goals.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final isSelected = _selectedGoal == goal['id'];
                    return _buildGoalCard(
                      goal: goal,
                      isSelected: isSelected,
                      onTap: () => _onGoalSelected(goal['id']!),
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
                                child: Icon(Icons.arrow_back,
                                    color: MyColors.white, size: 22.sp),
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
                        onPressed: _selectedGoal != null ? _onContinue : null,
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
                                child: Icon(Icons.arrow_forward,
                                    color: MyColors.white, size: 22.sp),
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
          l.step4of4,
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: MyColors.lingolaPrimaryColor,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: List.generate(4, (i) => [
            Expanded(
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: MyColors.lingolaPrimaryColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            if (i < 3) SizedBox(width: 8.w),
          ]).expand((e) => e).toList(),
        ),
      ],
    );
  }

  Widget _buildGoalCard({
    required Map<String, String> goal,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
            Container(
              width: 48.w,
              height: 48.w,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2EC4B6)
                    : const Color(0xFF2EC4B6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: goal['icon']!.endsWith('.svg')
                  ? SvgPicture.asset(
                      goal['icon']!,
                      width: 28.w,
                      height: 28.w,
                      fit: BoxFit.contain,
                      colorFilter: isSelected
                          ? ColorFilter.mode(MyColors.white, BlendMode.srcIn)
                          : null,
                    )
                  : Image.asset(
                      goal['icon']!,
                      width: 28.w,
                      height: 28.w,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      color: isSelected ? MyColors.white : null,
                    ),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal['title']!,
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: MyColors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  goal['duration']!,
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: MyColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
