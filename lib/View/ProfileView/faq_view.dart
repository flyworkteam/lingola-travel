import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';

class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: MediaQuery.of(context).padding.top + 8.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              // Header
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/icons/gerigelmeiconu.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    LocaleKeys.faq_faq_header.tr(),
                    style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              _buildSectionTitle(LocaleKeys.faq_faq_section_general.tr()),
              SizedBox(height: 16.h),

              _buildFaqItem(
                index: 0,
                question: LocaleKeys.faq_faq_q1.tr(),
                answer: LocaleKeys.faq_faq_a1.tr(),
              ),
              SizedBox(height: 12.h),
              _buildFaqItem(
                index: 1,
                question: LocaleKeys.faq_faq_q2.tr(),
                answer: LocaleKeys.faq_faq_a2.tr(),
              ),
              SizedBox(height: 12.h),
              _buildFaqItem(
                index: 2,
                question: LocaleKeys.faq_faq_q3.tr(),
                answer: LocaleKeys.faq_faq_a3.tr(),
              ),
              SizedBox(height: 12.h),
              _buildFaqItem(
                index: 3,
                question: LocaleKeys.faq_faq_q4.tr(),
                answer: LocaleKeys.faq_faq_a4.tr(),
              ),
              SizedBox(height: 12.h),
              _buildFaqItem(
                index: 4,
                question: LocaleKeys.faq_faq_q5.tr(),
                answer: LocaleKeys.faq_faq_a5.tr(),
              ),

              SizedBox(height: 32.h),

              _buildSectionTitle(LocaleKeys.faq_faq_section_usage.tr()),
              SizedBox(height: 16.h),

              _buildFaqItem(
                index: 5,
                question: LocaleKeys.faq_faq_q6.tr(),
                answer: LocaleKeys.faq_faq_a6.tr(),
              ),
              SizedBox(height: 12.h),
              _buildFaqItem(
                index: 6,
                question: LocaleKeys.faq_faq_q7.tr(),
                answer: LocaleKeys.faq_faq_a7.tr(),
              ),
              SizedBox(height: 12.h),
              _buildFaqItem(
                index: 7,
                question: LocaleKeys.faq_faq_q8.tr(),
                answer: LocaleKeys.faq_faq_a8.tr(),
              ),
              SizedBox(height: 12.h),
              _buildFaqItem(
                index: 8,
                question: LocaleKeys.faq_faq_q9.tr(),
                answer: LocaleKeys.faq_faq_a9.tr(),
              ),
              SizedBox(height: 12.h),
              _buildFaqItem(
                index: 9,
                question: LocaleKeys.faq_faq_q10.tr(),
                answer: LocaleKeys.faq_faq_a10.tr(),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 6.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: const Color(0xFF1B8A6B),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            letterSpacing: 16.sp * -0.03,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqItem({
    required int index,
    required String question,
    required String answer,
  }) {
    final bool isExpanded = _expandedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r), // Figma: Corner radius 15
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDCE1EC), // Figma: Shadow color #DCE1EC
            blurRadius: 4, // Figma: Blur 4
            offset: const Offset(
              0,
              0,
            ), // Figma: X:0, Y:0 (veya görseldeki gibi çok hafif aşağıysa 0, 1 yapabilirsiniz)
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: const Color(0xFF4ECDC4).withOpacity(0.05),
            highlightColor: const Color(0xFF4ECDC4).withOpacity(0.03),
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
            childrenPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            onExpansionChanged: (expanded) {
              setState(() {
                _expandedIndex = expanded ? index : null;
              });
            },
            initiallyExpanded: isExpanded,
            title: Text(
              question,
              style: GoogleFonts.montserrat(
                fontSize: 15.sp,
                letterSpacing: 15.sp * -0.03,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            trailing: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: isExpanded ? 0.5 : 0,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24,
                color: Color(0xFF6B7280),
              ),
            ),
            children: [
              Text(
                answer,
                style: GoogleFonts.montserrat(
                  fontSize: 13.sp, // Okunabilirlik için bir tık büyütüldü
                  fontWeight: FontWeight.w400,
                  color: const Color(
                    0xFF4B5563,
                  ), // Biraz daha koyu bir gri tonu
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
