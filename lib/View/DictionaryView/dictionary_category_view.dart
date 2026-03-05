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

import '../../Services/tts_service.dart';

class DictionaryCategoryView extends ConsumerStatefulWidget {
  final String
  categoryName; // Artık doğrudan LocaleKeys.home_cat... stringi gelecek
  final String categoryId;
  final bool isPremium;

  const DictionaryCategoryView({
    super.key,
    required this.categoryName,
    required this.categoryId,
    this.isPremium = false,
  });

  @override
  ConsumerState<DictionaryCategoryView> createState() =>
      _DictionaryCategoryViewState();
}

class _DictionaryCategoryViewState
    extends ConsumerState<DictionaryCategoryView> {
  final TextEditingController _searchController = TextEditingController();

  // YEREL BOOKMARK YÖNETİMİ
  Set<String> _bookmarkedItems = {};
  static const String _localBookmarksKey = 'lingola_local_bookmarks';

  String _searchQuery = '';

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingItemId;
  StreamSubscription? _audioCompletionSubscription;

  late final TtsService _ttsService;

  @override
  void initState() {
    super.initState();

    _loadLocalBookmarks(); // Yerel favorileri çek

    _ttsService = TtsService();
    _ttsService.init().then((_) {
      debugPrint('✅ TTS initialized');
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
  Future<void> _toggleBookmark(String itemId) async {
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

  @override
  void dispose() {
    _searchController.dispose();
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

  // Kelimeleri LanguageDataManager'dan dinamik olarak çek
  List<Map<String, String>> get _words {
    // categoryName değişkeni zaten 'home.catGeneral' formatında geldiği varsayılıyor.
    final List<String> keys =
        LanguageDataManager.vocabularyData[widget.categoryName] ?? [];

    return keys.map((key) {
      String englishWord = _formatEnglishWord(key);
      String translatedWord = key.tr();

      return {
        'id': key, // Favoriye eklerken orijinal anahtarı kullanacağız
        'word': englishWord,
        'translation': translatedWord,
        'targetLanguage': 'en',
      };
    }).toList();
  }

  // Arama Filtresi
  List<Map<String, String>> get _filteredWords {
    if (_searchQuery.isEmpty) return _words;
    final query = _searchQuery.toLowerCase();

    return _words.where((word) {
      final wordText = word['word']?.toLowerCase() ?? '';
      final translation = word['translation']?.toLowerCase() ?? '';
      return wordText.contains(query) || translation.contains(query);
    }).toList();
  }

  Future<void> _playAudio(
    String itemId,
    String word,
    String? targetLanguage,
  ) async {
    try {
      if (_playingItemId == itemId) {
        await _audioPlayer.stop();
        await _ttsService.stop();
        setState(() => _playingItemId = null);
        return;
      }

      await _audioPlayer.stop();
      await _ttsService.stop();

      setState(() => _playingItemId = itemId);

      _ttsService.speak(word, languageCode: targetLanguage ?? 'en');

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _playingItemId == itemId) {
          setState(() => _playingItemId = null);
        }
      });
    } catch (e) {
      setState(() => _playingItemId = null);
      debugPrint('Error playing audio: $e');
    }
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
          widget.categoryName.tr(), // Doğrudan local stringi .tr() ile çevirdik
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
                SizedBox(height: 12.h),
                _buildSearchBar(),
                SizedBox(height: 12.h),
                _buildItemCount(),
                SizedBox(height: 8.h),
                _buildWordList(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
          hintText: LocaleKeys.search_placeholder.tr(),
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            color: MyColors.textSecondary,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40.w,
            maxHeight: 24.h,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 12.w, right: 8.w),
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
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        cursorColor: MyColors.lingolaPrimaryColor,
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildItemCount() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '${_filteredWords.length} ${LocaleKeys.library_library_items.tr()}',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          fontFamily: 'Montserrat',
          color: MyColors.textSecondary,
        ),
      ),
    );
  }

  /// Word list
  Widget _buildWordList() {
    final words = _filteredWords;

    if (words.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 200),
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return _buildWordCard(word);
      },
    );
  }

  Widget _buildWordCard(Map<String, String> word) {
    final wordId = word['id']!;
    final isBookmarked = _bookmarkedItems.contains(wordId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    SizedBox(height: 4.h),
                    Text(
                      word['translation']!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        letterSpacing: 10.sp * -0.05,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                        color: const Color(0xFF96A4B9),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () =>
                    _playAudio(wordId, word['word']!, word['targetLanguage']),
                child: SvgPicture.asset('assets/icons/visualdictionaryses.svg'),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => _toggleBookmark(wordId),
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
            color: _playingItemId == wordId
                ? const Color(0xFF4ECDC4)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }
}
