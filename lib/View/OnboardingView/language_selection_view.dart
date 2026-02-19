import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Core/Theme/my_colors.dart';
import '../../Riverpod/Controllers/OnboardingController/onboarding_controller.dart';
import 'profession_selection_view.dart';

/// Language Selection View - Onboarding Step 1 of 4
/// User selects which language they want to learn
class LanguageSelectionView extends ConsumerStatefulWidget {
  const LanguageSelectionView({super.key});

  @override
  ConsumerState<LanguageSelectionView> createState() =>
      _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends ConsumerState<LanguageSelectionView> {
  String? selectedLanguage;

  final List<Map<String, String>> languages = [
    {'name': 'English', 'flag': 'assets/images/englishflag.png'},
    {'name': 'German', 'flag': 'assets/images/germanflag.png'},
    {'name': 'Italian', 'flag': 'assets/images/italianflag.png'},
    {'name': 'French', 'flag': 'assets/images/frenchflag.png'},
    {'name': 'Japanese', 'flag': 'assets/images/japaneseflag.png'},
    {'name': 'Spanish', 'flag': 'assets/images/spanishflag.png'},
    {'name': 'Russian', 'flag': 'assets/images/russianflag.png'},
    {'name': 'Turkish', 'flag': 'assets/images/turkishflag.png'},
    {'name': 'Korean', 'flag': 'assets/images/koreanflag.png'},
    {'name': 'Hindi', 'flag': 'assets/images/hindiflag.png'},
    {'name': 'Portuguese', 'flag': 'assets/images/portugalflag.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step indicator
                  Text(
                    'ADIM 1 / 4',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: MyColors.lingolaPrimaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
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
                        flex: 1,
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
                        flex: 1,
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
                        flex: 1,
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
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),

                    // Title
                    Text(
                      'Öğrenmek istediğiniz\ndili seçin',
                      style: GoogleFonts.montserrat(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: MyColors.black,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Subtitle
                    Text(
                      'Lütfen öğrenmek istediğiniz\ndili seçin',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: MyColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Language List
                    Expanded(
                      child: ListView.separated(
                        itemCount: languages.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final language = languages[index];
                          final isSelected =
                              selectedLanguage == language['name'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLanguage = language['name'];
                              });
                            },
                            child: Container(
                              height: 56.h,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: MyColors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isSelected
                                      ? MyColors.lingolaPrimaryColor
                                      : MyColors.grey200,
                                  width: isSelected ? 2 : 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Flag
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4.r),
                                    child: Image.asset(
                                      language['flag']!,
                                      width: 32.w,
                                      height: 24.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  // Language name
                                  Text(
                                    language['name']!,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: MyColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: selectedLanguage != null
                            ? () {
                                // Save to onboarding controller
                                ref
                                    .read(onboardingControllerProvider.notifier)
                                    .setTargetLanguage(selectedLanguage!);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfessionSelectionView(
                                          selectedLanguage: selectedLanguage,
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
                        child: Text(
                          'Devam Et',
                          style: GoogleFonts.montserrat(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: MyColors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
