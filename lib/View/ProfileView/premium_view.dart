import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Services/revenuecat_service.dart';

class PremiumView extends StatefulWidget {
  const PremiumView({super.key});

  @override
  State<PremiumView> createState() => _PremiumViewState();
}

class _PremiumViewState extends State<PremiumView> {
  String _selectedPlan = 'annual'; // 'annual' or 'monthly'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back, Logo and Restore buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Text(
                        'BACK',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Logo in the center
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 72.w,
                    height: 72.w,
                  ),

                  // Restore Button
                  GestureDetector(
                    onTap: () async {
                      await RevenueCatService().restorePurchases();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Text(
                        'RESTORE',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 12.h),

                    // Title
                    Text(
                      'Lingola Travel Premium',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Thin line under title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Divider(color: Color(0xFFE5E7EB), thickness: 1.2),
                    ),

                    SizedBox(height: 24.h),

                    // Features List
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            icon: Icons.flight_takeoff_rounded,
                            title:
                                'Unlimited travel-focused word learning and review access',
                          ),
                          SizedBox(height: 20.h),
                          _buildFeatureItem(
                            icon: Icons.bookmark_outline,
                            title: 'Unlimited word saving',
                          ),
                          SizedBox(height: 20.h),
                          _buildFeatureItem(
                            icon: Icons.psychology_outlined,
                            title:
                                'Smart review reminders for learned travel words',
                          ),
                          SizedBox(height: 20.h),
                          _buildFeatureItem(
                            icon: Icons.emoji_events_outlined,
                            title: 'Daily and weekly learning goals',
                          ),
                          SizedBox(height: 20.h),
                          _buildFeatureItem(
                            icon: Icons.chat_bubble_outline,
                            title:
                                'Take travel-themed quizzes with learned words',
                          ),
                          SizedBox(height: 20.h),
                          _buildFeatureItem(
                            icon: Icons.people_outline,
                            title: 'Priority support',
                          ),
                          SizedBox(height: 20.h),
                          _buildFeatureItem(
                            icon: Icons.language_outlined,
                            title: 'Early access to new features',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 36.h),

                    // Pricing Plans
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          // Annual Plan
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPlan = 'annual';
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: _selectedPlan == 'annual'
                                      ? Color(0xFF4ECDC4)
                                      : Color(0xFFE5E7EB),
                                  width: _selectedPlan == 'annual' ? 2 : 1.5,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Annual',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Montserrat',
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        '\$79,99/yr (\$6,67/mo)',
                                        style: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Montserrat',
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF4ECDC4),
                                        borderRadius: BorderRadius.circular(
                                          100.r,
                                        ),
                                      ),
                                      child: Text(
                                        'SAVE 19%',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Montserrat',
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // Monthly Plan
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPlan = 'monthly';
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: _selectedPlan == 'monthly'
                                      ? Color(0xFF4ECDC4)
                                      : Color(0xFFE5E7EB),
                                  width: _selectedPlan == 'monthly' ? 2 : 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Monthly',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Montserrat',
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          '\$9,99/mo',
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'Montserrat',
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // Continue Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Container(
                        width: double.infinity,
                        height: 58.h,
                        decoration: BoxDecoration(
                          color: Color(0xFF4ECDC4),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await RevenueCatService().showPaywall();
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Cancel anytime',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Montserrat',
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Privacy Policy and Terms
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // TODO: Open privacy policy
                          },
                          child: Text(
                            'Privacy policy',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        SizedBox(width: 32.w),
                        GestureDetector(
                          onTap: () {
                            // TODO: Open terms of service
                          },
                          child: Text(
                            'Terms of service',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String title}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28.sp, color: Color(0xFF1A1A1A)),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
              color: Color(0xFF1A1A1A),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
