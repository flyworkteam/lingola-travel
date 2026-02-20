import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Widgets/Common/custom_bottom_nav_bar.dart';
import '../../Riverpod/Controllers/library_controller.dart';
import '../../Models/library_model.dart';
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
  int _selectedTab = 0; // 0: All, 1: Words, 2: Phrases
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
      duration: Duration(seconds: 3),
    );

    // Initialize TTS service
    _ttsService = TtsService();
    _ttsService
        .init()
        .then((_) {
          print('✅ TTS initialized in library_folder_detail_view');
        })
        .catchError((e) {
          print('⚠️ Error initializing TTS: $e');
        });

    // Load folder items from backend
    Future.microtask(() {
      print(
        '🔵 LibraryFolderDetailView initState - folderId: ${widget.folderId}',
      );
      ref
          .read(libraryFolderItemsControllerProvider(widget.folderId).notifier)
          .init();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _ttsService.stop(); // Stop any ongoing TTS
    super.dispose();
  }

  // Filter items by tab (All, Words, Phrases)
  List<LibraryItemModel> _getFilteredItems(List<LibraryItemModel> allItems) {
    if (_selectedTab == 0) return allItems; // All
    if (_selectedTab == 1) {
      // Words: dictionary_word and lesson_vocabulary
      return allItems
          .where(
            (item) =>
                item.itemType == 'dictionary_word' ||
                item.itemType == 'lesson_vocabulary',
          )
          .toList();
    }
    // Phrases: travel_phrase
    return allItems.where((item) => item.itemType == 'travel_phrase').toList();
  }

  // Delete item from library
  void _deleteItem(int libraryItemId) async {
    try {
      final controller = ref.read(
        libraryFolderItemsControllerProvider(widget.folderId).notifier,
      );
      await controller.removeItem(libraryItemId);
    } catch (e) {
      print('❌ Error deleting item: $e');
    }
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

  void _playAudio(
    String itemId,
    String targetLanguageText,
    String? languageCode,
  ) async {
    setState(() {
      if (_playingItemId == itemId) {
        // Stop playing
        _playingItemId = null;
        _progressController.stop();
        _progressController.reset();
        _ttsService.stop();
      } else {
        // Start playing
        _playingItemId = itemId;
        _progressController.reset();
        _progressController.forward();

        // Speak the target language word/phrase with correct language
        print(
          '🔊🔊🔊 LIBRARY SPEAKER BUTTON - Speaking: "$targetLanguageText" in $languageCode',
        );
        _ttsService
            .speak(targetLanguageText, languageCode: languageCode)
            .then((_) {
              print('✅ TTS completed for: $targetLanguageText');
            })
            .catchError((e) {
              print('❌ TTS error in callback: $e');
            });
      }
    });

    if (_playingItemId == itemId) {
      // Auto-stop after 3 seconds (approximate TTS duration)
      Future.delayed(Duration(seconds: 3), () {
        if (mounted && _playingItemId == itemId) {
          setState(() {
            _playingItemId = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get folder items from backend
    final folderItemsState = ref.watch(
      libraryFolderItemsControllerProvider(widget.folderId),
    );
    final allItems = folderItemsState.items;
    final filteredItems = _getFilteredItems(allItems);

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
                                    left: 29.w,
                                    top: 4.h,
                                    bottom: 4.h,
                                  ),
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
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
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
                    child: folderItemsState.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4ECDC4),
                            ),
                          )
                        : folderItemsState.errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64.sp,
                                    color: Colors.red,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    folderItemsState.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[700],
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Folder ID: ${widget.folderId}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[500],
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  ElevatedButton(
                                    onPressed: () {
                                      print(
                                        '🔄 Retrying to load items for ${widget.folderId}',
                                      );
                                      ref
                                          .read(
                                            libraryFolderItemsControllerProvider(
                                              widget.folderId,
                                            ).notifier,
                                          )
                                          .loadItems();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4ECDC4),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 32.w,
                                        vertical: 12.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Tekrar Dene',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

              // Bottom Navigation Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 8.h,
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
          SizedBox(
            height: 140.h,
          ), // Increased from 60.h to push everything further down
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

  Widget _buildItemCard(LibraryItemModel item, bool isPlaying) {
    return GestureDetector(
      onTap: null, // Disabled bottom sheet trigger
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
                            // For English: word is target, translation is Turkish
                            // For others: translation is target, word is Turkish
                            item.targetLanguage == 'en'
                                ? item.word
                                : item.translation,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.targetLanguage == 'en'
                                ? item.translation
                                : item.word,
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

                    // Audio and Bookmark buttons - YAN YANA
                    if (!_isEditMode)
                      Row(
                        children: [
                          // Audio Play Button
                          GestureDetector(
                            onTap: () => _playAudio(
                              item.itemId,
                              // Speak the target language word
                              item.targetLanguage == 'en'
                                  ? item.word
                                  : item.translation,
                              item.targetLanguage,
                            ),
                            child: Container(
                              width: 48.w,
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: Color(0xFFE0F7F4),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.all(12.w),
                              child: SvgPicture.asset(
                                'assets/icons/travelvocabularyseslendirme.svg',
                                width: 24.w,
                                height: 24.h,
                                color: Color(0xFF4ECDC4),
                              ),
                            ),
                          ),

                          SizedBox(width: 8.w),

                          // Bookmark Button (already saved) - BEYAZIMSI ARKAPLAN
                          Container(
                            width: 48.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: Color(0xFFF3F4F6), // Beyazımsı gri
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.all(12.w),
                            child: SvgPicture.asset(
                              'assets/icons/travelvocabularykaydet.svg',
                              width: 24.w,
                              height: 24.h,
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        ],
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
                onTap: () => _deleteItem(item.libraryItemId),
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
