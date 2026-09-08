import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:market_view/core/utils/app_colors.dart';

/// Reusable status bar wrapper that applies the appropriate [SystemUiOverlayStyle]
/// based on the screen background. Defaults to light theme (dark icons & text).
class AppStatusBar extends StatelessWidget {
  final Widget child;
  final Color? statusBarColor;
  final Brightness? iconBrightness;

  const AppStatusBar({
    super.key,
    required this.child,
    this.statusBarColor,
    this.iconBrightness,
  });

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = iconBrightness ?? Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? AppColors.statusBarBackgroundColor,
        statusBarIconBrightness: brightness,
        statusBarBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: child,
    );
  }
}
