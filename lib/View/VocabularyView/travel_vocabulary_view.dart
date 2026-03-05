import 'dart:async';
import 'dart:convert'; // JSON işlemleri için eklendi

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
import 'package:shared_preferences/shared_preferences.dart'; // Yerel kayıt için eklendi

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

class _TravelVocabularyViewState extends ConsumerState<TravelVocabularyView> {
  // State variables
  bool _isShowingWords = true; // DEFAULT: Words
  String _selectedCategory = LocaleKeys.travel_vocabulary_all_topics;
  final TextEditingController _searchController = TextEditingController();

  // YEREL BOOKMARK YÖNETİMİ
  Set<String> _bookmarkedItems = {};
  static const String _localBookmarksKey = 'lingola_local_bookmarks';

  String? _lastLoadedLanguage;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingItemId;
  StreamSubscription? _audioCompletionSubscription;
  late TtsService _ttsService;

  // Sabit Kategori Listesi (Lokalizasyondan)
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
    _ttsService
        .init()
        .then((_) {
          debugPrint('✅ TTS initialized in travel_vocabulary_view');
        })
        .catchError((e) {
          debugPrint('⚠️ Error initializing TTS: $e');
        });

    _audioCompletionSubscription = _audioPlayer.onPlayerComplete.listen((
      event,
    ) {
      if (mounted) {
        setState(() {
          _playingItemId = null;
        });
      }
    });

