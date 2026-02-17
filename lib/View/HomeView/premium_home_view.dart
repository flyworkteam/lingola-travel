import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Models/language.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import '../../Riverpod/Controllers/home_view_controller.dart';
import '../../Riverpod/Controllers/dictionary_controller.dart';
import '../../Repositories/profile_repository.dart';
import '../../Repositories/travel_phrase_repository.dart';
import '../../Models/travel_phrase_model.dart';
import '../NotificationsView/notifications_view.dart';
import '../VocabularyView/travel_vocabulary_view.dart';
import '../CourseView/course_view.dart';
import '../DictionaryView/visual_dictionary_view.dart';
import '../ProfileView/profile_view.dart';

class PremiumHomeView extends ConsumerStatefulWidget {
  const PremiumHomeView({super.key});

  @override
  ConsumerState<PremiumHomeView> createState() => _PremiumHomeViewState();
}

class _PremiumHomeViewState extends ConsumerState<PremiumHomeView> {
  Language _selectedLanguage = AppLanguages.all.first; // Default to English
  int _selectedCategoryIndex = 0; // Track selected phrasebook category
  Map<int, double> _swipeProgressMap =
      {}; // Track swipe progress for each feature card
  bool _isNavigating = false; // Prevent double navigation
  String _userName = 'Guest';
  List<TravelPhraseModel> _phrases = [];
  final ProfileRepository _profileRepository = ProfileRepository();
  final TravelPhraseRepository _travelPhraseRepository =
      TravelPhraseRepository();

  @override
  void initState() {
    super.initState();
    print('🏠 PremiumHomeView initState called');
    _loadUserProfile();

    // ONLY load if NOT already loaded - prevents re-initialization on navigation back
    Future.microtask(() async {
      try {
        // Check if home data already loaded
        final homeState = ref.read(homeViewControllerProvider);
        print(
          '📊 Home state: courses=${homeState.courses.length}, isLoading=${homeState.isLoading}',
        );

        if (homeState.courses.isEmpty && !homeState.isLoading) {
          print('📚 Loading courses for first time...');
          await ref.read(homeViewControllerProvider.notifier).init();
        } else {
          print(
            '📚 Courses already loaded (${homeState.courses.length} courses), skipping init',
          );
        }

        // Small delay before loading dictionary
        await Future.delayed(Duration(milliseconds: 100));

        // Check if dictionary categories already loaded
        if (mounted) {
          final dictState = ref.read(dictionaryControllerProvider);
          print(
            '📖 Dictionary state: categories=${dictState.categories.length}, isLoading=${dictState.isLoading}',
          );

          if (dictState.categories.isEmpty && !dictState.isLoading) {
            print('📖 Loading dictionary categories for first time...');
            await ref.read(dictionaryControllerProvider.notifier).init();
          } else {
            print(
              '📖 Dictionary categories already loaded (${dictState.categories.length} categories), skipping init',
            );
          }
        }

        print('✅ PremiumHomeView init completed');
      } catch (e) {
        print('❌ Premium home init error: $e');
      }
    });
  }

