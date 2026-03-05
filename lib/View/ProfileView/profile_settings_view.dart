import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Localization/localization_manager.dart';
import 'package:lingola_travel/Core/Utils/future_extensions.dart';
import 'package:lingola_travel/Models/language_model.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';

import '../../Models/language.dart';
import '../../Repositories/notification_repository.dart';
import '../../Repositories/profile_repository.dart';
import '../../Riverpod/Providers/selected_language_provider.dart';
import '../../Services/onesignal_service.dart';
import '../../Services/secure_storage_service.dart';

// DİKKAT: localizationManagerProvider'ı tanımladığın dosyayı kendi projenin yoluna göre buraya ekle
// import '../../Riverpod/Providers/localization_manager.dart';

class ProfileSettingsView extends ConsumerStatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  ConsumerState<ProfileSettingsView> createState() =>
      _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends ConsumerState<ProfileSettingsView> {
  final ProfileRepository _profileRepository = ProfileRepository();

  bool _isLoading = true;

  String _selectedGender = 'Male';
  late Language _selectedLanguage;
  String? _userPhotoUrl;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDefaultLanguage();
    _loadProfile();
  }

  void _initDefaultLanguage() {
    final currentLocaleCode = Intl.getCurrentLocale().split('_')[0];

    _selectedLanguage = AppLanguages.all.firstWhere(
      (lang) => lang.code == currentLocaleCode,
      orElse: () => AppLanguages.all.first,
    );
  }

  Future<void> _loadProfile() async {
    try {
      final response = await _profileRepository.getProfile();

      if (response.success && response.data != null) {
        final userData = response.data['user'];

        if (userData['name'] != null) _nameController.text = userData['name'];
        if (userData['email'] != null)
          _emailController.text = userData['email'];
        if (userData['photo_url'] != null)
          _userPhotoUrl = userData['photo_url'];
        if (userData['age'] != null)
          _ageController.text = userData['age'].toString();
        if (userData['gender'] != null) _selectedGender = userData['gender'];

        final targetLanguageCode = userData['target_language'] as String?;
        Language? foundLanguage;
        if (targetLanguageCode != null) {
          foundLanguage = AppLanguages.all.firstWhere(
            (lang) => lang.code == targetLanguageCode,
            orElse: () => _selectedLanguage,
          );
        }

        if (mounted) {
          setState(() {
            if (foundLanguage != null) _selectedLanguage = foundLanguage;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
            )
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context),
                  SizedBox(height: 20.h),
                  _buildProfilePhotoSection(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        _buildLabel(LocaleKeys.profile_profile_full_name.tr()),
                        SizedBox(height: 10.h),
                        _buildInputField(
                          controller: _nameController,
                          iconPath: 'assets/icons/fullname.svg',
                          hint: LocaleKeys.profile_enterYourName.tr(),
                          enabled: true,
                        ),
                        SizedBox(height: 20.h),
                        _buildLabel(LocaleKeys.profile_profile_email.tr()),
                        SizedBox(height: 10.h),
                        _buildInputField(
                          controller: _emailController,
                          iconPath: 'assets/icons/email.svg',
                          hint: LocaleKeys.profile_enterYourEmail.tr(),
                          enabled: false,
                          showLock: true,
                        ),
                        SizedBox(height: 20.h),
                        _buildLabel(LocaleKeys.profile_profile_age.tr()),
                        SizedBox(height: 10.h),
                        _buildInputField(
                          controller: _ageController,
                          iconPath: 'assets/icons/age.svg',
                          hint: LocaleKeys.profile_enterYourAge.tr(),
                          enabled: false,
                          showLock: true,
                        ),
                        SizedBox(height: 24.h),
                        _buildLabel(LocaleKeys.profile_profile_gender.tr()),
                        SizedBox(height: 12.h),
                        _buildGenderSelector(),
                        SizedBox(height: 24.h),
                        _buildLabel(
                          LocaleKeys.profile_select_language_subtitle.tr(),
                        ),
                        SizedBox(height: 10.h),
                        _buildLanguageDropdown(),
                        SizedBox(height: 40.h),
                        _buildSaveButton(),
                        SizedBox(height: 20.h),
                        _buildDeleteAccountButton(),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: MediaQuery.of(context).padding.top + 8.h,
        bottom: 8.h,
      ),
      child: Row(
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
            LocaleKeys.profile_profile_settings.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4ECDC4), width: 3),
                ),
                child: ClipOval(
                  child: _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
                      ? Image.network(
                          _userPhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            LocaleKeys.profile_profile_change_photo.tr(),
            style: TextStyle(
              fontSize: 12.sp,
              letterSpacing: 12.sp * -0.05,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              color: const Color(0xFF5F8486),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF4ECDC4).withOpacity(0.1),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/userlogo.svg',
          width: 50.w,
          height: 50.w,
          colorFilter: const ColorFilter.mode(
            Color(0xFF4ECDC4),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
        color: const Color(0xFF6B7280),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String iconPath,
    required String hint,
    required bool enabled,
    bool showLock = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF9FAFB) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
          color: enabled ? const Color(0xFF1A1A1A) : const Color(0xFF9CA3AF),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 15.sp, color: const Color(0xFF9CA3AF)),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 12.w),
            child: SvgPicture.asset(
              iconPath,
              width: 22.w,
              colorFilter: ColorFilter.mode(
                enabled ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                BlendMode.srcIn,
              ),
              fit: BoxFit.scaleDown,
            ),
          ),
          suffixIcon: showLock
              ? Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: SvgPicture.asset(
                    'assets/icons/lock.svg',
                    width: 20.w,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF9CA3AF),
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.scaleDown,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildGenderOption(
            label: LocaleKeys.profile_profile_gender_male.tr(),
            iconPath: 'assets/icons/male.svg',
            isSelected: _selectedGender == 'Male',
            onTap: () => setState(() => _selectedGender = 'Male'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildGenderOption(
            label: LocaleKeys.profile_profile_gender_female.tr(),
            iconPath: 'assets/icons/female.svg',
            isSelected: _selectedGender == 'Female',
            onTap: () => setState(() => _selectedGender = 'Female'),
          ),
        ),
        SizedBox(width: 12.w),
        _buildGenderIconOption(
          iconPath: 'assets/icons/forbidden.svg',
          isSelected: _selectedGender == 'Other',
          onTap: () => setState(() => _selectedGender = 'Other'),
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String label,
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4ECDC4)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 22.w,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderIconOption({
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4ECDC4)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 24.w,
            colorFilter: ColorFilter.mode(
              isSelected ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return GestureDetector(
      onTap: _showLanguageSelector,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Image.asset(
                  _selectedLanguage.flagAsset,
                  width: 28.w,
                  height: 28.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  _selectedLanguage.nativeName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                LocaleKeys.profile_profile_select_language.tr(),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AppLanguages.all.length,
                itemBuilder: (context, index) {
                  final language = AppLanguages.all[index];
                  final isSelected = language.code == _selectedLanguage.code;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedLanguage = language);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      color: isSelected
                          ? const Color(0xFF4ECDC4).withOpacity(0.1)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: Image.asset(
                              language.flagAsset,
                              width: 32.w,
                              height: 32.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              language.getTranslatedName(),
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF4ECDC4)
                                    : Colors.black,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF4ECDC4),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF2EC4B6)],
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
          onTap: () => _saveProfile().withLoading(context),
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
              LocaleKeys.profile_save.tr(),
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return Center(
      child: TextButton(
        onPressed: _showDeleteAccountDialog,
        child: Text(
          LocaleKeys.profile_delete_dialog_confirm.tr(),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE57373),
          ),
        ),
      ),
    );
  }

  // --- Yeni eklenen yardımcı fonksiyon ---
  Locale _getLocaleFromCode(String code) {
    return LocalizationManager.supportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => LocalizationManager.defaultLocale,
    );
  }

  // --- Güncellenen _saveProfile fonksiyonu ---
  Future<void> _saveProfile() async {
    await _profileRepository.updateProfile(name: _nameController.text.trim());
    final langResult = await _profileRepository.saveOnboarding(
      targetLanguage: _selectedLanguage.code,
    );

    if (langResult.success) {
      // 1. Riverpod state'ini güncelle
      ref.read(selectedLanguageProvider.notifier).state =
          _selectedLanguage.code;

      // 2. Uygulamanın UI dilini değiştir
      final newLocale = _getLocaleFromCode(_selectedLanguage.code);
      await ref
          .read(localizationManagerProvider.notifier)
          .changeLanguage(context, newLocale);

      // 3. Başarılı olduğuna dair bilgi mesajı
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${LocaleKeys.profile_save.tr()} Başarılı!'),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: const Color(0xFFFFF5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(28.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_forever_rounded,
                  color: const Color(0xFFE57373),
                  size: 50.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  LocaleKeys.profile_delete_dialog_title.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteAccount().withLoading(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE63D4F),
                  ),
                  child: Text(
                    LocaleKeys.profile_delete_dialog_confirm.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(LocaleKeys.profile_delete_dialog_cancel.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final playerId = await OneSignalService().getPlayerId();
    if (playerId != null) {
      await NotificationRepository().unregisterDevice(playerId);
    }
    await OneSignalService().removeExternalUserId();
    final response = await _profileRepository.deleteAccount();
    if (response.success) {
      await SecureStorageService().clearUserData();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/signIn', (route) => false);
      }
    }
  }
}
