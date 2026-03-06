import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class BunnyCdnService {
  // BunnyCDN Bilgilerin
  static const String _storageZone = 'lingola-travel';
  static const String _apiKey = 'd200d0d2-e1da-4883-82d03fdd4a43-ceb4-4d42';
  static const String _cdnUrl = 'https://lingola-travel.b-cdn.net';
  static const String _storageEndpoint = 'https://storage.bunnycdn.com';

  // Kendi API client'ından bağımsız, sadece bu servise özel temiz bir Dio instance'ı
  final Dio _dio = Dio();

  /// Fotoğrafı yükler ve başarılı olursa CDN URL'ini döndürür
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Dosya uzantısını alıp benzersiz bir isim oluşturuyoruz
      final extension = path.extension(imageFile.path);
      final uniqueFileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}$extension';

      final url = '$_storageEndpoint/$_storageZone/profiles/$uniqueFileName';

      // Dosyayı byte olarak okuyoruz
      final bytes = await imageFile.readAsBytes();

      // BunnyCDN PUT isteği ile doğrudan raw binary verisi bekler
      final response = await _dio.put(
        url,
        data: bytes,
        options: Options(
          headers: {
            'AccessKey': _apiKey,
            'Content-Type': 'application/octet-stream',
            'accept': 'application/json',
          },
        ),
      );

      // Yükleme başarılıysa URL'i dön
      if (response.statusCode == 201 || response.statusCode == 200) {
        return '$_cdnUrl/profiles/$uniqueFileName';
      }
      return null;
    } catch (e) {
      print('BunnyCDN Upload Hatası: $e');
      return null;
    }
  }
}
