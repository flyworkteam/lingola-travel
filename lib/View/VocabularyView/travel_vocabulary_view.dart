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
      true; // ✅ DEFAULT: Words (Kelimeler) - changed from false to true
  String _selectedCategory = 'All Topics';
  final TextEditingController _searchController = TextEditingController();
  Set<String> _bookmarkedItems = {}; // Will be loaded from backend
  bool _isLoadingCategory = false; // Prevent rapid category changes
  int _categoryRequestId =
      0; // Track category selection requests to prevent race conditions
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

    // Get TTS service singleton and initialize it
    _ttsService = TtsService();
    _ttsService
        .init()
        .then((_) {
          print('✅ TTS initialized in travel_vocabulary_view');
        })
        .catchError((e) {
          print('⚠️ Error initializing TTS: $e');
        });

    // ✅ CRITICAL: Stop TTS immediately, non-blocking (fire and forget)
    // Don't use microtask or await - just stop and move on
    _ttsService.stop().catchError((e) {
      print('⚠️ Error stopping TTS in initState: $e');
    });

    // Setup audio completion listener with ULTRA SAFE mounted checks
    _audioCompletionSubscription = _audioPlayer.onPlayerComplete.listen((
      event,
    ) {
      // DOUBLE CHECK: both mounted AND subscription is not null
      if (mounted && _audioCompletionSubscription != null) {
        try {
          setState(() {
            _playingItemId = null;
          });
        } catch (e) {
          print('⚠️ setState in audio completion failed: $e');
        }
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

  // 🚀 ULTRA FAST initialization - NO DELAYS, NON-BLOCKING
  void _simpleInit() {
    if (!mounted || _isInitialized) {
      print('❌ Already initialized or widget not mounted');
      return;
    }

    print('🚀 ULTRA Simple init BULLETPROOF (NO DELAYS)');

    try {
      // Dictionary categories already loaded by parent
      print('✅ Dictionary categories already loaded by parent');

      // ✅ CRITICAL: NO DELAYS! Load immediately
      if (widget.initialCategory != null) {
        print('🎯 Filtering by category: ${widget.initialCategory}');
        // ✅ Load words for selected category (since _isShowingWords = true by default)
        _loadWords(widget.initialCategory);
      } else {
        print('🔄 Generic vocab init - Loading All Topics');
        // ✅ Load All Topics for both Words and Phrases
        _loadWords(null); // null = All Topics for Words
        ref
            .read(travelVocabularyControllerProvider.notifier)
            .init(); // All Topics for Phrases
      }

      // ✅ CRITICAL: Load bookmarks in TRULY async way - fire and forget
      // Don't await, don't block UI, just start loading in background
      _loadBookmarkedItemsAsync();

      _isInitialized = true;
      print('✅ Init completed successfully (bookmarks loading in background)');
    } catch (e, stackTrace) {
      print('❌ FATAL init error: $e');
      print('📍 Stack: $stackTrace');
    }
  }

  // 🚀 Load bookmarks TRULY async - fire and forget, non-blocking
  void _loadBookmarkedItemsAsync() {
    // Background task - don't await, don't block
    Future(() async {
      if (!mounted) return;

      try {
        final repository = LibraryRepository();
        final allBookmarkedIds = <String>{};

        // Get all folders
        final foldersResponse = await repository.getFolders();
        if (!mounted) return;

        if (foldersResponse.success && foldersResponse.data != null) {
          // ✅ CRITICAL FIX: Load ALL folders in PARALLEL instead of sequential
          final futures = foldersResponse.data!.map((folder) async {
            try {
              final itemsResponse = await repository.getFolderItems(
                folderId: folder.id,
                limit: 100,
              );

              if (itemsResponse.success && itemsResponse.data != null) {
                return itemsResponse.data!.map((item) => item.itemId).toList();
              }
            } catch (e) {
              print('⚠️ Error loading folder ${folder.id}: $e');
            }
            return <String>[];
          }).toList();

          // Wait for ALL folders to load in parallel (much faster!)
          final results = await Future.wait(futures);

          if (!mounted) return;

          // Merge all results
          for (final ids in results) {
            allBookmarkedIds.addAll(ids);
          }

          // Update UI only once
          if (mounted) {
            setState(() {
              _bookmarkedItems = allBookmarkedIds;
            });
            print(
              '📚 Loaded ${_bookmarkedItems.length} bookmarked items (parallel loading)',
            );
          }
        }
      } catch (e) {
        print('❌ Error loading bookmarks: $e');
        // Silently fail - bookmarks are not critical
      }
    });
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

      // ✅ All Topics seçiliyse tüm kategoriler için kelime yükle
      if (categoryName == null || categoryName == 'All Topics') {
        final dictionaryState = ref.read(dictionaryControllerProvider);
        final allWords = <dynamic>[];

        // Her kategori için kelime yükle
        for (var category in dictionaryState.categories) {
          final response = await repository.getWordsByCategory(
            categoryId: category.id,
            limit: 12, // Her kategoriden 12 kelime
          );

          if (response.success && response.data != null) {
            allWords.addAll(response.data!);
          }
        }

        if (!mounted) return;
        setState(() {
          _words = allWords;
          _isLoadingWords = false;
        });
        return;
      }

      // Belirli bir kategori seçiliyse
      String? categoryId;
      final dictionaryState = ref.read(dictionaryControllerProvider);
      final category = dictionaryState.categories.firstWhere(
        (cat) => cat.name == categoryName,
        orElse: () => dictionaryState.categories.first,
      );
      categoryId = category.id;

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

  // Category selection handler - RACE-CONDITION SAFE with REQUEST ID
  void _onCategorySelected(String categoryName) async {
    if (!mounted || _isLoadingCategory) {
      print('⏳ Already loading or widget disposed');
      return;
    }

    // Generate unique request ID to track this specific selection
    final requestId = ++_categoryRequestId;
    print('📂 Selecting category: $categoryName (requestId: $requestId)');

    setState(() {
      _isLoadingCategory = true;
      _selectedCategory = categoryName;
      _playingItemId = null;
    });

    // ✅ Stop audio BEFORE async operations (fire-and-forget, non-blocking)
    _audioPlayer.stop().catchError((e) => print('⚠️ Audio stop error: $e'));
    _ttsService.stop().catchError((e) => print('⚠️ TTS stop error: $e'));

    try {
      // ✅ NO DELAY! Check immediately
      if (!mounted || requestId != _categoryRequestId) {
        print(
          '⏭️ Ignoring old category request $requestId (current: $_categoryRequestId)',
        );
        return;
      }

      // Load content with timeout protection
      await Future.any([
        Future(() async {
          if (_isShowingWords) {
            await _loadWords(
              categoryName == 'All Topics' ? null : categoryName,
            );
          } else {
            if (categoryName == 'All Topics') {
              await ref
                  .read(travelVocabularyControllerProvider.notifier)
                  .init();
            } else {
              await ref
                  .read(travelVocabularyControllerProvider.notifier)
                  .filterByCategory(categoryName);
            }
          }
        }),
        Future.delayed(Duration(seconds: 10), () {
          throw TimeoutException('Category loading timeout');
        }),
      ]);

      // After loading, check if this is still the current request
      if (!mounted || requestId != _categoryRequestId) {
        print(
          '⏭️ Ignoring old category result $requestId (current: $_categoryRequestId)',
        );
        return;
      }
    } on TimeoutException catch (e) {
      print('⏱️ Category selection timeout: $e');
      if (mounted && requestId == _categoryRequestId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loading timeout. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Category selection error: $e');
    } finally {
      // Only reset loading flag if this is still the current request
      if (mounted && requestId == _categoryRequestId) {
        setState(() {
          _isLoadingCategory = false;
        });
      }
    }
  }

  @override
  void deactivate() {
    // Called when widget is removed from tree but might be reinserted
    // Stop audio BEFORE dispose
    print('🔄 TravelVocabularyView deactivating...');

    // ✅ Fire-and-forget - don't block deactivate lifecycle
    _audioPlayer.stop().catchError((e) {
      print('⚠️ AudioPlayer stop error in deactivate: $e');
    });

    _ttsService.stop().catchError((e) {
      print('⚠️ TTS stop error in deactivate: $e');
    });

    _playingItemId = null;

    super.deactivate();
  }

  @override
  void dispose() {
    print('🗑️ TravelVocabularyView disposing SAFELY...');

    // Invalidate any pending category requests
    _categoryRequestId = -1;

    // CRITICAL: Cancel subscription FIRST before any setState can happen
    try {
      _audioCompletionSubscription?.cancel();
      _audioCompletionSubscription = null;
    } catch (e) {
      print('⚠️ Subscription cancel error: $e');
    }

    // Clear playing state
    _playingItemId = null;

    // Reset initialization flag
    _isInitialized = false;

    // ✅ Stop audio WITHOUT await (fire-and-forget to prevent blocking dispose)
    _audioPlayer.stop().catchError((e) {
      print('⚠️ AudioPlayer stop error: $e');
    });

    // ✅ Stop TTS WITHOUT await (fire-and-forget)
    _ttsService.stop().catchError((e) {
      print('⚠️ TTS stop error: $e');
    });

    // Dispose controllers
    try {
      _searchController.dispose();
    } catch (e) {
      print('⚠️ SearchController dispose error: $e');
    }

    // Finally dispose audio player
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
    // ULTRA safe checks - also check if subscription exists
    if (!mounted || _audioCompletionSubscription == null) {
      print('❌ Widget not mounted or disposed, skipping audio');
      return;
    }

    print('🔊 Playing audio for: $itemId');

    try {
      // If already playing this item, stop it
      if (_playingItemId == itemId) {
        print('⏹️ Stopping current audio');
        try {
          await _audioPlayer.stop();
          await _ttsService.stop();
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
        await _audioPlayer.stop();
        await _ttsService.stop();
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
          await _audioPlayer.play(UrlSource(audioUrl));
        } catch (e) {
          print('❌ Audio player error: $e');
          if (mounted) {
            setState(() {
              _playingItemId = null;
            });
          }
        }
      } else {
        print('🔊 Using TTS for: $translation');
        try {
          // TTS with mounted check - don't await to prevent UI blocking
          if (mounted) {
            // Fire and forget - TTS will complete in background
            _ttsService
                .speak(translation, languageCode: targetLanguage)
                .then((_) {
                  print('✅ TTS completed for: $translation');
                })
                .catchError((e) {
                  print('❌ TTS error in callback: $e');
                });
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
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // Don't use async here - just trigger cleanup
        // Audio is already stopped in deactivate()
        print('🔙 Pop invoked, didPop: $didPop');
      },
      child: Scaffold(
        backgroundColor: MyColors.white, // Consistent white background
        appBar: _buildAppBar(),
        body: SafeArea(
          bottom: false,
          child: Stack(
            key: ValueKey(
              'travel_vocab_stack_${widget.initialCategory}',
            ), // Unique key to force rebuild
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
              CustomBottomNavBar(
                key: ValueKey('bottom_nav_travel_vocab'), // Unique key
                currentIndex: 1,
                isPremium: widget.isPremium,
              ),
            ],
          ),
        ),
      ),
    ); // PopScope child end
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
        onPressed: () {
          // Audio will be stopped in deactivate() automatically
          // Just navigate back without blocking operations
          if (mounted) {
            Navigator.pop(context);
          }
        },
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

                  // ✅ NO DELAY! Load immediately
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

                  // ✅ NO DELAY! Load immediately
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

    // ✅ All Topics seçiliyse kategorilere göre gruplandır
    if (_selectedCategory == 'All Topics') {
      // Kelimeleri kategoriye göre grupla
      final Map<String, List<dynamic>> groupedWords = {};
      for (var word in _words) {
        final categoryId = word.categoryId ?? 'unknown';
        if (!groupedWords.containsKey(categoryId)) {
          groupedWords[categoryId] = [];
        }
        groupedWords[categoryId]!.add(word);
      }

      // Kategori bilgilerini al
      final dictionaryState = ref.read(dictionaryControllerProvider);

      return ListView.builder(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
        itemCount: groupedWords.length,
        itemBuilder: (context, index) {
          final categoryId = groupedWords.keys.elementAt(index);
          final categoryWords = groupedWords[categoryId]!;

          // Kategori bilgisini bul
          final category = dictionaryState.categories.firstWhere(
            (cat) => cat.id == categoryId,
            orElse: () => dictionaryState.categories.first,
          );

          return _buildCategoryGroup(
            categoryName: category.name,
            iconPath: category.iconPath,
            words: categoryWords,
            isWords: true,
          );
        },
      );
    }

    // ✅ Belirli kategori seçiliyse düz liste
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
              // Target language word - BOLD (on top)
              Text(
                // For English: word is target, translation is Turkish
                // For others: translation is target, word is Turkish
                word.targetLanguage == 'en' ? word.word : word.translation,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),

              SizedBox(height: 8.h),

              // Turkish translation (below)
              Text(
                word.targetLanguage == 'en' ? word.translation : word.word,
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
                      // Speak target language word
                      word.targetLanguage == 'en'
                          ? word.word
                          : word.translation,
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

  /// Category group widget - Kategorilere göre gruplandırılmış kelime/cümle gösterimi
  Widget _buildCategoryGroup({
    required String categoryName,
    required String iconPath,
    required List<dynamic> words,
    required bool isWords,
  }) {
    // İlk 3 item göster, geri kalanını "Load More" ile
    final displayCount = words.length > 3 ? 3 : words.length;
    final hasMore = words.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori başlığı
        Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
          child: Row(
            children: [
              // Icon
              Image.asset(
                iconPath,
                width: 24.w,
                height: 24.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.category, size: 24.w);
                },
              ),
              SizedBox(width: 12.w),
              // Category name
              Text(
                categoryName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),
              Spacer(),
              // Word count
              Text(
                '${words.length} ${isWords ? "Words" : "Phrases"}',
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

        // İlk 3 item
        ...words.take(displayCount).map((item) {
          return isWords
              ? _buildDynamicWordCard(item)
              : _buildDynamicPhraseCard(item);
        }).toList(),

        // Load More butonu (varsa)
        if (hasMore)
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
            child: Center(
              child: TextButton(
                onPressed: () {
                  // Kategoriye göre filtrele
                  _onCategorySelected(categoryName);
                },
                child: Text(
                  '+ Load More',
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

    // ✅ All Topics seçiliyse kategorilere göre gruplandır
    if (_selectedCategory == 'All Topics') {
      // Cümleleri kategoriye göre grupla
      final Map<String, List<dynamic>> groupedPhrases = {};
      for (var phrase in phrases) {
        final category = phrase.category;
        if (!groupedPhrases.containsKey(category)) {
          groupedPhrases[category] = [];
        }
        groupedPhrases[category]!.add(phrase);
      }

      // Kategori bilgilerini al
      final dictionaryState = ref.read(dictionaryControllerProvider);

      return ListView.builder(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
        itemCount: groupedPhrases.length,
        itemBuilder: (context, index) {
          final categoryName = groupedPhrases.keys.elementAt(index);
          final categoryPhrases = groupedPhrases[categoryName]!;

          // Kategori bilgisini bul
          final category = dictionaryState.categories.firstWhere(
            (cat) => cat.name == categoryName,
            orElse: () => dictionaryState.categories.first,
          );

          return _buildCategoryGroup(
            categoryName: category.name,
            iconPath: category.iconPath,
            words: categoryPhrases,
            isWords: false,
          );
        },
      );
    }

    // ✅ Belirli kategori seçiliyse düz liste
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
              // Target language phrase - BOLD (on top)
              Text(
                // For English: englishText is target, translation is Turkish
                // For others: translation is target, englishText is Turkish
                phrase.targetLanguage == 'en'
                    ? phrase.englishText
                    : phrase.translation,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: MyColors.textPrimary,
                ),
              ),

              SizedBox(height: 8.h),

              // Turkish translation (below)
              Text(
                phrase.targetLanguage == 'en'
                    ? phrase.translation
                    : phrase.englishText,
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
                      // Speak target language phrase
                      phrase.targetLanguage == 'en'
                          ? phrase.englishText
                          : phrase.translation,
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
