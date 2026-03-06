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

class _VisualDictionaryViewState extends ConsumerState<VisualDictionaryView> {
  final TextEditingController _searchController = TextEditingController();

  static const String _recentSearchesKey = 'visual_dict_recent_searches';

  List<Map<String, String>> _recentSearches = [];

  final Set<String> _bookmarkedCategories = {};
  final Set<String> _bookmarkedWords = {};
  String _searchQuery = '';
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingCategory;
  String? _playingWordId;
  StreamSubscription? _audioCompletionSubscription;

  late final TtsService _ttsService;

  @override
  void initState() {
    super.initState();

    _loadRecentSearches();

    _ttsService = TtsService();
    _ttsService
        .init()
        .then((_) {
          debugPrint('✅ TTS initialized in visual_dictionary_view');
        })
        .catchError((e) {
          debugPrint('⚠️ Error initializing TTS: $e');
        });

    _audioCompletionSubscription = _audioPlayer.onPlayerComplete.listen((
      event,
    ) {
      if (mounted) {
        setState(() {
          _playingCategory = null;
          _playingWordId = null;
        });
      }
    });
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

  // --- STATİK KATEGORİ LİSTESİ (GERÇEK KELİME SAYILARI İLE) ---
  int _getWordCount(String categoryKey) {
    return LanguageDataManager.vocabularyData[categoryKey]?.length ?? 0;
  }

  List<Map<String, dynamic>> get _staticCategories {
    return [
      {
        'id': 'dict-cat-001',
        'key': LocaleKeys.home_catGeneral, // Tıklama için orijinal key gerekli
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
    _searchController.dispose();
    _debounceTimer?.cancel();
    _audioCompletionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // İngilizce kelimeyi formatlama (camelCase düzeltici)
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

    // Taramayı statik LanguageDataManager üzerinden yap
    LanguageDataManager.vocabularyData.forEach((catKey, words) {
      for (var wordKey in words) {
        String englishWord = _formatEnglishWord(wordKey);
        String translated = wordKey.tr();

        if (englishWord.toLowerCase().contains(q) ||
            translated.toLowerCase().contains(q)) {
          results.add({
            'id': wordKey, // Kelimenin orjinal anahtarı
            'word': englishWord,
            'translation': translated,
            'categoryName': catKey, // Kategori anahtarı
          });

          if (results.length >= 50) break;
        }
      }
    });

    setState(() {
      _searchResults = results;
      _isSearching = false; // Arama tamamlandı
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

  void _toggleBookmark(String categoryKey) async {
    try {
      final isCurrentlyBookmarked = _bookmarkedCategories.contains(categoryKey);

      if (isCurrentlyBookmarked) {
        await LibraryRepository().removeBookmarkByItem(
          itemType: 'dictionary_category',
          itemId: categoryKey,
        );
        setState(() {
          _bookmarkedCategories.remove(categoryKey);
        });
      } else {
        await LibraryRepository().addBookmark(
          itemType: 'dictionary_category',
          itemId: categoryKey,
          category: 'Dictionary',
        );
        setState(() {
          _bookmarkedCategories.add(categoryKey);
        });
        ref.read(libraryControllerProvider.notifier).loadFolders();
      }
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
    }
  }

  Future<void> _playAudio(String textToSpeak) async {
    try {
      if (_playingCategory == textToSpeak) {
        await _audioPlayer.stop();
        await _ttsService.stop();
        setState(() {
          _playingCategory = null;
        });
        return;
      }

      await _audioPlayer.stop();
      await _ttsService.stop();

      setState(() {
        _playingCategory = textToSpeak;
      });

      _ttsService
          .speak(textToSpeak, languageCode: context.locale.languageCode)
          .catchError((e) {
            debugPrint('❌ TTS error: $e');
          });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _playingCategory == textToSpeak) {
          setState(() {
            _playingCategory = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _playingCategory = null;
      });
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> _playWordAudio(String wordId, String englishWord) async {
    try {
      if (_playingWordId == wordId) {
        await _audioPlayer.stop();
        await _ttsService.stop();
        setState(() {
          _playingWordId = null;
        });
        return;
      }

      await _audioPlayer.stop();
      await _ttsService.stop();

      setState(() {
        _playingWordId = wordId;
        _playingCategory = null;
      });

      _ttsService.speak(englishWord, languageCode: 'en').catchError((e) {
        debugPrint('❌ TTS error: $e');
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _playingWordId == wordId) {
          setState(() {
            _playingWordId = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _playingWordId = null;
      });
      debugPrint('Error playing word audio: $e');
    }
  }

  void _toggleWordBookmark(String wordId, String categoryName) async {
    try {
      setState(() => _bookmarkedWords.remove(wordId));
      final isCurrentlyBookmarked = _bookmarkedWords.contains(wordId);

      if (isCurrentlyBookmarked) {
        await LibraryRepository().removeBookmarkByItem(
          itemType: 'dictionary_word',
          itemId: wordId,
        );
      } else {
        setState(() => _bookmarkedWords.add(wordId));
        await LibraryRepository().addBookmark(
          itemType: 'dictionary_word',
          itemId: wordId,
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
          categoryName: categoryKey, // Tıklananın gerçek key'i aktarılır
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
    // Color specification for the shadow
    const shadowColor = Color(0xFFC2D6E1); // Hex value from spec

    return Container(
      height: 48.h, // Maintain current height
      decoration: BoxDecoration(
        color: MyColors.white, // Fill: White (FFFFFF) from spec
        borderRadius: BorderRadius.circular(
          10.r,
        ), // Corner radius: 10 from spec
        // REMOVED: Border.all - spec has no stroke applied
        // ADDED: boxshadow with spec settings
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(
              0.5,
            ), // Spec: Color C2D6E1, 50% opacity
            blurRadius: 4.r, // Spec: Blur 4
            spreadRadius: 0.r, // Spec: Spread 0
            offset: Offset(0, 2.h), // Spec: Position X=0, Y=2
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
          // REMOVED complex constraints for prefix icon to allow vertical centering
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
          border:
              InputBorder.none, // Component border is defined by BoxDecoration
          contentPadding: EdgeInsets.symmetric(
            horizontal: 0.w,
          ), // Reset to help vertical centering
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
      onTap: () => _navigateToCategory(category['key']), // KEY aktarılıyor
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
                // EKLENEN KISIM: Uzantıya göre SVG veya PNG render etme
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
              category['name'], // Ekrana çevrilmiş isim yazılır
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
            crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _buildSearchWordCard(Map<String, String> word) {
    final wordId = word['id']!;
    final isBookmarked = _bookmarkedWords.contains(wordId);
    final isPlaying = _playingWordId == wordId;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        _addWordToRecentSearches(word);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC2D6E1).withOpacity(0.60),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
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
                        word['word']!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          letterSpacing: 12.sp * -0.05,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          color: MyColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            word['translation']!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              letterSpacing: 10.sp * -0.05,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                              color: const Color(0xFF96A4B9),
                            ),
                          ),
                          Text(
                            " • ${word['categoryName']!.tr()}",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                              color: const Color(0xFF4ECDC4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    _addWordToRecentSearches(word);
                    _playWordAudio(wordId, word['word']!);
                  },
                  child: SvgPicture.asset(
                    'assets/icons/visualdictionaryses.svg',
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    _addWordToRecentSearches(word);
                    _toggleWordBookmark(wordId, word['categoryName']!);
                  },
                  child: Container(
                    width: 30.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: isBookmarked
                          ? const Color(0xFF2989E9).withOpacity(0.2)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/visualdictionarysaved.svg',
                        width: 12.w,
                        height: 12.h,
                        colorFilter: ColorFilter.mode(
                          isBookmarked
                              ? const Color(0xFF2989E9)
                              : const Color(0xFFCBD5E1),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3.h,
            margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12.h),
            decoration: BoxDecoration(
              color: isPlaying ? const Color(0xFF4ECDC4) : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
