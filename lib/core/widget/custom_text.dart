import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_font_size.dart';

class CustomText extends GetView {
  final String text;
  final double? fontSize;
  final Color? textColor;
  final TextOverflow? overflow;
  final TextAlign? align;
  final FontWeight? fontWeight;
  const CustomText({
    super.key,
    required this.text,
    this.fontSize,
    this.textColor,
    this.overflow,
    this.align,
    this.fontWeight
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? AppFontSize.bodyText,
        fontFamily: AppFontFamily.fontFamily,
        color: textColor ?? AppColors.primaryTextColor,
        fontWeight: fontWeight ?? AppFontWidth.normal,
      ),
      overflow: overflow ?? TextOverflow.visible,
      textAlign: align ?? TextAlign.start,
    );
  }
}
