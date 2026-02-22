import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Core/Localization/app_localizations.dart';
import '../../Core/Theme/my_colors.dart';
import 'profession_detail_view.dart';

/// Profession Selection View - Onboarding Step 2 of 4
class ProfessionSelectionView extends ConsumerStatefulWidget {
  final String? selectedLanguage;

  const ProfessionSelectionView({super.key, this.selectedLanguage});

  @override
  ConsumerState<ProfessionSelectionView> createState() =>
      _ProfessionSelectionViewState();
}

class _ProfessionSelectionViewState
    extends ConsumerState<ProfessionSelectionView> {
  String? selectedProfessionKey; // store key like 'student', 'professional'...

  @override
  Widget build(BuildContext context) {
    // Always use English for onboarding
    final l = AppLocalizations.of('en');

    final professions = [
      {
        'key': 'student',
        'name': l.profStudent,
        'subtitle': l.profStudentSub,
        'icon': 'assets/images/student.png',
      },
      {
        'key': 'professional',
        'name': l.profProfessional,
        'subtitle': l.profProfessionalSub,
        'icon': 'assets/images/professional.png',
      },
      {
        'key': 'technology',
        'name': l.profTechnology,
        'subtitle': l.profTechnologySub,
        'icon': 'assets/images/technology.png',
      },
      {
        'key': 'healthcare',
        'name': l.profHealthcare,
        'subtitle': l.profHealthcareSub,
        'icon': 'assets/images/healtcare.png',
      },
      {
        'key': 'arts',
        'name': l.profArtsMedia,
        'subtitle': l.profArtsMediaSub,
        'icon': 'assets/images/artsmedia.png',
      },
      {
        'key': 'other',
        'name': l.profOther,
        'subtitle': l.profOtherSub,
        'icon': 'assets/images/other.png',
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
              // Progress Bar
              SizedBox(height: 20.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.step2of4,
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
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Container(
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: MyColors.lingolaPrimaryColor,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Container(
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: MyColors.grey200,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Container(
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: MyColors.grey200,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Title
              Text(
                l.step2Title,
                style: GoogleFonts.montserrat(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: MyColors.black,
                  height: 1.2,
                ),
              ),

              SizedBox(height: 6.h),

              // Subtitle
              Text(
                l.step2Subtitle,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: MyColors.grey600,
                  height: 1.3,
                ),
              ),

              SizedBox(height: 28.h),

              // Profession Cards Grid
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: professions.length,
                  itemBuilder: (context, index) {
                    final profession = professions[index];
                    final isSelected =
                        selectedProfessionKey == profession['key'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedProfessionKey = profession['key'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE0F7F5)
                              : MyColors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? MyColors.lingolaPrimaryColor
                                : MyColors.grey200,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 10.h,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 52.w,
                                    height: 52.h,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? MyColors.lingolaPrimaryColor
                                          : const Color(0xFFE0F7F5),
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  ),
                                  Image.asset(
                                    profession['icon']!,
                                    width: 32.w,
                                    height: 32.h,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                    color: isSelected
                                        ? MyColors.white
                                        : const Color(0xFF2EC4B6),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                profession['name']!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: MyColors.black,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                profession['subtitle']!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w400,
                                  color: MyColors.textSecondary,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 10.h),

              // Bottom Buttons
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
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
                        onPressed: selectedProfessionKey != null
                            ? () {
                                // find the localized name of the selected profession
                                final selectedProf = professions.firstWhere(
                                  (p) => p['key'] == selectedProfessionKey,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfessionDetailView(
                                      selectedCategory: selectedProf['name'],
                                      selectedLanguage: widget.selectedLanguage,
                                    ),
                                  ),
                                );
                              }
                            : null,
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

              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}
