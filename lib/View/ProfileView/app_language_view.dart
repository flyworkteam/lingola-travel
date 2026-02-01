import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Models/language_model.dart';

class AppLanguageView extends StatefulWidget {
  const AppLanguageView({super.key});

  @override
  State<AppLanguageView> createState() => _AppLanguageViewState();
}

class _AppLanguageViewState extends State<AppLanguageView> {
  String _selectedLanguageCode = 'en';
  final List<Language> _languages = Language.getAllLanguages();

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
                      'App Language',
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
                  children: [
                    SizedBox(height: 20.h),

                    // Title
                    Text(
                      'Select the application\nlanguage',
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
                    ...List.generate(_languages.length, (index) {
                      final language = _languages[index];
                      final isSelected = _selectedLanguageCode == language.code;
                      final isLast = index == _languages.length - 1;

                      return Column(
                        children: [
                          _buildLanguageItem(
                            flag: language.flag,
                            name: language.name,
                            code: language.code,
                            isSelected: isSelected,
                          ),
                          if (!isLast) SizedBox(height: 12.h),
                        ],
                      );
                    }),

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
                          onTap: () {
                            // TODO: Save language preference
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(16.r),
                          child: Center(
                            child: Text(
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

  Widget _buildLanguageItem({
    required String flag,
    required String name,
    required String code,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguageCode = code;
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
            // Flag
            Text(flag, style: TextStyle(fontSize: 32.sp)),
            SizedBox(width: 16.w),
            // Language Name
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
            // Selection Indicator
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
