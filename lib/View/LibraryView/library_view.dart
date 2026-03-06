import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Riverpod/Controllers/library_controller.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';

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
          key: const ValueKey('library_stack'),
          children: [
            if (viewModel.isLoading && folders.isEmpty)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
              )
            else
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Text(
                        LocaleKeys.library_library_collection.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          letterSpacing: 13.sp * -0.05,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                          color: const Color(0xFF4ECDC4),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        LocaleKeys.library_library_title.tr(),
                        style: TextStyle(
                          fontSize: 28.sp,
                          letterSpacing: 28.sp * -0.05,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        LocaleKeys.library_library_folders.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          letterSpacing: 16.sp * -0.05,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
            CustomBottomNavBar(
              key: const ValueKey('bottom_nav_library'),
              currentIndex: 2,
              isPremium: widget.isPremium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderCard({required folder, required bool isVertical}) {
    Color parseColor(String? colorString) {
      if (colorString == null || colorString.isEmpty) {
        return const Color(0xFFE3F2FD);
      }
      final hexColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    }

    String getFolderIcon(String folderName) {
      final nameLower = folderName.toLowerCase();

      if (nameLower.contains('general'))
        return 'assets/images/home/general.png';
      if (nameLower.contains('travel')) return 'assets/icons/airport.svg';
      if (nameLower.contains('accommodation')) return 'assets/icons/acc.svg';
      if (nameLower.contains('food')) return 'assets/icons/ffff.svg';
      if (nameLower.contains('culture')) return 'assets/icons/culture.svg';
      if (nameLower.contains('shopping')) return 'assets/icons/shopping.svg';
      if (nameLower.contains('direction'))
        return 'assets/images/home/direction.png';
      if (nameLower.contains('sport')) return 'assets/icons/sport.svg';
      if (nameLower.contains('health')) return 'assets/icons/health.svg';
      if (nameLower.contains('business')) return 'assets/icons/business.png';
      if (nameLower.contains('emergency'))
        return 'assets/images/home/emergency.png';

      return 'assets/icons/airport.svg';
    }

    final folderColor = parseColor(folder.color);

    // Veritabanından gelen icon path'i varsa onu, yoksa isme göre eşleşeni kullan.
    String folderIcon = folder.icon ?? getFolderIcon(folder.name);

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
        if (result == true) {
          ref.read(libraryControllerProvider.notifier).loadFolders();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC2D6E1).withOpacity(0.6),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: isVertical
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconBox(folderColor, folderIcon),
                  SizedBox(height: 12.h),
                  _buildFolderName(folder.name),
                  SizedBox(height: 12.h),
                  _buildItemStats(folder.itemCount, folder.createdAt),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIconBox(folderColor, folderIcon),
                      SizedBox(width: 8.w),
                      Expanded(child: _buildFolderName(folder.name)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildItemStats(folder.itemCount, folder.createdAt),
                ],
              ),
      ),
    );
  }

  Widget _buildIconBox(Color color, String iconPath) {
    final bool isSvg = iconPath.toLowerCase().endsWith('.svg');

    return Container(
      width: 36.w,
      height: 36.w,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: isSvg
            ? SvgPicture.asset(iconPath, fit: BoxFit.contain)
            : Image.asset(
                iconPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
      ),
    );
  }

  Widget _buildFolderName(String name) {
    return Text(
      _getLocalizedFolderName(name),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15.sp,
        letterSpacing: 15.sp * -0.05,
        fontWeight: FontWeight.w700,
        fontFamily: 'Montserrat',
        color: Colors.black,
      ),
    );
  }

  Widget _buildItemStats(int count, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count ${LocaleKeys.library_library_items.tr()}',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
            color: const Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          _formatLocalizedDate(date),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  String _getLocalizedFolderName(String name) {
    final n = name.trim().toLowerCase();

    if (n == 'general essentials') return LocaleKeys.home_catGeneral.tr();
    if (n == 'travel essentials') return LocaleKeys.home_catTravel.tr();
    if (n == 'accommodation essentials')
      return LocaleKeys.home_catAccommodation.tr();
    if (n == 'food & drink essentials')
      return LocaleKeys.home_catFoodAndDrink.tr();
    if (n == 'culture essentials') return LocaleKeys.home_catCulture.tr();
    if (n == 'shopping essentials') return LocaleKeys.home_catShop.tr();
    if (n == 'direction essentials') return LocaleKeys.home_catDirection.tr();
    if (n == 'sport essentials') return LocaleKeys.home_catSport.tr();
    if (n == 'health essentials') return LocaleKeys.home_catHealth.tr();
    if (n == 'business essentials') return LocaleKeys.home_catBusiness.tr();
    if (n == 'emergency essentials') return LocaleKeys.home_catEmergency.tr();

    return name;
  }

  String _formatLocalizedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return LocaleKeys.library_today.tr();
    if (difference.inDays == 1) return LocaleKeys.library_yesterday.tr();

    String timeValue;

    if (difference.inDays < 7) {
      timeValue = '${difference.inDays}${LocaleKeys.library_unit_day.tr()}';
    } else if (difference.inDays < 30) {
      timeValue =
          '${(difference.inDays / 7).floor()}${LocaleKeys.library_unit_week.tr()}';
    } else if (difference.inDays < 365) {
      timeValue =
          '${(difference.inDays / 30).floor()}${LocaleKeys.library_unit_month.tr()}';
    } else {
      timeValue =
          '${(difference.inDays / 365).floor()}${LocaleKeys.library_unit_year.tr()}';
    }

    return LocaleKeys.library_library_updated.tr(args: [timeValue]);
  }
}
