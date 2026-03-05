import 'package:easy_localization/easy_localization.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';

class Language {
  final String code; // Örn: 'en'
  final String countryCode; // Örn: 'US'
  final String flagAsset; // Örn: 'assets/images/englishflag.png'
  final String
  nativeName; // Dilin kendi ana dilindeki adı (Örn: 'Türkçe', 'English')

  const Language({
    required this.code,
    required this.countryCode,
    required this.flagAsset,
    required this.nativeName,
  });

  // Uygulamanın o anki diline göre çevrilmiş ismi getirir
  // Örn: Uygulama Türkçeyse 'İngilizce', İngilizceyse 'English' döner.
  String getTranslatedName() {
    switch (code) {
      case 'en':
        return LocaleKeys.lang_english.tr();
      case 'tr':
        return LocaleKeys.lang_turkish.tr();
      case 'de':
        return LocaleKeys.lang_german.tr();
      case 'es':
        return LocaleKeys.lang_spanish.tr();
      case 'fr':
        return LocaleKeys.lang_french.tr();
      case 'hi':
        return LocaleKeys.lang_hindi.tr();
      case 'it':
        return LocaleKeys.lang_italian.tr();
      case 'ja':
        return LocaleKeys.lang_japanese.tr();
      case 'ko':
        return LocaleKeys.lang_korean.tr();
      case 'pt':
        return LocaleKeys.lang_portuguese.tr();
      case 'ru':
        return LocaleKeys.lang_russian.tr();
      default:
        return nativeName;
    }
  }
}
