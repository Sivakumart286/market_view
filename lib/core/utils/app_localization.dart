import 'dart:ui';

import 'package:get/get.dart';

import '../language/en.dart';
import '../language/ta.dart';
import 'app_preference.dart';

class LocalizationService extends Translations {
  static Locale get locale {
    final lang = AppPreference().selectedLanguage;
    return Locale(lang, '');
  }

  static final langs = ['en', 'ta'];

  static final locales = [
    const Locale('en', ''),
    const Locale('ta', ''),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'en': enLang,
    'ta': taLang,
  };

  void changeLocale(String lang) {
    final locale = getLocaleFromLanguage(lang);
    Get.updateLocale(locale);
  }

  Locale getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) return locales[i];
    }
    return Get.locale ?? locales.first;
  }
}
