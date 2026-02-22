import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

/// Holds and persists the selected app locale code (e.g. 'en', 'tr').
/// Default is English ('en') for initial onboarding.
class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('en') {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLocaleKey);

    // If user has previously selected a language, use it
    // Otherwise keep default 'en' for onboarding
    if (saved != null && saved.isNotEmpty) {
      state = saved;
    }
  }

  Future<void> setLocale(String langCode) async {
    state = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, langCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, String>(
  (ref) => LocaleNotifier(),
);
