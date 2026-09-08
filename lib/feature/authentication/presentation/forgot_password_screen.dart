import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/enum/button_type.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_font_size.dart';
import 'package:market_view/core/widget/app_status_bar.dart';
import 'package:market_view/core/widget/custom_buttons.dart';
import 'package:market_view/core/widget/custom_text.dart';
import 'package:market_view/core/widget/custom_text_field.dart';
import '../controller/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  ForgotPasswordController get controller =>
      Get.isRegistered<ForgotPasswordController>()
          ? Get.find<ForgotPasswordController>()
          : Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return AppStatusBar(
      child: Scaffold(
        backgroundColor: AppColors.screenBGColor,
        appBar: AppBar(
          backgroundColor: AppColors.screenBGColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryTextColor),
            onPressed: () => Get.back(),
          ),
          title: CustomText(
            text: 'forgotPassword'.tr,
            fontWeight: AppFontWidth.bold,
            fontSize: AppFontSize.sectionTitle,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'forgotPassword'.tr,
                  fontSize: AppFontSize.mainHeading,
                  fontWeight: AppFontWidth.bold,
                  textColor: AppColors.primaryTextColor,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: 'forgotPasswordDescription'.tr,
                  fontSize: AppFontSize.bodyText,
                  textColor: AppColors.secondaryTextColor,
                ),
                const SizedBox(height: 28),
                CustomTextFiled(
                  textEditingController: controller.emailController,
                  title: 'label_email'.tr,
                  hintText: 'enterEmail'.tr,
                  textInputType: TextInputType.emailAddress,
                  isPrefix: true,
                  inputIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.hintColor,
                  ),
                ),
                const Spacer(),
                CustomButton(
                  buttonText: 'sendResetLink'.tr,
                  buttonType: CustomButtonType.secondary,
                  buttonHeight: 50,
                  buttonWidth: Get.width,
                  isLoading: controller.isLoading,
                  onTap: () => controller.sendResetEmail(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
