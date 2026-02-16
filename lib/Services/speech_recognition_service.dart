import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Speech Recognition Service - Handles speech-to-text functionality
class SpeechRecognitionService {
  static final SpeechRecognitionService _instance =
      SpeechRecognitionService._internal();
  factory SpeechRecognitionService() => _instance;
  SpeechRecognitionService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      print('🎤 Initializing speech recognition...');

      // Request microphone permission
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        print('❌ Microphone permission denied');
        return false;
      }

      // Initialize SpeechToText
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          print('❌ Speech recognition error: ${error.errorMsg}');
          _isListening = false;
        },
        onStatus: (status) {
          print('🎤 Speech recognition status: $status');
          _isListening = status == 'listening';
        },
      );

      if (_isInitialized) {
        print('✅ Speech recognition initialized');
      } else {
        print('❌ Failed to initialize speech recognition');
      }

      return _isInitialized;
    } catch (e) {
      print('❌ Error initializing speech recognition: $e');
      return false;
    }
  }

  /// Start listening
  Future<void> startListening({
    required String languageCode,
    required Function(String) onResult,
    Function(String)? onPartialResult,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    try {
      print('🎤 Starting to listen in language: $languageCode');

      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            print('✅ Final result: ${result.recognizedWords}');
            onResult(result.recognizedWords);
          } else if (onPartialResult != null) {
            print('📝 Partial result: ${result.recognizedWords}');
            onPartialResult(result.recognizedWords);
          }
        },
        localeId: _mapLanguageCode(languageCode),
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: onPartialResult != null,
      );

      _isListening = true;
    } catch (e) {
      print('❌ Error starting to listen: $e');
      _isListening = false;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      print('🎤 Stopping listening...');
      await _speechToText.stop();
      _isListening = false;
      print('✅ Stopped listening');
    } catch (e) {
      print('❌ Error stopping listening: $e');
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      print('🎤 Canceling listening...');
      await _speechToText.cancel();
      _isListening = false;
      print('✅ Canceled listening');
    } catch (e) {
      print('❌ Error canceling listening: $e');
    }
  }

  /// Get available locales
  Future<List<String>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }

    final locales = await _speechToText.locales();
    return locales.map((locale) => locale.localeId).toList();
  }

  /// Map language codes to speech recognition locale IDs
  String _mapLanguageCode(String code) {
    switch (code) {
      case 'en':
        return 'en_US';
      case 'it':
        return 'it_IT';
      case 'fr':
        return 'fr_FR';
      case 'de':
        return 'de_DE';
      case 'es':
        return 'es_ES';
      case 'ja':
        return 'ja_JP';
      case 'pt':
        return 'pt_PT';
      case 'ru':
        return 'ru_RU';
      case 'ko':
        return 'ko_KR';
      case 'hi':
        return 'hi_IN';
      case 'tr':
        return 'tr_TR';
      default:
        return 'en_US';
    }
  }

  /// Compare recognized text with target sentence
  /// Returns a similarity score (0.0 to 1.0)
  double compareTexts(String recognized, String target) {
    // Normalize texts
    final normalizedRecognized = recognized.toLowerCase().trim();
    final normalizedTarget = target.toLowerCase().trim();

    if (normalizedRecognized == normalizedTarget) {
      return 1.0; // Perfect match
    }

    // Calculate Levenshtein distance
    final distance = _levenshteinDistance(
      normalizedRecognized,
      normalizedTarget,
    );
    final maxLength = normalizedTarget.length.toDouble();
    final similarity = 1.0 - (distance / maxLength);

    return similarity.clamp(0.0, 1.0);
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    final matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    for (var i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  /// Check if speech recognition is available on device
  Future<bool> isAvailable() async {
    return await _speechToText.initialize();
  }

  /// Dispose resources
  void dispose() {
    if (_isListening) {
      _speechToText.stop();
    }
  }
}