  /// Load user profile from backend
  Future<void> _loadUserProfile() async {
    try {
      final response = await _profileRepository.getProfile();
      if (response.success && response.data != null) {
        final userData = response.data['user'];

        // Set user name
        if (mounted && userData['name'] != null) {
          setState(() {
            _userName = userData['name'];
          });
        }

        // Load phrases for user's target language
        await _loadPhrases();
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  /// Load travel phrases for selected language
  Future<void> _loadPhrases() async {
    try {
      final response = await _travelPhraseRepository.getPhrasesByCategory(null);
      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _phrases = response.data!.take(2).toList();
          });
        }
      }
    } catch (e) {
      print('Error loading phrases: $e');
    }
  }

  @override
  void dispose() {
    // Clear swipe progress map to prevent memory leaks
    _swipeProgressMap.clear();
    // Reset navigation flag
    _isNavigating = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          key: ValueKey('premium_home_stack'), // Unique key to force rebuild
          children: [
            // Main scrollable content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),

                  SizedBox(height: 16.h),

                  // Greeting
                  _buildGreeting(),

                  SizedBox(height: 16.h),

                  // Quick Phrasebook
                  _buildQuickPhrasebook(),

                  SizedBox(height: 4.h),

                  // Questions
                  _buildQuestions(),

                  // Features
                  _buildFeatures(),

                  SizedBox(height: 16.h),

                  // Quick Actions
                  _buildQuickActions(),

                  SizedBox(height: 16.h),

                  // Course Cards
                  _buildCourseCards(),

                  SizedBox(height: 16.h),

                  // Visual Dictionary Card
                  _buildVisualDictionaryCard(),

                  SizedBox(height: 20.h),

                  // Bottom padding for floating nav
                  SizedBox(height: 100.h),
                ],
              ),
            ),

            // Floating bottom navigation
            CustomBottomNavBar(
              key: ValueKey('bottom_nav_premium_home'), // Unique key
              currentIndex: 0,
              isPremium: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Header with language selector, premium badge, notification, and profile
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: MediaQuery.of(context).padding.top + 16.h,
        bottom: 16.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Language Selector
          _buildLanguageSelector(),

          // Right side: Premium Badge + Notification + Profile
          Row(
            children: [
              // Premium Badge Icon
              _buildPremiumBadge(),
              SizedBox(width: 12.w),

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
              _selectedLanguage.getLocalizedName(_selectedLanguage.code),
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

                          // Language name - localized
                          Expanded(
                            child: Text(
                              language.getLocalizedName(_selectedLanguage.code),
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

  /// Premium badge icon
  Widget _buildPremiumBadge() {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: MyColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: MyColors.border, width: 1),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/images/premiumlogo.svg',
          width: 24.w,
          height: 24.h,
        ),
      ),
    );
  }

  /// Notification icon
  Widget _buildNotificationIcon() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationsView(
              isPremiumUser: true, // Premium user
            ),
          ),
        );
      },
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: MyColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: MyColors.border, width: 1),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/zil.svg',
            width: 18.w,
            height: 18.h,
          ),
        ),
      ),
    );
  }

  /// Greeting section
  Widget _buildGreeting() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting text
          Text(
            'Hey, $_userName 👋',
            style: TextStyle(
              fontSize: 16.sp,
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
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              color: MyColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Phrasebook section - TAMAMEN DİNAMİK! Backend'den isim + icon 🚀🔥
  Widget _buildQuickPhrasebook() {
    final dictionaryState = ref.watch(dictionaryControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with padding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Phrasebook',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  // Prevent double navigation
                  if (_isNavigating) {
                    print('⏳ Already navigating...');
                    return;
                  }

                  setState(() {
                    _isNavigating = true;
                  });

                  try {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TravelVocabularyView(isPremium: true),
                      ),
                    );
                  } catch (e) {
                    print('❌ Navigation error: $e');
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isNavigating = false;
                      });
                    }
                  }
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Dynamic categories from backend with STATIC ICONS!
        SizedBox(
          height: 100.h,
          child: dictionaryState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : dictionaryState.categories.isEmpty
              ? Center(
                  child: Text(
                    'Categories not found',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: MyColors.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  // ✅ CRITICAL: Explicit physics for smooth scrolling
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(left: 16.w),
                  itemCount: dictionaryState.categories.length,
                  // ✅ PERFORMANCE: Optimize rendering
                  cacheExtent: 500, // Pre-render nearby items
                  addAutomaticKeepAlives:
                      true, // Keep items alive when scrolling
                  addRepaintBoundaries: true, // Prevent unnecessary repaints
                  itemBuilder: (context, index) {
                    final category = dictionaryState.categories[index];
                    final isSelected = _selectedCategoryIndex == index;

                    return Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: _buildPhrasebookCategory(
                        iconPath: category.iconPath,
                        label: category.name,
                        isSelected: isSelected,
                        onTap: () async {
                          // Prevent navigation if still loading or already navigating
                          if (dictionaryState.isLoading || _isNavigating) {
                            print('⏳ Still loading or navigating...');
                            return;
                          }

                          // Ultra paranoid checks before navigation
                          if (!mounted) {
                            print('❌ Widget not mounted, canceling navigation');
                            return;
                          }

                          final navigator = Navigator.of(context);
                          if (!navigator.mounted) {
                            print('❌ Navigator not mounted');
                            return;
                          }

                          // Set navigation flag
                          setState(() {
                            _isNavigating = true;
                          });

                          try {
                            // ✅ NO DELAY! Navigate immediately
                            if (!mounted) {
                              print('❌ Widget disposed before navigation');
                              return;
                            }

                            print(
                              '🚀 PREMIUM ULTRA SAFE Navigation to: ${category.name}',
                            );

                            // Navigate to Travel Vocabulary View with selected category - SUPER SAFE
                            await navigator.push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                      return TravelVocabularyView(
                                        key: ValueKey(
                                          'travel_vocab_${category.name}_${DateTime.now().millisecondsSinceEpoch}',
                                        ),
                                        isPremium: true,
                                        initialCategory: category.name,
                                      );
                                    },
                                transitionDuration: Duration(milliseconds: 150),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return SlideTransition(
                                        position:
                                            Tween<Offset>(
                                              begin: const Offset(1.0, 0.0),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOut,
                                              ),
                                            ),
                                        child: child,
                                      );
                                    },
                              ),
                            );

                            print(
                              '✅ PREMIUM Navigation completed successfully',
                            );
                          } catch (e, stackTrace) {
                            print('❌ CRITICAL PREMIUM Navigation error: $e');
                            print('📍 Stack trace: $stackTrace');

                            // Try fallback simple navigation if widget still mounted
                            if (mounted && navigator.mounted) {
                              try {
                                await navigator.push(
                                  MaterialPageRoute(
                                    builder: (context) => TravelVocabularyView(
                                      key: ValueKey(
                                        'travel_vocab_fallback_${category.name}_${DateTime.now().millisecondsSinceEpoch}',
                                      ),
                                      isPremium: true,
                                      initialCategory: category.name,
                                    ),
                                  ),
                                );
                                print(
                                  '✅ PREMIUM Fallback navigation succeeded',
                                );
                              } catch (e2) {
                                print(
                                  '❌ PREMIUM Fallback navigation also failed: $e2',
                                );
                              }
                            }
                          } finally {
                            // Reset navigation flag when returning - ULTRA SAFE
                            if (mounted) {
                              setState(() {
                                _isNavigating = false;
                              });
                            }
                          }
                        },
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
    required VoidCallback onTap,
  }) {
    // ✅ CRITICAL FIX: InkWell instead of GestureDetector
    // This allows scroll gestures to pass through properly
    return InkWell(
      onTap: onTap,
      // ✅ Transparent to allow scroll gestures
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        children: [
          // Icon container
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MyColors.white,
              border: Border.all(
                color: isSelected
                    ? MyColors.lingolaPrimaryColor
                    : MyColors.border,
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
                width: 28.w,
                height: 28.h,
                fit: BoxFit.contain,
                // ✅ CRITICAL FIX: Add errorBuilder to prevent crash
                errorBuilder: (context, error, stackTrace) {
                  print('❌ Failed to load icon: $iconPath - Error: $error');
                  // Show fallback icon
                  return Icon(
                    Icons.image_not_supported,
                    size: 28.w,
                    color: MyColors.textSecondary,
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 6.h),

          // Label
          SizedBox(
            width: 56.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
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

  /// Questions section - Dynamic from backend
  Widget _buildQuestions() {
    // Show loading or empty state if no phrases
    if (_phrases.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _phrases
            .map(
              (phrase) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildQuestionCard(
                  targetLanguageText: phrase.translation,
                  turkishText: phrase.englishText,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Single question card
  Widget _buildQuestionCard({
    required String targetLanguageText,
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
                // Target language text (bold, primary)
                Text(
                  targetLanguageText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: 8.h),

                // Turkish text (normal, secondary)
                Text(
                  turkishText,
                  style: TextStyle(
                    fontSize: 14.sp,
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
        // Header with padding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Features',
                style: TextStyle(
                  fontSize: 20.sp,
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
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Horizontal scrollable feature cards - full width
        SizedBox(
          height: 300.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16.w),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];

              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: _buildFeatureCard(
                  title: feature['title'] as String,
                  subtitle: feature['subtitle'] as String,
                  gradientColors: feature['gradient'] as List<Color>,
                  cardIndex: index,
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
    required int cardIndex,
  }) {
    return Container(
      width: 240.w,
      height: 300.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            bottom: -30.h,
            right: -20.w,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 40.h,
            right: 60.w,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: 100.h,
            left: -40.w,
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
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
                    borderRadius: BorderRadius.circular(20.r),
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
                    fontSize: 24.sp,
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
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                Spacer(),

                // Swipe to start button - SlideAction style
                LayoutBuilder(
                  builder: (context, constraints) {
                    final currentProgress = _swipeProgressMap[cardIndex] ?? 0.0;
                    return GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (!mounted) return; // Safety check

                        try {
                          setState(() {
                            // ✅ CRITICAL FIX: Read current value from map INSIDE setState
                            // This prevents using stale captured value
                            final actualProgress =
                                _swipeProgressMap[cardIndex] ?? 0.0;
                            final newProgress =
                                actualProgress + details.delta.dx;
                            _swipeProgressMap[cardIndex] = newProgress.clamp(
                              0.0,
                              constraints.maxWidth - 60.w,
                            );
                          });
                        } catch (e) {
                          print('⚠️ Swipe update error: $e');
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        if (!mounted) return; // Safety check

                        try {
                          // ✅ CRITICAL FIX: Read current value from map at drag end
                          final finalProgress =
                              _swipeProgressMap[cardIndex] ?? 0.0;
                          if (finalProgress > constraints.maxWidth * 0.7) {
                            // Success - Navigate based on feature type
                            if (title.contains('Sentence')) {
                              // Learn New Sentence -> Travel Vocabulary (Phrases tab)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TravelVocabularyView(
                                        isPremium: true,
                                      ),
                                ),
                              );
                            } else if (title.contains('Words')) {
                              // Learn New Words -> Visual Dictionary
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VisualDictionaryView(
                                        isPremium: true,
                                      ),
                                ),
                              );
                            } else if (title.contains('Speaking')) {
                              // Practice Speaking -> Course View
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CourseView(isPremium: true),
                                ),
                              );
                            }
                          }
                          setState(() {
                            _swipeProgressMap[cardIndex] = 0;
                          });
                        } catch (e) {
                          print('⚠️ Swipe end error: $e');
                        }
                      },
                      child: Container(
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
                        child: Stack(
                          children: [
                            // Background progress
                            if (currentProgress > 0)
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: currentProgress + 48.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(28.r),
                                  ),
                                ),
                              ),
                            // Slider button
                            Positioned(
                              left: currentProgress,
                              top: 8.h,
                              bottom: 8.h,
                              child: Container(
                                width: 40.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: gradientColors[0],
                                  size: 20.sp,
                                ),
                              ),
                            ),
                            // Text - Aligned to left to avoid being hidden by button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 50.w),
                                child: Text(
                                  'SWIPE TO START',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
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
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Actions section
  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              color: MyColors.textPrimary,
            ),
          ),

          SizedBox(height: 20.h),

          // Current Course Card
          _buildCurrentCourseCard(),
        ],
      ),
    );
  }

  /// Current course card - DİNAMİK (Backend'den aktif kurs!)
  Widget _buildCurrentCourseCard() {
    final homeState = ref.watch(homeViewControllerProvider);

    // Backend'den gelen ilk kursu "Current Course" olarak göster
    final currentCourse = homeState.courses.isNotEmpty
        ? homeState.courses.first
        : null;

    if (currentCourse == null) {
      // Eğer kurs yoksa boş container göster
      return const SizedBox.shrink();
    }

    // Progress hesaplama (eğer progress varsa)
    final progress = currentCourse.progressPercentage / 100.0;
    final completedLessons = currentCourse.lessonsCompleted;
    final totalLessons = currentCourse.totalLessons;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CourseView(isPremium: true),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
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
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.2,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Course title (Backend'den!)
                  Text(
                    currentCourse.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Progress info (Backend'den!)
                  Row(
                    children: [
                      Text(
                        '${(progress * 100).toInt()}% Progress',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        '$completedLessons/$totalLessons Lessons',
                        style: TextStyle(
                          fontSize: 13.sp,
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

  /// Course Cards section - DİNAMİK! Backend'den geliyor 🚀
  Widget _buildCourseCards() {
    final homeState = ref.watch(homeViewControllerProvider);

    // Loading state
    if (homeState.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 180.h,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Error state
    if (homeState.errorMessage != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 180.h,
          child: Center(
            child: Text(
              'Kurslar yüklenemedi\n${homeState.errorMessage}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.red),
            ),
          ),
        ),
      );
    }

    // Empty state
    if (homeState.courses.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 180.h,
          child: Center(
            child: Text(
              'Henüz kurs bulunmuyor',
              style: TextStyle(fontSize: 14.sp, color: MyColors.textSecondary),
            ),
          ),
        ),
      );
    }

    // Backend'den gelen GERÇEK kurslar!
    final courses = homeState.courses.take(2).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 180.h,
        child: Row(
          children: [
            if (courses.isNotEmpty)
              Expanded(
                child: _buildCourseCard(
                  title: courses[0].title,
                  subtitle: '${courses[0].totalLessons} lessons',
                  iconPath: 'assets/icons/englishfortravel.svg',
                  iconBgColor: const Color(0xFFE3F2FD),
                  arrowColor: const Color(0xFF4A90E2),
                ),
              ),
            if (courses.length > 1) ...[
              SizedBox(width: 12.w),
              Expanded(
                child: _buildCourseCard(
                  title: courses[1].title,
                  subtitle: '${courses[1].totalLessons} lessons',
                  iconPath: 'assets/icons/englishforhealth.svg',
                  iconBgColor: const Color(0xFFF3E5F5),
                  arrowColor: const Color(0xFF9C27B0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Single course card
  Widget _buildCourseCard({
    required String title,
    required String subtitle,
    required String iconPath,
    required Color iconBgColor,
    required Color arrowColor,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to Course page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CourseView(isPremium: true),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
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
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: SvgPicture.asset(iconPath, width: 28.w, height: 28.h),
              ),
            ),

            SizedBox(height: 16.h),

            // Title (Backend'den!)
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: MyColors.textPrimary,
                height: 1.2,
              ),
            ),

            SizedBox(height: 4.h),

            // Subtitle (Backend'den!)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
                color: MyColors.textSecondary,
              ),
            ),

            const Spacer(),

            // Start Course button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start Course',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                ),
                Icon(Icons.arrow_forward, color: arrowColor, size: 20.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Visual Dictionary Card
  Widget _buildVisualDictionaryCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VisualDictionaryView(isPremium: true),
            ),
          );
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
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: MyColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '20,000+ Translated Items',
                      style: TextStyle(
                        fontSize: 13.sp,
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
      ),
    );
  }

  /// Profile avatar
  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileView(isPremium: true),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }
}
