import '../Models/api_response.dart';
import '../Models/library_model.dart';
import 'base_repository.dart';

/// Library Repository - Handles user's saved/bookmarked content
class LibraryRepository extends BaseRepository {
  /// Get all library folders
  Future<ApiResponse<List<LibraryFolderModel>>> getFolders() async {
    try {
      final response = await apiClient.get('/library/folders');

      if (response.success && response.data != null) {
        final List<dynamic> foldersJson = response.data['folders'] ?? [];
        final folders = foldersJson
            .map(
              (json) =>
                  LibraryFolderModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return ApiResponse(success: true, data: folders);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get items in a specific folder
  Future<ApiResponse<List<LibraryItemModel>>> getFolderItems({
    required String folderId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get(
        '/library/folders/$folderId/items',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.success && response.data != null) {
        final List<dynamic> itemsJson = response.data['items'] ?? [];
        final items = itemsJson
            .map(
              (json) => LibraryItemModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return ApiResponse(success: true, data: items);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  Future<ApiResponse<bool>> updateFolder({
    required String folderId,
    required String name,
    String? color,
  }) async {
    try {
      final response = await apiClient.put(
        '/library/folders/$folderId',
        data: {'name': name, 'color': color ?? '#3B82F6'},
      );
      return ApiResponse(success: response.success);
    } catch (e) {
      return ApiResponse(success: false);
    }
  }

  /// Add an item (word or phrase) to a folder
  /// GÜNCELLENDİ: Artık word ve translation değerlerini de backend'e yolluyoruz.
  Future<ApiResponse<bool>> addItemToFolder({
    required String folderId,
    required String
    itemType, // 'dictionary_word', 'travel_phrase', 'lesson_vocabulary'
    required String itemId,
    required String word,
    required String translation,
  }) async {
    try {
      final response = await apiClient.post(
        '/library/folders/$folderId/items',
        data: {
          'item_type': itemType,
          'item_id': itemId,
          'word': word,
          'translation': translation,
        },
      );

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }

  /// Add a bookmark (without folder)
  /// GÜNCELLENDİ: Artık word ve translation değerlerini de backend'e yolluyoruz.
  Future<ApiResponse<bool>> addBookmark({
    required String
    itemType, // 'dictionary_word', 'travel_phrase', 'lesson_vocabulary'
    required String itemId,
    required String word,
    required String translation,
    String? category,
  }) async {
    try {
      final response = await apiClient.post(
        '/library/bookmarks',
        data: {
          'item_type': itemType,
          'item_id': itemId,
          'word': word,
          'translation': translation,
          if (category != null) 'category': category,
        },
      );

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }

  /// Remove bookmark by item details
  Future<ApiResponse<bool>> removeBookmarkByItem({
    required String itemType,
    required String itemId,
  }) async {
    try {
      // Doğrudan item_id ve item_type ile DELETE isteği atıyoruz
      final response = await apiClient.delete(
        '/library/bookmarks/$itemId',
        queryParameters: {'item_type': itemType},
      );

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }

  /// Remove item from library
  Future<ApiResponse<bool>> removeItem(int libraryItemId) async {
    try {
      final response = await apiClient.delete('/library/items/$libraryItemId');

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }

  /// Create a new folder
  Future<ApiResponse<LibraryFolderModel>> createFolder({
    required String name,
    String? color,
  }) async {
    try {
      final response = await apiClient.post(
        '/library/folders',
        data: {'name': name, if (color != null) 'color': color},
      );

      if (response.success && response.data != null) {
        final folder = LibraryFolderModel.fromJson(
          response.data['folder'] as Map<String, dynamic>,
        );
        return ApiResponse(success: true, data: folder);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Delete a folder
  Future<ApiResponse<bool>> deleteFolder(String folderId) async {
    try {
      final response = await apiClient.delete('/library/folders/$folderId');

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }
}
