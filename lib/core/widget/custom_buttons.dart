import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/enum/button_type.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_font_size.dart';
import 'package:market_view/core/widget/custom_text.dart';

class CustomButton extends GetView {
  final GestureTapCallback? onTap;
  final String buttonText;
  final double? fontSize;
  final Color? buttonContentColor;
  final double? buttonHeight;
  final double? buttonWidth;
  final CustomButtonType buttonType;
  final Color? buttonColor;
  final double? borderWidth;
  final bool? isShowLeadIcon;
  final bool? isSufficesIcon;
  final bool? showLeadingIcon;
  final bool? showSuffixIcon;
  final FontWeight? fontWidth;
  final Widget? buttonIcon;

  /// Optional loader state. Can be an [RxBool] / [Rx<bool>] or a [bool].
  /// When tapped, if an [Rx] boolean is provided, its value is automatically set to true.
  final dynamic isLoading;
  final Widget? loaderWidget;
  final Color? loaderColor;

  const CustomButton({
    super.key,
    this.onTap,
    required this.buttonText,
    required this.buttonType,
    this.buttonContentColor,
    this.fontSize,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonColor,
    this.borderWidth,
    this.isShowLeadIcon,
    this.isSufficesIcon,
    this.showLeadingIcon,
    this.showSuffixIcon,
    this.fontWidth,
    this.buttonIcon,
    this.isLoading,
    this.loaderWidget,
    this.loaderColor,
  });

  bool get _isLoadingNow {
    if (isLoading == null) return false;
    if (isLoading is Rx<bool>) {
      return (isLoading as Rx<bool>).value;
    }
    if (isLoading is bool) {
      return isLoading as bool;
    }
    try {
      return (isLoading as dynamic).value == true;
    } catch (_) {
      return false;
    }
  }

  bool get _isReactiveLoader {
    if (isLoading == null) return false;
    return isLoading is Rx<bool> || isLoading is RxInterface;
  }

  bool get _hasLeadingIcon => (showLeadingIcon ?? isShowLeadIcon) ?? false;
  bool get _hasSuffixIcon => (showSuffixIcon ?? isSufficesIcon) ?? false;

  void _handleTap() {
    if (_isLoadingNow) return;

    if (isLoading is Rx<bool>) {
      (isLoading as Rx<bool>).value = true;
    } else {
      try {
        (isLoading as dynamic).value = true;
      } catch (_) {}
    }

    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isReactiveLoader) {
      return Obx(() => _buildButton(context));
    }
    return _buildButton(context);
  }

  Widget _buildButton(BuildContext context) {
    final bool loading = _isLoadingNow;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: loading ? null : _handleTap,
      child: Container(
        height: buttonHeight ?? 50,
        width: buttonWidth ?? Get.width * 0.4,
        decoration: _getDecoration(),
        child: loading ? _buildLoader() : _buildContent(),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: loaderWidget ??
          SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                loaderColor ?? buttonContentColor ?? _getLoaderColor(),
              ),
            ),
          ),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_hasLeadingIcon && buttonIcon != null)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: buttonIcon!,
          ),
        CustomText(
          text: buttonText,
          fontSize: fontSize,
          fontWeight: fontWidth ?? AppFontWidth.bold,
          textColor: buttonContentColor ?? _getTextColor(),
        ),
        if (_hasSuffixIcon && buttonIcon != null)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: buttonIcon!,
          ),
      ],
    );
  }

  // Button type based decoration

  BoxDecoration _getDecoration() {
    switch (buttonType) {
      case CustomButtonType.primary:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: buttonColor ?? AppColors.primaryColor,
        );

      case CustomButtonType.secondary:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: buttonColor ?? AppColors.secondaryColor,
        );

      case CustomButtonType.outline:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColors.staticWhite,
          border: Border.all(
            color: buttonColor ?? AppColors.primaryColor,
            width: borderWidth ?? 1,
          ),
        );
    }
  }

  // Button type based button text color
  Color _getTextColor() {
    switch (buttonType) {
      case CustomButtonType.primary:
        return AppColors.staticWhite;
      case CustomButtonType.secondary:
        return AppColors.staticWhite;
      case CustomButtonType.outline:
        return AppColors.primaryTextColor;
    }
  }

  // Loader default color based on button type
  Color _getLoaderColor() {
    switch (buttonType) {
      case CustomButtonType.primary:
        return AppColors.staticWhite;
      case CustomButtonType.secondary:
        return AppColors.staticWhite;
      case CustomButtonType.outline:
        return buttonColor ?? AppColors.primaryColor;
    }
  }
}
