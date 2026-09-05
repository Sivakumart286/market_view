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
  final FontWeight? fontWidth;
  final Widget? buttonIcon;
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
    this.fontWidth,
    this.buttonIcon
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: buttonHeight ?? Get.height * 0.1,
        width: buttonWidth ?? Get.width * 0.4,
        decoration: _getDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isShowLeadIcon ?? false)
              Padding(
                padding: EdgeInsets.only(right:10),
                child: buttonIcon,
              ),
            CustomText(
              text: buttonText,
              fontSize: fontSize,
              fontWeight: fontWidth ?? AppFontWidth.bold,
              textColor:  buttonContentColor ?? _getTextColor(),
            ),
            if (isSufficesIcon ?? false)
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: buttonIcon,
              ),
          ],
        ),
      ),
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
        return  AppColors.staticWhite;
      case CustomButtonType.secondary:
        return AppColors.staticWhite;
      case CustomButtonType.outline:
        return AppColors.primaryTextColor;
    }
  }
}
