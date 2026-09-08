import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/enum/button_type.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_font_size.dart';
import 'package:market_view/core/widget/custom_buttons.dart';
import 'package:market_view/core/widget/custom_text.dart';
import 'package:market_view/core/widget/custom_text_field.dart';
import '../controller/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  ProfileController get controller =>
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());

  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController phone;
  late final TextEditingController email;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: controller.userName.value);
    phone = TextEditingController(text: controller.userPhone.value);
    email = TextEditingController(text: controller.userEmail.value);
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.screenBGColor,
    appBar: AppBar(
      backgroundColor: AppColors.screenBGColor,
      elevation: 0,
      title: CustomText(text: 'editProfile'.tr, fontWeight: FontWeight.bold),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Obx(
          () {
            if (phone.text != controller.userPhone.value &&
                controller.userPhone.value.isNotEmpty) {
              phone.text = controller.userPhone.value;
            }
            if (email.text != controller.userEmail.value &&
                controller.userEmail.value.isNotEmpty) {
              email.text = controller.userEmail.value;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFiled(
                  textEditingController: name,
                  title: 'name'.tr,
                ),
                const SizedBox(height: 16),
                CustomTextFiled(
                  textEditingController: phone,
                  title: 'phoneNumber'.tr,
                  readOnly: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: CustomText(
                    text: 'readOnly'.tr,
                    textColor: AppColors.hintColor,
                    fontSize: AppFontSize.caption,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextFiled(
                  textEditingController: email,
                  title: 'email'.tr,
                  textInputType: TextInputType.emailAddress,
                  readOnly: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: CustomText(
                    text: 'readOnly'.tr,
                    textColor: AppColors.hintColor,
                    fontSize: AppFontSize.caption,
                  ),
                ),
                const Spacer(),
                CustomButton(
                  buttonText: 'updateProfile'.tr,
                  buttonType: CustomButtonType.primary,
                  buttonHeight: 50,
                  buttonWidth: Get.width,
                  isLoading: controller.isUpdatingProfile,
                  onTap: () => controller.updateProfileName(name.text),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
