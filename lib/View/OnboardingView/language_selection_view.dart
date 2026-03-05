import 'package:easy_localization/easy_localization.dart'; // easy_localization eklendi
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Core/Theme/my_colors.dart';
import '../../Riverpod/Controllers/OnboardingController/onboarding_controller.dart';
import 'profession_selection_view.dart';

class LanguageSelectionView extends ConsumerStatefulWidget {
  const LanguageSelectionView({super.key});

  @override
  ConsumerState<LanguageSelectionView> createState() =>
      _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends ConsumerState<LanguageSelectionView> {
  // Artık seçilen dilin adını değil, JSON'daki key değerini (örn: 'lang_english') tutuyoruz
  String? selectedLanguageKey;

  Widget _buildProgressBar(int currentStep, int totalSteps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'step_${currentStep}_of_$totalSteps'.tr(), // "STEP 1 OF 4"
          style: GoogleFonts.montserrat(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold, // Tasarımda biraz daha kalın duruyor
            color: MyColors.lingolaPrimaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: List.generate(totalSteps, (index) {
            bool isActive = index < currentStep;
            return Expanded(
              child: Container(
                height: 4.h, // Çizgi kalınlığı
                margin: EdgeInsets.only(
                  right: index == totalSteps - 1 ? 0 : 8.w,
                ), // Aradaki boşluklar
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dil listesini build metodu içinde tanımlıyoruz ki dil değiştiğinde isimler güncellensin
    final List<Map<String, String>> languages = [
      {
        'key': 'lang_english',
        'name': 'lang_english'.tr(),
        'flag': 'assets/images/englishflag.png',
      },
      {
        'key': 'lang_german',
        'name': 'lang_german'.tr(),
        'flag': 'assets/images/germanflag.png',
      },
      {
        'key': 'lang_italian',
        'name': 'lang_italian'.tr(),
        'flag': 'assets/images/italianflag.png',
      },
      {
        'key': 'lang_french',
        'name': 'lang_french'.tr(),
        'flag': 'assets/images/frenchflag.png',
      },
      {
        'key': 'lang_japanese',
        'name': 'lang_japanese'.tr(),
        'flag': 'assets/images/japaneseflag.png',
      },
      {
        'key': 'lang_spanish',
        'name': 'lang_spanish'.tr(),
        'flag': 'assets/images/spanishflag.png',
      },
      {
        'key': 'lang_russian',
        'name': 'lang_russian'.tr(),
        'flag': 'assets/images/russianflag.png',
      },
      {
        'key': 'lang_turkish',
        'name': 'lang_turkish'.tr(),
        'flag': 'assets/images/turkishflag.png',
      },
      {
        'key': 'lang_korean',
        'name': 'lang_korean'.tr(),
        'flag': 'assets/images/koreanflag.png',
      },
      {
        'key': 'lang_hindi',
        'name': 'lang_hindi'.tr(),
        'flag': 'assets/images/hindiflag.png',
      },
      {
        'key': 'lang_portuguese',
        'name': 'lang_portuguese'.tr(),
        'flag': 'assets/images/portugalflag.png',
      },
    ];

    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        bottom: false,
        top: false,
        child: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),
                    _buildProgressBar(1, 4),
                    SizedBox(height: 8.h),
                    Text(
                      'select_language_title'.tr(),
                      style: GoogleFonts.montserrat(
                        fontSize: 32.sp,
                        letterSpacing: 32.sp * -0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'select_language_subtitle'.tr(),
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        letterSpacing: 16.sp * -0.05,
                        color: MyColors.textSecondary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final language = languages[index];
                  final isSelected = selectedLanguageKey == language['key'];

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLanguageKey = language['key'];
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: Image.asset(
                                language['flag']!,
                                width: 36.w,
                                height: 27.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              language['name']!,
                              style: GoogleFonts.montserrat(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: languages.length),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                child: SizedBox(
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: selectedLanguageKey != null
                        ? () {
                            ref
                                .read(onboardingControllerProvider.notifier)
                                .setTargetLanguage(selectedLanguageKey!);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfessionSelectionView(
                                  selectedLanguage: selectedLanguageKey,
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
                      'continue_btn'.tr(),
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: MyColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
