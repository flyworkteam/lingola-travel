class Language {
  final String code;
  final String name; // English name
  final String nativeName; // Name in the language's native script
  final String flag;

  Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  static List<Language> getAllLanguages() {
    return [
      Language(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
      Language(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
      Language(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
      Language(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
      Language(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
      Language(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
      Language(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
      Language(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
      Language(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
      Language(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
      Language(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
    ];
  }
}
