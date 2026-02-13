import '../Models/api_response.dart';
import '../Services/api_client.dart';
import 'base_repository.dart';

/// Library Repository - Handles user's saved/bookmarked content
class LibraryRepository extends BaseRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get all library folders
  Future<ApiResponse<List<Map<String, dynamic>>>> getFolders() async {
    try {
      final response = await _apiClient.get('/library/folders');

      if (response.success && response.data != null) {
        final List<dynamic> foldersJson = response.data['folders'] ?? [];
        final folders = foldersJson
            .map((json) => json as Map<String, dynamic>)
            .toList();

        return ApiResponse(success: true, data: folders);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Get items in a specific folder
  Future<ApiResponse<List<Map<String, dynamic>>>> getFolderItems({
    required int folderId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/library/folders/$folderId/items',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.success && response.data != null) {
        final List<dynamic> itemsJson = response.data['items'] ?? [];
        final items = itemsJson
            .map((json) => json as Map<String, dynamic>)
            .toList();

        return ApiResponse(success: true, data: items);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Save/bookmark an item to library
  Future<ApiResponse<bool>> saveItem({
    required int folderId,
    required String itemType, // 'word', 'phrase', 'lesson'
    required int itemId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/library/items',
        data: {'folder_id': folderId, 'item_type': itemType, 'item_id': itemId},
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
  Future<ApiResponse<bool>> removeItem(int itemId) async {
    try {
      final response = await _apiClient.delete('/library/items/$itemId');

      return ApiResponse(
        success: response.success,
        data: response.success,
        error: response.error,
      );
    } catch (e) {
      return handleError(e);
    }
  }

  /// Check if item is saved
  Future<ApiResponse<bool>> isItemSaved({
    required String itemType,
    required int itemId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/library/check',
        queryParameters: {'item_type': itemType, 'item_id': itemId},
      );

      if (response.success && response.data != null) {
        final isSaved = response.data['is_saved'] as bool? ?? false;
        return ApiResponse(success: true, data: isSaved);
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Create a new folder
  Future<ApiResponse<Map<String, dynamic>>> createFolder({
    required String name,
    required String nameTr,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        '/library/folders',
        data: {
          'name': name,
          'name_tr': nameTr,
          if (description != null) 'description': description,
        },
      );

      if (response.success && response.data != null) {
        return ApiResponse(
          success: true,
          data: response.data as Map<String, dynamic>,
        );
      }

      return ApiResponse(success: false, error: response.error);
    } catch (e) {
      return handleError(e);
    }
  }

  /// Delete a folder
  Future<ApiResponse<bool>> deleteFolder(int folderId) async {
    try {
      final response = await _apiClient.delete('/library/folders/$folderId');

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
