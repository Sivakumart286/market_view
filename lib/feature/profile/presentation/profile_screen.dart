import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/enum/button_type.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/widget/custom_buttons.dart';
import 'package:market_view/core/widget/custom_text.dart';

import 'package:market_view/feature/market_news/presentation/market_news.dart';
import 'package:market_view/feature/stocks/view/all_stocks_screen.dart';

import '../../../core/utils/app_font_size.dart';
import '../controller/profile_controller.dart';
import 'change_password.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  ProfileController get controller =>
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.screenBGColor,
    body: Obx(
      () => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _header(),
            const SizedBox(height: 28),
            _section('preferences'.tr),
            ProfileMenuItem(
              icon: Icons.language_rounded,
              title: 'preferredLanguage'.tr,
              subtitle: controller.selectedLanguage.value == 'ta'
                  ? 'tamil'.tr
                  : 'english'.tr,
              onTap: _languageSheet,
            ),
            ProfileMenuItem(
              icon: Icons.newspaper_rounded,
              title: 'marketNews'.tr,
              onTap: () => Get.to(() => const MarketNewsScreen()),
            ),
            ProfileMenuItem(
              icon: Icons.show_chart_rounded,
              title: 'marketScreen'.tr,
              onTap: () => Get.to(() => const AllStocksScreen(isFrom: true,)),
            ),
            const SizedBox(height: 18),
            _section('account'.tr),
            ProfileMenuItem(
              icon: Icons.lock_outline_rounded,
              title: 'changePassword'.tr,
              onTap: () => Get.to(() => const ChangePasswordScreen()),
            ),
            ProfileMenuItem(
              icon: Icons.manage_accounts_outlined,
              title: 'manageAccount'.tr,
              onTap: _deleteDialog,
            ),
            const SizedBox(height: 40),
            Center(
              child: CustomButton(
                buttonText: 'signOut'.tr,
                buttonType: CustomButtonType.outline,
                buttonColor: AppColors.dangerButtonColor,
                buttonContentColor: AppColors.dangerButtonColor,
                buttonHeight: 48,
                buttonWidth: Get.width * .55,
                onTap: _signOutDialog,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _header() => Column(
    children: [
      CircleAvatar(
        radius: 42,
        backgroundColor: AppColors.profileAvatarBackground,
        child: CustomText(
          text: controller.avatarLetter,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          textColor: AppColors.profileAvatarText,
        ),
      ),
      const SizedBox(height: 12),
      CustomText(
        text: controller.userName.value.isEmpty
            ? 'User'
            : controller.userName.value,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      const SizedBox(height: 4),
      CustomText(
        text: controller.userEmail.value,
        textColor: AppColors.hintColor,
      ),
      const SizedBox(height: 16),
      CustomButton(
        buttonText: 'editProfile'.tr,
        buttonType: CustomButtonType.outline,
        buttonHeight: 42,
        buttonWidth: 150,
        onTap: () => Get.to(() => const EditProfileScreen()),
      ),
    ],
  );

  Widget _section(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: CustomText(
      text: text,
      fontWeight: FontWeight.bold,
      textColor: AppColors.profileSectionTitle,
    ),
  );

  void _languageSheet() => Get.bottomSheet(
    Container(
      color: AppColors.profileMenuBackground,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'preferredLanguage'.tr,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 12),
            _languageOption('en', 'english'.tr),
            _languageOption('ta', 'tamil'.tr),
          ],
        ),
      ),
    ),
  );

  Widget _languageOption(String code, String title) => Obx(
    () => ListTile(
      contentPadding: EdgeInsets.zero,
      title: CustomText(text: title),
      trailing: controller.selectedLanguage.value == code
          ? Icon(Icons.check_rounded, color: AppColors.primaryColor)
          : null,
      onTap: () async {
        await controller.selectLanguage(code);
        Get.back();
      },
    ),
  );

  void _signOutDialog() => Get.dialog(
    _confirmationDialog(
      title: 'signOutQuestion'.tr,
      message: 'signOutConfirmation'.tr,
      action: 'signOut'.tr,
      isLoading: controller.isSigningOut,
      onConfirm: controller.signOut,
    ),
  );

  void _deleteDialog() {
    final password = TextEditingController();
    Get.dialog(
      Obx(
        () => AlertDialog(
          backgroundColor: AppColors.profileMenuBackground,
          title: CustomText(
            text: 'deleteAccountQuestion'.tr,
            fontWeight: FontWeight.bold,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: 'deleteAccountConfirmation'.tr),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(labelText: 'currentPassword'.tr),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: CustomText(text: 'cancel'.tr),
            ),
            TextButton(
              onPressed: controller.isDeletingAccount.value
                  ? null
                  : () => controller.deleteAccount(password.text),
              child: controller.isDeletingAccount.value
                  ? const CircularProgressIndicator()
                  : CustomText(
                      text: 'delete'.tr,
                      textColor: AppColors.dangerColor,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmationDialog({
    required String title,
    required String message,
    required String action,
    required RxBool isLoading,
    required Future<void> Function() onConfirm,
  }) => Obx(
    () => AlertDialog(
      backgroundColor: AppColors.profileMenuBackground,
      title: CustomText(text: title, fontWeight: FontWeight.bold),
      content: CustomText(text: message),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: CustomText(text: 'cancel'.tr),
        ),
        TextButton(
          onPressed: isLoading.value ? null : onConfirm,
          child: isLoading.value
              ? const CircularProgressIndicator()
              : CustomText(text: action, textColor: AppColors.dangerColor),
        ),
      ],
    ),
  );
}

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: AppColors.profileMenuBackground,
      borderRadius: BorderRadius.circular(14),
    ),
    child: ListTile(
      leading: Icon(icon, color: AppColors.secondaryColor),
      title: CustomText(text: title, fontWeight: FontWeight.w600),
      subtitle: subtitle == null
          ? null
          : CustomText(text: subtitle!, textColor: AppColors.hintColor),
      trailing:
          trailing ??
          Icon(Icons.chevron_right_rounded, color: AppColors.hintColor),
      onTap: onTap,
    ),
  );
}
