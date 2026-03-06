import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/api_response.dart';
import '../Models/library_model.dart';
import 'base_repository.dart';
import 'profile_repository.dart';

/// Library Repository - Tamamen Lokal ve Kategorilere Ayrılmış (God Mode)
class LibraryRepository extends BaseRepository {
  final ProfileRepository _profileRepository = ProfileRepository();

  // 1. Kullanıcı ID'sini alan yardımcı metod
  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('current_user_id');

    if (userId == null) {
      try {
        final profileRes = await _profileRepository.getProfile();
        if (profileRes.success && profileRes.data != null) {
          userId = profileRes.data['user']['id'].toString();
          await prefs.setString('current_user_id', userId);
        }
      } catch (e) {
        debugPrint('Kullanıcı ID alınamadı: $e');
      }
    }
    return userId ?? 'guest_user';
  }

  /// Tüm klasörleri getirir (Yoksa 11 ana kategoriyi oluşturur)
  Future<ApiResponse<List<LibraryFolderModel>>> getFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();
      final String key = 'library_folders_$userId';

      final String? foldersJson = prefs.getString(key);
      List<LibraryFolderModel> folders = [];

      if (foldersJson != null) {
        final List<dynamic> decoded = jsonDecode(foldersJson);
        folders = decoded
            .map((json) => LibraryFolderModel.fromJson(json))
            .toList();
      }

      // ⚡ EĞER KLASÖRLER BOŞSA 11 ANA KATEGORİYİ SABİT ID'LERLE OLUŞTUR ⚡
      if (folders.isEmpty) {
        folders = [
          LibraryFolderModel(
            id: 'cat_general',
            name: 'General Essentials',
            color: '#FFD166',
            icon: 'assets/images/home/general.png',
            itemCount: 0,
            createdAt: DateTime.now(),
          ),
          LibraryFolderModel(
            id: 'cat_travel',
            name: 'Travel Essentials',
            color: '#B8A7FF',
            icon: 'assets/icons/airport.svg',
            itemCount: 0,
            createdAt: DateTime.now(),
          ),
          LibraryFolderModel(
            id: 'cat_accommodation',
            name: 'Accommodation Essentials',
            color: '#FF9F6A',
            icon: 'assets/icons/acc.svg',
            itemCount: 0,
            createdAt: DateTime.now(),
          ),
          LibraryFolderModel(
            id: 'cat_food',
            name: 'Food & Drink Essentials',
            color: '#FF8FA5',
            icon: 'assets/icons/ffff.svg',
            itemCount: 0,
            createdAt: DateTime.now(),
          ),
          LibraryFolderModel(
            id: 'cat_culture',
            name: 'Culture Essentials',
            color: '#B8D9FF',
            icon: 'assets/icons/culture.svg',
            itemCount: 0,
            createdAt: DateTime.now(),
          ),
          LibraryFolderModel(
            id: 'cat_shopping',
            name: 'Shopping Essentials',
            color: '#8BDDCD',
            icon: 'assets/icons/shopping.svg',
            itemCount: 0,
            createdAt: DateTime.now(),
          ),
          LibraryFolderModel(
            id: 'cat_direction',
            name: 'Direction Essentials',
            color: '#F9D26B',
            icon: 'assets/images/home/direction.png',
            itemCount: 0,
            createdAt: DateTime.now(),
          ),
          LibraryFolderModel(
            id: 'cat_sport',
            name: 'Sport Essentials',
            color: '#E4B3FF',
            icon: 'assets/icons/sport.svg',
            itemCount: 0,
            createdAt: DateTime.now(),
          ),
          LibraryFolderModel(
            id: 'cat_health',
            name: 'Health Essentials',
            color: '#B8FFC9',
            icon: 'assets/icons/health.svg',
            itemCount: 0,
            createdAt: DateTime.now(),
          ),
          LibraryFolderModel(
            id: 'cat_business',
            name: 'Business Essentials',
            color: '#A4C8E1',
            icon: 'assets/icons/business.png',
            itemCount: 0,
            createdAt: DateTime.now(),
          ),
          LibraryFolderModel(
            id: 'cat_emergency',
            name: 'Emergency Essentials',
            color: '#FF6B6B',
            icon: 'assets/images/home/emergency.png',
            itemCount: 0,
            createdAt: DateTime.now(),
          ),
        ];
        await prefs.setString(
          key,
          jsonEncode(folders.map((e) => e.toJson()).toList()),
        );
      }

      return ApiResponse(success: true, data: folders);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: ApiError(message: e.toString(), code: "404"),
      );
    }
  }

  // ⚡ GELEN KATEGORİ STRİNG'İNİ DOĞRU KLASÖRE YÖNLENDİREN RADAR SİSTEMİ ⚡
  String _getFolderIdByCategory(String? categoryKey) {
    if (categoryKey == null) return 'cat_general';
    final lower = categoryKey.toLowerCase();

    if (lower.contains('general')) return 'cat_general';
    if (lower.contains('travel')) return 'cat_travel';
    if (lower.contains('accommodation')) return 'cat_accommodation';
    if (lower.contains('food')) return 'cat_food';
    if (lower.contains('culture')) return 'cat_culture';
    if (lower.contains('shop')) return 'cat_shopping';
    if (lower.contains('direction')) return 'cat_direction';
    if (lower.contains('sport')) return 'cat_sport';
    if (lower.contains('health')) return 'cat_health';
    if (lower.contains('business')) return 'cat_business';
    if (lower.contains('emergency')) return 'cat_emergency';

    return 'cat_general'; // Hiçbiri tutmazsa varsayılan olarak General'a atsın
  }

  /// Belirli bir klasördeki kelimeleri/cümleleri getirir
  Future<ApiResponse<List<LibraryItemModel>>> getFolderItems({
    required String folderId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();
      final String key = 'folder_items_${userId}_$folderId';

      final String? itemsJson = prefs.getString(key);

      if (itemsJson != null) {
        final List<dynamic> decoded = jsonDecode(itemsJson);
        final items = decoded
            .map((json) => LibraryItemModel.fromJson(json))
            .toList();
        return ApiResponse(success: true, data: items);
      }

      return ApiResponse(success: true, data: []);
    } catch (e) {
      return ApiResponse(
        success: false,
        error: ApiError(message: e.toString(), code: "404"),
      );
    }
  }

  /// Favorilere öğe ekler (Radar sistemiyle doğru klasörü bulur)
  Future<ApiResponse<bool>> addBookmark({
    required String itemType,
    required String itemId,
    required String word,
    required String translation,
    String? category,
  }) async {
    try {
      // Klasörlerin var olduğundan emin ol
      await getFolders();

      // Radar metodumuzla bu öğenin hangi klasöre gideceğini nokta atışı buluyoruz
      String targetFolderId = _getFolderIdByCategory(category);

      // Öğeyi o klasöre kaydediyoruz
      return await addItemToFolder(
        folderId: targetFolderId,
        itemType: itemType,
        itemId: itemId,
        word: word,
        translation: translation,
      );
    } catch (e) {
      return ApiResponse(success: false);
    }
  }

  /// Belirli bir klasöre öğeyi (Model verileriyle) ekler
  Future<ApiResponse<bool>> addItemToFolder({
    required String folderId,
    required String itemType,
    required String itemId,
    required String word,
    required String translation,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();

      final response = await getFolderItems(folderId: folderId);
      List<LibraryItemModel> items = response.success && response.data != null
          ? response.data!
          : [];

      // Öğe zaten ekli mi kontrol et
      if (items.any(
        (item) => item.itemId == itemId && item.itemType == itemType,
      )) {
        return ApiResponse(success: true, data: true);
      }

      final newItem = LibraryItemModel(
        libraryItemId: DateTime.now().millisecondsSinceEpoch,
        itemType: itemType,
        itemId: itemId,
        word: word,
        translation: translation,
        audioUrl: null,
        imageUrl: null,
        category: null,
        sourceLanguage: 'tr',
        targetLanguage: 'en',
        createdAt: DateTime.now(),
      );

      items.insert(0, newItem);

      await prefs.setString(
        'folder_items_${userId}_$folderId',
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );

      // Klasörün içindeki sayıyı +1 artır
      await _updateFolderItemCount(folderId, 1);

      return ApiResponse(success: true, data: true);
    } catch (e) {
      debugPrint('AddItemToFolder error: $e');
      return ApiResponse(success: false);
    }
  }

  /// Favorilerden öğe çıkartır (Tüm klasörleri tarayarak siler)
  Future<ApiResponse<bool>> removeBookmarkByItem({
    required String itemType,
    required String itemId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();

      final foldersRes = await getFolders();
      if (!foldersRes.success || foldersRes.data == null)
        return ApiResponse(success: false);

      bool isRemoved = false;

      for (var folder in foldersRes.data!) {
        final itemsRes = await getFolderItems(folderId: folder.id);
        if (itemsRes.success && itemsRes.data != null) {
          final items = itemsRes.data!;
          final initialLength = items.length;

          items.removeWhere(
            (item) => item.itemId == itemId && item.itemType == itemType,
          );

          if (items.length < initialLength) {
            await prefs.setString(
              'folder_items_${userId}_${folder.id}',
              jsonEncode(items.map((e) => e.toJson()).toList()),
            );
            await _updateFolderItemCount(folder.id, -1);
            isRemoved = true;
          }
        }
      }
      return ApiResponse(success: isRemoved, data: isRemoved);
    } catch (e) {
      return ApiResponse(success: false);
    }
  }

  /// Kütüphaneden doğrudan (libraryItemId ile) çıkartır
  Future<ApiResponse<bool>> removeItem(int libraryItemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();

      final foldersRes = await getFolders();
      if (!foldersRes.success || foldersRes.data == null)
        return ApiResponse(success: false);

      for (var folder in foldersRes.data!) {
        final itemsRes = await getFolderItems(folderId: folder.id);
        if (itemsRes.success && itemsRes.data != null) {
          final items = itemsRes.data!;
          final initialLength = items.length;

          items.removeWhere((item) => item.libraryItemId == libraryItemId);

          if (items.length < initialLength) {
            await prefs.setString(
              'folder_items_${userId}_${folder.id}',
              jsonEncode(items.map((e) => e.toJson()).toList()),
            );
            await _updateFolderItemCount(folder.id, -1);
            return ApiResponse(success: true, data: true);
          }
        }
      }
      return ApiResponse(success: true, data: true);
    } catch (e) {
      return ApiResponse(success: false);
    }
  }

  /// Klasör rengini/adını günceller
  Future<ApiResponse<bool>> updateFolder({
    required String folderId,
    required String name,
    String? color,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();
      final response = await getFolders();

      if (response.success && response.data != null) {
        final folders = response.data!;
        final index = folders.indexWhere((f) => f.id == folderId);

        if (index != -1) {
          final old = folders[index];
          folders[index] = LibraryFolderModel(
            id: old.id,
            name: name,
            color: color ?? old.color,
            icon: old.icon,
            itemCount: old.itemCount,
            createdAt: old.createdAt,
          );

          await prefs.setString(
            'library_folders_$userId',
            jsonEncode(folders.map((e) => e.toJson()).toList()),
          );
          return ApiResponse(success: true, data: true);
        }
      }
      return ApiResponse(success: false);
    } catch (e) {
      return ApiResponse(success: false);
    }
  }

  /// Yeni klasör oluşturur
  Future<ApiResponse<LibraryFolderModel>> createFolder({
    required String name,
    String? color,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();
      final response = await getFolders();

      List<LibraryFolderModel> folders =
          response.success && response.data != null ? response.data! : [];

      final newFolder = LibraryFolderModel(
        id: 'local_folder_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        color: color ?? '#3B82F6',
        icon: 'assets/images/home/general.png',
        itemCount: 0,
        createdAt: DateTime.now(),
      );

      folders.add(newFolder);
      await prefs.setString(
        'library_folders_$userId',
        jsonEncode(folders.map((e) => e.toJson()).toList()),
      );

      return ApiResponse(success: true, data: newFolder);
    } catch (e) {
      return ApiResponse(success: false);
    }
  }

  /// Klasörü ve içindekileri siler
  Future<ApiResponse<bool>> deleteFolder(String folderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();
      final response = await getFolders();

      if (response.success && response.data != null) {
        final folders = response.data!;
        folders.removeWhere((f) => f.id == folderId);

        await prefs.setString(
          'library_folders_$userId',
          jsonEncode(folders.map((e) => e.toJson()).toList()),
        );
        await prefs.remove('folder_items_${userId}_$folderId');

        return ApiResponse(success: true, data: true);
      }
      return ApiResponse(success: false);
    } catch (e) {
      return ApiResponse(success: false);
    }
  }

  // --- YARDIMCI METOD ---
  // Klasördeki kelime sayısını UI'da güncel tutmak için artırır veya azaltır
  Future<void> _updateFolderItemCount(String folderId, int change) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _getUserId();
      final foldersRes = await getFolders();

      if (foldersRes.success && foldersRes.data != null) {
        final folders = foldersRes.data!;
        final index = folders.indexWhere((f) => f.id == folderId);

        if (index != -1) {
          final old = folders[index];
          int newCount = old.itemCount + change;
          if (newCount < 0) newCount = 0;

          folders[index] = LibraryFolderModel(
            id: old.id,
            name: old.name,
            color: old.color,
            icon: old.icon,
            itemCount: newCount,
            createdAt: old.createdAt,
          );

          await prefs.setString(
            'library_folders_$userId',
            jsonEncode(folders.map((e) => e.toJson()).toList()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating item count: $e');
    }
  }
}
