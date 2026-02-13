import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import '../../Riverpod/Controllers/travel_vocabulary_controller.dart';
import '../../Riverpod/Controllers/dictionary_controller.dart';
import '../../Models/dictionary_model.dart';

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
  int _selectedTab = 0; // 0: Words, 1: Phrases - MODIFIED: Start with Words
  String _selectedCategory = 'All Topics';
  final TextEditingController _searchController = TextEditingController();
  Set<String> _bookmarkedItems = {};

  @override
  void initState() {
    super.initState();

    // Set initial category if provided
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }

    // Initialize controllers
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(dictionaryControllerProvider.notifier).init(); // Categories için

      // Load phrases with initial category filter
      if (widget.initialCategory != null) {
        ref
            .read(travelVocabularyControllerProvider.notifier)
            .filterByCategory(widget.initialCategory);
      } else {
        ref
            .read(travelVocabularyControllerProvider.notifier)
            .init(); // Phrases için
      }
    });
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

  // Category selection handler
  void _onCategorySelected(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
    });

    // Load everything for selected category (Words & Phrases)
    ref
        .read(travelVocabularyControllerProvider.notifier)
        .filterByCategory(categoryName);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleBookmark(String id) {
    setState(() {
      if (_bookmarkedItems.contains(id)) {
        _bookmarkedItems.remove(id);
      } else {
        _bookmarkedItems.add(id);
      }
    });
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

                SizedBox(height: 16.h),

                // Tab switcher
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

  /// Tab switcher (Words/Phrases)
  Widget _buildTabSwitcher() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5), // Gray background for container
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(child: _buildTabButton('Words', 0)),
            Expanded(child: _buildTabButton('Phrases', 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
        // Tab değişince datayı yenile
        _onCategorySelected(_selectedCategory);
      },
      child: Container(
        margin: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected ? MyColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              color: isSelected ? Color(0xFF4ECDC4) : MyColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  /// Category filters
  Widget _buildCategoryFilters() {
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

  /// Content (Words or Phrases) - DİNAMİK!
  Widget _buildContent() {
    if (_selectedTab == 0) {
      // Words tab - TODO: Words için de backend endpoint'i eklenecek
      return _buildWordsContent();
    } else {
      // Phrases tab - Backend'den geliyor! 🚀
      return _buildPhrasesContent();
    }
  }

  /// Words content (placeholder for now)
  Widget _buildWordsContent() {
    final vocabularyState = ref.watch(travelVocabularyControllerProvider);

    if (vocabularyState.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final words = vocabularyState.words;

    if (words.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64.r, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                "No words found in this category",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return _buildWordListItem(word);
      },
    );
  }

  /// Word list item widget
  Widget _buildWordListItem(DictionaryWordModel word) {
    final isBookmarked = _bookmarkedItems.contains(word.id);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Row(
        children: [
          // Play sound button
          GestureDetector(
            onTap: () {
              // TODO: Sound logic
            },
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Color(0x3D4ECDC4),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  'assets/icons/travelvocabularyseslendirme.svg',
                  width: 20.w,
                  height: 18.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),

          // Word and translation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.word,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  word.translation,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Bookmark button
          GestureDetector(
            onTap: () => _toggleBookmark(word.id),
            child: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked
                  ? Color(0xFF2989E9)
                  : Colors.grey.withOpacity(0.5),
            ),
          ),
        ],
      ),
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

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          // English text (question/statement)
          Text(
            phrase.englishText,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              color: MyColors.textPrimary,
            ),
          ),

          SizedBox(height: 8.h),

          // Translation
          Text(
            phrase.translation,
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
            children: [
              // Category tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  phrase.category,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: MyColors.textSecondary,
                  ),
                ),
              ),

              Spacer(),

              // Play button
              GestureDetector(
                onTap: () {
                  // TODO: Audio oynatma fonksiyonu
                },
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Color(0x3D4ECDC4),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/travelvocabularyseslendirme.svg',
                      width: 20.w,
                      height: 18.h,
                    ),
                  ),
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
                        ? Color(0x3D2989E9)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/travelvocabularykaydet.svg',
                      width: 20.w,
                      height: 20.h,
                      colorFilter: ColorFilter.mode(
                        isBookmarked
                            ? const Color(0xFF2989E9)
                            : const Color(0xFF9E9E9E).withOpacity(0.5),
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
    );
  }
}
