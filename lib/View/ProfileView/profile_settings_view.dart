import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Models/language.dart';
import '../../Repositories/profile_repository.dart';
import '../../Repositories/notification_repository.dart';
import '../../Services/secure_storage_service.dart';
import '../../Services/onesignal_service.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _isSaving = false;
  bool _isLoading = true;

  String _selectedGender = 'Male';
  Language _selectedLanguage = AppLanguages.all.first; // English
  String? _userPhotoUrl;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Load user profile from backend
  Future<void> _loadProfile() async {
    try {
      final response = await _profileRepository.getProfile();

      if (response.success && response.data != null) {
        final userData = response.data['user'];

        // Set name
        if (userData['name'] != null) {
          _nameController.text = userData['name'];
        }

        // Set email
        if (userData['email'] != null) {
          _emailController.text = userData['email'];
        }

        // Set photo URL
        if (userData['photo_url'] != null) {
          _userPhotoUrl = userData['photo_url'];
        }

        // Set age (if available in backend)
        if (userData['age'] != null) {
          _ageController.text = userData['age'].toString();
        }

        // Set gender (if available in backend)
        if (userData['gender'] != null) {
          _selectedGender = userData['gender'];
        }

        // Set target language from backend
        final targetLanguageCode = userData['target_language'] as String?;
        Language? targetLanguage;
        if (targetLanguageCode != null) {
          targetLanguage = AppLanguages.all.firstWhere(
            (lang) => lang.code == targetLanguageCode,
            orElse: () => AppLanguages.all.first,
          );
        }

        if (mounted) {
          setState(() {
            if (targetLanguage != null) {
              _selectedLanguage = targetLanguage;
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4)))
            : Column(
                children: [
                  // Custom AppBar
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
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
                            'Profile Settings',
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

                          // Profile Photo
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 130.w,
                                  height: 130.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: _userPhotoUrl != null
                                        ? null
                                        : LinearGradient(
                                            colors: [
                                              Color(0xFFFFB3C1),
                                              Color(0xFFFF85A1),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                          0xFFFFB3C1,
                                        ).withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child:
                                      _userPhotoUrl != null &&
                                          _userPhotoUrl!.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            _userPhotoUrl!,
                                            width: 130.w,
                                            height: 130.w,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  // If image fails to load, show default
                                                  return Center(
                                                    child: SvgPicture.asset(
                                                      'assets/icons/userlogo.svg',
                                                      width: 65.w,
                                                      height: 65.w,
                                                      colorFilter:
                                                          const ColorFilter.mode(
                                                            Colors.white,
                                                            BlendMode.srcIn,
                                                          ),
                                                    ),
                                                  );
                                                },
                                          ),
                                        )
                                      : Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/userlogo.svg',
                                            width: 65.w,
                                            height: 65.w,
                                            colorFilter: const ColorFilter.mode(
                                              Colors.white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                ),
                                Transform.translate(
                                  offset: Offset(40.w, -30.h),
                                  child: Container(
                                    width: 44.w,
                                    height: 44.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/changephoto.svg',
                                        width: 22.w,
                                        height: 22.w,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF4ECDC4),
                                          BlendMode.srcIn,
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset: Offset(0, -20.h),
                                  child: Text(
                                    'Change Photo',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF4ECDC4),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // Full Name
                          _buildLabel('Full Name'),
                          SizedBox(height: 10.h),
                          _buildInputField(
                            controller: _nameController,
                            iconPath: 'assets/icons/fullname.svg',
                            hint: 'Enter your name',
                            enabled: true,
                          ),

                          SizedBox(height: 20.h),

                          // E-mail
                          _buildLabel('E-mail'),
                          SizedBox(height: 10.h),
                          _buildInputField(
                            controller: _emailController,
                            iconPath: 'assets/icons/email.svg',
                            hint: 'Enter your email',
                            enabled: false,
                            showLock: true,
                          ),

                          SizedBox(height: 20.h),

                          // Age
                          _buildLabel('Age'),
                          SizedBox(height: 10.h),
                          _buildInputField(
                            controller: _ageController,
                            iconPath: 'assets/icons/age.svg',
                            hint: 'Enter your age',
                            enabled: false,
                            showLock: true,
                          ),

                          SizedBox(height: 24.h),

                          // Gender
                          _buildLabel('Gender'),
                          SizedBox(height: 12.h),
                          _buildGenderSelector(),

                          SizedBox(height: 24.h),

                          // Language
                          _buildLabel('Select Learn Language'),
                          SizedBox(height: 10.h),
                          _buildLanguageDropdown(),

                          SizedBox(height: 40.h),

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
                                onTap: _isSaving ? null : _saveProfile,
                                borderRadius: BorderRadius.circular(16.r),
                                child: Center(
                                  child: _isSaving
                                      ? SizedBox(
                                          width: 24.w,
                                          height: 24.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          'Save',
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

                          SizedBox(height: 20.h),

                          // Delete Account
                          Center(
                            child: TextButton(
                              onPressed: () {
                                _showDeleteAccountDialog();
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 12.h,
                                ),
                              ),
                              child: Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  color: Color(0xFFE57373),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ],
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
        color: Color(0xFF6B7280),
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
        color: enabled ? Color(0xFFF9FAFB) : Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: enabled ? Color(0xFFE5E7EB) : Color(0xFFE5E7EB),
          width: 1.2,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
          color: enabled ? Color(0xFF1A1A1A) : Color(0xFF9CA3AF),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
            color: enabled
                ? Color(0xFF9CA3AF)
                : Color(0xFF9CA3AF).withOpacity(0.6),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 12.w),
            child: SvgPicture.asset(
              iconPath,
              width: 22.w,
              height: 22.w,
              colorFilter: ColorFilter.mode(
                enabled
                    ? Color(0xFF6B7280)
                    : Color(0xFF9CA3AF).withOpacity(0.8),
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
                    height: 20.w,
                    colorFilter: ColorFilter.mode(
                      enabled
                          ? Color(0xFF9CA3AF)
                          : Color(0xFF9CA3AF).withOpacity(0.7),
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
            label: 'Male',
            iconPath: 'assets/icons/male.svg',
            isSelected: _selectedGender == 'Male',
            onTap: () => setState(() => _selectedGender = 'Male'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildGenderOption(
            label: 'Female',
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
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? Color(0xFF4ECDC4) : Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 22.w,
              height: 22.w,
              colorFilter: ColorFilter.mode(
                isSelected ? Color(0xFF6B7280) : Color(0xFF9CA3AF),
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: isSelected ? Color(0xFF6B7280) : Color(0xFF9CA3AF),
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
        duration: Duration(milliseconds: 200),
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? Color(0xFF4ECDC4) : Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 24.w,
            height: 24.w,
            colorFilter: ColorFilter.mode(
              isSelected ? Color(0xFF6B7280) : Color(0xFF9CA3AF),
              BlendMode.srcIn,
            ),
            fit: BoxFit.contain,
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
          border: Border.all(color: Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              // Flag image
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
                  _selectedLanguage.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24.sp,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show language selector bottom sheet
  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'Select Learn Language',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),

            // Language list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AppLanguages.all.length,
                itemBuilder: (context, index) {
                  final language = AppLanguages.all[index];
                  final isSelected = language.code == _selectedLanguage.code;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(0xFF4ECDC4).withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          // Flag
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

                          // Language name
                          Expanded(
                            child: Text(
                              language.getLocalizedName(_selectedLanguage.code),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontFamily: 'Montserrat',
                                color: isSelected
                                    ? Color(0xFF4ECDC4)
                                    : Color(0xFF1A1A1A),
                              ),
                            ),
                          ),

                          // Checkmark
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Color(0xFF4ECDC4),
                              size: 24.sp,
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

  /// Save profile changes
  Future<void> _saveProfile() async {
    if (_isSaving) return;

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your name',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          backgroundColor: Color(0xFFE57373),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final result = await _profileRepository.updateProfile(
        name: _nameController.text.trim(),
      );

      if (!mounted) return;

      if (result.success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Profile updated successfully!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF4ECDC4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
            duration: Duration(seconds: 2),
          ),
        );

        // Close the page after a brief delay
        await Future.delayed(Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.error?.message ??
                  'Failed to update profile. Please try again.',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            backgroundColor: Color(0xFFE57373),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred: ${e.toString()}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          backgroundColor: Color(0xFFE57373),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 340.w,
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Delete Icon
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/userlogo.svg',
                          width: 42.w,
                          height: 42.w,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFE57373),
                            BlendMode.srcIn,
                          ),
                        ),
                        Positioned(
                          bottom: 8.h,
                          right: 8.w,
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: Color(0xFFE57373),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFFFE5E5),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Title
                  Text(
                    'Are you sure you want to\ndelete your account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Description
                  Text(
                    'This action cannot be undone, and all\nyour history and data will be\npermanently deleted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Delete Account Button
                  Container(
                    width: double.infinity,
                    height: 54.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE57373), Color(0xFFEF5350)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFE57373).withOpacity(0.4),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteAccountConfirmation();
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 22.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Delete Account',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Cancel Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF4ECDC4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show final confirmation before deleting account
  void _showDeleteAccountConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 32.w,
                  color: Color(0xFFE57373),
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                'Delete Account?',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Message
              Text(
                'This action cannot be undone. All your progress, courses, and saved words will be permanently deleted.',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // Delete Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE57373),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  /// Delete account permanently
  Future<void> _deleteAccount() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
              ),
              SizedBox(height: 16.h),
              Text(
                'Deleting account...',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Unregister device from push notifications before deletion
      final playerId = await OneSignalService().getPlayerId();
      if (playerId != null && playerId.isNotEmpty) {
        await NotificationRepository().unregisterDevice(playerId);
      }
      await OneSignalService().removeExternalUserId();

      final response = await _profileRepository.deleteAccount();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response.success) {
        // Clear local storage
        final secureStorage = SecureStorageService();
        await secureStorage.clearUserData();

        // Navigate to onboarding
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/onboarding',
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your account has been deleted successfully'),
            backgroundColor: Color(0xFF4ECDC4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Show error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Text(
              'Error',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              response.error?.toString() ??
                  'Failed to delete account. Please try again.',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4ECDC4),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Error',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'An error occurred while deleting your account. Please try again.',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4ECDC4),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
