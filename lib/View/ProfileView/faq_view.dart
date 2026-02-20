import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/icons/gerigelmeiconu.svg',
                      width: 13.w,
                      height: 13.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'F.A.Q.',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),

                  // Genel Section
                  _buildSectionTitle('Genel'),
                  SizedBox(height: 16.h),

                  _buildFaqItem(
                    index: 0,
                    question: 'Lingola Travel nedir?',
                    answer:
                        'Lingola Travel, seyahat sırasında ihtiyaç duyulan İngilizce kelime ve ifadeleri pratik şekilde öğreten bir dil öğrenme uygulamasıdır.',
                  ),

                  SizedBox(height: 12.h),

                  _buildFaqItem(
                    index: 1,
                    question: 'Lingola Travel kimler için uygundur?',
                    answer:
                        'Yurt dışına çıkan, tatil yapan veya seyahat sırasında İngilizceyi daha rahat kullanmak isteyen herkes için uygundur.',
                  ),

                  SizedBox(height: 12.h),

                  _buildFaqItem(
                    index: 2,
                    question: 'Lingola Travel genel İngilizce mi öğretir?',
                    answer:
                        'Hayır. Lingola Travel, seyahatte en sık karşılaşılan durumlara özel kelime ve ifadelere odaklanır.',
                  ),

                  SizedBox(height: 12.h),

                  _buildFaqItem(
                    index: 3,
                    question: 'Hangi konular yer alıyor?',
                    answer:
                        'Havaalanı, otel, restoran, ulaşım, alışveriş ve acil durumlar gibi temel seyahat konuları yer alır.',
                  ),

                  SizedBox(height: 12.h),

                  _buildFaqItem(
                    index: 4,
                    question: 'Yeni başlayanlar için uygun mu?',
                    answer:
                        'Evet. Lingola Travel, İngilizceye yeni başlayanlar için bile kolay anlaşılır içerikler sunar.',
                  ),

                  SizedBox(height: 32.h),

                  // Kullanım Section
                  _buildSectionTitle('Kullanım'),
                  SizedBox(height: 16.h),

                  _buildFaqItem(
                    index: 5,
                    question: 'Günlük ne kadar zaman ayırmam gerekir?',
                    answer:
                        'Günde sadece birkaç dakika ayırarak kelime ve ifadeleri hızlıca öğrenebilirsin.',
                  ),

                  SizedBox(height: 12.h),

                  _buildFaqItem(
                    index: 6,
                    question: 'Kelimeler nasıl öğretiliyor?',
                    answer:
                        'Kelimeler kısa açıklamalar ve gerçek seyahat senaryolarına uygun örneklerle sunulur.',
                  ),

                  SizedBox(height: 12.h),

                  _buildFaqItem(
                    index: 7,
                    question: 'İnternet bağlantısı olmadan kullanılabilir mi?',
                    answer:
                        'Bazı içerikler çevrimdışı kullanılabilir; tam deneyim için internet bağlantısı önerilir.',
                  ),

                  SizedBox(height: 12.h),

                  _buildFaqItem(
                    index: 8,
                    question:
                        'Öğrendiklerimi seyahatte gerçekten kullanabilir miyim?',
                    answer:
                        'Evet. İçerikler, seyahat sırasında birebir ihtiyaç duyulan gerçek kullanım durumlarına göre hazırlanmıştır.',
                  ),

                  SizedBox(height: 12.h),

                  _buildFaqItem(
                    index: 9,
                    question: 'Lingola Travel ücretsiz mi?',
                    answer:
                        'Uygulama ücretsiz olarak kullanılabilir, ek özellikler ve içerikler için premium seçenekler sunulabilir.',
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
            color: Color(0xFF1B8A6B),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: Color(0xFF1A1A1A),
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
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Color(0xFF4ECDC4).withOpacity(0.05),
            highlightColor: Color(0xFF4ECDC4).withOpacity(0.03),
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            childrenPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            onExpansionChanged: (expanded) {
              setState(() {
                _expandedIndex = expanded ? index : null;
              });
            },
            initiallyExpanded: isExpanded,
            title: Text(
              question,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: Color(0xFF1A1A1A),
              ),
            ),
            trailing: AnimatedRotation(
              duration: Duration(milliseconds: 200),
              turns: isExpanded ? 0.5 : 0,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24.sp,
                color: Color(0xFF6B7280),
              ),
            ),
            children: [
              Text(
                answer,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF6B7280),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
