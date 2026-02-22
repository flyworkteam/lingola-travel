import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Core/Localization/app_localizations.dart';
import 'package:lingola_travel/Riverpod/Providers/locale_provider.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../../Services/tts_service.dart';
import '../../Repositories/library_repository.dart';
import '../../Repositories/dictionary_repository.dart';
import '../../Riverpod/Controllers/library_controller.dart';
import '../../Models/dictionary_model.dart';
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
  List<String> _recentSearches = ['Accommodation', 'Airport'];
  Set<String> _bookmarkedCategories = {};
  Set<String> _bookmarkedWords = {};
  String _searchQuery = '';
  List<DictionaryWordModel> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingCategory;
  String? _playingWordId;
  StreamSubscription? _audioCompletionSubscription;

  // TTS Service
  late final TtsService _ttsService;

  // STATIC categories - using localized names via getter
  List<Map<String, dynamic>> get _staticCategories {
    final l = AppLocalizations.of(ref.read(localeProvider));
    return [
      {
        'id': 'dict-cat-011',
        'name': l.catAirport,
        'icon': 'assets/icons/airport.png',
        'color': '#B8A7FF',
        'count': 20,
      },
      {
        'id': 'dict-cat-002',
        'name': l.catAccommodation,
        'icon': 'assets/icons/accommodation.png',
        'color': '#FF9F6A',
        'count': 20,
      },
      {
        'id': 'dict-cat-003',
        'name': l.catTransportation,
        'icon': 'assets/icons/transportation.png',
        'color': '#F9D26B',
        'count': 20,
      },
      {
        'id': 'dict-cat-004',
        'name': l.catFoodAndDrink,
        'icon': 'assets/icons/food_drink.png',
        'color': '#FF8FA5',
        'count': 20,
      },
      {
        'id': 'dict-cat-005',
        'name': l.catShopping,
        'icon': 'assets/icons/shopping.png',
        'color': '#8BDDCD',
        'count': 20,
      },
      {
        'id': 'dict-cat-006',
        'name': l.catCulture,
        'icon': 'assets/icons/culture.png',
        'color': '#B8D9FF',
        'count': 20,
      },
      {
        'id': 'dict-cat-007',
        'name': l.catMeeting,
        'icon': 'assets/icons/meeting.png',
        'color': '#FFB8B8',
        'count': 20,
      },
      {
        'id': 'dict-cat-008',
        'name': l.catSport,
        'icon': 'assets/icons/sport.png',
        'color': '#E4B3FF',
        'count': 20,
      },
      {
        'id': 'dict-cat-009',
        'name': l.catHealth,
        'icon': 'assets/icons/health.png',
        'color': '#B8FFC9',
        'count': 20,
      },
      {
        'id': 'dict-cat-010',
        'name': l.catBusiness,
        'icon': 'assets/icons/business.png',
        'color': '#A4C8E1',
        'count': 20,
      },
    ];
  }

  @override
  void initState() {
    super.initState();

    // Initialize TTS service
    _ttsService = TtsService();
    _ttsService
        .init()
        .then((_) {
          print('✅ TTS initialized in visual_dictionary_view');
        })
        .catchError((e) {
          print('⚠️ Error initializing TTS: $e');
        });

    // Setup audio completion listener
    _audioCompletionSubscription = _audioPlayer.onPlayerComplete.listen((
      event,
    ) {
      if (mounted) {
        setState(() {
          _playingCategory = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _audioCompletionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Perform word search with debounce
  Future<void> _performSearch(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await DictionaryRepository().searchWords(
        query: query.trim(),
        limit: 50,
      );

      if (response.success && response.data != null) {
        setState(() {
          _searchResults = response.data!;
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  // Filter categories based on search query
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

  void _toggleBookmark(String categoryName) async {
    try {
      final isCurrentlyBookmarked = _bookmarkedCategories.contains(
        categoryName,
      );

      if (isCurrentlyBookmarked) {
        // Remove from library
        await LibraryRepository().removeBookmarkByItem(
          itemType: 'dictionary_category',
          itemId: categoryName,
        );
        setState(() {
          _bookmarkedCategories.remove(categoryName);
        });
      } else {
        // Save to library
        await LibraryRepository().addBookmark(
          itemType: 'dictionary_category',
          itemId: categoryName,
          category: 'Dictionary',
        );
        setState(() {
          _bookmarkedCategories.add(categoryName);
        });
        // Refresh library folders
        ref.read(libraryControllerProvider.notifier).loadFolders();
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }

  Future<void> _playAudio(String categoryName) async {
    try {
      // If same category is playing, stop it
      if (_playingCategory == categoryName) {
        await _audioPlayer.stop();
        await _ttsService.stop();
        setState(() {
          _playingCategory = null;
        });
        return;
      }

      // Stop any current playback
      await _audioPlayer.stop();
      await _ttsService.stop();

      // Play new audio using TTS
      setState(() {
        _playingCategory = categoryName;
      });

      print('🔊 Playing category name: "$categoryName"');
      _ttsService
          .speak(categoryName, languageCode: 'en')
          .then((_) {
            print('✅ TTS completed for: $categoryName');
          })
          .catchError((e) {
            print('❌ TTS error: $e');
          });

      // Reset playing state after estimated TTS duration
      Future.delayed(Duration(seconds: 2), () {
        if (mounted && _playingCategory == categoryName) {
          setState(() {
            _playingCategory = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _playingCategory = null;
      });
      print('Error playing audio: $e');
    }
  }

  Future<void> _playWordAudio(DictionaryWordModel word) async {
    try {
      final wordId = word.id.toString();

      // If same word is playing, stop it
      if (_playingWordId == wordId) {
        await _audioPlayer.stop();
        await _ttsService.stop();
        setState(() {
          _playingWordId = null;
        });
        return;
      }

      // Stop any current playback
      await _audioPlayer.stop();
      await _ttsService.stop();

      setState(() {
        _playingWordId = wordId;
        _playingCategory = null;
      });

      final targetWord = word.targetLanguage == 'en'
          ? word.word
          : word.translation;
      final languageCode = word.targetLanguage ?? 'en';

      print('🔊 Playing word: "$targetWord" ($languageCode)');

      // Try audio URL first, fallback to TTS
      if (word.audioUrl != null && word.audioUrl!.isNotEmpty) {
        try {
          await _audioPlayer.play(UrlSource(word.audioUrl!));
          return;
        } catch (e) {
          print('Audio URL failed, using TTS: $e');
        }
      }

      // Use TTS
      _ttsService
          .speak(targetWord, languageCode: languageCode)
          .then((_) {
            print('✅ TTS completed for: $targetWord');
          })
          .catchError((e) {
            print('❌ TTS error: $e');
          });

      // Reset playing state
      Future.delayed(Duration(seconds: 3), () {
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
      print('Error playing word audio: $e');
    }
  }

  void _toggleWordBookmark(DictionaryWordModel word) async {
    try {
      final wordId = word.id.toString();
      final isCurrentlyBookmarked = _bookmarkedWords.contains(wordId);

      if (isCurrentlyBookmarked) {
        await LibraryRepository().removeBookmarkByItem(
          itemType: 'dictionary_word',
          itemId: wordId,
        );
        setState(() {
          _bookmarkedWords.remove(wordId);
        });
      } else {
        await LibraryRepository().addBookmark(
          itemType: 'dictionary_word',
          itemId: wordId,
          category: 'Dictionary',
        );
        setState(() {
          _bookmarkedWords.add(wordId);
        });
        ref.read(libraryControllerProvider.notifier).loadFolders();
      }
    } catch (e) {
      print('Error toggling word bookmark: $e');
    }
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  void _navigateToCategory(String categoryName, String categoryId) {
    // Add to recent searches
    setState(() {
      _recentSearches.remove(categoryName);
      _recentSearches.insert(0, categoryName);
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DictionaryCategoryView(
          categoryName: categoryName,
          categoryId: categoryId,
          isPremium: widget.isPremium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main scrollable content
            _searchQuery.trim().length >= 2
                ? _buildSearchResults()
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
                                AppLocalizations.of(ref.watch(localeProvider)).visualDictionary,
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

                          SizedBox(height: 24.h),

                          // Category grid - STATIC categories
                          _buildCategoryGrid(),

                          SizedBox(height: 16.h),

                          // Recent Search (only show when not searching)
                          if (_recentSearches.isNotEmpty) _buildRecentSearch(),

                          SizedBox(height: 100.h), // Space for bottom nav
                        ],
                      ),
                    ),
                  ),

            // Floating bottom navigation
            CustomBottomNavBar(
              key: ValueKey('bottom_nav_dictionary'), // Unique key
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
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });

          // Debounce search
          _debounceTimer?.cancel();
          if (value.trim().length >= 2) {
            _debounceTimer = Timer(Duration(milliseconds: 500), () {
              _performSearch(value);
            });
          } else {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
          }
        },
        style: TextStyle(
          fontSize: 14.sp,
          fontFamily: 'Montserrat',
          color: MyColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(ref.watch(localeProvider)).searchWordsOrPhrases,
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
                      _searchResults = [];
                      _isSearching = false;
                    });
                    _debounceTimer?.cancel();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  /// Category grid - STATIC with search filtering
  Widget _buildCategoryGrid() {
    final categories = _filteredCategories;

    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 64.sp,
                color: MyColors.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(ref.watch(localeProvider)).noCategoriesFound,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: MyColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(ref.watch(localeProvider)).tryDifferentKeywords,
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

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  /// Category card - STATIC data
  Widget _buildCategoryCard(Map<String, dynamic> category) {
    // Parse color from string
    Color bgColor;
    try {
      final colorStr = category['color'].replaceAll('#', '');
      final colorInt = int.parse('FF$colorStr', radix: 16);
      bgColor = Color(colorInt).withOpacity(0.2);
    } catch (e) {
      bgColor = Color(0xFF4ECDC4).withOpacity(0.2);
    }

    return GestureDetector(
      onTap: () => _navigateToCategory(category['name'], category['id']),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Image.asset(
                  category['icon'], // Direct static icon path
                  width: 20.w,
                  height: 20.h,
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

            Spacer(),

            // Category name
            Text(
              category['name'],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: MyColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 4.h),

            // Item count
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppLocalizations.of(ref.watch(localeProvider)).itemsCount(category['count'] as int)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                      color: MyColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 20.sp,
                  color: MyColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Recent Search section
  Widget _buildRecentSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(ref.watch(localeProvider)).recentSearch,
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
                AppLocalizations.of(ref.watch(localeProvider)).clearText,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF4ECDC4),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Recent items
        ..._recentSearches
            .map((search) => _buildRecentSearchItem(search))
            .toList(),
      ],
    );
  }

  /// Recent search item
  Widget _buildRecentSearchItem(String categoryName) {
    final isBookmarked = _bookmarkedCategories.contains(categoryName);
    final isPlaying = _playingCategory == categoryName;

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
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First row: Category name + Buttons
              Row(
                children: [
                  // History icon
                  Icon(
                    Icons.history,
                    size: 20.sp,
                    color: MyColors.textSecondary,
                  ),

                  SizedBox(width: 8.w),

                  // Category name
                  Expanded(
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: MyColors.textPrimary,
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Audio button
                  GestureDetector(
                    onTap: () => _playAudio(categoryName),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFE0F7F4),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/travelvocabularyseslendirme.svg',
                          width: 18.w,
                          height: 18.h,
                          colorFilter: ColorFilter.mode(
                            Color(0xFF4ECDC4),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 6.w),

                  // Bookmark button
                  GestureDetector(
                    onTap: () => _toggleBookmark(categoryName),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? Color(0x3D2989E9)
                            : Color(0xFFF3F4F6),
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
                                : Color(0xFF9CA3AF),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Recent item label on second line
              Padding(
                padding: EdgeInsets.only(left: 28.w),
                child: Text(
                  AppLocalizations.of(ref.watch(localeProvider)).recentItem,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Progress bar at the bottom of the card
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: 3.h,
          margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 16.h),
          decoration: BoxDecoration(
            color: isPlaying ? Color(0xFF4ECDC4) : Colors.transparent,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }

  /// Search results list
  Widget _buildSearchResults() {
    return SingleChildScrollView(
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
                  AppLocalizations.of(ref.watch(localeProvider)).visualDictionary,
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

            // Loading indicator
            if (_isSearching)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40.h),
                  child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
                ),
              )
            // No results
            else if (_searchResults.isEmpty)
              Padding(
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
                      AppLocalizations.of(ref.watch(localeProvider)).noWordsFound,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: MyColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppLocalizations.of(ref.watch(localeProvider)).tryDifferentKeywords,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        color: MyColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            // Search results
            else ...[
              // Result count
              Text(
                '${_searchResults.length} results found',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                  color: MyColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),

              // Word list
              for (var word in _searchResults) _buildSearchWordCard(word),
            ],

            SizedBox(height: 100.h), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  /// Search word card
  Widget _buildSearchWordCard(DictionaryWordModel word) {
    final wordId = word.id.toString();
    final isBookmarked = _bookmarkedWords.contains(wordId);
    final isPlaying = _playingWordId == wordId;

    final displayWord = word.targetLanguage == 'en'
        ? word.word
        : word.translation;
    final translation = word.targetLanguage == 'en'
        ? word.translation
        : word.word;

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
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First row: Word + Buttons
              Row(
                children: [
                  // Word text
                  Expanded(
                    child: Text(
                      displayWord,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: MyColors.textPrimary,
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Audio button
                  GestureDetector(
                    onTap: () => _playWordAudio(word),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFE0F7F4),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/travelvocabularyseslendirme.svg',
                          width: 18.w,
                          height: 18.h,
                          colorFilter: ColorFilter.mode(
                            Color(0xFF4ECDC4),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 6.w),

                  // Bookmark button
                  GestureDetector(
                    onTap: () => _toggleWordBookmark(word),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? Color(0x3D2989E9)
                            : Color(0xFFF3F4F6),
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
                                : Color(0xFF9CA3AF),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Translation and category on second line
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translation,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                      color: MyColors.textSecondary,
                    ),
                  ),
                  if (word.categoryName != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      word.categoryName!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF4ECDC4),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        // Progress bar at the bottom of the card
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: 3.h,
          margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 16.h),
          decoration: BoxDecoration(
            color: isPlaying ? Color(0xFF4ECDC4) : Colors.transparent,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }
}
