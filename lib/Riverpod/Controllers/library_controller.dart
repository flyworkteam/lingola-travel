import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Models/library_model.dart';
import '../../Repositories/library_repository.dart';

/// Library View Model - Klasör listesi için state
class LibraryViewModel {
  final bool isLoading;
  final String? errorMessage;
  final List<LibraryFolderModel> folders;

  const LibraryViewModel({
    this.isLoading = false,
    this.errorMessage,
    this.folders = const [],
  });

  LibraryViewModel copyWith({
    bool? isLoading,
    String? errorMessage,
    List<LibraryFolderModel>? folders,
  }) {
    return LibraryViewModel(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      folders: folders ?? this.folders,
    );
  }
}

/// Library Controller - Klasörleri yönetir
class LibraryController extends StateNotifier<LibraryViewModel> {
  final LibraryRepository _libraryRepository = LibraryRepository();

  LibraryController() : super(const LibraryViewModel());

  /// Initialize library - load folders
  Future<void> init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await loadFolders();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Kütüphane yüklenemedi',
      );
    }
  }

  /// Update an existing folder
  Future<bool> updateFolder({
    required String folderId,
    required String name,
  }) async {
    try {
      final response = await _libraryRepository.updateFolder(
        folderId: folderId,
        name: name,
      );

      if (response.success) {
        await loadFolders(); // Listeyi yenile
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Load all library folders
  Future<void> loadFolders() async {
    try {
      final response = await _libraryRepository.getFolders();

      if (response.success && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          folders: response.data!,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.error?.message ?? 'Klasörler yüklenemedi',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network hatası: ${e.toString()}',
      );
    }
  }

  /// Create a new folder
  Future<bool> createFolder({required String name, String? color}) async {
    try {
      final response = await _libraryRepository.createFolder(
        name: name,
        color: color,
      );

      if (response.success) {
        await loadFolders(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete a folder
  Future<bool> deleteFolder(String folderId) async {
    try {
      final response = await _libraryRepository.deleteFolder(folderId);

      if (response.success) {
        await loadFolders(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Refresh folders
  Future<void> refresh() async {
    await loadFolders();
  }
}

/// Library Folder Items View Model - Klasör içindeki itemlar için state
class LibraryFolderItemsViewModel {
  final bool isLoading;
  final String? errorMessage;
  final List<LibraryItemModel> items;
  final String? folderName;

  const LibraryFolderItemsViewModel({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
    this.folderName,
  });

  LibraryFolderItemsViewModel copyWith({
    bool? isLoading,
    String? errorMessage,
    List<LibraryItemModel>? items,
    String? folderName,
  }) {
    return LibraryFolderItemsViewModel(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      items: items ?? this.items,
      folderName: folderName ?? this.folderName,
    );
  }
}

/// Library Folder Items Controller - Klasör itemlarını yönetir
class LibraryFolderItemsController
    extends StateNotifier<LibraryFolderItemsViewModel> {
  final LibraryRepository _libraryRepository = LibraryRepository();
  final String folderId;

  LibraryFolderItemsController({required this.folderId})
    : super(const LibraryFolderItemsViewModel());

  /// Initialize and load items
  Future<void> init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await loadItems();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'İtemler yüklenemedi',
      );
    }
  }

  /// Load items in folder
  Future<void> loadItems() async {
    try {
      print('📂 Loading items for folder: $folderId');
      final response = await _libraryRepository.getFolderItems(
        folderId: folderId,
        limit: 100,
      );

      print('📂 Response success: ${response.success}');
      print('📂 Response data: ${response.data?.length ?? 0} items');
      print('📂 Response error: ${response.error?.message}');

      if (response.success && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          items: response.data!,
          errorMessage: null,
        );
        print('✅ Loaded ${response.data!.length} items successfully');
      } else {
        final errorMsg = response.error?.message ?? 'İtemler yüklenemedi';
        print('❌ Error loading items: $errorMsg');
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      }
    } catch (e, stackTrace) {
      print('❌ Exception loading items: $e');
      print('❌ StackTrace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Remove an item from folder
  Future<bool> removeItem(int libraryItemId) async {
    try {
      final response = await _libraryRepository.removeItem(libraryItemId);

      if (response.success) {
        await loadItems(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Refresh items
  Future<void> refresh() async {
    await loadItems();
  }
}

/// Provider for Library Controller
final libraryControllerProvider =
    StateNotifierProvider<LibraryController, LibraryViewModel>((ref) {
      return LibraryController();
    });

/// Provider factory for Library Folder Items Controller
final libraryFolderItemsControllerProvider =
    StateNotifierProvider.family<
      LibraryFolderItemsController,
      LibraryFolderItemsViewModel,
      String
    >((ref, folderId) {
      return LibraryFolderItemsController(folderId: folderId);
    });
