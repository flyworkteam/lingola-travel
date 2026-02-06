import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'dictionary_category_view.dart';

class VisualDictionaryView extends StatefulWidget {
  final bool isPremium;
  const VisualDictionaryView({super.key, this.isPremium = false});

  @override
  State<VisualDictionaryView> createState() => _VisualDictionaryViewState();
}

class _VisualDictionaryViewState extends State<VisualDictionaryView> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = ['Accommodation', 'Airport'];

  // Categories data - using getter to avoid initializer issues
  List<Map<String, dynamic>> get _categories => [
    {
      'name': 'Airport',
      'items': 1240,
      'icon': 'assets/icons/airport.png',
      'color': Color(0xFF2E48F0).withOpacity(0.2),
    },
    {
      'name': 'Accommodation',
      'items': 1000,
      'icon': 'assets/icons/accommodation.png',
      'color': Color(0xFFF0722E).withOpacity(0.2),
    },
    {
      'name': 'Transportation',
      'items': 980,
      'icon': 'assets/icons/transportation.png',
      'color': Color(0xFFF0CC2E).withOpacity(0.2),
    },
    {
      'name': 'Food & Drink',
      'items': 1250,
      'icon': 'assets/icons/food_drink.png',
      'color': Color(0xFFF02E2E).withOpacity(0.2),
    },
    {
      'name': 'Shopping',
      'items': 1520,
      'icon': 'assets/icons/shopping.png',
      'color': Color(0xFF8BD99D).withOpacity(0.2),
    },
    {
      'name': 'Culture',
      'items': 550,
      'icon': 'assets/icons/culture.png',
      'color': Color(0xFF70CDBB).withOpacity(0.2),
    },
    {
      'name': 'Meeting',
      'items': 1520,
      'icon': 'assets/icons/meeting.png',
      'color': Color(0xFFFDB0B0).withOpacity(0.2),
    },
    {
      'name': 'Sport',
      'items': 1550,
      'icon': 'assets/icons/sport.png',
      'color': Color(0xFFFCD5F0),
    },
    {
      'name': 'Health',
      'items': 1520,
      'icon': 'assets/icons/health.png',
      'color': Color(0xFF86E17C).withOpacity(0.3),
    },
    {
      'name': 'Business',
      'items': 1550,
      'icon': 'assets/icons/business.png',
      'color': Color(0xFF53BAF5).withOpacity(0.25),
    },
  ];

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

  void _navigateToCategory(String categoryName) {
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
        children: [
          // Main content
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
                      // Category grid
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

  /// Category grid
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
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  /// Category card
  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => _navigateToCategory(category['name']),
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
                color: category['color'],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Image.asset(
                  category['icon'],
                  width: 20.w,
                  height: 20.h,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high, // HD quality
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
                    '${category['items']} items',
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
