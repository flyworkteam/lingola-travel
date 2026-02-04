import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'library_folder_detail_view.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {

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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content with smooth scrolling
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
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

                    // Folders Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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

                    SizedBox(height: 100.h), // Space for bottom nav
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            CustomBottomNavBar(currentIndex: 2),
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


}
