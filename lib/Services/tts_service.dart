import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

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
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      print('🔊 TTS: Attempting to speak: "$text"');

      // Check if TTS is available
      final isAvailable = await _flutterTts.awaitSpeakCompletion(false);
      print('🔊 TTS: Service available: $isAvailable');

      // Get available languages
      final languages = await _flutterTts.getLanguages;
      print('🔊 TTS: Available languages: $languages');

      // Get current language
      final currentLang = await _flutterTts.getDefaultEngine;
      print('🔊 TTS: Current engine: $currentLang');

      final result = await _flutterTts.speak(text);
      print('🔊 TTS: Speak result: $result');
    } catch (e) {
      print('❌ TTS speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('❌ TTS stop error: $e');
    }
  }

  Future<void> pause() async {
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
