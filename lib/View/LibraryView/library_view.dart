import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'package:lingola_travel/Riverpod/Controllers/library_controller.dart';
import 'library_folder_detail_view.dart';

class LibraryView extends ConsumerStatefulWidget {
  final bool isPremium;
  const LibraryView({super.key, this.isPremium = false});

  @override
  ConsumerState<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends ConsumerState<LibraryView> {
  @override
  void initState() {
    super.initState();
    // Load folders from backend
    Future.microtask(() {
      ref.read(libraryControllerProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(libraryControllerProvider);
    final folders = viewModel.folders;

    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Show loading indicator
            if (viewModel.isLoading && folders.isEmpty)
              Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4)))
            // Show error message
            else if (viewModel.errorMessage != null && folders.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.sp, color: Colors.red),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(libraryControllerProvider.notifier).init();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            // Show folders
            else
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

                      // Folders Grid with backend data
                      if (folders.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.h),
                            child: Text(
                              'No folders yet',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Color(0xFFB8BCC8),
                              ),
                            ),
                          ),
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column
                            Expanded(
                              child: Column(
                                children: [
                                  for (int i = 0; i < folders.length; i += 2)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 16.h),
                                      child: _buildFolderCard(
                                        folder: folders[i],
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
                                  for (int i = 1; i < folders.length; i += 2)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 16.h),
                                      child: _buildFolderCard(
                                        folder: folders[i],
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

  Widget _buildFolderCard({required folder, required bool isVertical}) {
    // Parse color from hex string (e.g., "#E3F2FD" or "E3F2FD")
    Color parseColor(String? colorString) {
      if (colorString == null || colorString.isEmpty) {
        return Color(0xFFE3F2FD); // Default color
      }
      final hexColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    }

    // Map folder name to icon
    String getFolderIcon(String folderName) {
      final nameLower = folderName.toLowerCase();

      if (nameLower.contains('airport') || nameLower.contains('havaalani')) {
        return 'assets/icons/airport.png';
      } else if (nameLower.contains('hotel') ||
          nameLower.contains('accommodation')) {
        return 'assets/icons/accommodation.png';
      } else if (nameLower.contains('transport')) {
        return 'assets/icons/transportation.png';
      } else if (nameLower.contains('food')) {
        return 'assets/icons/food_drink.png';
      } else if (nameLower.contains('shopping')) {
        return 'assets/icons/shopping.png';
      } else if (nameLower.contains('culture')) {
        return 'assets/icons/culture.png';
      } else if (nameLower.contains('meeting')) {
        return 'assets/icons/meeting.png';
      } else if (nameLower.contains('sport')) {
        return 'assets/icons/sport.png';
      } else if (nameLower.contains('health')) {
        return 'assets/icons/health.png';
      } else if (nameLower.contains('business')) {
        return 'assets/icons/business.png';
      }

      return 'assets/icons/folder.png'; // Default
    }

    final folderColor = parseColor(folder.color);
    final folderIcon = folder.icon ?? getFolderIcon(folder.name);

    final folderName = Text(
      folder.name,
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
          '${folder.itemCount} items',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
            color: Color(0xFFB8BCC8),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          _formatDate(folder.createdAt),
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
        color: folderColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Image.asset(
          folderIcon,
          width: 22.w,
          height: 22.w,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.folder,
              size: 22.w,
              color: folderColor.computeLuminance() > 0.5
                  ? Colors.black54
                  : Colors.white70,
            );
          },
        ),
      ),
    );

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LibraryFolderDetailView(
              folderId: folder.id,
              folderName: folder.name,
              icon: folderIcon,
              isPremium: widget.isPremium,
            ),
          ),
        );

        // Refresh folders list if needed
        if (result != null && result == true) {
          ref.read(libraryControllerProvider.notifier).loadFolders();
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}
