import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_font_size.dart';
import 'package:market_view/core/widget/custom_text.dart';

class CustomTextFiled extends GetView {
  final TextEditingController textEditingController;
  final FocusNode? focusNode;
  final TextInputType? textInputType;
  final String? title;
  final String? hintText;
  final bool? isObscureText;
  final bool? isPrefix;
  final bool? isSuffix;
  final Widget? inputIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmit;
  const CustomTextFiled({
    super.key,
    required this.textEditingController,
    this.focusNode,
    this.textInputType,
    this.hintText,
    this.title,
    this.isObscureText,
    this.isPrefix,
    this.isSuffix,
    this.inputIcon,
    this.onChanged,
    this.onSubmit
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(title != null)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomText(text: title??"",
            fontSize: AppFontSize.cardTitle,
            fontWeight: AppFontWidth.semiBold,
          ),
        ),
        TextFormField(
          controller: textEditingController,
          keyboardType: textInputType?? TextInputType.text,
          focusNode: focusNode,
          obscureText: isObscureText?? false,
          decoration: InputDecoration(
            prefixIcon: isPrefix??false ? inputIcon: null,
            suffixIcon: isSuffix??false ? inputIcon: null,
            hintText: hintText?? "hint_text_label".trParams({"field": title?.toLowerCase()??""})??"",
            hintStyle: TextStyle(
              color: AppColors.hintColor
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.borderColor
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.borderColor
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.borderColor
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          onChanged: onChanged,
          onFieldSubmitted: onSubmit,
        ),
      ],
    );
  }
}
