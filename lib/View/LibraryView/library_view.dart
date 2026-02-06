import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'library_folder_detail_view.dart';

class LibraryView extends StatefulWidget {
  final bool isPremium;
  const LibraryView({super.key, this.isPremium = false});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  // Folder data
  final List<Map<String, dynamic>> _folders = [
    {
      'name': 'My Airport\nEssentials',
      'items': 12,
      'icon': 'assets/icons/airport.png',
      'color': Color(0xFFE3F2FD),
      'iconColor': Color(0xFF2196F3),
    },
    {
      'name': 'My Hotel\nEssentials',
      'items': 20,
      'icon': 'assets/icons/accommodation.png',
      'color': Color(0xFFFFE4CC),
      'iconColor': Color(0xFFFF6B35),
    },
    {
      'name': 'Transport\nEssentials',
      'items': 35,
      'icon': 'assets/icons/transportation.png',
      'color': Color(0xFFFFF9C4),
      'iconColor': Color(0xFFFBC02D),
    },
    {
      'name': 'My Food\nEssentials',
      'items': 8,
      'icon': 'assets/icons/food_drink.png',
      'color': Color(0xFFFFCDD2),
      'iconColor': Color(0xFFE53935),
    },
    {
      'name': 'My Shopping\nEssentials',
      'items': 21,
      'icon': 'assets/icons/shopping.png',
      'color': Color(0xFFC8E6C9),
      'iconColor': Color(0xFF43A047),
    },
    {
      'name': 'Culture\nEssentials',
      'items': 10,
      'icon': 'assets/icons/culture.png',
      'color': Color(0xFFB3E5FC),
      'iconColor': Color(0xFF0288D1),
    },
    {
      'name': 'Meeting\nEssentials',
      'items': 32,
      'icon': 'assets/icons/meeting.png',
      'color': Color(0xFFD7CCC8),
      'iconColor': Color(0xFF6D4C41),
    },
    {
      'name': 'Sport\nEssentials',
      'items': 18,
      'icon': 'assets/icons/sport.png',
      'color': Color(0xFFF8BBD0),
      'iconColor': Color(0xFFE91E63),
    },
    {
      'name': 'Health\nEssentials',
      'items': 8,
      'icon': 'assets/icons/health.png',
      'color': Color(0xFFC5E1A5),
      'iconColor': Color(0xFF7CB342),
    },
    {
      'name': 'Business\nEssentials',
      'items': 5,
      'icon': 'assets/icons/business.png',
      'color': Color(0xFFBBDEFB),
      'iconColor': Color(0xFF1976D2),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main content with smooth scrolling
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    // Header
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

                    SizedBox(height: 32.h),

                    // Folders Section Title
                    Text(
                      'Folders',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Folders Grid replacement with Staggered layout and Layout Variations
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column
                        Expanded(
                          child: Column(
                            children: [
                              for (int i = 0; i < _folders.length; i += 2)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 16.h),
                                  child: _buildFolderCard(
                                    name: _folders[i]['name'],
                                    items: _folders[i]['items'],
                                    icon: _folders[i]['icon'],
                                    color: _folders[i]['color'],
                                    iconColor: _folders[i]['iconColor'],
                                    isVertical: i % 4 == 0 || i % 4 == 3,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Right Column
                        Expanded(
                          child: Column(
                            children: [
                              for (int i = 1; i < _folders.length; i += 2)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 16.h),
                                  child: _buildFolderCard(
                                    name: _folders[i]['name'],
                                    items: _folders[i]['items'],
                                    icon: _folders[i]['icon'],
                                    color: _folders[i]['color'],
                                    iconColor: _folders[i]['iconColor'],
                                    isVertical: i % 4 == 0 || i % 4 == 3,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 100.h), // Space for bottom nav
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            CustomBottomNavBar(currentIndex: 2, isPremium: widget.isPremium),
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
    required bool isVertical,
  }) {
    final folderName = Text(
      name.replaceAll('\n', ' '),
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Montserrat',
        color: Color(0xFF1A1A1A),
        height: 1.2,
      ),
    );

    final itemInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$items items',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
            color: Color(0xFFB8BCC8),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Updated 2d ago',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
            color: Color(0xFFB8BCC8),
          ),
        ),
      ],
    );

    final iconWidget = Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Image.asset(
          icon,
          width: 22.w,
          height: 22.w,
          fit: BoxFit.contain,
        ),
      ),
    );

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LibraryFolderDetailView(
              folderName: name,
              icon: icon,
              isPremium: widget.isPremium,
            ),
          ),
        );

        // Eğer folder ismi değiştirilirse güncelle
        if (result != null && result is Map) {
          setState(() {
            final newName = result['newName'] as String;
            final oldName = result['oldName'] as String;

            // Eski isimle eşleşen folder'ı bul (newline karakterlerine dikkate al)
            final folderIndex = _folders.indexWhere(
              (f) =>
                  f['name'].replaceAll('\n', ' ').trim() ==
                  oldName.replaceAll('\n', ' ').trim(),
            );

            if (folderIndex != -1) {
              _folders[folderIndex]['name'] = newName;
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: isVertical
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  SizedBox(height: 20.h),
                  folderName,
                  SizedBox(height: 12.h),
                  itemInfo,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      iconWidget,
                      SizedBox(width: 8.w),
                      Expanded(child: folderName),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  itemInfo,
                ],
              ),
      ),
    );
  }
}
