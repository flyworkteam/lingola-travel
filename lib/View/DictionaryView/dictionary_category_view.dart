import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../../Riverpod/Controllers/visual_dictionary_words_controller.dart';
import '../../Riverpod/Controllers/library_controller.dart';
import '../../Repositories/library_repository.dart';
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

class _DictionaryCategoryViewState
    extends ConsumerState<DictionaryCategoryView> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _bookmarkedItems = {};
  String _searchQuery = '';

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingItemId;
  StreamSubscription? _audioCompletionSubscription;

  // TTS Service
  late final TtsService _ttsService;

  @override
  void initState() {
    super.initState();

    // Initialize TTS service
    _ttsService = TtsService();
    _ttsService
        .init()
        .then((_) {
          print('✅ TTS initialized in dictionary_category_view');
        })
        .catchError((e) {
          print('⚠️ Error initializing TTS: $e');
        });

    // Setup audio completion listener once
    _audioCompletionSubscription = _audioPlayer.onPlayerComplete.listen((
      event,
    ) {
      if (mounted) {
        setState(() {
          _playingItemId = null;
        });
      }
    });

    // Load words from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(
            visualDictionaryWordsControllerProvider(widget.categoryId).notifier,
          )
          .init();
    });
  }

  List<Map<String, String>> get _words {
    final wordsState = ref.watch(
      visualDictionaryWordsControllerProvider(widget.categoryId),
    );

    // Convert DictionaryWordModel to Map for compatibility with existing UI
    return wordsState.words.map((word) {
      // For English: word is target, translation is Turkish
      // For others: translation is target, word is Turkish
      final isEnglish = word.targetLanguage == 'en';
      return {
        'word': isEnglish ? word.word : word.translation,
        'translation': isEnglish ? word.translation : word.word,
        'audioUrl': word.audioUrl ?? '',
        'targetLanguage': word.targetLanguage ?? 'en', // Language code
      };
    }).toList();
  }

  // Filter words based on search query
  List<Map<String, String>> get _filteredWords {
    if (_searchQuery.isEmpty) {
      return _words;
    }

    final query = _searchQuery.toLowerCase();
    return _words.where((word) {
      final wordText = word['word']?.toLowerCase() ?? '';
      final translation = word['translation']?.toLowerCase() ?? '';
      return wordText.contains(query) || translation.contains(query);
    }).toList();
  }

  int get _itemCount {
    return _filteredWords.length;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioCompletionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleBookmark(String id) async {
    try {
      final isCurrentlyBookmarked = _bookmarkedItems.contains(id);

      if (isCurrentlyBookmarked) {
        // Remove from library
        await LibraryRepository().removeBookmarkByItem(
          itemType: 'dictionary_word',
          itemId: id,
        );
        setState(() {
          _bookmarkedItems.remove(id);
        });
      } else {
        // Save to library with category
        await LibraryRepository().addBookmark(
          itemType: 'dictionary_word',
          itemId: id,
          category: widget.categoryName,
        );
        setState(() {
          _bookmarkedItems.add(id);
        });
        // Refresh library folders
        ref.read(libraryControllerProvider.notifier).loadFolders();
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }

  Future<void> _playAudio(
    String itemId,
    String audioUrl,
    String word,
    String? targetLanguage,
  ) async {
    try {
      // If same item is playing, stop it
      if (_playingItemId == itemId) {
        await _audioPlayer.stop();
        await _ttsService.stop();
        setState(() {
          _playingItemId = null;
        });
        return;
      }

      // Stop any current playback
      await _audioPlayer.stop();
      await _ttsService.stop();

      // Play new audio
      setState(() {
        _playingItemId = itemId;
      });

      // If audioUrl is available, use audioplayer; otherwise use TTS
      if (audioUrl.isNotEmpty) {
        await _audioPlayer.play(UrlSource(audioUrl));
      } else {
        print(
          '🔊🔊🔊 DICTIONARY SPEAKER BUTTON - Using TTS for: "$word" in $targetLanguage',
        );
        // Use TTS with target language pronunciation - don't await to prevent UI blocking
        _ttsService
            .speak(word, languageCode: targetLanguage)
            .then((_) {
              print('✅ TTS completed for: $word');
            })
            .catchError((e) {
              print('❌ TTS error in callback: $e');
            });

        // Reset playing state after estimated TTS duration
        Future.delayed(Duration(seconds: 3), () {
          if (mounted && _playingItemId == itemId) {
            setState(() {
              _playingItemId = null;
            });
          }
        });
      }
      // Completion handled by the listener in initState
    } catch (e) {
      setState(() {
        _playingItemId = null;
      });
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordsState = ref.watch(
      visualDictionaryWordsControllerProvider(widget.categoryId),
    );

    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          key: ValueKey('dictionary_category_stack_${widget.categoryId}'),
          children: [
            // Main scrollable content
            wordsState.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
                  )
                : wordsState.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          wordsState.errorMessage!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: MyColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(
                                  visualDictionaryWordsControllerProvider(
                                    widget.categoryId,
                                  ).notifier,
                                )
                                .refresh();
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // Header with back button and title
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: MyColors.textPrimary,
                                  size: 24.sp,
                                ),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                widget.categoryName,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                  color: MyColors.textPrimary,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // Search bar
                          _buildSearchBar(),

                          SizedBox(height: 16.h),

                          // Item count
                          _buildItemCount(),

                          SizedBox(height: 16.h),

                          // Word list (non-scrollable, inside outer scroll)
                          _buildWordList(),

                          SizedBox(height: 100.h), // Space for bottom nav
                        ],
                      ),
                    ),
                  ),

            // Floating bottom navigation
            CustomBottomNavBar(
              key: ValueKey('bottom_nav_dictionary_category'),
              currentIndex: 2,
              isPremium: widget.isPremium,
            ),
          ],
        ),
      ),
    );
  }

  /// Search bar
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
          hintText: 'Search words or phrases...',
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
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  /// Item count
  Widget _buildItemCount() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '$_itemCount items',
        style: TextStyle(
          fontSize: 14.sp,
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
              'No words found',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: MyColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Montserrat',
                color: MyColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final wordId = '${widget.categoryName}-$index';
        return _buildWordCard(word, wordId);
      },
    );
  }

  /// Word card
  Widget _buildWordCard(Map<String, String> word, String id) {
    final isBookmarked = _bookmarkedItems.contains(id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 0),
          padding: EdgeInsets.all(16.w),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word['word']!, // Target language word (e.g., "Airport")
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: MyColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      word['translation']!, // Turkish translation
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
              SizedBox(width: 12.w),
              // Audio button
              GestureDetector(
                onTap: () {
                  final audioUrl = word['audioUrl'] ?? '';
                  final targetWord = word['word'] ?? '';
                  final targetLang = word['targetLanguage'];
                  print('Playing audio for: $targetWord');
                  _playAudio(id, audioUrl, targetWord, targetLang);
                },
                child: SvgPicture.asset(
                  'assets/icons/visualdictionaryses.svg',
                  width: 40.w,
                  height: 40.h,
                ),
              ),
              SizedBox(width: 8.w),
              // Bookmark button
              GestureDetector(
                onTap: () => _toggleBookmark(id),
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: isBookmarked
                        ? Color(0xFF2989E9).withOpacity(0.2)
                        : Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/visualdictionarysaved.svg',
                      width: 11.w,
                      height: 13.h,
                      colorFilter: ColorFilter.mode(
                        isBookmarked ? Color(0xFF2989E9) : Color(0xFFCBD5E1),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Progress bar at the bottom of the card - full width
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: 3.h,
          margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12.h),
          decoration: BoxDecoration(
            color: _playingItemId == id
                ? Color(0xFF4ECDC4)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }
}