    if (widget.initialCategory != null) {
      if (widget.initialCategory == 'All Topics' ||
          widget.initialCategory == LocaleKeys.travel_vocabulary_all_topics) {
        _selectedCategory = LocaleKeys.travel_vocabulary_all_topics;
      } else {
        _selectedCategory = widget.initialCategory!;
      }
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadLocalBookmarks(); // Artık API'den değil, cihazın hafızasından çekiyor
      _lastLoadedLanguage = ref.read(selectedLanguageProvider);
    });

    // Arama barı için dinleyici
    _searchController.addListener(() {
      setState(() {});
    });
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
            _bookmarkedItems = decoded.cast<String>().toSet();
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Yerel favoriler yüklenirken hata: $e');
    }
  }

  // --- %100 YEREL (LOCAL) BOOKMARK KAYDETME/SİLME ---
  Future<void> _toggleBookmark(
    String itemId, {
    String? itemType,
    String? category,
  }) async {
    // 1. Arayüzü anında güncelle
    setState(() {
      if (_bookmarkedItems.contains(itemId)) {
        _bookmarkedItems.remove(itemId);
      } else {
        _bookmarkedItems.add(itemId);
      }
    });

    // 2. Arka planda cihaz hafızasına (SharedPreferences) kaydet (Sıfır API isteği)
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_bookmarkedItems.toList());
      await prefs.setString(_localBookmarksKey, encoded);
    } catch (e) {
      debugPrint('❌ Yerel favoriler kaydedilirken hata: $e');
    }
  }

  // Kullanıcı Kategori değiştirdiğinde (Sadece sesi durdurur)
  void _onCategorySelected(String categoryName) {
    if (!mounted) return;

    if (_playingItemId != null) {
      _audioPlayer.stop().catchError((e) {});
      _ttsService.stop().catchError((e) {});
    }

    setState(() {
      _selectedCategory = categoryName;
      _playingItemId = null;
    });
  }

  @override
  void dispose() {
    _audioCompletionSubscription?.cancel();
    _playingItemId = null;
    _audioPlayer.stop().catchError((e) {});
    _ttsService.stop().catchError((e) {});
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // İngilizce metni oluşturmak için camelCase anahtarları düzenleyen yardımcı fonksiyon
  String _getEnglishText(String key) {
    final lastPart = key.split('.').last;

    if (lastPart == 'oneMomentPlease') return 'One moment, please';

    final RegExp exp = RegExp(r'(?<=[a-z])(?=[A-Z])');
    final parts = lastPart.split(exp);

    String formatted = parts.map((p) => p.toLowerCase()).join(' ');
    formatted = formatted[0].toUpperCase() + formatted.substring(1);
    formatted = formatted.replaceAll(RegExp(r'\bi\b'), 'I');

    formatted = formatted.replaceAll("I dont ", "I don't ");
    formatted = formatted.replaceAll("Im ", "I'm ");
    formatted = formatted.replaceAll("Youre ", "You're ");
    formatted = formatted.replaceAll("Cant ", "Can't ");
    formatted = formatted.replaceAll("Lets ", "Let's ");

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

  // Ses çalma (Yalnızca TTS kullanılıyor)
  Future<void> _playAudio(String itemId, String englishText) async {
    if (!mounted || _audioCompletionSubscription == null) return;

    try {
      if (_playingItemId == itemId) {
        await _audioPlayer.stop();
        await _ttsService.stop();
        if (mounted) setState(() => _playingItemId = null);
        return;
      }

      await _audioPlayer.stop();
      await _ttsService.stop();

      if (!mounted) return;
      setState(() => _playingItemId = itemId);

      // İngilizce metni her zaman 'en' koduyla okutuyoruz
      _ttsService.speak(englishText, languageCode: 'en').catchError((e) {
        debugPrint('❌ TTS error: $e');
        if (mounted) setState(() => _playingItemId = null);
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _playingItemId == itemId) {
          setState(() => _playingItemId = null);
        }
      });
    } catch (e) {
      debugPrint('❌ CRITICAL Audio error: $e');
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

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {},
      child: Scaffold(
        backgroundColor: MyColors.white,
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColors.white,
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
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: MyColors.border, width: 1),
        ),
        child: TextField(
          controller: _searchController,
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
            prefixIcon: Icon(
              Icons.search,
              color: MyColors.textSecondary,
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
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
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_playingItemId != null) {
                    _audioPlayer.stop().catchError((e) {});
                    _ttsService.stop().catchError((e) {});
                  }
                  setState(() {
                    _isShowingWords = true;
                    _playingItemId = null;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _isShowingWords ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      LocaleKeys.travel_vocabulary_tab_words.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: _isShowingWords
                            ? const Color(0xFF4ECDC4)
                            : MyColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_playingItemId != null) {
                    _audioPlayer.stop().catchError((e) {});
                    _ttsService.stop().catchError((e) {});
                  }
                  setState(() {
                    _isShowingWords = false;
                    _playingItemId = null;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: !_isShowingWords ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      LocaleKeys.travel_vocabulary_tab_phrases.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: !_isShowingWords
                            ? const Color(0xFF4ECDC4)
                            : MyColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final categoryKey = _categories[index];
          final isSelected = _selectedCategory == categoryKey;

          final displayName =
              categoryKey == LocaleKeys.travel_vocabulary_all_topics
              ? LocaleKeys.travel_vocabulary_all_topics.tr()
              : categoryKey.tr();

          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () => _onCategorySelected(categoryKey),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4ECDC4) : MyColors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: MyColors.border, width: 1),
                ),
                child: Center(
                  child: Text(
                    displayName,
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

    // Sadece belirli kategoriyi göster
    if (_selectedCategory != LocaleKeys.travel_vocabulary_all_topics) {
      List<String> items = sourceData[_selectedCategory] ?? [];

      if (query.isNotEmpty) {
        items = items.where((key) {
          final english = _getEnglishText(key).toLowerCase();
          final translated = key.tr().toLowerCase();
          return english.contains(query) || translated.contains(query);
        }).toList();
      }

      if (items.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildDynamicItemCard(items[index], _selectedCategory);
        },
      );
    }

    // "All Topics" seçiliyse kategorilere göre gruplandır
    final List<Widget> groupedWidgets = [];

    for (String catKey in sourceData.keys) {
      List<String> items = sourceData[catKey] ?? [];

      if (query.isNotEmpty) {
        items = items.where((key) {
          final english = _getEnglishText(key).toLowerCase();
          final translated = key.tr().toLowerCase();
          return english.contains(query) || translated.contains(query);
        }).toList();
      }

      if (items.isNotEmpty) {
        groupedWidgets.add(
          _buildCategoryGroup(categoryKey: catKey, items: items),
        );
      }
    }

    if (groupedWidgets.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
      children: groupedWidgets,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Text(
          LocaleKeys.travel_vocabulary_no_items.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            color: MyColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGroup({
    required String categoryKey,
    required List<String> items,
  }) {
    final displayCount = items.length > 3 ? 3 : items.length;
    final hasMore = items.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
          child: Row(
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
              const Spacer(),
              Text(
                '${items.length} ${_isShowingWords ? LocaleKeys.travel_vocabulary_tab_words.tr() : LocaleKeys.travel_vocabulary_tab_phrases.tr()}',
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
        ...items
            .take(displayCount)
            .map((key) => _buildDynamicItemCard(key, categoryKey)),
        if (hasMore)
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
            child: Center(
              child: TextButton(
                onPressed: () => _onCategorySelected(categoryKey),
                child: Text(
                  LocaleKeys.travel_vocabulary_load_more.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    color: MyColors.lingolaPrimaryColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDynamicItemCard(String itemKey, String categoryKey) {
    final isBookmarked = _bookmarkedItems.contains(itemKey);
    final englishText = _getEnglishText(itemKey);
    final translatedText = itemKey.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 0),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
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
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: MyColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => _playAudio(itemKey, englishText),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7F4),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/travelvocabularyseslendirme.svg',
                          width: 18.w,
                          height: 18.h,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF4ECDC4),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  GestureDetector(
                    onTap: () => _toggleBookmark(
                      itemKey,
                      itemType: _isShowingWords
                          ? 'dictionary_word'
                          : 'travel_phrase',
                      category: categoryKey,
                    ),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? const Color(0x3D2989E9)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/travelvocabularykaydet.svg',
                          width: 18.w,
                          height: 18.h,
                          colorFilter: ColorFilter.mode(
                            isBookmarked
                                ? const Color(0xFF2989E9)
                                : const Color(0xFFB0B0B0),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                translatedText,
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 3.h,
          margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 16.h),
          decoration: BoxDecoration(
            color: _playingItemId == itemKey
                ? const Color(0xFF4ECDC4)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }
}
