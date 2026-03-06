import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Core/Utils/language_data.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: Repository yolunu projenize göre kontrol edin
import '../../Repositories/library_repository.dart';
import '../../Riverpod/Providers/selected_language_provider.dart';
import '../../Services/tts_service.dart';

class TravelVocabularyView extends ConsumerStatefulWidget {
  final bool isPremium;
  final String? initialCategory;
  const TravelVocabularyView({
    super.key,
    this.isPremium = false,
    this.initialCategory,
  });

  @override
  ConsumerState<TravelVocabularyView> createState() =>
      _TravelVocabularyViewState();
}

class _TravelVocabularyViewState extends ConsumerState<TravelVocabularyView>
    with TickerProviderStateMixin {
  // Backend Repository Tanımı
  final LibraryRepository _libraryRepository = LibraryRepository();

  bool _isShowingWords = true;
  String _selectedCategory = LocaleKeys.travel_vocabulary_all_topics;
  final TextEditingController _searchController = TextEditingController();

  Set<String> _bookmarkedItems = {};
  static const String _localBookmarksKey = 'lingola_local_bookmarks';
  String? _lastLoadedLanguage;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingItemId;
  late TtsService _ttsService;

  late AnimationController _progressController;

  final List<String> _categories = [
    LocaleKeys.travel_vocabulary_all_topics,
    LocaleKeys.home_catGeneral,
    LocaleKeys.home_catTravel,
    LocaleKeys.home_catAccommodation,
    LocaleKeys.home_catFoodAndDrink,
    LocaleKeys.home_catCulture,
    LocaleKeys.home_catShop,
    LocaleKeys.home_catDirection,
    LocaleKeys.home_catSport,
    LocaleKeys.home_catHealth,
    LocaleKeys.home_catBusiness,
    LocaleKeys.home_catEmergency,
  ];

  @override
  void initState() {
    super.initState();
    _ttsService = TtsService();
    _ttsService.init();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory == 'All Topics'
          ? LocaleKeys.travel_vocabulary_all_topics
          : widget.initialCategory!;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadLocalBookmarks();
      _lastLoadedLanguage = ref.read(selectedLanguageProvider);
    });

    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _loadLocalBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? bookmarksJson = prefs.getString(_localBookmarksKey);
      if (bookmarksJson != null) {
        final List<dynamic> decoded = jsonDecode(bookmarksJson);
        if (mounted)
          setState(() => _bookmarkedItems = decoded.cast<String>().toSet());
      }
    } catch (e) {
      debugPrint('❌ Favori yükleme hatası: $e');
    }
  }

  // Backend Entegrasyonlu Toggle Bookmark (Optimistic UI)
  Future<void> _toggleBookmark(String itemId, {String? category}) async {
    final bool isCurrentlyBookmarked = _bookmarkedItems.contains(itemId);
    // Kelime mi cümle mi olduğunu tab durumuna göre belirliyoruz
    final String itemType = _isShowingWords
        ? 'dictionary_word'
        : 'travel_phrase';

    // 1. Arayüzü anında güncelle
    setState(() {
      if (isCurrentlyBookmarked) {
        _bookmarkedItems.remove(itemId);
      } else {
        _bookmarkedItems.add(itemId);
      }
    });

    bool apiSuccess = false;

    try {
      if (isCurrentlyBookmarked) {
        // Backend'den Sil
        final response = await _libraryRepository.removeBookmarkByItem(
          itemType: itemType,
          itemId: itemId,
        );
        apiSuccess = response.success;
      } else {
        // YENİ GÜNCELLEME: İngilizce kelimeyi ve çevirisini de repository'ye yolluyoruz.
        final response = await _libraryRepository.addBookmark(
          itemType: itemType,
          itemId: itemId,
          word: _getEnglishText(itemId), // Kelimenin İngilizce hali
          translation: itemId.tr(), // Seçili dildeki karşılığı
          category: category ?? _selectedCategory,
        );
        apiSuccess = response.success;
      }
    } catch (e) {
      debugPrint('❌ Backend bookmark hatası: $e');
      apiSuccess = false;
    }

    // 2. Sonuca göre aksiyon al
    if (apiSuccess) {
      // Başarılıysa yerel cache güncelle
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _localBookmarksKey,
          jsonEncode(_bookmarkedItems.toList()),
        );
      } catch (e) {
        debugPrint('❌ Yerel cache kaydetme hatası: $e');
      }
    } else {
      // Başarısızsa geri al (Rollback)
      if (mounted) {
        setState(() {
          if (isCurrentlyBookmarked) {
            _bookmarkedItems.add(itemId);
          } else {
            _bookmarkedItems.remove(itemId);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bağlantı hatası: İşlem gerçekleştirilemedi.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onCategorySelected(String categoryName) {
    if (!mounted) return;
    _stopAllAudio();
    setState(() {
      _selectedCategory = categoryName;
      _playingItemId = null;
    });
  }

  void _stopAllAudio() {
    _audioPlayer.stop();
    _ttsService.stop();
    _progressController.reset();
  }

  @override
  void dispose() {
    _stopAllAudio();
    _progressController.dispose();
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getEnglishText(String key) {
    final lastPart = key.split('.').last;
    if (lastPart == 'oneMomentPlease') return 'One moment, please';
    final RegExp exp = RegExp(r'(?<=[a-z])(?=[A-Z])');
    final parts = lastPart.split(exp);
    String formatted = parts.map((p) => p.toLowerCase()).join(' ');
    formatted = formatted[0].toUpperCase() + formatted.substring(1);
    formatted = formatted
        .replaceAll(RegExp(r'\bi\b'), 'I')
        .replaceAll("I dont ", "I don't ")
        .replaceAll("Im ", "I'm ")
        .replaceAll("Youre ", "You're ")
        .replaceAll("Cant ", "Can't ")
        .replaceAll("Lets ", "Let's ");
    final lower = formatted.toLowerCase();
    if ([
      'can ',
      'where ',
      'what ',
      'is ',
      'do ',
      'how ',
      'which ',
      'will ',
      'are ',
      'should ',
    ].any((q) => lower.startsWith(q))) {
      formatted += '?';
    }
    return formatted;
  }

  Future<void> _playAudio(String itemId, String englishText) async {
    if (!mounted) return;

    try {
      if (_playingItemId == itemId) {
        _stopAllAudio();
        setState(() => _playingItemId = null);
        return;
      }

      _stopAllAudio();
      setState(() => _playingItemId = itemId);

      int durationMs = (englishText.length * 90).clamp(1200, 5000);
      _progressController.duration = Duration(milliseconds: durationMs);

      _progressController.forward();
      await _ttsService.speak(englishText, languageCode: 'en');

      _progressController.addStatusListener((status) {
        if (status == AnimationStatus.completed &&
            mounted &&
            _playingItemId == itemId) {
          setState(() => _playingItemId = null);
          _progressController.reset();
        }
      });
    } catch (e) {
      debugPrint('❌ TTS error: $e');
      if (mounted) setState(() => _playingItemId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(selectedLanguageProvider);
    if (currentLanguage != _lastLoadedLanguage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _lastLoadedLanguage = currentLanguage;
          setState(() {});
        }
      });
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 16.h),
                _buildSearchBar(),
                SizedBox(height: 20.h),
                _buildTabSwitcher(),
                SizedBox(height: 20.h),
                _buildCategoryFilters(),
                SizedBox(height: 20.h),
                Expanded(child: _buildContent()),
              ],
            ),
            CustomBottomNavBar(currentIndex: 1, isPremium: widget.isPremium),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFF8FAFC),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        LocaleKeys.travel_vocabulary_title.tr(),
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
          color: MyColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC2D6E1).withOpacity(0.5),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            color: MyColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: _isShowingWords
                ? LocaleKeys.travel_vocabulary_search_words.tr()
                : LocaleKeys.travel_vocabulary_search_phrases.tr(),
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              color: MyColors.textSecondary,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.w),
              child: SvgPicture.asset('assets/icons/scope.svg', width: 18.w),
            ),
            border: InputBorder.none,
          ),
          cursorColor: MyColors.lingolaPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            _tabButton(
              LocaleKeys.travel_vocabulary_tab_words.tr(),
              _isShowingWords,
              () => setState(() => _isShowingWords = true),
            ),
            _tabButton(
              LocaleKeys.travel_vocabulary_tab_phrases.tr(),
              !_isShowingWords,
              () => setState(() => _isShowingWords = false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _stopAllAudio();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: active
                    ? const Color(0xFF4ECDC4)
                    : MyColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 44.h,
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final categoryKey = _categories[index];
          final isSelected = _selectedCategory == categoryKey;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () => _onCategorySelected(categoryKey),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4ECDC4) : MyColors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: MyColors.border),
                ),
                child: Center(
                  child: Text(
                    categoryKey.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: isSelected ? Colors.white : MyColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    final Map<String, List<String>> sourceData = _isShowingWords
        ? LanguageDataManager.vocabularyData
        : LanguageDataManager.sentencesData;
    final String query = _searchController.text.trim().toLowerCase();

    if (_selectedCategory != LocaleKeys.travel_vocabulary_all_topics) {
      List<String> items = (sourceData[_selectedCategory] ?? []).where((key) {
        return _getEnglishText(key).toLowerCase().contains(query) ||
            key.tr().toLowerCase().contains(query);
      }).toList();
      return items.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _buildDynamicItemCard(items[index], _selectedCategory),
            );
    }

    final List<Widget> groupedWidgets = [];
    for (String catKey in sourceData.keys) {
      List<String> items = (sourceData[catKey] ?? []).where((key) {
        return _getEnglishText(key).toLowerCase().contains(query) ||
            key.tr().toLowerCase().contains(query);
      }).toList();
      if (items.isNotEmpty)
        groupedWidgets.add(
          _buildCategoryGroup(categoryKey: catKey, items: items),
        );
    }
    return groupedWidgets.isEmpty
        ? _buildEmptyState()
        : ListView(
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
            children: groupedWidgets,
          );
  }

  Widget _buildEmptyState() => Center(
    child: Text(
      LocaleKeys.travel_vocabulary_no_items.tr(),
      style: TextStyle(fontFamily: 'Montserrat', color: MyColors.textSecondary),
    ),
  );

  Widget _buildCategoryGroup({
    required String categoryKey,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryKey.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),
              Text(
                '${items.length} ${(_isShowingWords ? LocaleKeys.travel_vocabulary_tab_words : LocaleKeys.travel_vocabulary_tab_phrases).tr()}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: MyColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ...items.take(3).map((key) => _buildDynamicItemCard(key, categoryKey)),
        if (items.length > 3)
          Center(
            child: TextButton(
              onPressed: () => _onCategorySelected(categoryKey),
              child: Text(
                LocaleKeys.travel_vocabulary_load_more.tr(),
                style: TextStyle(
                  color: MyColors.lingolaPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDynamicItemCard(String itemKey, String categoryKey) {
    final isPlaying = _playingItemId == itemKey;
    final isBookmarked = _bookmarkedItems.contains(itemKey);
    final englishText = _getEnglishText(itemKey);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 0, top: 0),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.r),
              topRight: Radius.circular(15.r),
              bottomLeft: Radius.circular(isPlaying ? 0 : 15.r),
              bottomRight: Radius.circular(isPlaying ? 0 : 15.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      englishText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        letterSpacing: 16.sp * -0.05,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: MyColors.textPrimary,
                      ),
                    ),
                  ),
                  _iconButton(
                    'assets/icons/travelvocabularyseslendirme.svg',
                    const Color(0xFFE0F7F4),
                    const Color(0xFF4ECDC4),
                    () => _playAudio(itemKey, englishText),
                  ),
                  SizedBox(width: 8.w),
                  _iconButton(
                    'assets/icons/travelvocabularykaydet.svg',
                    isBookmarked
                        ? const Color(0x3D2989E9)
                        : const Color(0xFFF3F4F6),
                    isBookmarked
                        ? const Color(0xFF2989E9)
                        : const Color(0xFFB0B0B0),
                    () => _toggleBookmark(itemKey, category: categoryKey),
                  ),
                ],
              ),

              Text(
                itemKey.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  letterSpacing: 13.sp * -0.05,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        if (isPlaying)
          Container(
            height: 6.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: _progressController.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.r),
                        bottomRight: Radius.circular(
                          _progressController.value > 0.98 ? 20.r : 0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          SizedBox(height: 16.h),
      ],
    );
  }

  Widget _iconButton(
    String iconPath,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 20.w,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
