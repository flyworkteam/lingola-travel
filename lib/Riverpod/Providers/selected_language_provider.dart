import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global provider that holds the currently selected target language code.
/// Updated when user changes language in Profile Settings and saves.
/// Watched by CourseView and TravelVocabularyView to reload content dynamically.
final selectedLanguageProvider = StateProvider<String>((ref) => 'en');
