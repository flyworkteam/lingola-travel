import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Models/language.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _selectedIndex = 0;
  Language _selectedLanguage = AppLanguages.all.first; // Default to English

  /// Handle navigation item tap
  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Navigate to different pages based on index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header
                _buildHeader(),

                // Content - Scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 24.w, right: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          
                          // Greeting
                          _buildGreeting(),
                          
                          SizedBox(height: 32.h),
                          
                          // Quick Phrasebook
                          _buildQuickPhrasebook(),
                          
                          SizedBox(height: 32.h),
                          
                          // Questions
                          _buildQuestions(),
                          
                          SizedBox(height: 32.h),
                          
                          // Features
                          _buildFeatures(),
                          
                          SizedBox(height: 32.h),
                          
                          // Quick Actions
                          _buildQuickActions(),
                          
                          SizedBox(height: 32.h),
                          
                          // Course Cards
                          _buildCourseCards(),
                          
                          SizedBox(height: 32.h),
                          
                          // Premium Membership Card
                          _buildPremiumCard(),
                          
                          SizedBox(height: 32.h),
                          
                          // Visual Dictionary Card
                          _buildVisualDictionaryCard(),
                          
                          SizedBox(height: 24.h),
                          
                          // TODO: Add more sections here
                          
                          SizedBox(height: 100.h), // Bottom padding for floating nav
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Floating bottom navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 20.h, // Space from bottom
              child: _buildBottomNavigationBar(),
            ),
          ],
        ),
      ),
    );
  }

  /// Header with language selector, notification, and profile
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Language Selector
          _buildLanguageSelector(),

          // Right side: Notification + Profile
          Row(
            children: [
              // Notification Icon
              _buildNotificationIcon(),
              SizedBox(width: 12.w),

              // Profile Avatar
              _buildProfileAvatar(),
            ],
          ),
        ],
      ),
    );
  }

  /// Language selector dropdown
  Widget _buildLanguageSelector() {
    return GestureDetector(
      onTap: _showLanguageSelector,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: MyColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flag image
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: Image.asset(
                _selectedLanguage.flagAsset,
                width: 24.w,
                height: 24.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              _selectedLanguage.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: MyColors.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20.sp,
              color: MyColors.textSecondary,
            ),
          ],
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
          color: MyColors.white,
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
                color: MyColors.grey300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: MyColors.textPrimary,
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
                            ? MyColors.lingolaPrimaryColor.withOpacity(0.1)
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
                              language.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? MyColors.lingolaPrimaryColor
                                    : MyColors.textPrimary,
                              ),
                            ),
                          ),

                          // Checkmark
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: MyColors.lingolaPrimaryColor,
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

  /// Notification icon
  Widget _buildNotificationIcon() {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: MyColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: MyColors.border, width: 1),
      ),
      child: Icon(
        Icons.notifications_outlined,
        size: 24.sp,
        color: MyColors.textPrimary,
      ),
    );
  }

  /// Greeting section
  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting text
        Text(
          'Hey, Alex 👋',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
            color: MyColors.textSecondary,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        // Main title
        Text(
          'Master Languages\nWhile Exploring',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: MyColors.textPrimary,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  /// Quick Phrasebook section
  Widget _buildQuickPhrasebook() {
    final categories = [
      {'icon': 'assets/images/general.png', 'label': 'General'},
      {'icon': 'assets/images/trip.png', 'label': 'Trip'},
      {'icon': 'assets/images/food.png', 'label': 'Food &\nDrink'},
      {'icon': 'assets/images/accomo.png', 'label': 'Accommo...'},
      {'icon': 'assets/images/culture.png', 'label': 'Culture'},
      {'icon': 'assets/images/shope.png', 'label': 'Shop'},
      {'icon': 'assets/images/direction.png', 'label': 'Direction &\nNavigation'},
      {'icon': 'assets/images/sport.png', 'label': 'Sport'},
      {'icon': 'assets/images/health.png', 'label': 'Health'},
      {'icon': 'assets/images/bussines.png', 'label': 'Business'},
      {'icon': 'assets/images/emergency.png', 'label': 'Emergency'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Phrasebook',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: MyColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Navigate to all phrasebook categories
                print('Tapped on See All - Phrasebook');
              },
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                  color: MyColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 20.h),
        
        // Horizontal scrollable categories
        SizedBox(
          height: 145.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isFirst = index == 0;
              
              return Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: _buildPhrasebookCategory(
                  iconPath: category['icon']!,
                  label: category['label']!,
                  isSelected: isFirst,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Single phrasebook category item
  Widget _buildPhrasebookCategory({
    required String iconPath,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to category detail page
        print('Tapped on category: $label');
      },
      child: Column(
        children: [
          // Icon container
          Container(
            width: 90.w,
            height: 90.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MyColors.white,
              border: Border.all(
                color: isSelected ? MyColors.lingolaPrimaryColor : MyColors.border,
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: 45.w,
                height: 45.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          SizedBox(height: 10.h),
          
          // Label
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
                color: MyColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Questions section
  Widget _buildQuestions() {
    final questions = [
      {
        'english': 'Where is the check-in counter for British Airways?',
        'turkish': 'British Airways check-in kontuarı nerede?',
      },
      {
        'english': 'Is this the line for security?',
        'turkish': 'Güvenlik sırası bu mu?',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: questions.map((q) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: _buildQuestionCard(
          englishText: q['english']!,
          turkishText: q['turkish']!,
        ),
      )).toList(),
    );
  }

  /// Single question card
  Widget _buildQuestionCard({
    required String englishText,
    required String turkishText,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background SVG
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/ceviriarkaplan.svg',
              fit: BoxFit.cover,
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.only(right: 40.w), // Space for bookmark button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English text
                Text(
                  englishText,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Turkish text
                Text(
                  turkishText,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          
          // Bookmark button
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/images/kaydet.png',
              width: 32.w,
              height: 32.h,
            ),
          ),
        ],
      ),
    );
  }

  /// Features section
  Widget _buildFeatures() {
    final features = [
      {
        'title': 'Learn New\nSentence',
        'subtitle': 'Daily Conversation',
        'gradient': [Color(0xFF7B68EE), Color(0xFF9D8FFF)], // Purple gradient
      },
      {
        'title': 'Learn New\nWords',
        'subtitle': 'Quick Learn',
        'gradient': [Color(0xFF4A90E2), Color(0xFF5BA3F5)], // Blue gradient
      },
      {
        'title': 'Practice\nSpeaking',
        'subtitle': 'Improve Fluency',
        'gradient': [Color(0xFF50C878), Color(0xFF6FD99A)], // Green gradient
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Features',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: MyColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Navigate to all features
                print('Tapped on See All - Features');
              },
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                  color: MyColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 20.h),
        
        // Horizontal scrollable feature cards
        SizedBox(
          height: 300.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: _buildFeatureCard(
                  title: feature['title'] as String,
                  subtitle: feature['subtitle'] as String,
                  gradientColors: feature['gradient'] as List<Color>,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Single feature card
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to feature detail page
        print('Tapped on feature: $title');
      },
      child: Container(
        width: 240.w,
        height: 300.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: Image.asset(
                  'assets/images/messageboxarkaplan.png',
                  fit: BoxFit.cover,
                  opacity: AlwaysStoppedAnimation(0.3),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/messagebox.png',
                        width: 32.w,
                        height: 32.h,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Subtitle
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Swipe to start button
                  Container(
                    width: double.infinity,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: gradientColors[0],
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'SWIPE TO START',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quick Actions section
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: MyColors.textPrimary,
          ),
        ),
        
        SizedBox(height: 20.h),
        
        // Current Course Card
        _buildCurrentCourseCard(),
      ],
    );
  }

  /// Current course card
  Widget _buildCurrentCourseCard() {
    const double progress = 0.65; // 65%
    const int currentLesson = 12;
    const int totalLessons = 18;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to course detail page
        print('Tapped on current course');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4ECDC4), // Turquoise
              Color(0xFF44B3AC),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF4ECDC4).withOpacity(0.3),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    'CURRENT COURSE',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.2,
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // Course title
                  Text(
                    'Terminal Talks:\nAirport Basics',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Progress info
                  Row(
                    children: [
                      Text(
                        '${(progress * 100).toInt()}% Progress',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        '$currentLesson/$totalLessons Lessons',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8.h,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Play button
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Color(0xFF4ECDC4),
                size: 36.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Course Cards section
  Widget _buildCourseCards() {
    final courses = [
      {
        'title': 'English for\nTravelers',
        'icon': Icons.account_balance,
        'iconColor': Color(0xFF4A90E2),
        'iconBgColor': Color(0xFFE3F2FD), // Light blue
        'arrowColor': Color(0xFF4A90E2),
      },
      {
        'title': 'English for\nHealth',
        'icon': Icons.favorite,
        'iconColor': Color(0xFF9C27B0),
        'iconBgColor': Color(0xFFF3E5F5), // Light purple
        'arrowColor': Color(0xFF9C27B0),
      },
    ];

    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          
          return Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: _buildCourseCard(
              title: course['title'] as String,
              icon: course['icon'] as IconData,
              iconColor: course['iconColor'] as Color,
              iconBgColor: course['iconBgColor'] as Color,
              arrowColor: course['arrowColor'] as Color,
            ),
          );
        },
      ),
    );
  }

  /// Single course card
  Widget _buildCourseCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color arrowColor,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to course detail page
        print('Tapped on course: $title');
      },
      child: Container(
        width: 200.w,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28.sp,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: MyColors.textPrimary,
                height: 1.2,
              ),
            ),
            
            Spacer(),
            
            // Start Course button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start Course',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: arrowColor,
                  size: 20.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Premium Membership Card
  Widget _buildPremiumCard() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to premium subscription page
        print('Tapped on Premium Membership');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A2332), // Dark navy
              Color(0xFF2D3A4F),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with badge and premium logo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // PRO MEMBERSHIP badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFA726), // Orange
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'PRO MEMBERSHIP',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                // Premium logo
                Image.asset(
                  'assets/images/premiumlogo.png',
                  width: 48.w,
                  height: 48.h,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            // Title
            Text(
              'Unlimited Access',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: Colors.white,
                height: 1.2,
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Description
            Text(
              'Unlock live translator and all\ncity guides worldwide.',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
                color: Colors.white.withOpacity(0.85),
                height: 1.4,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // UPGRADE NOW button
            Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'UPGRADE NOW',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF1A2332),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Visual Dictionary Card
  Widget _buildVisualDictionaryCard() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to visual dictionary page
        print('Tapped on Visual Dictionary');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Book icon
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Color(0xFFE0F7F4), // Light turquoise
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/book.png',
                  width: 36.w,
                  height: 36.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visual Dictionary',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: MyColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '20,000+ Translated Items',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                      color: MyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: MyColors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  /// Profile avatar
  Widget _buildProfileAvatar() {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MyColors.lingolaPrimaryColor.withOpacity(0.1),
        border: Border.all(color: MyColors.lingolaPrimaryColor, width: 2),
      ),
      child: Icon(
        Icons.person,
        size: 24.sp,
        color: MyColors.lingolaPrimaryColor,
      ),
    );
  }

  /// Bottom Navigation Bar - Floating with oval background
  Widget _buildBottomNavigationBar() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        height: 65.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35.r),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/home/altmenuarkaplan.png',
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: MyColors.white,
                        borderRadius: BorderRadius.circular(35.r),
                      ),
                    );
                  },
                ),
              ),

              // Navigation items - centered
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        icon: Icons.grid_view_rounded,
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.flight_takeoff_rounded,
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.account_balance_rounded,
                        index: 2,
                      ),
                      _buildNavItem(
                        icon: Icons.person_rounded,
                        index: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Single navigation item - icon only with white circle for active
  Widget _buildNavItem({
    required IconData icon,
    required int index,
  }) {
    final bool isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onNavigationItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color: isActive ? MyColors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 26.sp,
          color: isActive ? MyColors.lingolaPrimaryColor : MyColors.grey400,
        ),
      ),
    );
  }
}
