import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Core/Utils/language_data.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Repositories/library_repository.dart';
import '../../Riverpod/Controllers/library_controller.dart';
import '../../Services/tts_service.dart';
import 'dictionary_category_view.dart';

class VisualDictionaryView extends ConsumerStatefulWidget {
  final bool isPremium;
  const VisualDictionaryView({super.key, this.isPremium = false});

  @override
  ConsumerState<VisualDictionaryView> createState() =>
      _VisualDictionaryViewState();
}

// TravelVocabularyView ile senkron için TickerProviderStateMixin eklendi
class _VisualDictionaryViewState extends ConsumerState<VisualDictionaryView>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  static const String _recentSearchesKey = 'visual_dict_recent_searches';

  List<Map<String, String>> _recentSearches = [];

  final Set<String> _bookmarkedWords = {};
  String _searchQuery = '';
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingWordId;
  late final TtsService _ttsService;

  // İlerleme çubuğu animasyon kontrolcüsü
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();

    _ttsService = TtsService();
    _ttsService.init();

    // Animasyon kontrolcüsü başlatıldı
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? searchesJson = prefs.getString(_recentSearchesKey);

      if (searchesJson != null) {
        final List<dynamic> decodedList = jsonDecode(searchesJson);
        if (mounted) {
          setState(() {
            _recentSearches = decodedList
                .map((item) => Map<String, String>.from(item))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Arama geçmişi yüklenirken hata oluştu: $e');
    }
  }

  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = jsonEncode(_recentSearches);
      await prefs.setString(_recentSearchesKey, encodedList);
    } catch (e) {
      debugPrint('Arama geçmişi kaydedilirken hata oluştu: $e');
    }
  }

  int _getWordCount(String categoryKey) {
    return LanguageDataManager.vocabularyData[categoryKey]?.length ?? 0;
  }

  List<Map<String, dynamic>> get _staticCategories {
    return [
      {
        'id': 'dict-cat-001',
        'key': LocaleKeys.home_catGeneral,
        'name': LocaleKeys.home_catGeneral.tr(),
        'icon': 'assets/images/home/general.png',
        'color': '#FFD166',
        'count': _getWordCount(LocaleKeys.home_catGeneral),
      },
      {
        'id': 'dict-cat-002',
        'key': LocaleKeys.home_catTravel,
        'name': LocaleKeys.home_catTravel.tr(),
        'icon': 'assets/icons/airport.svg',
        'color': '#B8A7FF',
        'count': _getWordCount(LocaleKeys.home_catTravel),
      },
      {
        'id': 'dict-cat-003',
        'key': LocaleKeys.home_catAccommodation,
        'name': LocaleKeys.home_catAccommodation.tr(),
        'icon': 'assets/icons/acc.svg',
        'color': '#FF9F6A',
        'count': _getWordCount(LocaleKeys.home_catAccommodation),
      },
      {
        'id': 'dict-cat-004',
        'key': LocaleKeys.home_catFoodAndDrink,
        'name': LocaleKeys.home_catFoodAndDrink.tr(),
        'icon': 'assets/icons/ffff.svg',
        'color': '#FF8FA5',
        'count': _getWordCount(LocaleKeys.home_catFoodAndDrink),
      },
      {
        'id': 'dict-cat-005',
        'key': LocaleKeys.home_catCulture,
        'name': LocaleKeys.home_catCulture.tr(),
        'icon': 'assets/icons/culture.svg',
        'color': '#B8D9FF',
        'count': _getWordCount(LocaleKeys.home_catCulture),
      },
      {
        'id': 'dict-cat-006',
        'key': LocaleKeys.home_catShop,
        'name': LocaleKeys.home_catShop.tr(),
        'icon': 'assets/icons/shopping.svg',
        'color': '#8BDDCD',
        'count': _getWordCount(LocaleKeys.home_catShop),
      },
      {
        'id': 'dict-cat-007',
        'key': LocaleKeys.home_catDirection,
        'name': LocaleKeys.home_catDirection.tr(),
        'icon': 'assets/images/home/direction.png',
        'color': '#F9D26B',
        'count': _getWordCount(LocaleKeys.home_catDirection),
      },
      {
        'id': 'dict-cat-008',
        'key': LocaleKeys.home_catSport,
        'name': LocaleKeys.home_catSport.tr(),
        'icon': 'assets/icons/sport.svg',
        'color': '#E4B3FF',
        'count': _getWordCount(LocaleKeys.home_catSport),
      },
      {
        'id': 'dict-cat-009',
        'key': LocaleKeys.home_catHealth,
        'name': LocaleKeys.home_catHealth.tr(),
        'icon': 'assets/icons/health.svg',
        'color': '#B8FFC9',
        'count': _getWordCount(LocaleKeys.home_catHealth),
      },
      {
        'id': 'dict-cat-010',
        'key': LocaleKeys.home_catBusiness,
        'name': LocaleKeys.home_catBusiness.tr(),
        'icon': 'assets/icons/business.png',
        'color': '#A4C8E1',
        'count': _getWordCount(LocaleKeys.home_catBusiness),
      },
      {
        'id': 'dict-cat-011',
        'key': LocaleKeys.home_catEmergency,
        'name': LocaleKeys.home_catEmergency.tr(),
        'icon': 'assets/images/home/emergency.png',
        'color': '#FF6B6B',
        'count': _getWordCount(LocaleKeys.home_catEmergency),
      },
    ];
  }

  @override
  void dispose() {
    _stopAllAudio();
    _searchController.dispose();
    _debounceTimer?.cancel();
    _progressController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _stopAllAudio() {
    _audioPlayer.stop();
    _ttsService.stop();
    _progressController.reset();
  }

  String _formatEnglishWord(String key) {
    final lastPart = key.split('.').last;
    if (lastPart == 'oneMomentPlease') return 'One moment, please';

    final RegExp exp = RegExp(r'(?<=[a-z])(?=[A-Z])');
    final parts = lastPart.split(exp);

    String formatted = parts.map((p) => p.toLowerCase()).join(' ');
    formatted = formatted[0].toUpperCase() + formatted.substring(1);

    return formatted;
  }

  void _performSearch(String query) {
    final String q = query.toLowerCase();
    final List<Map<String, String>> results = [];

    LanguageDataManager.vocabularyData.forEach((catKey, words) {
      for (var wordKey in words) {
        String englishWord = _formatEnglishWord(wordKey);
        String translated = wordKey.tr();

        if (englishWord.toLowerCase().contains(q) ||
            translated.toLowerCase().contains(q)) {
          results.add({
            'id': wordKey,
            'word': englishWord,
            'translation': translated,
            'categoryName': catKey,
          });

          if (results.length >= 50) break;
        }
      }
    });

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  List<Map<String, dynamic>> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return _staticCategories;
    }

    final query = _searchQuery.toLowerCase();
    return _staticCategories.where((category) {
      final name = category['name'].toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  void _addWordToRecentSearches(Map<String, String> word) {
    if (!mounted) return;
    setState(() {
      _recentSearches.removeWhere((item) => item['id'] == word['id']);
      _recentSearches.insert(0, word);

      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    });

    _saveRecentSearches();
  }

  Future<void> _playAudio(String wordId, String englishText) async {
    if (!mounted) return;

    try {
      if (_playingWordId == wordId) {
        _stopAllAudio();
        setState(() => _playingWordId = null);
        return;
      }

      _stopAllAudio();
      setState(() => _playingWordId = wordId);

      // TravelVocabularyView ile aynı süre hesabı
      int durationMs = (englishText.length * 90).clamp(1200, 5000);
      _progressController.duration = Duration(milliseconds: durationMs);

      _progressController.forward();
      await _ttsService.speak(englishText, languageCode: 'en');

      _progressController.addStatusListener((status) {
        if (status == AnimationStatus.completed &&
            mounted &&
            _playingWordId == wordId) {
          setState(() => _playingWordId = null);
          _progressController.reset();
        }
      });
    } catch (e) {
      debugPrint('❌ TTS error: $e');
      if (mounted) setState(() => _playingWordId = null);
    }
  }

  // ⚡ GÜNCELLENDİ: word ve translation eklendi ⚡
  void _toggleWordBookmark(String wordId, String categoryName) async {
    try {
      final isCurrentlyBookmarked = _bookmarkedWords.contains(wordId);

      if (isCurrentlyBookmarked) {
        setState(() => _bookmarkedWords.remove(wordId));
        await LibraryRepository().removeBookmarkByItem(
          itemType: 'dictionary_word',
          itemId: wordId,
        );
      } else {
        setState(() => _bookmarkedWords.add(wordId));

        await LibraryRepository().addBookmark(
          itemType: 'dictionary_word',
          itemId: wordId,
          word: _formatEnglishWord(wordId), // İngilizce Hali
          translation: wordId.tr(), // Çevirisi
          category: categoryName,
        );

        ref.read(libraryControllerProvider.notifier).loadFolders();
      }
    } catch (e) {
      debugPrint('Error toggling word bookmark: $e');
    }
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
    _saveRecentSearches();
  }

  void _navigateToCategory(String categoryKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DictionaryCategoryView(
          categoryName: categoryKey,
          categoryId: categoryKey,
          isPremium: widget.isPremium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        backgroundColor: MyColors.background,
        elevation: 0,
        centerTitle: true,
        forceMaterialTransparency: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/gerigelmeiconu.svg',
              width: 16.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          LocaleKeys.home_visualDictionary.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            letterSpacing: 20.sp * -0.05,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: MyColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                _buildSearchBar(),
                SizedBox(height: 12.h),
                if (_searchQuery.trim().length >= 2)
                  _buildSearchResults()
                else
                  _buildDefaultContent(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        _buildCategoryGrid(),
        SizedBox(height: 16.h),
        if (_recentSearches.isNotEmpty) _buildRecentSearch(),
      ],
    );
  }

  Widget _buildSearchBar() {
    const shadowColor = Color(0xFFC2D6E1);

    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.5),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            if (value.trim().length >= 2) {
              _isSearching = true;
            } else {
              _searchResults = [];
              _isSearching = false;
            }
          });

          _debounceTimer?.cancel();
          if (value.trim().length >= 2) {
            _debounceTimer = Timer(const Duration(milliseconds: 500), () {
              _performSearch(value);
            });
          }
        },
        style: TextStyle(
          fontSize: 14.sp,
          fontFamily: 'Montserrat',
          color: MyColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: LocaleKeys.search_placeholder.tr(),
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            color: MyColors.textSecondary,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: SvgPicture.asset(
              'assets/icons/scope.svg',
              width: 18.w,
              height: 18.h,
              fit: BoxFit.contain,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: MyColors.textSecondary,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _searchResults = [];
                      _isSearching = false;
                    });
                    _debounceTimer?.cancel();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 0.w),
        ),
        cursorColor: MyColors.lingolaPrimaryColor,
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = _filteredCategories;

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    Color bgColor;
    try {
      final colorStr = category['color'].replaceAll('#', '');
      final colorInt = int.parse('FF$colorStr', radix: 16);
      bgColor = Color(colorInt).withOpacity(0.2);
    } catch (e) {
      bgColor = const Color(0xFF4ECDC4).withOpacity(0.2);
    }

    final String iconPath = category['icon'];
    final bool isSvg = iconPath.toLowerCase().endsWith('.svg');

    return GestureDetector(
      onTap: () => _navigateToCategory(category['key']),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC2D6E1).withOpacity(0.60),
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: isSvg
                    ? SvgPicture.asset(
                        iconPath,
                        width: 28.w,
                        height: 28.h,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(
                        iconPath,
                        width: 28.w,
                        height: 28.h,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.category,
                            size: 24.sp,
                            color: Colors.grey,
                          );
                        },
                      ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              category['name'],
              style: TextStyle(
                fontSize: 15.sp,
                letterSpacing: 15.sp * -0.05,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: MyColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${category['count']} ${LocaleKeys.library_library_items.tr()}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      letterSpacing: 12.sp * -0.05,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                      color: MyColors.textSecondary,
                    ),
                  ),
                ),
                SvgPicture.asset('assets/icons/righta.svg', fit: BoxFit.fill),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.search_recent.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: MyColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: _clearRecentSearches,
              child: Text(
                LocaleKeys.search_clear.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: const Color(0xFF4ECDC4),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ..._recentSearches.map((word) => _buildSearchWordCard(word)),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40.h),
          child: const CircularProgressIndicator(color: Color(0xFF4ECDC4)),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64.sp,
                color: MyColors.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: 16.h),
              Text(
                LocaleKeys.search_not_found.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: MyColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                LocaleKeys.search_try_different.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Montserrat',
                  color: MyColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_searchResults.length} ${LocaleKeys.library_library_items.tr()}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
            color: MyColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        for (var word in _searchResults) _buildSearchWordCard(word),
      ],
    );
  }

  Widget _buildSearchWordCard(Map<String, String> wordData) {
    final String itemKey = wordData['id'] ?? '';
    final String categoryKey = wordData['categoryName'] ?? '';
    final String englishText = wordData['word'] ?? '';

    final isPlaying = _playingWordId == itemKey;
    final isBookmarked = _bookmarkedWords.contains(itemKey);

    return Column(
      children: [
        Container(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 40.w,
                width: 40.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      englishText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        letterSpacing: 16.sp * -0.05,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: MyColors.textPrimary,
                      ),
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
              _iconButton(
                'assets/icons/travelvocabularyseslendirme.svg',
                const Color(0xFFE0F7F4),
                const Color(0xFF4ECDC4),
                () {
                  _addWordToRecentSearches(wordData);
                  _playAudio(itemKey, englishText);
                },
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
                () => _toggleWordBookmark(itemKey, categoryKey),
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
                bottomLeft: Radius.circular(15.r),
                bottomRight: Radius.circular(15.r),
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
                        bottomLeft: Radius.circular(15.r),
                        bottomRight: Radius.circular(
                          _progressController.value > 0.98 ? 15.r : 0,
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
