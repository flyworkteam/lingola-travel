import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import '../../Riverpod/Controllers/visual_dictionary_words_controller.dart';

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

  @override
  void initState() {
    super.initState();
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
      return {'english': word.word, 'turkish': word.translation};
    }).toList();
  }

  int get _itemCount {
    final wordsState = ref.watch(
      visualDictionaryWordsControllerProvider(widget.categoryId),
    );
    return wordsState.words.length;
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
    final wordsState = ref.watch(
      visualDictionaryWordsControllerProvider(widget.categoryId),
    );

    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Main content
          wordsState.isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
                )
              : wordsState.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
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
              : Column(
                  children: [
                    SizedBox(height: 16.h),

                    // Search bar
                    _buildSearchBar(),

                    SizedBox(height: 16.h),

                    // Item count
                    _buildItemCount(),

                    SizedBox(height: 16.h),

                    // Word list
                    Expanded(child: _buildWordList()),

                    SizedBox(height: 100.h), // Space for bottom nav
                  ],
                ),

          // Floating bottom navigation
          CustomBottomNavBar(currentIndex: 2, isPremium: widget.isPremium),
        ],
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
        widget.categoryName,
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

  /// Item count
  Widget _buildItemCount() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Align(
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
      ),
    );
  }

  /// Word list
  Widget _buildWordList() {
    return ListView.builder(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
      itemCount: _words.length,
      itemBuilder: (context, index) {
        final word = _words[index];
        final wordId = '${widget.categoryName}-$index';
        return _buildWordCard(word, wordId);
      },
    );
  }

  /// Word card
  Widget _buildWordCard(Map<String, String> word, String id) {
    final isBookmarked = _bookmarkedItems.contains(id);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
                  word['english']!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  word['turkish']!,
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
              print('Play audio: ${word['english']}');
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
                    ? Color(0xFF4ECDC4).withOpacity(0.2)
                    : Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/visualdictionarysaved.svg',
                  width: 11.w,
                  height: 13.h,
                  colorFilter: ColorFilter.mode(
                    isBookmarked ? Color(0xFF4ECDC4) : Color(0xFFCBD5E1),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
