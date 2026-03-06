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
import 'package:lingola_travel/Repositories/library_repository.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/tts_service.dart';

class DictionaryCategoryView extends ConsumerStatefulWidget {
  final String categoryName;
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

// TickerProviderStateMixin animasyon için eklendi
class _DictionaryCategoryViewState extends ConsumerState<DictionaryCategoryView>
    with TickerProviderStateMixin {
  // Backend işlemleri için Repository örneği
  final LibraryRepository _libraryRepository = LibraryRepository();

  final TextEditingController _searchController = TextEditingController();

  Set<String> _bookmarkedItems = {};
  static const String _localBookmarksKey = 'lingola_local_bookmarks';

  String _searchQuery = '';

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingItemId;
  late final TtsService _ttsService;

  // İlerleme çubuğu için animasyon kontrolcüsü
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _loadLocalBookmarks();

    _ttsService = TtsService();
    _ttsService.init();

    // Animasyon kontrolcüsü başlatıldı
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

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

  // Backend ile Senkronize Kaydetme / Silme İşlemi (Optimistic UI)
  Future<void> _toggleBookmark(String itemId) async {
    // 1. Mevcut durumu kaydet (İşlem başarısız olursa geri dönmek için)
    final bool isCurrentlyBookmarked = _bookmarkedItems.contains(itemId);

    // 2. Arayüzü anında güncelle (Kullanıcı bekletilmez)
    setState(() {
      if (isCurrentlyBookmarked) {
        _bookmarkedItems.remove(itemId);
      } else {
        _bookmarkedItems.add(itemId);
      }
    });

    // 3. Backend API isteğini yap
    bool apiSuccess = false;

    try {
      if (isCurrentlyBookmarked) {
        // Backend'den Silme
        final response = await _libraryRepository.removeBookmarkByItem(
          itemType: 'dictionary_word',
          itemId: itemId,
        );
        apiSuccess = response.success;
      } else {
        // Backend'e Ekleme (GÜNCELLENDİ: word ve translation eklendi)
        final response = await _libraryRepository.addBookmark(
          itemType: 'dictionary_word',
          itemId: itemId,
          word: _formatEnglishWord(itemId), // Kelimenin formatlı İngilizce hali
          translation: itemId.tr(), // Seçili dile göre çevirisi
          category: widget.categoryName,
        );
        apiSuccess = response.success;
      }
    } catch (e) {
      debugPrint('❌ Backend API hatası: $e');
      apiSuccess = false;
    }

    // 4. Sonuca göre aksiyon al
    if (apiSuccess) {
      // Başarılıysa yerel cache'i de güncelle
      try {
        final prefs = await SharedPreferences.getInstance();
        final String encoded = jsonEncode(_bookmarkedItems.toList());
        await prefs.setString(_localBookmarksKey, encoded);
      } catch (e) {
        debugPrint('❌ Yerel favoriler kaydedilirken hata: $e');
      }
    } else {
      // Başarısız olursa arayüzü eski haline döndür
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
            content: Text(
              'İşlem başarısız oldu. Lütfen internet bağlantınızı kontrol edin.',
            ),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _stopAllAudio();
    _searchController.dispose();
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

  List<Map<String, String>> get _words {
    final List<String> keys =
        LanguageDataManager.vocabularyData[widget.categoryName] ?? [];

    return keys.map((key) {
      String englishWord = _formatEnglishWord(key);
      String translatedWord = key.tr();

      return {
        'id': key,
        'word': englishWord,
        'translation': translatedWord,
        'targetLanguage': 'en',
      };
    }).toList();
  }

  List<Map<String, String>> get _filteredWords {
    if (_searchQuery.isEmpty) return _words;
    final query = _searchQuery.toLowerCase();

    return _words.where((word) {
      final wordText = word['word']?.toLowerCase() ?? '';
      final translation = word['translation']?.toLowerCase() ?? '';
      return wordText.contains(query) || translation.contains(query);
    }).toList();
  }

  // Senkronize edilmiş ses oynatma mekaniği
  Future<void> _playAudio(String itemId, String wordText) async {
    if (!mounted) return;

    try {
      if (_playingItemId == itemId) {
        _stopAllAudio();
        setState(() => _playingItemId = null);
        return;
      }

      _stopAllAudio();
      setState(() => _playingItemId = itemId);

      // Dinamik süre hesabı: Karakter başına ~90ms
      int durationMs = (wordText.length * 90).clamp(1200, 5000);
      _progressController.duration = Duration(milliseconds: durationMs);

      _progressController.forward();
      await _ttsService.speak(wordText, languageCode: 'en');

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
          widget.categoryName.tr(),
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
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.w),
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

  Widget _buildWordList() {
    final words = _filteredWords;

    if (words.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100.h),
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
    final isPlaying = _playingItemId == wordId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.r),
              topRight: Radius.circular(10.r),
              bottomLeft: Radius.circular(isPlaying ? 0 : 10.r),
              bottomRight: Radius.circular(isPlaying ? 0 : 10.r),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC2D6E1).withOpacity(0.60),
                offset: const Offset(0, 2),
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
                onTap: () => _playAudio(wordId, word['word']!),
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

        // Animasyonlu İlerleme Çubuğu
        if (isPlaying)
          Container(
            height: 4.h,
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.r),
                bottomRight: Radius.circular(10.r),
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
                        bottomLeft: Radius.circular(10.r),
                        bottomRight: Radius.circular(
                          _progressController.value > 0.98 ? 10.r : 0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          SizedBox(height: 12.h),
      ],
    );
  }
}
