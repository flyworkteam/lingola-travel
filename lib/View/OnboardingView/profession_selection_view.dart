import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Core/Theme/my_colors.dart';
import 'profession_detail_view.dart';

/// Profession Selection View - Onboarding Step 2 of 4
/// User selects their profession/background
class ProfessionSelectionView extends StatefulWidget {
  final String? selectedLanguage;

  const ProfessionSelectionView({super.key, this.selectedLanguage});

  @override
  State<ProfessionSelectionView> createState() =>
      _ProfessionSelectionViewState();
}

class _ProfessionSelectionViewState extends State<ProfessionSelectionView> {
  String? selectedProfession;

  final List<Map<String, String>> professions = [
    {
      'name': 'Student',
      'subtitle': 'University or high\nschool',
      'icon': 'assets/images/student.png',
      'background': 'assets/images/littlecard.png',
    },
    {
      'name': 'Professional',
      'subtitle': 'Corporate or\nfreelance',
      'icon': 'assets/images/professional.png',
      'background': 'assets/images/littlecard.png', // Same as others
    },
    {
      'name': 'Technology',
      'subtitle': 'IT, software, or\ndata',
      'icon': 'assets/images/technology.png',
      'background': 'assets/images/littlecard.png',
    },
    {
      'name': 'Healthcare',
      'subtitle': 'Medicine or\nnursing',
      'icon': 'assets/images/healtcare.png',
      'background': 'assets/images/littlecard.png',
    },
    {
      'name': 'Arts & Media',
      'subtitle': 'Design, film, or\nwriting',
      'icon': 'assets/images/artsmedia.png',
      'background': 'assets/images/littlecard.png',
    },
    {
      'name': 'Other',
      'subtitle': 'None of the\nabove',
      'icon': 'assets/images/other.png',
      'background': 'assets/images/littlecard.png',
    },
  ];

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STEP 2 OF 4',
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

              SizedBox(height: 28.h),

              // Title
              Text(
                'Mesleğiniz\nNedir?',
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
                'Geçmişinize göre dil yolculuğunuzu\nözelleştireceğiz',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: MyColors.grey600,
                  height: 1.3,
                ),
              ),

              SizedBox(height: 24.h),

              // Profession Cards Grid - Fixed height, no scroll
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: professions.length,
                  itemBuilder: (context, index) {
                    final profession = professions[index];
                    final isSelected = selectedProfession == profession['name'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedProfession = profession['name'];
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
                              // Icon with background card
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Background card - dark when selected, light when not
                                  Container(
                                    width: 70.w,
                                    height: 70.h,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? MyColors.lingolaPrimaryColor
                                          : const Color(0xFFE0F7F5),
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                  // Icon logo - white when selected, turquoise when not
                                  Image.asset(
                                    profession['icon']!,
                                    width: 36.w,
                                    height: 36.h,
                                    fit: BoxFit.contain,
                                    color: isSelected
                                        ? MyColors.white
                                        : const Color(0xFF2EC4B6),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              // Title (centered)
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
                              // Subtitle (centered)
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                        onPressed: selectedProfession != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfessionDetailView(
                                      selectedCategory: selectedProfession,
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
}
