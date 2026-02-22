import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Localization/app_localizations.dart';
import 'package:lingola_travel/Models/language.dart';
import 'package:lingola_travel/Riverpod/Providers/locale_provider.dart';

class AppLanguageView extends ConsumerStatefulWidget {
  const AppLanguageView({super.key});

  @override
  ConsumerState<AppLanguageView> createState() => _AppLanguageViewState();
}

class _AppLanguageViewState extends ConsumerState<AppLanguageView> {
  late Language _selectedLanguage;

  @override
  void initState() {
    super.initState();
    // Will be set properly on first build via didChangeDependencies
    _selectedLanguage = AppLanguages.all.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentCode = ref.read(localeProvider);
    _selectedLanguage = AppLanguages.getByCode(currentCode);
  }

  @override
  Widget build(BuildContext context) {
    final langCode = ref.watch(localeProvider);
    final l = AppLocalizations.of(langCode);

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
                    l.appLanguageViewTitle,
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

              // Title
              Text(
                l.appLanguageViewSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),

              SizedBox(height: 32.h),

              // Language List
              ...List.generate(AppLanguages.all.length, (index) {
                final language = AppLanguages.all[index];
                final isSelected = _selectedLanguage.code == language.code;
                final isLast = index == AppLanguages.all.length - 1;

                return Column(
                  children: [
                    _buildLanguageItem(
                      flagAsset: language.flagAsset,
                      name: language.getLocalizedName(langCode),
                      language: language,
                      isSelected: isSelected,
                    ),
                    if (!isLast) SizedBox(height: 12.h),
                  ],
                );
              }),

              SizedBox(height: 24.h),

              // Save Button
              Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF2EC4B6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4ECDC4).withOpacity(0.4),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await ref
                          .read(localeProvider.notifier)
                          .setLocale(_selectedLanguage.code);
                      if (context.mounted) Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Center(
                      child: Text(
                        l.save,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem({
    required String flagAsset,
    required String name,
    required Language language,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? Color(0xFF4ECDC4) : Color(0xFFE5E7EB),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFF4ECDC4).withOpacity(0.15),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: Image.asset(
                flagAsset,
                width: 32.w,
                height: 32.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: Color(0xFF4ECDC4),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 16.sp, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
