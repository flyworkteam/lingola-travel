/// Language model for app language selection
class Language {
  final String code;
  final String name;
  final String flagAsset;

  const Language({
    required this.code,
    required this.name,
    required this.flagAsset,
  });
}

/// Available languages in the app
class AppLanguages {
  AppLanguages._();

  static const List<Language> all = [
    Language(
      code: 'en',
      name: 'English',
      flagAsset: 'assets/images/englishflag.png',
    ),
    Language(
      code: 'tr',
      name: 'Türkçe',
      flagAsset: 'assets/images/turkishflag.png',
    ),
    Language(
      code: 'es',
      name: 'Español',
      flagAsset: 'assets/images/spanishflag.png',
    ),
    Language(
      code: 'fr',
      name: 'Français',
      flagAsset: 'assets/images/frenchflag.png',
    ),
    Language(
      code: 'de',
      name: 'Deutsch',
      flagAsset: 'assets/images/germanflag.png',
    ),
    Language(
      code: 'it',
      name: 'Italiano',
      flagAsset: 'assets/images/italianflag.png',
    ),
    Language(
      code: 'pt',
      name: 'Português',
      flagAsset: 'assets/images/portugalflag.png',
    ),
    Language(
      code: 'ru',
      name: 'Русский',
      flagAsset: 'assets/images/russianflag.png',
    ),
    Language(
      code: 'ja',
      name: '日本語',
      flagAsset: 'assets/images/japaneseflag.png',
    ),
    Language(
      code: 'ko',
      name: '한국어',
      flagAsset: 'assets/images/koreanflag.png',
    ),
    Language(
      code: 'hi',
      name: 'हिन्दी',
      flagAsset: 'assets/images/hindiflag.png',
    ),
  ];

  static Language getByCode(String code) {
    return all.firstWhere(
      (lang) => lang.code == code,
      orElse: () => all.first, // Default to English
    );
  }
}
