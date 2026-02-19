import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../Core/Theme/my_colors.dart';
import '../../Models/policy_model.dart';
import '../../Repositories/policy_repository.dart';

/// Policy Detail View - Displays Privacy Policy, Terms of Service, or Cookies Policy
class PolicyDetailView extends StatefulWidget {
  final String policyType; // 'privacy', 'terms', or 'cookies'

  const PolicyDetailView({super.key, required this.policyType});

  @override
  State<PolicyDetailView> createState() => _PolicyDetailViewState();
}

class _PolicyDetailViewState extends State<PolicyDetailView> {
  final PolicyRepository _policyRepository = PolicyRepository();

  bool _isLoading = true;
  PolicyModel? _policy;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔍 Loading policy type: ${widget.policyType}');
      final response = await _getPolicyByType();
      print('📦 Response: success=${response.success}, data=${response.data}');

      if (response.success && response.data != null) {
        print('✅ Policy loaded successfully: ${response.data!.title}');
        setState(() {
          _policy = response.data;
          _isLoading = false;
        });
      } else {
        print('❌ Policy load failed: ${response.error?.message}');
        setState(() {
          _errorMessage = response.error?.message ?? 'Politika yüklenemedi';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('🔥 Exception loading policy: $e');
      print('📍 StackTrace: $stackTrace');
      setState(() {
        _errorMessage = 'Bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<dynamic> _getPolicyByType() {
    switch (widget.policyType) {
      case 'privacy':
        return _policyRepository.getPrivacyPolicy();
      case 'terms':
        return _policyRepository.getTermsOfService();
      case 'cookies':
        return _policyRepository.getCookiesPolicy();
      default:
        return _policyRepository.getPrivacyPolicy();
    }
  }

  String _getAppBarTitle() {
    switch (widget.policyType) {
      case 'privacy':
        return 'Gizlilik Politikası';
      case 'terms':
        return 'Hizmet Şartları';
      case 'cookies':
        return 'Çerez Politikası';
      default:
        return 'Politika';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: MyColors.primary))
          : _errorMessage != null
          ? _buildErrorView()
          : _buildPolicyContentWithStickyHeader(),
    );
  }

  Widget _buildPolicyContentWithStickyHeader() {
    if (_policy == null) return const SizedBox();

    return CustomScrollView(
      slivers: [
        // AppBar - Kaydırınca yukarı çıkacak
        SliverAppBar(
          backgroundColor: MyColors.white,
          elevation: 0,
          pinned: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: MyColors.black,
              size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _getAppBarTitle(),
            style: GoogleFonts.montserrat(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: MyColors.black,
            ),
          ),
          centerTitle: true,
        ),

        // Markdown Content
        SliverToBoxAdapter(
          child: Markdown(
            data: _policy!.content,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(20.w),
            styleSheet: MarkdownStyleSheet(
              h1: GoogleFonts.montserrat(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: MyColors.black,
                height: 1.3,
              ),
              h2: GoogleFonts.montserrat(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: MyColors.black,
                height: 1.3,
              ),
              h3: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: MyColors.black,
                height: 1.4,
              ),
              p: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: MyColors.textPrimary,
                height: 1.6,
              ),
              strong: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: MyColors.black,
              ),
              em: GoogleFonts.montserrat(
                fontStyle: FontStyle.italic,
                color: MyColors.textPrimary,
              ),
              listBullet: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: MyColors.textPrimary,
              ),
              blockSpacing: 16.h,
              listIndent: 24.w,
              h1Padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
              h2Padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
              h3Padding: EdgeInsets.only(top: 12.h, bottom: 6.h),
              pPadding: EdgeInsets.only(bottom: 12.h),
            ),
          ),
        ),

        // Bottom Padding
        SliverToBoxAdapter(child: SizedBox(height: 40.h)),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: MyColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              _errorMessage ?? 'Bir hata oluştu',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: MyColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadPolicy,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Tekrar Dene',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: MyColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
