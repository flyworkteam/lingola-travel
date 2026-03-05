import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Localization/localization_manager.dart';
import 'package:lingola_travel/Models/language.dart';
import 'package:lingola_travel/Models/language_model.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';

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
    // İlk değer ataması.
    _selectedLanguage = AppLanguages.all.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mevcut aktif locale'e göre seçili dili bul ve senkronize et
    final currentLocale = context.locale;
    _selectedLanguage = AppLanguages.getByCode(currentLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    // Dil değiştiğinde tüm sayfanın rebuild olması için provider'ı izliyoruz
    ref.watch(localizationManagerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
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
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/icons/gerigelmeiconu.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    LocaleKeys.profile_app_language.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Title
              Text(
                LocaleKeys.profile_select_language_subtitle.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 24.h),

              // Language List
              ...List.generate(AppLanguages.all.length, (index) {
                final language = AppLanguages.all[index];
                final isSelected = _selectedLanguage.code == language.code;
                final isLast = index == AppLanguages.all.length - 1;

                return Column(
                  children: [
                    _buildLanguageItem(
                      language: language,
                      isSelected: isSelected,
                    ),
                    if (!isLast) SizedBox(height: 18.h),
                  ],
                );
              }),

              SizedBox(height: 24.h),

              // Save Button
              Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF2EC4B6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ECDC4).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      // LocalizationManager içindeki supportedLocales'den tam Locale'i buluyoruz
                      final targetLocale = LocalizationManager.supportedLocales
                          .firstWhere(
                            (l) => l.languageCode == _selectedLanguage.code,
                            orElse: () => Locale(
                              _selectedLanguage.code,
                              _selectedLanguage.countryCode,
                            ),
                          );

                      // Dil değiştirme işlemini bekle
                      await ref
                          .read(localizationManagerProvider.notifier)
                          .changeLanguage(context, targetLocale);
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Center(
                      child: Text(
                        LocaleKeys.profile_save.tr(),
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
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF4ECDC4) : Colors.white,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF4ECDC4).withOpacity(0.15)
                  : const Color(0xFFE2ECF0),
              blurRadius: 4,
              offset: isSelected ? const Offset(0, 4) : const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.asset(
                language.flagAsset,
                width: 32.w,
                height: 32.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.getTranslatedName(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 14.sp * -0.05,
                      fontFamily: 'Montserrat',
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4ECDC4),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
