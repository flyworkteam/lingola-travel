import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isInitializing = false;
  String? _currentLanguage;

  Future<void> init() async {
    if (_isInitialized) return;
    if (_isInitializing) {
      // Wait for ongoing initialization
      while (_isInitializing) {
        await Future.delayed(Duration(milliseconds: 50));
      }
      return;
    }

    _isInitializing = true;

    try {
      print('🔊 TTS: Initializing...');

      // Set language to English
      await _flutterTts.setLanguage("en-US");
      print('🔊 TTS: Language set to en-US');

      // Set speech rate (0.0 to 1.0, slower for better clarity)
      await _flutterTts.setSpeechRate(0.4);
      print('🔊 TTS: Speech rate set to 0.4');

      // Set volume to MAXIMUM (0.0 to 1.0)
      await _flutterTts.setVolume(1.0);
      print('🔊 TTS: Volume set to maximum (1.0)');

      // Set pitch (0.0 to 2.0, default is 1.0)
      await _flutterTts.setPitch(1.2);
      print('🔊 TTS: Pitch set to 1.2');

      // Set additional properties for Android
      await _flutterTts.awaitSpeakCompletion(true);
      print('🔊 TTS: Await speak completion enabled');

      _isInitialized = true;
      print('✅ TTS Service initialized successfully');
    } catch (e) {
      print('❌ TTS initialization error: $e');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> speak(String text, {String? languageCode}) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      print('🔊 TTS: Attempting to speak: "$text"');

      // Set language if provided and different from current
      if (languageCode != null && languageCode != _currentLanguage) {
        String ttsLanguage = _mapLanguageCode(languageCode);
        await _flutterTts.setLanguage(ttsLanguage);
        _currentLanguage = languageCode;
        print(
          '🔊 TTS: Language changed to $ttsLanguage for code $languageCode',
        );
      }

      // Speak the text - awaitSpeakCompletion(true) is already set in init()
      final result = await _flutterTts.speak(text);
      print('🔊 TTS: Speak completed with result: $result');
    } catch (e) {
      print('❌ TTS speak error: $e');
    }
  }

  // Map ISO 639-1 language codes to TTS language codes
  String _mapLanguageCode(String code) {
    switch (code) {
      case 'en':
        return 'en-US';
      case 'de':
        return 'de-DE';
      case 'it':
        return 'it-IT';
      case 'fr':
        return 'fr-FR';
      case 'ja':
        return 'ja-JP';
      case 'es':
        return 'es-ES';
      case 'ru':
        return 'ru-RU';
      case 'tr':
        return 'tr-TR';
      case 'ko':
        return 'ko-KR';
      case 'hi':
        return 'hi-IN';
      case 'pt':
        return 'pt-PT';
      default:
        return 'en-US';
    }
  }

  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.stop();
    } catch (e) {
      print('❌ TTS stop error: $e');
    }
  }

  Future<void> pause() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.pause();
    } catch (e) {
      print('❌ TTS pause error: $e');
    }
  }

  Future<bool> get isSpeaking async {
    try {
      final speaking = await _flutterTts.awaitSpeakCompletion(false);
      return speaking;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}
