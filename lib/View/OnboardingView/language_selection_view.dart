import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Core/Localization/app_localizations.dart';
import '../../Core/Theme/my_colors.dart';
import '../../Riverpod/Controllers/OnboardingController/onboarding_controller.dart';
import '../../Riverpod/Providers/locale_provider.dart';
import 'profession_selection_view.dart';

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
    final appLocale = ref.watch(localeProvider);
    final l = AppLocalizations.of(appLocale);

    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        bottom: false, // 🔥 ALT BOŞLUK KALKTI
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.step1of4,
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: MyColors.lingolaPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      l.step1Title,
                      style: GoogleFonts.montserrat(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      l.step1Subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        color: MyColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final language = languages[index];
                  final isSelected = selectedLanguage == language['name'];

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: GestureDetector(
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
                    onPressed: selectedLanguage != null
                        ? () {
                            ref
                                .read(onboardingControllerProvider.notifier)
                                .setTargetLanguage(selectedLanguage!);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfessionSelectionView(
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
                      l.continueBtn,
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
