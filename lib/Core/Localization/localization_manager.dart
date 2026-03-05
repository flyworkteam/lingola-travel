import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lokalizasyon durumunu (Locale nesnesi) yönetir.
class LocalizationManager extends StateNotifier<Locale> {
  LocalizationManager() : super(defaultLocale);

  /// Fotoğraftaki tüm JSON dosyalarına karşılık gelen desteklenen diller
  static const List<Locale> supportedLocales = [
    Locale('de', 'DE'), // Almanca
    Locale('en', 'US'), // İngilizce
    Locale('es', 'ES'), // İspanyolca
    Locale('fr', 'FR'), // Fransızca
    Locale('hi', 'IN'), // Hintçe
    Locale('it', 'IT'), // İtalyanca
    Locale('ja', 'JP'), // Japonca
    Locale('ko', 'KR'), // Korece
    Locale('pt', 'PT'), // Portekizce
    Locale('ru', 'RU'), // Rusça
    Locale('tr', 'TR'), // Türkçe
  ];

  static const String path = 'assets/translations';

  // Varsayılan dil (İsteğe bağlı olarak değiştirebilirsiniz)
  static const Locale defaultLocale = Locale('en', 'US');

  static Locale currentLocale(BuildContext context) {
    return context.locale;
  }

  Future<void> changeLanguage(BuildContext context, Locale newLocale) async {
    if (supportedLocales.contains(newLocale) && context.locale != newLocale) {
      await context.setLocale(newLocale); // İşlemin bitmesini bekleyin
      state = newLocale; // State'i güncelleyerek Riverpod'u tetikleyin
    }
  }
}

// Riverpod Provider (Legacy kullanımı yerine güncel kullanımı önerilir)
final localizationManagerProvider =
    StateNotifierProvider<LocalizationManager, Locale>((ref) {
      return LocalizationManager();
    });
