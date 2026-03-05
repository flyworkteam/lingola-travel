import 'package:lingola_travel/Models/language_model.dart';

class AppLanguages {
  AppLanguages._();

  static const List<Language> all = [
    Language(
      code: 'en',
      countryCode: 'US',
      nativeName: 'English',
      flagAsset: 'assets/images/englishflag.png',
    ),
    Language(
      code: 'tr',
      countryCode: 'TR',
      nativeName: 'Türkçe',
      flagAsset: 'assets/images/turkishflag.png',
    ),
    Language(
      code: 'de',
      countryCode: 'DE',
      nativeName: 'Deutsch',
      flagAsset: 'assets/images/germanflag.png',
    ),
    Language(
      code: 'es',
      countryCode: 'ES',
      nativeName: 'Español',
      flagAsset: 'assets/images/spanishflag.png',
    ),
    Language(
      code: 'fr',
      countryCode: 'FR',
      nativeName: 'Français',
      flagAsset: 'assets/images/frenchflag.png',
    ),
    Language(
      code: 'hi',
      countryCode: 'IN',
      nativeName: 'हिन्दी',
      flagAsset: 'assets/images/hindiflag.png',
    ),
    Language(
      code: 'it',
      countryCode: 'IT',
      nativeName: 'Italiano',
      flagAsset: 'assets/images/italianflag.png',
    ),
    Language(
      code: 'ja',
      countryCode: 'JP',
      nativeName: '日本語',
      flagAsset: 'assets/images/japaneseflag.png',
    ),
    Language(
      code: 'ko',
      countryCode: 'KR',
      nativeName: '한국어',
      flagAsset: 'assets/images/koreanflag.png',
    ),
    Language(
      code: 'pt',
      countryCode: 'PT',
      nativeName: 'Português',
      flagAsset: 'assets/images/portugalflag.png',
    ),
    Language(
      code: 'ru',
      countryCode: 'RU',
      nativeName: 'Русский',
      flagAsset: 'assets/images/russianflag.png',
    ),
  ];

  static Language getByCode(String code) {
    return all.firstWhere((lang) => lang.code == code, orElse: () => all.first);
  }
}
