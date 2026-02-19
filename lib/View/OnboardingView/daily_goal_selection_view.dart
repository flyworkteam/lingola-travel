import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Core/Theme/my_colors.dart';
import '../../Core/Routes/app_routes.dart';
import '../../Riverpod/Controllers/OnboardingController/onboarding_controller.dart';

/// Step 4 of 4 - Daily Goal Selection View
/// Pixel-perfect implementation from Figma
class DailyGoalSelectionView extends ConsumerStatefulWidget {
  const DailyGoalSelectionView({super.key});

  @override
  ConsumerState<DailyGoalSelectionView> createState() =>
      _DailyGoalSelectionViewState();
}

class _DailyGoalSelectionViewState
    extends ConsumerState<DailyGoalSelectionView> {
  String? _selectedGoal;

  final List<Map<String, String>> _goals = [
    {
      'id': 'casual',
      'title': 'Hafif',
      'duration': '5 dk/gün',
      'icon': 'assets/images/casual.png',
    },
    {
      'id': 'regular',
      'title': 'Normal',
      'duration': '15 dk/gün',
      'icon': 'assets/images/regular.svg',
    },
    {
      'id': 'serious',
      'title': 'Ciddi',
      'duration': '30 dk/gün',
      'icon': 'assets/images/serious.png',
    },
  ];

  void _onGoalSelected(String goalId) {
    setState(() {
      _selectedGoal = goalId;
    });
  }

  void _onContinue() {
    if (_selectedGoal != null) {
      // Convert goal to minutes and save to state
      int dailyGoalMinutes = _getGoalMinutes(_selectedGoal!);
      ref
          .read(onboardingControllerProvider.notifier)
          .setDailyGoal(_selectedGoal!, dailyGoalMinutes);

      Navigator.pushNamed(context, AppRoutes.creatingPlan);
    }
  }

  /// Convert goal ID to minutes
  int _getGoalMinutes(String goalId) {
    switch (goalId) {
      case 'casual':
        return 5;
      case 'regular':
        return 15;
      case 'serious':
        return 30;
      default:
        return 15;
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
                'Günlük hedefiniz\nnedir?',
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
                'Öğrenmeye ne kadar zaman ayırmak istediğinizi\nseçin. Bunu daha sonra değiştirebilirsiniz.',
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
                  itemCount: _goals.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
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
                  // Back Button
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
                              'Geri',
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
                  // Continue Button
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
                              'Devam Et',
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

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADIM 4 / 4',
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
            // Step 3 - Completed
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
            // Step 4 - Current
            Expanded(
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: MyColors.lingolaPrimaryColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ],
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
            // Icon
            Container(
              width: 48.w,
              height: 48.w,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? MyColors.lingolaPrimaryColor
                    : MyColors.grey200,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: goal['icon']!.endsWith('.svg')
                  ? SvgPicture.asset(
                      goal['icon']!,
                      width: 24.w,
                      height: 24.w,
                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? MyColors.white
                            : MyColors.lingolaPrimaryColor,
                        BlendMode.srcIn,
                      ),
                    )
                  : Image.asset(
                      goal['icon']!,
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.contain,
                      color: isSelected
                          ? MyColors.white
                          : MyColors.lingolaPrimaryColor,
                    ),
            ),

            SizedBox(width: 16.w),

            // Text Content
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
