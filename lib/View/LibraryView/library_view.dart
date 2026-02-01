import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import '../DictionaryView/visual_dictionary_view.dart';
import '../VocabularyView/travel_vocabulary_view.dart';
import '../ProfileView/profile_view.dart';
import 'library_folder_detail_view.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  int _selectedNavIndex = 2; // Library is index 2

  // Folder data
  final List<Map<String, dynamic>> _folders = [
    {
      'name': 'My Airport\nEssentials',
      'items': 12,
      'icon': '✈️',
      'color': Color(0xFFE3F2FD),
      'iconColor': Color(0xFF2196F3),
    },
    {
      'name': 'My Hotel\nEssentials',
      'items': 20,
      'icon': '🏨',
      'color': Color(0xFFFFE4CC),
      'iconColor': Color(0xFFFF6B35),
    },
    {
      'name': 'Transport\nEssentials',
      'items': 35,
      'icon': '🚕',
      'color': Color(0xFFFFF9C4),
      'iconColor': Color(0xFFFBC02D),
    },
    {
      'name': 'My Food\nEssentials',
      'items': 8,
      'icon': '🍽️',
      'color': Color(0xFFFFCDD2),
      'iconColor': Color(0xFFE53935),
    },
    {
      'name': 'My Shopping\nEssentials',
      'items': 21,
      'icon': '🛒',
      'color': Color(0xFFC8E6C9),
      'iconColor': Color(0xFF43A047),
    },
    {
      'name': 'Culture\nEssentials',
      'items': 10,
      'icon': '🏛️',
      'color': Color(0xFFB3E5FC),
      'iconColor': Color(0xFF0288D1),
    },
    {
      'name': 'Meeting\nEssentials',
      'items': 32,
      'icon': '👥',
      'color': Color(0xFFD7CCC8),
      'iconColor': Color(0xFF6D4C41),
    },
    {
      'name': 'Sport\nEssentials',
      'items': 18,
      'icon': '🏐',
      'color': Color(0xFFF8BBD0),
      'iconColor': Color(0xFFE91E63),
    },
    {
      'name': 'Health\nEssentials',
      'items': 8,
      'icon': '🏥',
      'color': Color(0xFFC5E1A5),
      'iconColor': Color(0xFF7CB342),
    },
    {
      'name': 'Business\nEssentials',
      'items': 5,
      'icon': '💼',
      'color': Color(0xFFBBDEFB),
      'iconColor': Color(0xFF1976D2),
    },
  ];

  void _onNavigationItemTapped(int index) {
    if (index == 0) {
      // Navigate to Home
      Navigator.pop(context);
    } else if (index == 1) {
      // Navigate to Travel Vocabulary
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TravelVocabularyView()),
      );
    } else if (index == 3) {
      // Navigate to Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileView()),
      );
    } else {
      setState(() {
        _selectedNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR COLLECTION',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          color: Color(0xFF4ECDC4),
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'My Library',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Montserrat',
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Folders Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    'Folders',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Folders Grid
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: GridView.builder(
                      padding: EdgeInsets.only(bottom: 100.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _folders.length,
                      itemBuilder: (context, index) {
                        final folder = _folders[index];
                        return _buildFolderCard(
                          name: folder['name'],
                          items: folder['items'],
                          icon: folder['icon'],
                          color: folder['color'],
                          iconColor: folder['iconColor'],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 20.h,
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  height: 65.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35.r),
                    child: Stack(
                      children: [
                        // Background image
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/home/altmenuarkaplan.png',
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: MyColors.white,
                                  borderRadius: BorderRadius.circular(35.r),
                                ),
                              );
                            },
                          ),
                        ),

                        // Navigation items - centered
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildNavItem(
                                  icon: Icons.grid_view_rounded,
                                  index: 0,
                                ),
                                _buildNavItem(
                                  icon: Icons.flight_takeoff_rounded,
                                  index: 1,
                                ),
                                _buildNavItem(
                                  icon: Icons.account_balance_rounded,
                                  index: 2,
                                ),
                                _buildNavItem(
                                  icon: Icons.person_rounded,
                                  index: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildFolderCard({
    required String name,
    required int items,
    required String icon,
    required Color color,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LibraryFolderDetailView(folderName: name, icon: icon),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(icon, style: TextStyle(fontSize: 28.sp)),
              ),
            ),

            Spacer(),

            // Folder name
            Text(
              name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: Color(0xFF1A1A1A),
                height: 1.2,
              ),
            ),

            SizedBox(height: 8.h),

            // Items count
            Text(
              '$items items',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
                color: Color(0xFF9CA3AF),
              ),
            ),

            SizedBox(height: 4.h),

            // Updated time
            Text(
              'Updated 2d ago',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
                color: Color(0xFFB8BCC8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool isActive = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () => _onNavigationItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: isActive ? MyColors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 26.sp,
          color: isActive ? MyColors.lingolaPrimaryColor : MyColors.grey400,
        ),
      ),
    );
  }
}
