import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';
const _kLocaleUserSetKey =
    'app_locale_user_set'; // Track if user manually changed

/// Holds and persists the selected app locale code (e.g. 'en', 'tr').
/// Default is system language. Updates with system language unless user manually changed it.
class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super(_getSystemLocale()) {
    _load();
  }

  /// Get the system's language code, fallback to 'en' if unsupported
  static String _getSystemLocale() {
    final systemLocale = ui.PlatformDispatcher.instance.locale.languageCode;

    // Supported languages
    const supportedLangs = [
      'en',
      'tr',
      'es',
      'fr',
      'de',
      'it',
      'pt',
      'ru',
      'ja',
      'ko',
      'hi',
    ];

    // Return system language if supported, otherwise fallback to English
    return supportedLangs.contains(systemLocale) ? systemLocale : 'en';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final userSet = prefs.getBool(_kLocaleUserSetKey) ?? false;

    // If user manually set a language, use it
    // Otherwise always use current system language
    if (userSet) {
      final saved = prefs.getString(_kLocaleKey);
      if (saved != null && saved.isNotEmpty) {
        state = saved;
      }
    } else {
      // Always use system language for onboarding
      state = _getSystemLocale();
    }
  }

  /// Set locale manually (from settings page)
  /// This marks the locale as user-set so it won't follow system changes
  Future<void> setLocale(String langCode) async {
    state = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, langCode);
    await prefs.setBool(_kLocaleUserSetKey, true); // Mark as user-set
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, String>(
  (ref) => LocaleNotifier(),
);
