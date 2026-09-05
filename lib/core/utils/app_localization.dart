import 'dart:ui';

import 'package:get/get.dart';

import '../language/en.dart';


class LocalizationService extends Translations {
  static const locale = Locale('en', '');

  static final langs = ['en',];

  static final locales = [
    const Locale('en', ''),

  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'en': enLang,
  };

  void changeLocale(String lang) {
    final locale = _getLocaleFromLanguage(lang);
    Get.updateLocale(locale);
  }

  Locale _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) return locales[i];
    }
    return Get.locale!;
  }
}
