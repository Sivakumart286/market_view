import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/enum/button_type.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/widget/app_status_bar.dart';
import 'package:market_view/core/widget/custom_buttons.dart';
import 'package:market_view/core/widget/custom_text.dart';
import 'package:market_view/core/widget/custom_text_field.dart';
import '../controller/profile_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  ProfileController get controller =>
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());

  @override
  void dispose() {
    controller.clearPasswordFields();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppStatusBar(
    child: Scaffold(
      backgroundColor: AppColors.screenBGColor,
      appBar: AppBar(
        backgroundColor: AppColors.screenBGColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryTextColor),
          onPressed: () => Get.back(),
        ),
        title: CustomText(text: 'changePassword'.tr, fontWeight: FontWeight.bold),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'changePasswordDescription'.tr,
                  textColor: AppColors.hintColor,
                ),
                const SizedBox(height: 20),
                CustomTextFiled(
                  textEditingController: controller.current,
                  title: 'currentPassword'.tr,
                  showVisibilityToggle: true,
                  isPasswordVisible: controller.isCurrentPasswordVisible.value,
                  onVisibilityToggle: controller.toggleCurrentPasswordVisibility,
                  textInputType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 16),
                CustomTextFiled(
                  textEditingController: controller.password,
                  title: 'newPassword'.tr,
                  showVisibilityToggle: true,
                  isPasswordVisible: controller.isNewPasswordVisible.value,
                  onVisibilityToggle: controller.toggleNewPasswordVisibility,
                  textInputType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 16),
                CustomTextFiled(
                  textEditingController: controller.confirmation,
                  title: 'confirmPassword'.tr,
                  showVisibilityToggle: true,
                  isPasswordVisible: controller.isConfirmPasswordVisible.value,
                  onVisibilityToggle: controller.toggleConfirmPasswordVisibility,
                  textInputType: TextInputType.visiblePassword,
                ),
                const Spacer(),
                CustomButton(
                  buttonText: 'changePassword'.tr,
                  buttonType: CustomButtonType.primary,
                  buttonHeight: 50,
                  buttonWidth: Get.width,
                  isEnabled: controller.isPasswordFormValid,
                  isLoading: controller.isChangingPassword,
                  onTap: () => controller.changePassword(
                    currentPassword: controller.current.text,
                    newPassword: controller.password.text,
                    confirmation: controller.confirmation.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
