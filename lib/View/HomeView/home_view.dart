import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Localization/localization_manager.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Core/Utils/language_data.dart';
import 'package:lingola_travel/Models/language.dart';
import 'package:lingola_travel/Models/language_model.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Repositories/profile_repository.dart';
import '../../Riverpod/Controllers/dictionary_controller.dart';
import '../../Riverpod/Controllers/home_view_controller.dart';
import '../CourseView/course_detail_view.dart';
import '../CourseView/course_view.dart';
import '../DictionaryView/visual_dictionary_view.dart';
import '../NotificationsView/notifications_view.dart';
import '../ProfileView/premium_view.dart';
import '../ProfileView/profile_view.dart';
import '../VocabularyView/travel_vocabulary_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  Language _selectedLanguage = AppLanguages.all.first;
  int _selectedCategoryIndex = 0; // Kategori filtrelemesi için tıklanan index
  final Map<int, double> _swipeProgressMap = {};
  bool _isNavigating = false;

  String _userName = 'Guest';
  bool _isPremium = false;
  String? _userPhotoUrl; // Profil fotoğrafı için eklenen değişken

  // Yerel Bookmark Set'i ve SharedPreferences Anahtarı
  Set<String> _bookmarkedPhrases = {};
  static const String _localBookmarksKey = 'lingola_local_bookmarks';

  final ProfileRepository _profileRepository = ProfileRepository();

  // --- STATİK KATEGORİ LİSTESİ (EMOJİ + SVG KARIŞIK) ---
  final List<Map<String, dynamic>> _staticCategories = [
    {
      'id': 'dict-cat-001',
      'nameKey': LocaleKeys.home_catGeneral,
      'icon': '🌍',
      'isEmoji': true,
    },
    {
      'id': 'dict-cat-002',
      'nameKey': LocaleKeys.home_catTravel,
      'icon': '✈️',
      'isEmoji': true,
    },
    {
      'id': 'dict-cat-003',
      'nameKey': LocaleKeys.home_catAccommodation,
      'icon': '🏨',
      'isEmoji': true,
    },
    {
      'id': 'dict-cat-004',
      'nameKey': LocaleKeys.home_catFoodAndDrink,
      'icon': '🍕',
      'isEmoji': true,
    },
    {
      'id': 'dict-cat-005',
      'nameKey': LocaleKeys.home_catCulture,
      'icon': '⛰️',
      'isEmoji': true,
    },
    {
      'id': 'dict-cat-006',
      'nameKey': LocaleKeys.home_catShop,
      'icon': '🛍️',
      'isEmoji': true,
    },
    {
      'id': 'dict-cat-007',
      'nameKey': LocaleKeys.home_catDirection,
      'icon': 'assets/images/home/d.svg', // BURASI SVG OLACAK
      'isEmoji': false,
    },
    {
      'id': 'dict-cat-008',
      'nameKey': LocaleKeys.home_catSport,
      'icon': '⚽',
      'isEmoji': true,
    },
    {
      'id': 'dict-cat-009',
      'nameKey': LocaleKeys.home_catHealth,
      'icon': '🏥',
      'isEmoji': true,
    },
    {
      'id': 'dict-cat-010',
      'nameKey': LocaleKeys.home_catBusiness,
      'icon': '💼',
      'isEmoji': true,
    },
    {
      'id': 'dict-cat-011',
      'nameKey': LocaleKeys.home_catEmergency,
      'icon': '🚨',
      'isEmoji': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadLocalBookmarks();

    Future.microtask(() async {
      try {
        await ref.read(homeViewControllerProvider.notifier).init();
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          final dictState = ref.read(dictionaryControllerProvider);
          if (dictState.categories.isEmpty && !dictState.isLoading) {
            await ref.read(dictionaryControllerProvider.notifier).init();
          }
        }
      } catch (e) {
        debugPrint('❌ Home init error: $e');
      }
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await _profileRepository.getProfile();
      if (response.success && response.data != null) {
        final userData = response.data['user'];
        if (mounted) {
          setState(() {
            if (userData['name'] != null) {
              _userName = userData['name'];
            }
            // Hatanın çözüldüğü kısım burası: 1 ise veya true ise _isPremium = true olur
            if (userData['is_premium'] != null) {
              _isPremium =
                  userData['is_premium'] == 1 || userData['is_premium'] == true;
            }
            if (userData['photo_url'] != null) {
              _userPhotoUrl = userData['photo_url'];
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  // --- %100 YEREL (LOCAL) BOOKMARK YÜKLEME ---
  Future<void> _loadLocalBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? bookmarksJson = prefs.getString(_localBookmarksKey);

      if (bookmarksJson != null) {
        final List<dynamic> decoded = jsonDecode(bookmarksJson);
        if (mounted) {
          setState(() {
            _bookmarkedPhrases = decoded.cast<String>().toSet();
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Yerel favoriler yüklenirken hata: $e');
    }
  }

  // --- %100 YEREL (LOCAL) BOOKMARK KAYDETME/SİLME ---
  Future<void> _toggleBookmark(String itemId) async {
    setState(() {
      if (_bookmarkedPhrases.contains(itemId)) {
        _bookmarkedPhrases.remove(itemId);
      } else {
        _bookmarkedPhrases.add(itemId);
      }
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_bookmarkedPhrases.toList());
      await prefs.setString(_localBookmarksKey, encoded);
    } catch (e) {
      debugPrint('❌ Yerel favoriler kaydedilirken hata: $e');
    }
  }

  // İngilizce kelimeyi formatlama (camelCase düzeltici)
  String _getEnglishText(String key) {
    final lastPart = key.split('.').last;
    if (lastPart == 'oneMomentPlease') return 'One moment, please';

    final RegExp exp = RegExp(r'(?<=[a-z])(?=[A-Z])');
    final parts = lastPart.split(exp);

    String formatted = parts.map((p) => p.toLowerCase()).join(' ');
    formatted = formatted[0].toUpperCase() + formatted.substring(1);

    // Kısmaltmaları düzelt
    formatted = formatted.replaceAll("I dont ", "I don't ");
    formatted = formatted.replaceAll("Im ", "I'm ");
    formatted = formatted.replaceAll("Youre ", "You're ");
    formatted = formatted.replaceAll("Cant ", "Can't ");
    formatted = formatted.replaceAll("Lets ", "Let's ");

    // Soru cümlelerine soru işareti ekle
    final lower = formatted.toLowerCase();
    if (lower.startsWith('can ') ||
        lower.startsWith('where ') ||
        lower.startsWith('what ') ||
        lower.startsWith('is ') ||
        lower.startsWith('do ') ||
        lower.startsWith('how ') ||
        lower.startsWith('which ') ||
        lower.startsWith('will ') ||
        lower.startsWith('are ') ||
        lower.startsWith('should ')) {
      formatted += '?';
    }

    return formatted;
  }

  // Seçilen kategoriye göre LanguageDataManager'dan ilk 2 cümleyi getirir
  List<Map<String, String>> _getFilteredSentences() {
    final selectedCategoryKey =
        _staticCategories[_selectedCategoryIndex]['nameKey'] as String;

    // Verileri lokal dosyadan çek
    final sentences =
        LanguageDataManager.sentencesData[selectedCategoryKey] ?? [];

    // Sadece ilk 2 cümleyi göster
    return sentences.take(2).map((key) {
      return {
        'id': key,
        'englishText': _getEnglishText(key),
        'translationText': key.tr(),
      };
    }).toList();
  }

  @override
  void dispose() {
    _swipeProgressMap.clear();
    _isNavigating = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localizationManagerProvider);

    final currentLocale = context.locale;
    final syncedLanguage = AppLanguages.getByCode(currentLocale.languageCode);

    if (_selectedLanguage.code != syncedLanguage.code) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedLanguage = syncedLanguage;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          key: const ValueKey('home_stack'),
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildGreeting(),
                  SizedBox(height: 24.h),
                  _buildQuickPhrasebook(),
                  SizedBox(height: 4.h),
                  _buildQuestions(), // Artık lokalize ve dinamik
                  SizedBox(height: 16.h),
                  _buildFeatures(),
                  SizedBox(height: 16.h),
                  _buildQuickActions(),
                  SizedBox(height: 16.h),
                  _buildCourseCards(),
                  SizedBox(height: 16.h),
                  Visibility(
                    visible: !_isPremium,
                    child: Column(
                      children: [
                        _buildPremiumCard(),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                  _buildVisualDictionaryCard(),
                  SizedBox(height: 20.h),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
            const CustomBottomNavBar(
              key: ValueKey('bottom_nav_home'),
              currentIndex: 0,
            ),
          ],
        ),
      ),
    );
  }

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
          _buildLanguageSelector(),
          Row(
            children: [
              Visibility(
                visible: _isPremium,
                child: Row(
                  children: [
                    _buildPremiumBadge(),
                    SizedBox(width: 12.w),
                  ],
                ),
              ),
              _buildNotificationIcon(),
              SizedBox(width: 12.w),
              _buildProfileAvatar(),
            ],
          ),
        ],
      ),
    );
  }

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
              _selectedLanguage.getTranslatedName(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: MyColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(width: 4.w),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: MyColors.textSecondary,
            ),
          ],
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
          color: MyColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: MyColors.grey300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                LocaleKeys.home_selectLanguage.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: MyColors.textPrimary,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AppLanguages.all.length,
                itemBuilder: (context, index) {
                  final language = AppLanguages.all[index];
                  final isSelected =
                      language.code == context.locale.languageCode;

                  return InkWell(
                    onTap: () {
                      final newLocale = Locale(
                        language.code,
                        language.countryCode,
                      );
                      ref
                          .read(localizationManagerProvider.notifier)
                          .changeLanguage(context, newLocale);
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
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: MyColors.lingolaPrimaryColor,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationsView(isPremiumUser: _isPremium),
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

  Widget _buildGreeting() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hey, $_userName 👋',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
              color: MyColors.textSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            LocaleKeys.home_homeTitle.tr(),
            style: TextStyle(
              fontSize: 28.sp,
              letterSpacing: 28.sp * -0.05,
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

  Widget _buildQuickPhrasebook() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.home_quickPhrasebook.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 14.sp * -0.05,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (_isNavigating) return;
                  setState(() => _isNavigating = true);
                  try {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TravelVocabularyView(isPremium: false),
                      ),
                    );
                  } finally {
                    if (mounted) setState(() => _isNavigating = false);
                  }
                },
                child: Text(
                  LocaleKeys.home_seeAll.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    letterSpacing: 12.sp * -0.05,

                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(left: 16.w),
            itemCount: _staticCategories.length,
            itemBuilder: (context, index) {
              final category = _staticCategories[index];
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: _buildPhrasebookCategory(
                  iconOrPath: category['icon']!,
                  isEmoji: category['isEmoji'] as bool,
                  label: category['nameKey']!.toString().tr(),
                  isSelected: _selectedCategoryIndex == index,
                  onTap: () {
                    // Tıklanan kategoriyi seçili yap ve altındaki cümleleri güncelle
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhrasebookCategory({
    required String iconOrPath,
    required bool isEmoji,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
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
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isEmoji
                  ? Text(iconOrPath, style: TextStyle(fontSize: 26.sp))
                  : SvgPicture.asset(iconOrPath, width: 26.w, height: 26.h),
            ),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            width: 56.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: MyColors.textPrimary,
                letterSpacing: 11.sp * -0.009,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LOKALDEN ÇEKİLEN VERİLERLE DİNAMİK CÜMLE LİSTESİ
  Widget _buildQuestions() {
    final filteredSentences = _getFilteredSentences();

    if (filteredSentences.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: filteredSentences
            .map(
              (phrase) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildQuestionCard(
                  targetLanguageText:
                      phrase['englishText']!, // Her zaman ana dili (en) üstte gösteriyoruz
                  turkishText:
                      phrase['translationText']!, // Çeviriyi altta gösteriyoruz
                  isBookmarked: _bookmarkedPhrases.contains(phrase['id']),
                  onBookmarkToggle: () => _toggleBookmark(phrase['id']!),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildQuestionCard({
    required String targetLanguageText,
    required String turkishText,
    required bool isBookmarked,
    required VoidCallback onBookmarkToggle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          const BoxShadow(
            color: Color(0xFFDCE1EC),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/ceviriarkaplan.svg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 40.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  targetLanguageText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    letterSpacing: 16.sp * -0.05,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  turkishText,
                  style: TextStyle(
                    fontSize: 13.sp,
                    letterSpacing: 13.sp * -0.05,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: onBookmarkToggle,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFF4F7F9),
                ),
                child: Icon(
                  Icons.bookmark,
                  color: isBookmarked
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFCBD5E1),
                  size: 24.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'title': LocaleKeys.home_featureLearnSentence.tr(),
        'subtitle': LocaleKeys.home_featureDailyConversation.tr(),
        'gradient': [
          const Color(0xFF6366F1),
          const Color(0xFF6366FF),
        ], // Tasarımdaki mor tonları
        'icon': 'assets/images/messagebox.png',
        'isIconSvg': false,
      },
      {
        'title': LocaleKeys.home_featureLearnWords.tr(),
        'subtitle': LocaleKeys.home_featureQuickLearn.tr(),
        'gradient': [
          const Color(0xFF1D73F6),
          const Color(0xFF1D73FF),
        ], // Tasarımdaki mavi tonları
        'icon': 'assets/icons/learnnewword.svg',
        'isIconSvg': true,
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.home_features.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  letterSpacing: 14.sp * -0.05,
                  fontWeight: FontWeight.w700,
                  color: MyColors.textPrimary,
                ),
              ),
              Text(
                LocaleKeys.home_seeAll.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: MyColors.textSecondary,
                  letterSpacing: 12.sp * -0.05,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 280.h, // Kart boyutu tasarıma göre biraz büyütüldü
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 12.w),
            itemCount: features.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: _buildFeatureCard(
                title: features[index]['title'] as String,
                subtitle: features[index]['subtitle'] as String,
                gradientColors: features[index]['gradient'] as List<Color>,
                cardIndex: index,
                iconPath: features[index]['icon'] as String,
                isIconSvg: features[index]['isIconSvg'] as bool,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required int cardIndex,
    required String iconPath,
    required bool isIconSvg,
  }) {
    return Container(
      width: 230.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Arka plandaki dekoratif yuvarlak desenler
          Positioned(
            bottom: -30.h,
            left: 30.w,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80.h,
            left: 10.w,
            child: Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Positioned(
            top: -40.h,
            right: -40.w,
            child: Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // İçerikler
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol üstteki ikon
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: isIconSvg
                        ? SvgPicture.asset(
                            iconPath,
                            width: 24.w,
                            height: 24.w,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          )
                        : Image.asset(
                            iconPath,
                            width: 24.w,
                            height: 24.w,
                            color: Colors.white,
                          ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Başlık (Learn New Sentence)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700, // Bold
                    letterSpacing: 24.sp * -0.04,
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    height: 1.1, // Satır arası boşluk sıkılaştırıldı
                  ),
                ),
                SizedBox(height: 8.h),

                // Alt Başlık (Daily Conversation)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'Montserrat',
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 13.sp * -0.02,
                  ),
                ),

                // Swipe Butonu
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 8,
            right: 8,
            child: _buildSwipeButton(cardIndex, gradientColors[0]),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeButton(int cardIndex, Color iconColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentProgress = _swipeProgressMap[cardIndex] ?? 0.0;
        final maxDrag =
            constraints.maxWidth -
            56.w; // 56w = ikon genişliği + kenar boşlukları

        return Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25), // Yarı saydam arka plan
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Ortadaki "SWIPE TO START" yazısı ve sağdaki çift oklar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50.w,
                  ), // İkonun kapladığı alanı dengelemek için offset
                  Text(
                    LocaleKeys.home_swipeToStart.tr().toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                      letterSpacing: 10.sp * -0.05,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 16.sp,
                  ),
                  Transform.translate(
                    offset: const Offset(
                      -8,
                      0,
                    ), // Okları birbirine yaklaştırmak için
                    child: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 16.sp,
                    ),
                  ),
                ],
              ),

              // Sürüklenen beyaz yuvarlak buton
              Positioned(
                left: currentProgress,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _swipeProgressMap[cardIndex] =
                          (currentProgress + details.delta.dx).clamp(
                            0.0,
                            maxDrag,
                          );
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (currentProgress > maxDrag * 0.75) {
                      // Kaydırma başarılıysa butonu tamamen sağa daya
                      setState(() => _swipeProgressMap[cardIndex] = maxDrag);

                      // Ufak bir animasyon gecikmesi ile sayfaya geçiş yap
                      Future.delayed(const Duration(milliseconds: 150), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => cardIndex == 0
                                ? const TravelVocabularyView(isPremium: false)
                                : const VisualDictionaryView(isPremium: false),
                          ),
                        ).then((_) {
                          // Sayfadan geri dönüldüğünde butonu sıfırla
                          if (mounted) {
                            setState(() => _swipeProgressMap[cardIndex] = 0);
                          }
                        });
                      });
                    } else {
                      // Yeterince kaydırılmadıysa geri yaylan
                      setState(() => _swipeProgressMap[cardIndex] = 0);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.all(4.w),
                    width: 48.w,
                    height: 48.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: iconColor, // Kartın kendi rengi oka verilir
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.home_quickActions.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: MyColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _buildCurrentCourseCard(),
        ],
      ),
    );
  }

  Widget _buildCurrentCourseCard() {
    final homeState = ref.watch(homeViewControllerProvider);
    if (homeState.courses.isEmpty) return const SizedBox.shrink();
    final currentCourse = homeState.courses.first;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CourseView(isPremium: false),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44B3AC)],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC2D6E1).withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.home_currentCourse.tr().toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    currentCourse.title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  LinearProgressIndicator(
                    value: currentCourse.progressPercentage / 100,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: SvgPicture.asset('assets/icons/pl.svg', width: 24.w),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCards() {
    final homeState = ref.watch(homeViewControllerProvider);
    if (homeState.isLoading)
      return const Center(child: CircularProgressIndicator());
    final courses = homeState.courses.take(2).toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          for (int i = 0; i < courses.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _buildCourseCard(
                  courseData: courses[i].toJson(),
                  title: courses[i].title,
                  subtitle: LocaleKeys.home_startCourse.tr(),
                  iconPath: i == 0
                      ? 'assets/icons/englishfortravel.svg'
                      : 'assets/icons/englishforhealth.svg',
                  iconBgColor: i == 0
                      ? const Color(0xFF2563EB).withOpacity(0.2)
                      : const Color(0xFF8F1BE9).withOpacity(0.2),
                  arrowColor: i == 0
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF8F1BE9),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseCard({
    required Map<String, dynamic> courseData,
    required String title,
    required String subtitle,
    required String iconPath,
    required Color iconBgColor,
    required Color arrowColor,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CourseDetailView(courseData: courseData, isPremium: false),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        height: 180.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC2D6E1).withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 24.w,
                  colorFilter: ColorFilter.mode(arrowColor, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              maxLines: 2,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: arrowColor,
                  size: 22.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment.bottomRight,
            radius: 1.45,
            colors: [Color(0xFF49463B), Color(0xFF10182B)],
            stops: [0.1, 0.9],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    LocaleKeys.home_proMembership.tr().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.05,
                    ),
                  ),
                ),
                SvgPicture.asset('assets/images/premiumlogo.svg', width: 30),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              LocaleKeys.home_unlimitedAccess.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 20 * -0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              LocaleKeys.home_premiumDesc.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumView()),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 40),
              ),
              child: Text(
                LocaleKeys.home_upgradeNow.tr().toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualDictionaryCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VisualDictionaryView(isPremium: false),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC2D6E1).withOpacity(0.25),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset('assets/images/book.png'),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.home_visualDictionary.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      LocaleKeys.home_translatedItemsCount.tr(),
                      style: TextStyle(
                        color: MyColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileView(isPremium: false),
        ),
      ),
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: MyColors.lingolaPrimaryColor, width: 2),
          color: MyColors.white,
        ),
        child: ClipOval(
          child: _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
              ? Image.network(
                  _userPhotoUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person,
                    color: MyColors.lingolaPrimaryColor,
                  ),
                )
              : const Icon(Icons.person, color: MyColors.lingolaPrimaryColor),
        ),
      ),
    );
  }
}
