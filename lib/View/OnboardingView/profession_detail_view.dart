import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';

import '../../Core/Theme/my_colors.dart';
import 'english_level_selection_view.dart';

class ProfessionDetailView extends ConsumerStatefulWidget {
  final String? selectedCategory;
  final String? selectedLanguage;

  const ProfessionDetailView({
    super.key,
    this.selectedCategory,
    this.selectedLanguage,
  });

  @override
  ConsumerState<ProfessionDetailView> createState() =>
      _ProfessionDetailViewState();
}

class _ProfessionDetailViewState extends ConsumerState<ProfessionDetailView> {
  final TextEditingController _professionController = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _professionController.dispose();
    super.dispose();
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
              SizedBox(height: 20.h),

              // Progress Bar (Localized)
              Text(
                LocaleKeys.step_2_of_4
                    .tr(), // JSON'da "STEP 2 OF 4" karşılığı olmalı
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
                  // İlk iki çubuk aktif (Step 2 olduğu için)
                  bool isActive = index < 2;
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

              SizedBox(height: 16.h),

              // Title (Localized)
              Text(
                LocaleKeys.prof_title.tr(),
                style: GoogleFonts.montserrat(
                  fontSize: 32.sp, // Tasarıma göre biraz küçültüldü
                  fontWeight: FontWeight.w700,
                  letterSpacing: 32.sp * -0.05,
                  color: MyColors.black,
                  height: 1.1,
                ),
              ),

              SizedBox(height: 6.h),

              // Subtitle (Localized)
              Text(
                LocaleKeys.prof_professional_desc.tr(),
                style: GoogleFonts.montserrat(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 15.sp * -0.05,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 20.h),

              // Text Input
              TextField(
                controller: _professionController,
                cursorColor: MyColors.lingolaPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    _hasText = value.trim().isNotEmpty;
                  });
                },
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: MyColors.black,
                ),
                decoration: InputDecoration(
                  // Hint text localize edildi
                  hintText: "Ui/Ux Designer", // Örn: "Ui/Ux Designer"
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: MyColors.textSecondary.withOpacity(0.4),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: MyColors.lingolaPrimaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 18.h,
                  ),
                ),
              ),

              const Spacer(),

              // Buttons
              Row(
                children: [
                  // Back Button (Localized)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
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
                  // Continue Button (Localized)
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _hasText
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EnglishLevelSelectionView(
                                          selectedLanguage:
                                              widget.selectedLanguage,
                                        ),
                                  ),
                                );
                              }
                            : null,
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
}
