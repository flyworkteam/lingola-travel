import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18.sp,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'F.A.Q.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),

                    // Uygulama Hakkında Section
                    _buildSectionTitle('Uygulama Hakkında'),
                    SizedBox(height: 16.h),

                    _buildFaqItem(
                      index: 0,
                      question: 'Lingola Travel nasıl çalışır?',
                      answer:
                          'Lingola Travel, interaktif dersler ve pratik alıştırmalarla yabancı dil öğrenmenizi kolaylaştırır. Günlük hedefler belirleyerek, sesli telaffuz çalışmaları yaparak ve kelime dağarcığınızı geliştirerek ilerleme kaydedebilirsiniz.',
                    ),

                    SizedBox(height: 12.h),

                    _buildFaqItem(
                      index: 1,
                      question: 'Verilerim güvende mi?',
                      answer:
                          'Evet, tüm verileriniz şifreli olarak saklanır ve gizlilik politikamıza uygun şekilde korunur. Kişisel bilgileriniz hiçbir şekilde üçüncü şahıslarla paylaşılmaz.',
                    ),

                    SizedBox(height: 12.h),

                    _buildFaqItem(
                      index: 2,
                      question: 'Çevrimdışı kullanabilir miyim?',
                      answer:
                          'Evet, daha önce indirdiğiniz derslere internet bağlantısı olmadan da erişebilirsiniz. Ancak bazı özellikler için internet bağlantısı gereklidir.',
                    ),

                    SizedBox(height: 32.h),

                    // Hesap ve Abonelik Section
                    _buildSectionTitle('Hesap ve Abonelik'),
                    SizedBox(height: 16.h),

                    _buildFaqItem(
                      index: 3,
                      question: 'Aboneliğimi nasıl iptal ederim?',
                      answer:
                          'Aboneliğinizi Profile > Premium bölümünden veya uygulama mağazası ayarlarınızdan iptal edebilirsiniz. İptal işlemi sonrası mevcut dönem sonuna kadar premium özelliklerden yararlanmaya devam edebilirsiniz.',
                    ),

                    SizedBox(height: 12.h),

                    _buildFaqItem(
                      index: 4,
                      question: 'Aile paylaşımı var mı?',
                      answer:
                          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to',
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: Color(0xFF4ECDC4),
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
