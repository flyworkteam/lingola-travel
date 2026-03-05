import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';

import '../../Models/library_model.dart';
import '../../Riverpod/Controllers/library_controller.dart';
import '../../Services/tts_service.dart';

class LibraryFolderDetailView extends ConsumerStatefulWidget {
  final String folderId;
  final String folderName;
  final String icon;
  final bool isPremium;

  const LibraryFolderDetailView({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.icon,
    this.isPremium = false,
  });

  @override
  ConsumerState<LibraryFolderDetailView> createState() =>
      _LibraryFolderDetailViewState();
}

class _LibraryFolderDetailViewState
    extends ConsumerState<LibraryFolderDetailView>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  String? _playingItemId;
  bool _isEditMode = false;
  late String _currentFolderName;
  late TtsService _ttsService;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _currentFolderName = widget.folderName;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _ttsService = TtsService();
    _ttsService.init();

    Future.microtask(() {
      ref
          .read(libraryFolderItemsControllerProvider(widget.folderId).notifier)
          .init();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  // Varsayılan klasör isimlerini çeviren, özel isimleri ise DİREKT gösteren fonksiyon
  String getLocalizedFolderName(String name) {
    final n = name.trim().toLowerCase();

    // Sadece backend'den gelen varsayılan orijinal isimlerle TAM eşleşiyorsa çevir
    if (n == 'my airport essentials' || n == 'airport essentials')
      return LocaleKeys.library_folder_airport.tr();
    if (n == 'my hotel essentials' || n == 'hotel essentials')
      return LocaleKeys.library_folder_hotel.tr();
    if (n == 'transport essentials')
      return LocaleKeys.library_folder_transport.tr();
    if (n == 'my food essentials' || n == 'food essentials')
      return LocaleKeys.library_folder_food.tr();
    if (n == 'my shopping essentials' || n == 'shopping essentials')
      return LocaleKeys.library_folder_shopping.tr();
    if (n == 'culture essentials')
      return LocaleKeys.library_folder_culture.tr();
    if (n == 'meeting essentials')
      return LocaleKeys.library_folder_meeting.tr();
    if (n == 'sport essentials') return LocaleKeys.library_folder_sport.tr();
    if (n == 'health essentials') return LocaleKeys.library_folder_health.tr();
    if (n == 'business essentials')
      return LocaleKeys.library_folder_business.tr();

    // Kullanıcı ismi değiştirmişse (Örn: "Benim Tatilim" veya "Airport Trip"), GİRDİĞİ GİBİ GÖSTER!
    return name;
  }

  List<LibraryItemModel> _getFilteredItems(List<LibraryItemModel> allItems) {
    if (_selectedTab == 0) return allItems;
    if (_selectedTab == 1) {
      return allItems
          .where(
            (item) =>
                item.itemType == 'dictionary_word' ||
                item.itemType == 'lesson_vocabulary',
          )
          .toList();
    }
    return allItems.where((item) => item.itemType == 'travel_phrase').toList();
  }

  void _deleteItem(int libraryItemId) async {
    try {
      final controller = ref.read(
        libraryFolderItemsControllerProvider(widget.folderId).notifier,
      );
      final success = await controller.removeItem(libraryItemId);
      if (success) {
        // İtem silindiğinde klasörün tarihi güncellendiği için ana listeyi yenile
        ref.read(libraryControllerProvider.notifier).loadFolders();
      }
    } catch (e) {
      debugPrint('❌ Error deleting item: $e');
    }
  }

  void _showEditNameDialog() async {
    final TextEditingController nameController = TextEditingController(
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
          LocaleKeys.library_library_edit_folder_title.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: const Color(0xFF1A1A1A),
          ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          cursorColor: const Color(0xFF4ECDC4),
          decoration: InputDecoration(
            hintText: LocaleKeys.library_library_enter_folder_name.tr(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF4ECDC4), width: 2),
            ),
          ),
          style: TextStyle(fontSize: 16.sp, fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              LocaleKeys.profile_delete_dialog_cancel.tr(),
              style: TextStyle(color: const Color(0xFF6B7280)),
            ),
          ),
          GestureDetector(
            onTap: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) Navigator.pop(context, newName);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF2EC4B6)],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                LocaleKeys.profile_save.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != _currentFolderName) {
      final success = await ref
          .read(libraryControllerProvider.notifier)
          .updateFolder(folderId: widget.folderId, name: result);

      if (success) {
        if (mounted) {
          setState(() => _currentFolderName = result);
          // İsim değişince tarih de güncellendiği için ana listeyi yenile
          ref.read(libraryControllerProvider.notifier).loadFolders();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocaleKeys.library_library_update_success.tr()),
              backgroundColor: const Color(0xFF4ECDC4),
            ),
          );
        }
      }
    }
  }

  void _playAudio(
    String itemId,
    String targetLanguageText,
    String? languageCode,
  ) async {
    setState(() {
      if (_playingItemId == itemId) {
        _playingItemId = null;
        _progressController.stop();
        _progressController.reset();
        _ttsService.stop();
      } else {
        _playingItemId = itemId;
        _progressController.reset();
        _progressController.forward();
        _ttsService.speak(targetLanguageText, languageCode: languageCode);
      }
    });

    if (_playingItemId == itemId) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _playingItemId == itemId) {
          setState(() => _playingItemId = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final folderItemsState = ref.watch(
      libraryFolderItemsControllerProvider(widget.folderId),
    );
    final allItems = folderItemsState.items;
    final filteredItems = _getFilteredItems(allItems);

    return Scaffold(
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
                      InkWell(
                        onTap: () => Navigator.pop(context, true),
                        child: SvgPicture.asset(
                          'assets/icons/gerigelmeiconu.svg',
                        ),
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
                                  left: 29.w,
                                  top: 4.h,
                                  bottom: 4.h,
                                ),
                                child: Text(
                                  getLocalizedFolderName(_currentFolderName),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Montserrat',
                                    color: const Color(0xFF1A1A1A),
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
                                      width: 28.w,
                                      height: 28.w,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/editpen.svg',
                                          width: 15.w,
                                          height: 15.h,
                                          colorFilter: const ColorFilter.mode(
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
                        onTap: () => setState(() => _isEditMode = !_isEditMode),
                        child: Text(
                          _isEditMode
                              ? LocaleKeys.library_library_done.tr()
                              : LocaleKeys.library_library_edit.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            color: const Color(0xFF4ECDC4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Dinamik Tabs
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTab(
                              LocaleKeys.library_library_tab_all.tr(),
                              0,
                            ),
                          ),
                          Expanded(
                            child: _buildTab(
                              LocaleKeys.library_library_tab_words.tr(),
                              1,
                            ),
                          ),
                          Expanded(
                            child: _buildTab(
                              LocaleKeys.library_library_tab_phrases.tr(),
                              2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 2.h,
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Toplam genişliği üçe bölerek her bir tabın genişliğini buluyoruz
                          final tabWidth = constraints.maxWidth / 3;
                          return Stack(
                            children: [
                              // Arka plan çizgisi
                              Container(
                                height: 2.h,
                                color: const Color(0xFFE5E7EB),
                              ),
                              // Animasyonlu Seçili Tab Çizgisi
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                left:
                                    _selectedTab *
                                    tabWidth, // Dinamik konumlandırma
                                child: Container(
                                  height: 2.h,
                                  width: tabWidth,
                                  alignment: Alignment.center,
                                  // Yeşil çizgiyi hücrenin %60'lık kısmına ortalar (daha şık durur)
                                  child: FractionallySizedBox(
                                    widthFactor: 0.6,
                                    child: Container(
                                      height: 2.h,
                                      color: const Color(0xFF4ECDC4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Items list
                Expanded(
                  child: folderItemsState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4ECDC4),
                          ),
                        )
                      : filteredItems.isEmpty
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
                            final isPlaying = _playingItemId == item.itemId;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: _buildItemCard(item, isPlaying),
                            );
                          },
                        ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8.h,
              child: CustomBottomNavBar(
                currentIndex: 2,
                isPremium: widget.isPremium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      behavior: HitTestBehavior
          .opaque, // Sadece metne değil, tüm alana tıklamayı algılar
      child: Container(
        padding: EdgeInsets.only(bottom: 8.h),
        alignment: Alignment.center,
        child: Text(
          title,
          maxLines: 1, // Uzun kelimelerde taşıp tasarımı bozmaması için
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            color: isSelected
                ? const Color(0xFF4ECDC4)
                : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 140.h),
          SvgPicture.asset(
            'assets/icons/nosaveditemyet.svg',
            width: 140.w,
            height: 140.w,
          ),
          SizedBox(height: 48.h),
          Text(
            LocaleKeys.library_library_no_items_title.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              letterSpacing: 16.sp * -0.05,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            LocaleKeys.library_library_no_items_subtitle.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              letterSpacing: 14.sp * -0.05,
              color: const Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  LocaleKeys.library_library_browse_lessons.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  Widget _buildItemCard(LibraryItemModel item, bool isPlaying) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r), // Figma Corner Radius
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFC2D6E1,
                ).withOpacity(0.60), // Figma Drop Shadow
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          // Progress barın taşmasını önlemek için
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- SENİN KODLARIN BAŞLANGICI (DOKUNULMADI) ---
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.targetLanguage == 'en'
                                ? item.word
                                : item.translation,
                            style: TextStyle(
                              fontSize: 16.sp,
                              letterSpacing: 16.sp * -0.05,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.targetLanguage == 'en'
                                ? item.translation
                                : item.word,
                            style: TextStyle(
                              letterSpacing: 13.sp * -0.05,
                              fontSize: 13.sp,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isEditMode)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _playAudio(
                              item.itemId,
                              item.targetLanguage == 'en'
                                  ? item.word
                                  : item.translation,
                              item.targetLanguage,
                            ),
                            child: Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2EC4B6).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              padding: EdgeInsets.all(10.w),
                              child: SvgPicture.asset(
                                'assets/icons/travelvocabularyseslendirme.svg',
                                color: const Color(0xFF4ECDC4),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F7F9),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            padding: EdgeInsets.all(10.w),
                            child: SvgPicture.asset(
                              'assets/icons/travelvocabularykaydet.svg',
                              color: const Color(0xFF4ECDC4),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // --- SENİN KODLARIN BİTİŞİ ---

              // Animasyonlu Alt Progress Bar
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isPlaying
                    ? AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _progressController.value,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4ECDC4),
                            ),
                            minHeight: 4.h,
                          );
                        },
                      )
                    : const SizedBox(width: double.infinity, height: 0),
              ),
            ],
          ),
        ),
        if (_isEditMode)
          Positioned(
            top: -8.w,
            left: 4.w,
            child: GestureDetector(
              onTap: () => _deleteItem(item.libraryItemId),
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove, size: 12, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
