import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/feature/onboarding/presentation/pages/get_started_page.dart';
import 'core/utils/app_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: LocalizationService.locale,
      defaultTransition: Transition.leftToRight,
      supportedLocales: LocalizationService.locales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      translations: LocalizationService(),
     debugShowCheckedModeBanner: false,
      home: GetStartedPage(),
    );
  }
}
