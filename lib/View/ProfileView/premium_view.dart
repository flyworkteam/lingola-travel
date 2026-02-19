import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../Services/revenuecat_service.dart';

class PremiumView extends StatefulWidget {
  const PremiumView({super.key});

  @override
  State<PremiumView> createState() => _PremiumViewState();
}

class _PremiumViewState extends State<PremiumView> {
  String _selectedPlan = 'annual'; // 'annual' or 'monthly'
  bool _isLoading = false;
  bool _isLoadingPackages = true;
  String? _errorMessage;

  Package? _annualPackage;
  Package? _monthlyPackage;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoadingPackages = true;
      _errorMessage = null;
    });

    try {
      final offerings = await RevenueCatService().getOfferings();

      if (offerings != null && offerings.current != null) {
        final availablePackages = offerings.current!.availablePackages;

        // Find annual and monthly packages
        for (var package in availablePackages) {
          if (package.packageType == PackageType.annual) {
            _annualPackage = package;
          } else if (package.packageType == PackageType.monthly) {
            _monthlyPackage = package;
          }
        }

        print(
          '✅ Packages loaded: Annual=${_annualPackage != null}, Monthly=${_monthlyPackage != null}',
        );
      } else {
        _errorMessage = 'No packages available';
        print('⚠️ No offerings found');
      }
    } catch (e) {
      _errorMessage = 'Failed to load packages: $e';
      print('❌ Error loading packages: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPackages = false;
        });
      }
    }
  }

  Future<void> _handlePurchase() async {
    final selectedPackage = _selectedPlan == 'annual'
        ? _annualPackage
        : _monthlyPackage;

    if (selectedPackage == null) {
      _showSnackBar('Package not available', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final customerInfo = await RevenueCatService().purchasePackage(
        selectedPackage,
      );

      if (customerInfo != null) {
        // Check if purchase was successful
        if (customerInfo.entitlements.active.containsKey('premium')) {
          _showSnackBar('✅ Purchase successful! Welcome to Premium!');
          // Wait a bit to show the message, then pop
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context, true); // Return true to indicate success
          }
        } else {
          _showSnackBar(
            'Purchase completed but premium not activated',
            isError: true,
          );
        }
      } else {
        _showSnackBar('Purchase cancelled or failed', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
      print('❌ Purchase error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customerInfo = await RevenueCatService().restorePurchases();

      if (customerInfo != null) {
        if (customerInfo.entitlements.active.containsKey('premium')) {
          _showSnackBar('✅ Purchases restored successfully!');
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          _showSnackBar('No active subscriptions found', isError: true);
        }
      } else {
        _showSnackBar('Failed to restore purchases', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error restoring: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header with Back, Logo and Restore buttons
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
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
                        onTap: _isLoading ? null : _handleRestore,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: _isLoading
                                ? Color(0xFFE5E7EB)
                                : Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            'RESTORE',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              color: _isLoading
                                  ? Color(0xFF9CA3AF)
                                  : Color(0xFF1A1A1A),
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
                  child: _isLoadingPackages
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF4ECDC4),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Loading packages...',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Montserrat',
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64.sp,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: 'Montserrat',
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                ElevatedButton(
                                  onPressed: _loadPackages,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4ECDC4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32.w,
                                      vertical: 16.h,
                                    ),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
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
                                child: Divider(
                                  color: Color(0xFFE5E7EB),
                                  thickness: 1.2,
                                ),
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
                                    if (_annualPackage != null)
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
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            border: Border.all(
                                              color: _selectedPlan == 'annual'
                                                  ? Color(0xFF4ECDC4)
                                                  : Color(0xFFE5E7EB),
                                              width: _selectedPlan == 'annual'
                                                  ? 2
                                                  : 1.5,
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Montserrat',
                                                      color: Color(0xFF1A1A1A),
                                                    ),
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  Text(
                                                    _annualPackage!
                                                        .storeProduct
                                                        .priceString,
                                                    style: TextStyle(
                                                      fontSize: 17.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          100.r,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'BEST VALUE',
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
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

                                    if (_annualPackage != null &&
                                        _monthlyPackage != null)
                                      SizedBox(height: 12.h),

                                    // Monthly Plan
                                    if (_monthlyPackage != null)
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
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            border: Border.all(
                                              color: _selectedPlan == 'monthly'
                                                  ? Color(0xFF4ECDC4)
                                                  : Color(0xFFE5E7EB),
                                              width: _selectedPlan == 'monthly'
                                                  ? 2
                                                  : 1.5,
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
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: Color(
                                                          0xFF1A1A1A,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 6.h),
                                                    Text(
                                                      _monthlyPackage!
                                                          .storeProduct
                                                          .priceString,
                                                      style: TextStyle(
                                                        fontSize: 17.sp,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: Color(
                                                          0xFF1A1A1A,
                                                        ),
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
                                    color: _isLoading
                                        ? Color(0xFFB0E5E1)
                                        : Color(0xFF4ECDC4),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _isLoading
                                          ? null
                                          : _handlePurchase,
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: _isLoading
                                          ? Center(
                                              child: SizedBox(
                                                width: 24.w,
                                                height: 24.w,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              ),
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                    color: Colors.white
                                                        .withOpacity(0.9),
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
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF4ECDC4)),
                      SizedBox(height: 16.h),
                      Text(
                        'Processing...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
