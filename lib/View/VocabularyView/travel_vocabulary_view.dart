import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';

class TravelVocabularyView extends StatefulWidget {
  final bool isPremium;
  const TravelVocabularyView({super.key, this.isPremium = false});

  @override
  State<TravelVocabularyView> createState() => _TravelVocabularyViewState();
}

class _TravelVocabularyViewState extends State<TravelVocabularyView> {
  // State variables
  int _selectedTab = 0; // 0: Words, 1: Phrases
  String _selectedCategory = 'All Topics';
  final TextEditingController _searchController = TextEditingController();
  Set<String> _bookmarkedItems = {};

  // Categories
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All Topics', 'icon': '✈️'},
    {'name': 'Airport', 'icon': '🛫'},
    {'name': 'Hotel', 'icon': '🏨'},
    {'name': 'Taxi', 'icon': '🚕'},
    {'name': 'Food & Drink', 'icon': '🍽️'},
    {'name': 'Shopping', 'icon': '🛒'},
    {'name': 'Culture', 'icon': '🏛️'},
    {'name': 'Meeting', 'icon': '👥'},
    {'name': 'Sport', 'icon': '🏐'},
    {'name': 'Health', 'icon': '🏥'},
    {'name': 'Business', 'icon': '💼'},
  ];

  // Mock data - Words
  final Map<String, List<Map<String, String>>> _wordsData = {
    'Airport': [
      {'title': 'Boarding Pass', 'translation': 'Biniş Kartı'},
      {'title': 'Custom Declaration', 'translation': 'Gümrük Beyanı'},
      {'title': 'Carry-on Baggage', 'translation': 'El Bagajı'},
    ],
    'Hotel': [
      {'title': 'Late Check-out', 'translation': 'Geç Çıkış'},
      {'title': 'Housekeeping', 'translation': 'Oda Servisi/Temizlik'},
    ],
  };

  // Mock data - Phrases
  final Map<String, List<Map<String, String>>> _phrasesData = {
    'Airport': [
      {
        'question': 'Where is the check-in counter for British Airways?',
        'translation': 'British Airways check-in kontuarı nerede?',
      },
      {
        'question': 'Is this the line for security?',
        'translation': 'Güvenlik sırası bu mu?',
      },
    ],
    'Hotel': [
      {
        'question': 'What time is breakfast served?',
        'translation': 'Kahvaltı saat kaçta servis ediliyor?',
      },
      {
        'question': 'Could I have some extra towels, please',
        'translation': 'Lütfen birkaç tane daha havlu alabilir miyim?',
      },
    ],
  };

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
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'];
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF4ECDC4) : MyColors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: MyColors.border, width: 1),
                ),
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
          );
        },
      ),
    );
  }

  /// Content (Words or Phrases)
  Widget _buildContent() {
    final data = _selectedTab == 0 ? _wordsData : _phrasesData;
    final categories = _selectedCategory == 'All Topics'
        ? data.keys.toList()
        : [_selectedCategory];

    return ListView.builder(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        bottom: 100.h,
      ), // Space for bottom nav
      itemCount: categories.length * 2, // Category + items
      itemBuilder: (context, index) {
        final categoryIndex = index ~/ 2;
        if (categoryIndex >= categories.length) return SizedBox.shrink();

        final categoryName = categories[categoryIndex];
        final items = data[categoryName] ?? [];

        if (index % 2 == 0) {
          // Category header
          return _buildCategoryHeader(categoryName, items.length);
        } else {
          // Items
          return Column(
            children: [
              ...items.asMap().entries.map((entry) {
                final itemIndex = entry.key;
                final item = entry.value;
                final itemId = '$categoryName-$itemIndex';

                return _selectedTab == 0
                    ? _buildWordCard(item, itemId)
                    : _buildPhraseCard(item, itemId);
              }).toList(),
              _buildLoadMoreButton(),
              SizedBox(height: 20.h),
            ],
          );
        }
      },
    );
  }

  /// Category header
  Widget _buildCategoryHeader(String categoryName, int count) {
    // Find the icon for this category
    final category = _categories.firstWhere(
      (cat) => cat['name'] == categoryName,
      orElse: () => {'name': categoryName, 'icon': '📁'},
    );
    final categoryIcon = category['icon'] ?? '�';
    final label = _selectedTab == 0 ? 'Words' : 'Phrases';

    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
      child: Row(
        children: [
          // Category icon - use SVG for Airport and Hotel
          if (categoryName == 'Airport')
            SvgPicture.asset(
              'assets/images/tvairport.svg',
              width: 20.w,
              height: 20.h,
            )
          else if (categoryName == 'Hotel')
            SvgPicture.asset(
              'assets/images/tvhotel.svg',
              width: 20.w,
              height: 20.h,
            )
          else
            Text(categoryIcon, style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 8.w),
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
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
              color: MyColors.textSecondary,
            ),
          ),
        ],
      ),
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
                  word['title']!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  word['translation']!,
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
              print('Play audio: ${word['title']}');
            },
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity(0.2),
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
                color: isBookmarked ? Color(0x3D2989E9) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/travelvocabularykaydet.svg',
                  width: 20.w,
                  height: 20.h,
                  colorFilter: ColorFilter.mode(
                    isBookmarked ? const Color(0xFF2989E9) : const Color(0xFF9E9E9E).withOpacity(0.5),
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

  /// Phrase card
  Widget _buildPhraseCard(Map<String, String> phrase, String id) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phrase['question']!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: MyColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      phrase['translation']!,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Audio button
                  GestureDetector(
                    onTap: () {
                      print('Play audio: ${phrase['question']}');
                    },
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withOpacity(0.2),
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
                            isBookmarked ? const Color(0xFF2989E9) : const Color(0xFF9E9E9E).withOpacity(0.5),
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
        ],
      ),
    );
  }

  /// Load More button
  Widget _buildLoadMoreButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          print('Load more items');
        },
        style: TextButton.styleFrom(
          overlayColor: Colors.transparent, // No splash/overlay effect
        ),
        child: Text(
          '+ Load More',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            color: Color(0xFF4ECDC4),
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFF4ECDC4),
          ),
        ),
      ),
    );
  }
}
