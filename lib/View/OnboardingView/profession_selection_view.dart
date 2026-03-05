import 'package:easy_localization/easy_localization.dart'; // easy_localization eklendi
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // Meslek listesini build içinde tanımlıyoruz ki dil değiştiğinde isimler güncellensin
    final professions = [
      {
        'key': 'student',
        'name': 'prof_student_title'.tr(),
        'subtitle': 'prof_student_desc'.tr(),
        'icon': 'assets/images/student.png',
      },
      {
        'key': 'professional',
        'name': 'prof_professional_title'.tr(),
        'subtitle': 'prof_professional_desc'.tr(),
        'icon': 'assets/images/professional.png',
      },
      {
        'key': 'technology',
        'name': 'prof_tech_title'.tr(),
        'subtitle': 'prof_tech_desc'.tr(),
        'icon': 'assets/images/technology.png',
      },
      {
        'key': 'healthcare',
        'name': 'prof_health_title'.tr(),
        'subtitle': 'prof_health_desc'.tr(),
        'icon': 'assets/images/healtcare.png', // Orijinal dosya adını korudum
      },
      {
        'key': 'arts',
        'name': 'prof_arts_title'.tr(),
        'subtitle': 'prof_arts_desc'.tr(),
        'icon': 'assets/images/artsmedia.png',
      },
      {
        'key': 'other',
        'name': 'prof_other_title'.tr(),
        'subtitle': 'prof_other_desc'.tr(),
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
                    'step_2_of_4'.tr(),
                    style: GoogleFonts.montserrat(
                      fontSize: 11.sp,
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

              // Title (Letter spacing %-5 olarak uyarlandı)
              Text(
                'prof_title'.tr(),
                style: GoogleFonts.montserrat(
                  fontSize: 32.sp,
                  letterSpacing: 32.sp * -0.05, // %-5 hesaplaması
                  fontWeight: FontWeight.w700,
                  color: MyColors.black,
                  height: 1.2,
                ),
              ),

              SizedBox(height: 6.h),

              // Subtitle (Letter spacing %-5 olarak uyarlandı)
              Text(
                'prof_subtitle'.tr(),
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  letterSpacing: 16.sp * -0.05, // %-5 hesaplaması
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),

              SizedBox(height: 12.h),

              // Profession Cards Grid
              Expanded(
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 80.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 9.h,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: professions.length,
                  itemBuilder: (context, index) {
                    final profession = professions[index];
                    final isSelected =
                        selectedProfessionKey == profession['key'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedProfessionKey = profession['key'] as String;
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
                            // Görüntü_3'teki (image_3.png) gölge değerleri
                            BoxShadow(
                              color: const Color(
                                0xFF303030,
                              ).withOpacity(0.3), // #303030 at 30% opaklık
                              offset: const Offset(0, 2), // X: 0, Y: 2
                              blurRadius: 4, // Blur 4
                              spreadRadius: 0, // Spread 0
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
                                    profession['icon'] as String,
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
                                profession['name'] as String,
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
                                profession['subtitle'] as String,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10.sp,
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
                              'btn_back'.tr(),
                              style: GoogleFonts.montserrat(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: MyColors.white,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: selectedProfessionKey != null
                            ? () {
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
                              'continue_btn'.tr(),
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
