import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../../Riverpod/Controllers/travel_vocabulary_controller.dart';
import '../../Riverpod/Controllers/dictionary_controller.dart';
import '../../Riverpod/Controllers/library_controller.dart';
import '../../Repositories/library_repository.dart';
import '../../Repositories/dictionary_repository.dart';
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
  bool _isShowingWords =
      false; // false = Phrases (Cümleler), true = Words (Kelimeler)
  String _selectedCategory = 'All Topics';
  final TextEditingController _searchController = TextEditingController();
  Set<String> _bookmarkedItems = {}; // Will be loaded from backend
  bool _isLoadingCategory = false; // Prevent rapid category changes
  bool _isInitialized = false; // Track if initialization completed

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingItemId;
  StreamSubscription? _audioCompletionSubscription;
  late TtsService _ttsService;

  // Words state (local)
  bool _isLoadingWords = false;
  List<dynamic> _words = [];
  String? _wordsError;

  @override
  void initState() {
    super.initState();

    // Get TTS service singleton (will auto-initialize on first speak() call)
    _ttsService = TtsService();

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

    // Set initial category if provided
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }

    // SIMPLER initialization - less complex async handling
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _simpleInit();
    });
  }

  // ULTRA SIMPLE initialization - BULLETPROOF VERSION
  void _simpleInit() {
    if (!mounted || _isInitialized) {
      print('❌ Already initialized or widget not mounted');
      return;
    }

    print('🚀 ULTRA Simple init BULLETPROOF');

    try {
      // Load categories (async, don't wait) - with error handling
      try {
        ref.read(dictionaryControllerProvider.notifier).init();
        print('✅ Dictionary controller init called');
      } catch (e) {
        print('❌ Dictionary init error: $e');
      }

      // Load phrases with delay and ultra safe checks
      Future.delayed(Duration(milliseconds: 300), () {
        if (!mounted) {
          print('❌ Widget disposed during delayed init');
          return;
        }

        try {
          if (widget.initialCategory != null) {
            print('🎯 Filtering by category: ${widget.initialCategory}');
            ref
                .read(travelVocabularyControllerProvider.notifier)
                .filterByCategory(widget.initialCategory);
          } else {
            print('🔄 Generic vocab init');
            ref.read(travelVocabularyControllerProvider.notifier).init();
          }

          // Load bookmarks safely
          try {
            _loadBookmarkedItems();
          } catch (e) {
            print('❌ Bookmark loading error: $e');
          }

          _isInitialized = true;
          print('✅ Init completed successfully');
        } catch (e, stackTrace) {
          print('❌ CRITICAL delayed init error: $e');
          print('📍 Stack: $stackTrace');
        }
      });
    } catch (e, stackTrace) {
      print('❌ FATAL init error: $e');
      print('📍 Stack: $stackTrace');
    }
  }

  // Load all bookmarked item IDs from backend
  Future<void> _loadBookmarkedItems() async {
    try {
      final repository = LibraryRepository();
      final allBookmarkedIds = <String>{};

      // Get all folders
      final foldersResponse = await repository.getFolders();
      if (foldersResponse.success && foldersResponse.data != null) {
        // For each folder, get items
        for (final folder in foldersResponse.data!) {
          final itemsResponse = await repository.getFolderItems(
            folderId: folder.id,
            limit: 1000,
          );

          if (itemsResponse.success && itemsResponse.data != null) {
            // Add item IDs to set
            for (final item in itemsResponse.data!) {
              allBookmarkedIds.add(item.itemId);
            }
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _bookmarkedItems = allBookmarkedIds;
      });

      print(
        '📚 Loaded ${_bookmarkedItems.length} bookmarked items from backend',
      );
    } catch (e) {
      print('❌ Error loading bookmarks: $e');
    }
  }

  // Load words by category from backend
  Future<void> _loadWords(String? categoryName) async {
    if (!mounted) return;

    setState(() {
      _isLoadingWords = true;
      _wordsError = null;
    });

    try {
      final repository = DictionaryRepository();

      // Get category ID if specific category selected
      String? categoryId;
      if (categoryName != null && categoryName != 'All Topics') {
        final dictionaryState = ref.read(dictionaryControllerProvider);
        final category = dictionaryState.categories.firstWhere(
          (cat) => cat.name == categoryName,
          orElse: () => dictionaryState.categories.first,
        );
        categoryId = category.id;
      }

      // If no specific category (All Topics), show message
      if (categoryId == null) {
        if (!mounted) return;
        setState(() {
          _words = [];
          _isLoadingWords = false;
        });
        return;
      }

      final response = await repository.getWordsByCategory(
        categoryId: categoryId,
        limit: 100,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _words = response.data!;
          _isLoadingWords = false;
        });
      } else {
        setState(() {
          _wordsError = response.error?.message ?? 'Failed to load words';
          _isLoadingWords = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _wordsError = 'Network error: ${e.toString()}';
        _isLoadingWords = false;
      });
    }
  }

  // Categories - DİNAMİK! Backend'den geliyor + All Topics ekliyoruz
  List<Map<String, dynamic>> get _categories {
    final dictionaryState = ref.watch(dictionaryControllerProvider);

    final allTopicsCategory = {'name': 'All Topics'};

    if (dictionaryState.categories.isNotEmpty) {
      final backendCategories = dictionaryState.categories.map((category) {
        return {'name': category.name};
      }).toList();

      return [allTopicsCategory, ...backendCategories];
    }

    // Fallback: Loading durumunda default kategoriler
    return [allTopicsCategory];
  }

  // Category selection handler - SIMPLIFIED
  void _onCategorySelected(String categoryName) async {
    if (!mounted || _isLoadingCategory) return;

    print('📂 Selecting category: $categoryName');

    setState(() {
      _isLoadingCategory = true;
      _selectedCategory = categoryName;
      _playingItemId = null;
    });

    try {
      // Stop audio first
      _audioPlayer.stop();
      _ttsService.stop();

      // Small delay
      await Future.delayed(Duration(milliseconds: 100));

      if (!mounted) return;

      // Load content
      if (_isShowingWords) {
        _loadWords(categoryName == 'All Topics' ? null : categoryName);
      } else {
        if (categoryName == 'All Topics') {
          ref.read(travelVocabularyControllerProvider.notifier).init();
        } else {
          ref
              .read(travelVocabularyControllerProvider.notifier)
              .filterByCategory(categoryName);
        }
      }
    } catch (e) {
      print('❌ Category selection error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategory = false;
        });
      }
    }
  }

  @override
  void dispose() {
    print('🗑️ TravelVocabularyView disposing SAFELY...');

    try {
      // Stop all audio FIRST
      _audioPlayer.stop();
    } catch (e) {
      print('⚠️ AudioPlayer dispose error: $e');
    }

    try {
      _ttsService.stop();
    } catch (e) {
      print('⚠️ TTS dispose error: $e');
    }

    try {
      _searchController.dispose();
    } catch (e) {
      print('⚠️ SearchController dispose error: $e');
    }

    try {
      _audioCompletionSubscription?.cancel();
    } catch (e) {
      print('⚠️ Subscription dispose error: $e');
    }

    try {
      _audioPlayer.dispose();
    } catch (e) {
      print('⚠️ AudioPlayer dispose error: $e');
    }

    super.dispose();
    print('✅ TravelVocabularyView disposed successfully');
  }

  // Play audio for word or phrase using TTS or audio URL - BULLETPROOF
  Future<void> _playAudio(
    String itemId,
    String? audioUrl,
    String translation,
    String? targetLanguage,
  ) async {
    // ULTRA safe checks
    if (!mounted) {
      print('❌ Widget not mounted, skipping audio');
      return;
    }

    print('🔊 Playing audio for: $itemId');

    try {
      // If already playing this item, stop it
      if (_playingItemId == itemId) {
        print('⏹️ Stopping current audio');
        try {
          _audioPlayer.stop();
          _ttsService.stop();
        } catch (e) {
          print('⚠️ Error stopping: $e');
        }

        if (mounted) {
          setState(() {
            _playingItemId = null;
          });
        }
        return;
      }

      // Stop any current audio
      try {
        _audioPlayer.stop();
        _ttsService.stop();
      } catch (e) {
        print('⚠️ Error stopping previous: $e');
      }

      if (!mounted) return;

      // Start new audio
      setState(() {
        _playingItemId = itemId;
      });

      if (audioUrl != null && audioUrl.isNotEmpty) {
        print('🎵 Playing audio URL');
        try {
          _audioPlayer.play(UrlSource(audioUrl));
        } catch (e) {
          print('❌ Audio player error: $e');
          setState(() {
            _playingItemId = null;
          });
        }
      } else {
        print('🔊 Using TTS for: $translation');
        try {
          // TTS with mounted check
          if (mounted) {
            _ttsService.speak(translation, languageCode: targetLanguage);
          }
        } catch (e) {
          print('❌ TTS error: $e');
          if (mounted) {
            setState(() {
              _playingItemId = null;
            });
          }
          return;
        }

        // Reset after delay with mounted check
        Future.delayed(Duration(seconds: 3), () {
          if (mounted && _playingItemId == itemId) {
            setState(() {
              _playingItemId = null;
            });
          }
        });
      }
    } catch (e) {
      print('❌ CRITICAL Audio error: $e');
      if (mounted) {
        setState(() {
          _playingItemId = null;
        });
      }
    }
  }

  // Map category to folder ID
  String _getCategoryFolderId(String categoryName) {
    final categoryLower = categoryName.toLowerCase();

    // Simple mapping based on category keywords
    if (categoryLower.contains('airport') ||
        categoryLower.contains('havaalani')) {
      return 'folder-001'; // My Airport Essentials
    } else if (categoryLower.contains('hotel') ||
        categoryLower.contains('accommodation') ||
        categoryLower.contains('konaklama')) {
      return 'folder-002'; // My Hotel Essentials
    } else if (categoryLower.contains('transport') ||
        categoryLower.contains('ulaşım')) {
      return 'folder-003'; // Transport Essentials
    } else if (categoryLower.contains('food') ||
        categoryLower.contains('drink') ||
        categoryLower.contains('yemek')) {
      return 'folder-004'; // My Food Essentials
    } else if (categoryLower.contains('shopping') ||
        categoryLower.contains('alışveriş')) {
      return 'folder-005'; // My Shopping Essentials
    } else if (categoryLower.contains('culture') ||
        categoryLower.contains('kültür')) {
      return 'folder-006'; // Culture Essentials
    } else if (categoryLower.contains('meeting') ||
        categoryLower.contains('görüşme')) {
      return 'folder-007'; // Meeting Essentials
    } else if (categoryLower.contains('sport') ||
        categoryLower.contains('spor')) {
      return 'folder-008'; // Sport Essentials
    } else if (categoryLower.contains('health') ||
        categoryLower.contains('sağlık')) {
      return 'folder-009'; // Health Essentials
    } else if (categoryLower.contains('business') ||
        categoryLower.contains('iş')) {
      return 'folder-010'; // Business Essentials
    }

    // Default to Airport folder
    return 'folder-001';
  }

  void _toggleBookmark(
    String itemId, {
    String? itemType,
    String? category,
  }) async {
    final isCurrentlyBookmarked = _bookmarkedItems.contains(itemId);

    setState(() {
      if (isCurrentlyBookmarked) {
        _bookmarkedItems.remove(itemId);
      } else {
        _bookmarkedItems.add(itemId);
      }
    });

    // Save to backend library
    if (!isCurrentlyBookmarked) {
      try {
        final folderId = _getCategoryFolderId(category ?? _selectedCategory);
        final type =
            itemType ?? 'dictionary_word'; // Default to dictionary_word

        print('🔖 Saving to library:');
        print('   itemId: $itemId');
        print('   itemType: $type');
        print('   category: ${category ?? _selectedCategory}');
        print('   folderId: $folderId');

        final repository = LibraryRepository();
        final response = await repository.addItemToFolder(
          folderId: folderId,
          itemType: type,
          itemId: itemId,
        );

        print(
          '✅ Response: success=${response.success}, error=${response.error}',
        );

        if (response.success) {
          // Refresh library to update counts
          ref.read(libraryControllerProvider.notifier).loadFolders();
        }
      } catch (e) {
        print('❌ Error saving to library: $e');
        // Revert local state on error
        setState(() {
          _bookmarkedItems.remove(itemId);
        });

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Hata: $e'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white, // Consistent white background
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                SizedBox(height: 16.h), // Added spacing from AppBar
                // Search bar
                _buildSearchBar(),

                SizedBox(height: 20.h),

                // Word/Phrases toggle switch
                _buildTabSwitcher(),

                SizedBox(height: 20.h),

                // Category filters
                _buildCategoryFilters(),

                SizedBox(height: 20.h),

                // Content
                Expanded(child: _buildContent()),
              ],
            ),

            // Bottom Navigation Bar
            CustomBottomNavBar(currentIndex: 1, isPremium: widget.isPremium),
          ],
        ),
      ),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: MyColors.textPrimary, size: 24.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Travel Vocabulary',
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

  /// Search bar
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
            hintText: _isShowingWords ? 'Search words...' : 'Search phrases...',
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
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }

  /// Tab switcher - Words/Phrases toggle
  Widget _buildTabSwitcher() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            // Words tab
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (!mounted) return;

                  // Stop audio and TTS before switching
                  try {
                    await _audioPlayer.stop();
                    await _ttsService.stop();
                  } catch (e) {
                    print('Error stopping audio: $e');
                  }

                  if (!mounted) return;

                  setState(() {
                    _isShowingWords = true;
                    _playingItemId = null;
                  });

                  // Small delay
                  await Future.delayed(Duration(milliseconds: 50));

                  if (!mounted) return;

                  // Load words for selected category
                  _loadWords(
                    _selectedCategory == 'All Topics'
                        ? null
                        : _selectedCategory,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _isShowingWords ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      'Words',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: _isShowingWords
                            ? Color(0xFF4ECDC4)
                            : MyColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Phrases tab
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (!mounted) return;

                  // Stop audio and TTS before switching
                  try {
                    await _audioPlayer.stop();
                    await _ttsService.stop();
                  } catch (e) {
                    print('Error stopping audio: $e');
                  }

                  if (!mounted) return;

                  setState(() {
                    _isShowingWords = false;
                    _playingItemId = null;
                  });

                  // Small delay
                  await Future.delayed(Duration(milliseconds: 50));

                  if (!mounted) return;

                  // Load phrases for selected category
                  await ref
                      .read(travelVocabularyControllerProvider.notifier)
                      .filterByCategory(
                        _selectedCategory == 'All Topics'
                            ? null
                            : _selectedCategory,
                      );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: !_isShowingWords ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      'Phrases',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: !_isShowingWords
                            ? Color(0xFF4ECDC4)
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

  /// Category filters
  Widget _buildCategoryFilters() {
    final dictionaryState = ref.watch(dictionaryControllerProvider);

    // Show loading if categories are being loaded
    if (dictionaryState.isLoading) {
      return SizedBox(
        height: 44.h,
        child: Center(
          child: SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return SizedBox(
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['name'];

          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () => _onCategorySelected(category['name']),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF4ECDC4) : MyColors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: MyColors.border, width: 1),
                ),
                child: Center(
                  child: Text(
                    category['name'],
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

  /// Content - Conditional based on tab selection
  Widget _buildContent() {
    return _isShowingWords ? _buildWordsContent() : _buildPhrasesContent();
  }

  /// Words content - Backend'den geliyor! 🔥
  Widget _buildWordsContent() {
    if (_isLoadingWords) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_wordsError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $_wordsError',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  _loadWords(
                    _selectedCategory == 'All Topics'
                        ? null
                        : _selectedCategory,
                  );
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_words.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            'No words found for this category',
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

    return ListView.builder(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
      itemCount: _words.length,
      itemBuilder: (context, index) {
        final word = _words[index];
        return _buildDynamicWordCard(word);
      },
    );
  }

  /// Dynamic word card - Backend'den gelen kelimeler için! 🚀
  Widget _buildDynamicWordCard(dynamic word) {
    final id = word.id;
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target language word (translation) - BOLD
              Text(
                word.translation,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),

              SizedBox(height: 8.h),

              // Turkish word
              Text(
                word.word,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                  color: MyColors.textSecondary,
                ),
              ),

              SizedBox(height: 12.h),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Play button with container
                  GestureDetector(
                    onTap: () => _playAudio(
                      id,
                      word.audioUrl,
                      word.translation,
                      word.targetLanguage,
                    ),
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFE0F7F4),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/travelvocabularyseslendirme.svg',
                          width: 24.w,
                          height: 24.h,
                          colorFilter: ColorFilter.mode(
                            Color(0xFF4ECDC4),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Bookmark button
                  GestureDetector(
                    onTap: () => _toggleBookmark(
                      id,
                      itemType: 'dictionary_word',
                      category: _selectedCategory == 'All Topics'
                          ? 'General'
                          : _selectedCategory,
                    ),
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? Color(0x3D2989E9)
                            : Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/travelvocabularykaydet.svg',
                          width: 24.w,
                          height: 24.h,
                          colorFilter: ColorFilter.mode(
                            isBookmarked
                                ? const Color(0xFF2989E9)
                                : Color(0xFF4ECDC4),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Progress bar at the bottom of the card
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

  /// Phrases content - TAMAMEN DİNAMİK! Backend'den geliyor 🔥
  Widget _buildPhrasesContent() {
    final vocabularyState = ref.watch(travelVocabularyControllerProvider);

    if (vocabularyState.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (vocabularyState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: ${vocabularyState.errorMessage}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  ref.read(travelVocabularyControllerProvider.notifier).init();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final phrases = vocabularyState.phrases;

    if (phrases.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            'No phrases found for this category',
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

    return ListView.builder(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
      itemCount: phrases.length,
      itemBuilder: (context, index) {
        final phrase = phrases[index];
        return _buildDynamicPhraseCard(phrase);
      },
    );
  }

  /// Dynamic phrase card - Backend'den gelen veriler için! 🚀
  Widget _buildDynamicPhraseCard(dynamic phrase) {
    final id = phrase.id;
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target language phrase (translation) - BOLD
              Text(
                phrase.translation,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),

              SizedBox(height: 8.h),

              // Turkish phrase
              Text(
                phrase.englishText,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                  color: MyColors.textSecondary,
                ),
              ),

              SizedBox(height: 12.h),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Play button with container
                  GestureDetector(
                    onTap: () => _playAudio(
                      id,
                      phrase.audioUrl,
                      phrase.translation,
                      phrase.targetLanguage,
                    ),
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFE0F7F4),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/travelvocabularyseslendirme.svg',
                          width: 24.w,
                          height: 24.h,
                          colorFilter: ColorFilter.mode(
                            Color(0xFF4ECDC4),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Bookmark button
                  GestureDetector(
                    onTap: () => _toggleBookmark(
                      id,
                      itemType: 'travel_phrase',
                      category: phrase.category,
                    ),
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? Color(0x3D2989E9)
                            : Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/travelvocabularykaydet.svg',
                          width: 24.w,
                          height: 24.h,
                          colorFilter: ColorFilter.mode(
                            isBookmarked
                                ? const Color(0xFF2989E9)
                                : Color(0xFF4ECDC4),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Progress bar at the bottom of the card
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
