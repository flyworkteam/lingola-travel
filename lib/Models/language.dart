/// Language model for app language selection
class Language {
  final String code;
  final String name;
  final String flagAsset;
  final Map<String, String>?
  localizedNames; // Localized names for different languages

  const Language({
    required this.code,
    required this.name,
    required this.flagAsset,
    this.localizedNames,
  });

  /// Get localized name based on current app language
  String getLocalizedName(String currentLanguageCode) {
    if (localizedNames != null &&
        localizedNames!.containsKey(currentLanguageCode)) {
      return localizedNames![currentLanguageCode]!;
    }
    return name; // Fallback to default name
  }
}

/// Available languages in the app
class AppLanguages {
  AppLanguages._();

  static const List<Language> all = [
    Language(
      code: 'en',
      name: 'English',
      flagAsset: 'assets/images/englishflag.png',
      localizedNames: {
        'tr': 'İngilizce',
        'es': 'Inglés',
        'fr': 'Anglais',
        'de': 'Englisch',
        'it': 'Inglese',
        'pt': 'Inglês',
        'ru': 'Английский',
        'ja': '英語',
        'ko': '영어',
        'hi': 'अंग्रेज़ी',
      },
    ),
    Language(
      code: 'tr',
      name: 'Türkçe',
      flagAsset: 'assets/images/turkishflag.png',
      localizedNames: {
        'en': 'Turkish',
        'es': 'Turco',
        'fr': 'Turc',
        'de': 'Türkisch',
        'it': 'Turco',
        'pt': 'Turco',
        'ru': 'Турецкий',
        'ja': 'トルコ語',
        'ko': '터키어',
        'hi': 'तुर्की',
      },
    ),
    Language(
      code: 'es',
      name: 'Español',
      flagAsset: 'assets/images/spanishflag.png',
      localizedNames: {
        'en': 'Spanish',
        'tr': 'İspanyolca',
        'fr': 'Espagnol',
        'de': 'Spanisch',
        'it': 'Spagnolo',
        'pt': 'Espanhol',
        'ru': 'Испанский',
        'ja': 'スペイン語',
        'ko': '스페인어',
        'hi': 'स्पेनिश',
      },
    ),
    Language(
      code: 'fr',
      name: 'Français',
      flagAsset: 'assets/images/frenchflag.png',
      localizedNames: {
        'en': 'French',
        'tr': 'Fransızca',
        'es': 'Francés',
        'de': 'Französisch',
        'it': 'Francese',
        'pt': 'Francês',
        'ru': 'Французский',
        'ja': 'フランス語',
        'ko': '프랑스어',
        'hi': 'फ़्रेंच',
      },
    ),
    Language(
      code: 'de',
      name: 'Deutsch',
      flagAsset: 'assets/images/germanflag.png',
      localizedNames: {
        'en': 'German',
        'tr': 'Almanca',
        'es': 'Alemán',
        'fr': 'Allemand',
        'it': 'Tedesco',
        'pt': 'Alemão',
        'ru': 'Немецкий',
        'ja': 'ドイツ語',
        'ko': '독일어',
        'hi': 'जर्मन',
      },
    ),
    Language(
      code: 'it',
      name: 'Italiano',
      flagAsset: 'assets/images/italianflag.png',
      localizedNames: {
        'en': 'Italian',
        'tr': 'İtalyanca',
        'es': 'Italiano',
        'fr': 'Italien',
        'de': 'Italienisch',
        'pt': 'Italiano',
        'ru': 'Итальянский',
        'ja': 'イタリア語',
        'ko': '이탈리아어',
        'hi': 'इतालवी',
      },
    ),
    Language(
      code: 'pt',
      name: 'Português',
      flagAsset: 'assets/images/portugalflag.png',
      localizedNames: {
        'en': 'Portuguese',
        'tr': 'Portekizce',
        'es': 'Portugués',
        'fr': 'Portugais',
        'de': 'Portugiesisch',
        'it': 'Portoghese',
        'ru': 'Португальский',
        'ja': 'ポルトガル語',
        'ko': '포르투갈어',
        'hi': 'पुर्तगाली',
      },
    ),
    Language(
      code: 'ru',
      name: 'Русский',
      flagAsset: 'assets/images/russianflag.png',
      localizedNames: {
        'en': 'Russian',
        'tr': 'Rusça',
        'es': 'Ruso',
        'fr': 'Russe',
        'de': 'Russisch',
        'it': 'Russo',
        'pt': 'Russo',
        'ja': 'ロシア語',
        'ko': '러시아어',
        'hi': 'रूसी',
      },
    ),
    Language(
      code: 'ja',
      name: '日本語',
      flagAsset: 'assets/images/japaneseflag.png',
      localizedNames: {
        'en': 'Japanese',
        'tr': 'Japonca',
        'es': 'Japonés',
        'fr': 'Japonais',
        'de': 'Japanisch',
        'it': 'Giapponese',
        'pt': 'Japonês',
        'ru': 'Японский',
        'ko': '일본어',
        'hi': 'जापानी',
      },
    ),
    Language(
      code: 'ko',
      name: '한국어',
      flagAsset: 'assets/images/koreanflag.png',
      localizedNames: {
        'en': 'Korean',
        'tr': 'Korece',
        'es': 'Coreano',
        'fr': 'Coréen',
        'de': 'Koreanisch',
        'it': 'Coreano',
        'pt': 'Coreano',
        'ru': 'Корейский',
        'ja': '韓国語',
        'hi': 'कोरियाई',
      },
    ),
    Language(
      code: 'hi',
      name: 'हिन्दी',
      flagAsset: 'assets/images/hindiflag.png',
      localizedNames: {
        'en': 'Hindi',
        'tr': 'Hintçe',
        'es': 'Hindi',
        'fr': 'Hindi',
        'de': 'Hindi',
        'it': 'Hindi',
        'pt': 'Hindi',
        'ru': 'Хинди',
        'ja': 'ヒンディー語',
        'ko': '힌디어',
      },
    ),
  ];

  static Language getByCode(String code) {
    return all.firstWhere(
      (lang) => lang.code == code,
      orElse: () => all.first, // Default to English
    );
  }
}
