import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'dictionary_category_view.dart';

class VisualDictionaryView extends StatefulWidget {
  const VisualDictionaryView({super.key});

  @override
  State<VisualDictionaryView> createState() => _VisualDictionaryViewState();
}

class _VisualDictionaryViewState extends State<VisualDictionaryView> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedNavIndex = 2; // Dictionary is index 2
  List<String> _recentSearches = ['Accommodation', 'Airport'];

  // Categories data
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Airport', 'items': 1240, 'icon': '🛫', 'color': Color(0xFFE3F2FD)},
    {'name': 'Accommodation', 'items': 1000, 'icon': '🏨', 'color': Color(0xFFFFE0B2)},
    {'name': 'Transportation', 'items': 980, 'icon': '🚕', 'color': Color(0xFFFFF9C4)},
    {'name': 'Food & Drink', 'items': 1250, 'icon': '🍽️', 'color': Color(0xFFFFCDD2)},
    {'name': 'Shopping', 'items': 1520, 'icon': '🛒', 'color': Color(0xFFC8E6C9)},
    {'name': 'Culture', 'items': 550, 'icon': '🏛️', 'color': Color(0xFFB2EBF2)},
    {'name': 'Meeting', 'items': 1520, 'icon': '👥', 'color': Color(0xFFD1C4E9)},
    {'name': 'Sport', 'items': 1550, 'icon': '🏐', 'color': Color(0xFFF8BBD0)},
    {'name': 'Health', 'items': 1520, 'icon': '🏥', 'color': Color(0xFFC8E6C9)},
    {'name': 'Business', 'items': 1550, 'icon': '💼', 'color': Color(0xFFBBDEFB)},
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
        builder: (context) => DictionaryCategoryView(categoryName: categoryName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: _buildAppBar(),
      body: Column(
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
                  
                  SizedBox(height: 32.h),
                  
                  // Recent Search
                  if (_recentSearches.isNotEmpty) _buildRecentSearch(),
                  
                  SizedBox(height: 100.h), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: MyColors.textPrimary,
          size: 24.sp,
        ),
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
                child: Text(
                  category['icon'],
                  style: TextStyle(fontSize: 24.sp),
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
        ..._recentSearches.map((search) => _buildRecentSearchItem(search)).toList(),
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
          Icon(
            Icons.history,
            size: 24.sp,
            color: MyColors.textSecondary,
          ),
          
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

  /// Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70.h,
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.grid_view_rounded, 0),
          _buildNavItem(Icons.flight_takeoff, 1),
          _buildNavItem(Icons.account_balance, 2),
          _buildNavItem(Icons.person_outline, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Navigate back to home
          Navigator.pop(context);
        } else {
          setState(() {
            _selectedNavIndex = index;
          });
          // TODO: Navigate to different pages
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: Icon(
          icon,
          size: 28.sp,
          color: isSelected ? Color(0xFF4ECDC4) : MyColors.textSecondary,
        ),
      ),
    );
  }
}
