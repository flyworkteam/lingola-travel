import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Core/Config/app_config.dart';

/// Secure Storage Service for sensitive data
/// Uses flutter_secure_storage for encrypted storage
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  SecureStorageService._internal();

  // Token Management
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: AppConfig.keyAccessToken, value: token);
      print('💾 Token saved to secure storage');

      // Verify it was saved
      final verified = await _storage.read(key: AppConfig.keyAccessToken);
      if (verified == token) {
        print('✅ Token save verified successfully');
      } else {
        print('⚠️ Token verification failed!');
      }
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: AppConfig.keyAccessToken);
      if (token != null) {
        print('✅ Token retrieved from storage: ${token.substring(0, 20)}...');
      } else {
        print('⚠️ No token found in secure storage');
      }
      return token;
    } catch (e) {
      print('❌ Error reading token: $e');
      return null;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConfig.keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConfig.keyRefreshToken);
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: AppConfig.keyAccessToken);
    await _storage.delete(key: AppConfig.keyRefreshToken);
  }

  // User Data
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConfig.keyUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: AppConfig.keyUserId);
  }

  Future<void> saveUserProfile(String profileJson) async {
    await _storage.write(key: AppConfig.keyUserProfile, value: profileJson);
  }

  Future<String?> getUserProfile() async {
    return await _storage.read(key: AppConfig.keyUserProfile);
  }

  // Generic Methods
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all user data (logout)
  Future<void> clearUserData() async {
    await deleteTokens();
    await delete(AppConfig.keyUserId);
    await delete(AppConfig.keyUserProfile);
  }
}
