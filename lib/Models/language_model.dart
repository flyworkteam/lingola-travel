class Language {
  final String code;
  final String name;
  final String flag;

  Language({required this.code, required this.name, required this.flag});

  static List<Language> getAllLanguages() {
    return [
      Language(code: 'en', name: 'English', flag: '🇬🇧'),
      Language(code: 'de', name: 'German', flag: '🇩🇪'),
      Language(code: 'it', name: 'Italian', flag: '🇮🇹'),
      Language(code: 'fr', name: 'French', flag: '🇫🇷'),
      Language(code: 'ja', name: 'Japanese', flag: '🇯🇵'),
      Language(code: 'es', name: 'Spanish', flag: '🇪🇸'),
      Language(code: 'ru', name: 'Russian', flag: '🇷🇺'),
      Language(code: 'tr', name: 'Turkish', flag: '🇹🇷'),
      Language(code: 'ko', name: 'Korean', flag: '🇰🇷'),
      Language(code: 'hi', name: 'Hindi', flag: '🇮🇳'),
      Language(code: 'pt', name: 'Portuguese', flag: '🇵🇹'),
    ];
  }
}
