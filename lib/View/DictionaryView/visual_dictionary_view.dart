import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
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

  // STATIC categories - matching database content
  final List<Map<String, dynamic>> _staticCategories = [
    {
      'id': 'dict-cat-011',
      'name': 'Airport', // NEW: Airport-specific category
      'icon': 'assets/icons/airport.png',
      'color': '#B8A7FF',
      'count': 10,
    },
    {
      'id': 'dict-cat-002',
      'name': 'Accommodation',
      'icon': 'assets/icons/accommodation.png',
      'color': '#FF9F6A',
      'count': 10,
    },
    {
      'id': 'dict-cat-003',
      'name': 'Transportation',
      'icon': 'assets/icons/transportation.png',
      'color': '#F9D26B',
      'count': 10,
    },
    {
      'id': 'dict-cat-004',
      'name': 'Food & Drink',
      'icon': 'assets/icons/food_drink.png',
      'color': '#FF8FA5',
      'count': 10,
    },
    {
      'id': 'dict-cat-005',
      'name': 'Shopping',
      'icon': 'assets/icons/shopping.png',
      'color': '#8BDDCD',
      'count': 10,
    },
    {
      'id': 'dict-cat-006',
      'name': 'Culture',
      'icon': 'assets/icons/culture.png',
      'color': '#B8D9FF',
      'count': 10,
    },
    {
      'id': 'dict-cat-007',
      'name': 'Meeting',
      'icon': 'assets/icons/meeting.png',
      'color': '#FFB8B8',
      'count': 10,
    },
    {
      'id': 'dict-cat-008',
      'name': 'Sport',
      'icon': 'assets/icons/sport.png',
      'color': '#E4B3FF',
      'count': 10,
    },
    {
      'id': 'dict-cat-009',
      'name': 'Health',
      'icon': 'assets/icons/health.png',
      'color': '#B8FFC9',
      'count': 10,
    },
    {
      'id': 'dict-cat-010',
      'name': 'Business',
      'icon': 'assets/icons/business.png',
      'color': '#A4C8E1',
      'count': 10,
    },
  ];

  @override
  void initState() {
    super.initState();
    // NO backend loading - fully static
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      appBar: _buildAppBar(),
      body: Stack(
        key: ValueKey('visual_dictionary_stack'), // Unique key to force rebuild
        children: [
          // Main content - STATIC, no loading state
          Column(
            children: [
              SizedBox(height: 16.h),

              // Search bar
              _buildSearchBar(),

              SizedBox(height: 24.h),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category grid - STATIC categories
                      _buildCategoryGrid(),

                      SizedBox(height: 16.h),

                      // Recent Search
                      if (_recentSearches.isNotEmpty) _buildRecentSearch(),

                      SizedBox(height: 100.h), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating bottom navigation
          CustomBottomNavBar(
            key: ValueKey('bottom_nav_dictionary'), // Unique key
            currentIndex: 2,
            isPremium: widget.isPremium,
          ),
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
        'Visual Dictionary',
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
        ),
      ),
    );
  }

  /// Category grid - STATIC
  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.1,
      ),
      itemCount: _staticCategories.length,
      itemBuilder: (context, index) {
        final category = _staticCategories[index];
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
                    '${category['count']} items',
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
              'Recent Search',
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
                'Clear',
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
          // Clock icon
          Icon(Icons.history, size: 24.sp, color: MyColors.textSecondary),

          SizedBox(width: 12.w),

          // Category name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                  ),
                ),
                Text(
                  'Recent item',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Audio button
          GestureDetector(
            onTap: () {
              print('Play audio: $categoryName');
            },
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Color(0xFF4ECDC4).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volume_up,
                color: Color(0xFF4ECDC4),
                size: 20.sp,
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Bookmark button
          Icon(
            Icons.bookmark_border,
            color: MyColors.textSecondary,
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}
