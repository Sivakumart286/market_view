import 'dart:ui';

class AppFontSize {
  AppFontSize._();

  /// Caption / Small text
  static const double caption = 12.0;

  /// Secondary information
  static const double secondaryText = 13.0;

  /// Normal body text
  static const double bodyText = 14.0;

  /// Card title / Button / Input text
  static const double cardTitle = 16.0;

  /// Section heading / Important value
  static const double sectionTitle = 18.0;

  /// Main heading
  static const double mainHeading = 22.0;

  /// Screen title / Large price
  static const double screenTitle = 24.0;
}

class AppFontFamily {
  static const String fontFamily = 'Inter';
}

class AppFontWidth {
  AppFontWidth._();
  /// Screen title
  static const FontWeight bold = FontWeight.w700;

  /// Main heading
  static const FontWeight semiBold = FontWeight.w600;

  /// Button text
  static const FontWeight medium = FontWeight.w500;

  /// Normal text
  static const FontWeight normal = FontWeight.w400;
}
