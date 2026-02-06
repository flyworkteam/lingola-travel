import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';

class LibraryFolderDetailView extends StatefulWidget {
  final String folderName;
  final String icon;
  final bool isPremium;

  const LibraryFolderDetailView({
    super.key,
    required this.folderName,
    required this.icon,
    this.isPremium = false,
  });

  @override
  State<LibraryFolderDetailView> createState() =>
      _LibraryFolderDetailViewState();
}

class _LibraryFolderDetailViewState extends State<LibraryFolderDetailView>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0; // 0: All, 1: Words, 2: Phrases
  String? _playingItemId;
  bool _isEditMode = false;
  List<Map<String, dynamic>> _allItems = [];
  late String _currentFolderName;
  final Set<String> _bookmarkedIds = {};

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _currentFolderName = widget.folderName;
    _allItems = _getInitialItems();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  // Sample data - different for each category
  List<Map<String, dynamic>> _getInitialItems() {
    if (widget.folderName.contains('Airport')) {
      return [
        {
          'id': '1',
          'english': 'Boarding Pass',
          'turkish': 'Biniş Kartı',
          'type': 'word',
        },
        {
          'id': '2',
          'english': 'Where is the gate?',
          'turkish': 'Kapı nerede?',
          'type': 'phrase',
        },
        {
          'id': '3',
          'english': 'Passport Control',
          'turkish': 'Pasaport Kontrolü',
          'type': 'word',
        },
        {
          'id': '4',
          'english': 'Baggage Claim',
          'turkish': 'Bagaj Alım',
          'type': 'word',
        },
        {
          'id': '5',
          'english': 'Carry-on',
          'turkish': 'El bagajı',
          'type': 'word',
        },
      ];
    } else if (widget.folderName.contains('Hotel')) {
      return [
        {
          'id': '1',
          'english': 'Check-in',
          'turkish': 'Giriş yapma',
          'type': 'word',
        },
        {
          'id': '2',
          'english': 'Do you have a reservation?',
          'turkish': 'Rezervasyonunuz var mı?',
          'type': 'phrase',
        },
        {
          'id': '3',
          'english': 'Room service',
          'turkish': 'Oda servisi',
          'type': 'word',
        },
        {
          'id': '4',
          'english': 'Wake-up call',
          'turkish': 'Uyandırma servisi',
          'type': 'word',
        },
      ];
    } else if (widget.folderName.contains('Transport')) {
      return [
        {'id': '1', 'english': 'Taxi', 'turkish': 'Taksi', 'type': 'word'},
        {
          'id': '2',
          'english': 'How much is the fare?',
          'turkish': 'Ücret ne kadar?',
          'type': 'phrase',
        },
        {
          'id': '3',
          'english': 'Bus stop',
          'turkish': 'Otobüs durağı',
          'type': 'word',
        },
        {
          'id': '4',
          'english': 'Train station',
          'turkish': 'Tren istasyonu',
          'type': 'word',
        },
      ];
    } else if (widget.folderName.contains('Food')) {
      return [
        {'id': '1', 'english': 'Menu', 'turkish': 'Menü', 'type': 'word'},
        {
          'id': '2',
          'english': 'Can I see the menu?',
          'turkish': 'Menüyü görebilir miyim?',
          'type': 'phrase',
        },
        {'id': '3', 'english': 'Bill', 'turkish': 'Hesap', 'type': 'word'},
        {
          'id': '4',
          'english': 'Reservation',
          'turkish': 'Rezervasyon',
          'type': 'word',
        },
      ];
    } else if (widget.folderName.contains('Shopping')) {
      return [
        {
          'id': '1',
          'english': 'How much?',
          'turkish': 'Ne kadar?',
          'type': 'phrase',
        },
        {'id': '2', 'english': 'Receipt', 'turkish': 'Fiş', 'type': 'word'},
        {
          'id': '3',
          'english': 'Discount',
          'turkish': 'İndirim',
          'type': 'word',
        },
        {
          'id': '4',
          'english': 'Credit card',
          'turkish': 'Kredi kartı',
          'type': 'word',
        },
      ];
    } else {
      return [
        {'id': '1', 'english': 'Hello', 'turkish': 'Merhaba', 'type': 'word'},
        {
          'id': '2',
          'english': 'Thank you',
          'turkish': 'Teşekkür ederim',
          'type': 'phrase',
        },
        {
          'id': '3',
          'english': 'Goodbye',
          'turkish': 'Hoşça kal',
          'type': 'word',
        },
      ];
    }
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    if (_selectedTab == 0) return _allItems; // All
    if (_selectedTab == 1) {
      return _allItems
          .where((item) => item['type'] == 'word')
          .toList(); // Words
    }
    return _allItems
        .where((item) => item['type'] == 'phrase')
        .toList(); // Phrases
  }

  void _deleteItem(String itemId) {
    setState(() {
      _allItems.removeWhere((item) => item['id'] == itemId);
    });
  }

  void _showEditNameDialog() async {
    final TextEditingController controller = TextEditingController(
      text: _currentFolderName.replaceAll('\n', ' '),
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Edit Folder Name',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Color(0xFF4ECDC4),
              selectionColor: Color(0xFF4ECDC4).withOpacity(0.3),
              selectionHandleColor: Color(0xFF4ECDC4),
            ),
          ),
          child: TextField(
            controller: controller,
            autofocus: true,
            cursorColor: Color(0xFF4ECDC4),
            decoration: InputDecoration(
              hintText: 'Enter folder name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Color(0xFF4ECDC4), width: 2),
              ),
            ),
            style: TextStyle(fontSize: 16.sp, fontFamily: 'Montserrat'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF2EC4B6)],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _currentFolderName = result;
      });
    }
  }

  void _playAudio(String itemId) {
    setState(() {
      if (_playingItemId == itemId) {
        _playingItemId = null;
        _progressController.stop();
        _progressController.reset();
      } else {
        _playingItemId = itemId;
        _progressController.reset();
        _progressController.forward();
      }
    });

    if (_playingItemId == itemId) {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted && _playingItemId == itemId) {
          setState(() {
            _playingItemId = null;
          });
        }
      });
    }
  }

  void _toggleBookmark(String itemId) {
    setState(() {
      if (_bookmarkedIds.contains(itemId)) {
        _bookmarkedIds.remove(itemId);
      } else {
        _bookmarkedIds.add(itemId);
      }
    });
  }

  void _showItemDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),

              // English text
              Text(
                item['english'],
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 12.h),

              // Turkish text
              Text(
                item['turkish'],
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 32.h),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.volume_up,
                    onTap: () => _playAudio(item['id']),
                  ),
                  SizedBox(width: 20.w),
                  _buildActionButton(
                    icon: Icons.bookmark,
                    onTap: () => _toggleBookmark(item['id']),
                  ),
                ],
              ),

              SizedBox(height: 40.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: Color(0xFFE0F7F4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 28.sp, color: Color(0xFF4ECDC4)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _currentFolderName != widget.folderName) {
          // Sayfa kapandıktan sonra result null olabilir, bu yüzden burada handle edemeyiz
        }
      },
      child: Scaffold(
        backgroundColor: MyColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, {
                              'newName': _currentFolderName,
                              'oldName': widget.folderName,
                            });
                          },
                          child: Icon(Icons.arrow_back_ios_new, size: 24.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 29.w, top: 4.h, bottom: 4.h),
                                  child: Text(
                                    _currentFolderName.replaceAll('\n', ' '),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                if (_isEditMode)
                                  Positioned(
                                    left: 0,
                                    top: -8.h,
                                    child: GestureDetector(
                                      onTap: _showEditNameDialog,
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        width: 28.w, // Reduced from 36.w
                                        height: 28.w, // Reduced from 36.w
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/editpen.svg',
                                            width: 15.w,
                                            height: 15.h,
                                            colorFilter: ColorFilter.mode(
                                              Color(0xFF4ECDC4),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isEditMode = !_isEditMode;
                            });
                          },
                          child: Text(
                            _isEditMode ? 'Done' : 'Edit',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        _buildTab('All', 0),
                        SizedBox(width: 32.w),
                        _buildTab('Words', 1),
                        SizedBox(width: 32.w),
                        _buildTab('Phrases', 2),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Items list
                  Expanded(
                    child: filteredItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.only(
                              left: 24.w,
                              right: 24.w,
                              top: 8.h,
                              bottom: 100.h,
                            ),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final isPlaying = _playingItemId == item['id'];

                              return Padding(
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: _buildItemCard(item, isPlaying),
                              );
                            },
                          ),
                  ),
                ],
              ),

              // Bottom Navigation Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 20.h,
                child: CustomBottomNavBar(
                  currentIndex: 2,
                  isPremium: widget.isPremium,
                ),
              ),

              // Floating Action Button removed as requested
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              color: isSelected ? Color(0xFF4ECDC4) : Color(0xFF9CA3AF),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 2.h,
            width: 40.w,
            color: isSelected ? Color(0xFF4ECDC4) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 140.h), // Increased from 60.h to push everything further down
          // Updated Empty State Icon
          SvgPicture.asset(
            'assets/icons/nosaveditemyet.svg',
            width: 140.w,
            height: 140.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 48.h), // Increased from 24.h to pull texts down

          // Title
          Text(
            'No saved items yet',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 12.h),

          // Description
          Text(
            'Start adding words and phrases\nfrom your lessons to see them here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
              color: Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
          
          const Spacer(), // Pushes everything below it to the bottom

          // Browse Lesson Button
          GestureDetector(
            onTap: () {
              // Navigate to lessons or close
              Navigator.pop(context, {
                'newName': _currentFolderName,
                'oldName': widget.folderName,
              });
            },
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                color: Color(0xFF4ECDC4),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF4ECDC4).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'BROWSE LESSON',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 120.h), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, bool isPlaying) {
    return GestureDetector(
      onTap: null, // Disabled bottom sheet trigger as requested by user
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['english'],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item['turkish'],
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    if (!_isEditMode)
                      GestureDetector(
                        onTap: () => _playAudio(item['id']),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: Color(0xFFE0F7F4),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.volume_up,
                            size: 22.sp,
                            color: Color(0xFF4ECDC4),
                          ),
                        ),
                      ),
                    SizedBox(width: 8.w),
                    if (!_isEditMode)
                      GestureDetector(
                        onTap: () => _toggleBookmark(item['id']),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: _bookmarkedIds.contains(item['id'])
                                ? Color(0xFFE3F2FD)
                                : Color(0xFFE0F7F4),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.bookmark,
                            size: 22.sp,
                            color: _bookmarkedIds.contains(item['id'])
                                ? Color(0xFF3B82F6)
                                : Color(0xFF4ECDC4),
                          ),
                        ),
                      ),
                  ],
                ),
                if (isPlaying) ...[
                  SizedBox(height: 12.h),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(2.r),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: Color(0xFFE5E7EB),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF4ECDC4),
                          ),
                          minHeight: 4.h,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          if (_isEditMode)
            Positioned(
              top: -8.w,
              left: 4.w,
              child: GestureDetector(
                onTap: () => _deleteItem(item['id']),
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.remove, size: 12.sp, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
