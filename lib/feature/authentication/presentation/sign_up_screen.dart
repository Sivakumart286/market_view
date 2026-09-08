import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/enum/button_type.dart';
import 'package:market_view/core/utils/app_font_size.dart';
import 'package:market_view/core/utils/app_images.dart';
import 'package:market_view/core/widget/custom_buttons.dart';
import 'package:market_view/core/widget/custom_text.dart';
import 'package:market_view/core/widget/custom_text_field.dart';
import 'package:market_view/feature/authentication/controller/sign_up_controller.dart';
import 'package:market_view/feature/authentication/model/create_user_model.dart';
import 'package:market_view/feature/homepage/binding/home_binding.dart';
import 'package:market_view/feature/homepage/presentation/home_screen.dart';

import '../../../core/constant.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_preference.dart';
import '../../explore_page/binding/explore_binding.dart';
import '../../explore_page/presentation/explore_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignUpController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppColors.screenBGColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Obx(
          () => Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Create Account",
                        fontWeight: AppFontWidth.bold,
                        fontSize: AppFontSize.mainHeading,
                      ),

                      const SizedBox(height: 5),

                      CustomText(
                        text:
                            "Monitor real-time tickers, index trends, and algorithmic momentum.",
                        fontSize: AppFontSize.bodyText,
                      ),

                      const SizedBox(height: 10),

                      // Name field
                      CustomTextFiled(
                        textEditingController: controller.nameController,
                        focusNode: controller.nameFocus,
                        title: "label_name".tr,
                        hintText: "e.g. Steven Grand",
                        textInputType: TextInputType.text,
                        isPrefix: true,
                        inputIcon: Icon(
                          Icons.person,
                          color: AppColors.hintColor,
                          size: 20,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Phone field
                      CustomTextFiled(
                        textEditingController:
                            controller.phoneNumberController,
                        focusNode: controller.phoneNumberFocus,
                        title: "label_phone_no".tr,
                        hintText: "90428 XXXXX",
                        textInputType: TextInputType.phone,
                        isPrefix: true,
                        inputIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: InkWell(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                showPhoneCode: true,
                                onSelect: (Country country) {
                                  selectedCountryCode.value =
                                      '+${country.phoneCode}';

                                  selectedCountryFlag.value =
                                      country.flagEmoji;
                                },
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomText(
                                  text: selectedCountryFlag.value,
                                  fontSize: AppFontSize.sectionTitle,
                                ),
                                const SizedBox(width: 6),
                                CustomText(
                                  text: selectedCountryCode.value,
                                  fontSize: AppFontSize.cardTitle,
                                ),
                                const Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Email
                      CustomTextFiled(
                        textEditingController: controller.emailController,
                        focusNode: controller.emailFocus,
                        title: "label_email".tr,
                        hintText: "steven@gmail.com",
                        textInputType: TextInputType.emailAddress,
                        isPrefix: true,
                        inputIcon: Icon(
                          Icons.email_rounded,
                          color: AppColors.hintColor,
                          size: 20,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Password
                      CustomTextFiled(
                        textEditingController: controller.passwordController,
                        focusNode: controller.passwordFocus,
                        title: "label_password".tr,
                        isObscureText: controller.isPassword.value,
                        textInputType: TextInputType.visiblePassword,
                        isPrefix: true,
                        inputIcon: InkWell(
                          onTap: () {
                            controller.isPassword.value =
                                !controller.isPassword.value;
                          },
                          child: Icon(
                            controller.isPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: AppColors.hintColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Confirm password
                      CustomTextFiled(
                        textEditingController:
                            controller.confirmPasswordController,
                        focusNode: controller.confirmPasswordFocus,
                        title: "label_confirm_password".tr,
                        isObscureText: controller.isConfirmPassword.value,
                        textInputType: TextInputType.visiblePassword,
                        isPrefix: true,
                        inputIcon: InkWell(
                          onTap: () {
                            controller.isConfirmPassword.value =
                                !controller.isConfirmPassword.value;
                          },
                          child: Icon(
                            controller.isConfirmPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: AppColors.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: CustomButton(
                    buttonText: "Sign up",
                    buttonType: CustomButtonType.secondary,
                    isLoading: controller.isLoader.value,
                    onTap: () {
                      controller.isLoader.value = true;
                      controller.validateRegistrationForm().then((value) {
                        if (value == "") {
                          controller
                              .createUser(
                                email: controller.emailController.text.trim(),
                                password: controller.passwordController.text
                                    .trim(),
                              )
                              .then((value) {
                                controller.storeUserData(
                                  model: UserModel(
                                    uid: value.user?.uid??"",
                                    name: controller.nameController.text
                                        .trim(),
                                    phone: controller
                                        .phoneNumberController
                                        .text
                                        .trim(),
                                    email: controller.emailController.text
                                        .trim(),
                                  ),
                                );
                                if(value.user?.uid!= null){
                                  AppPreference().authToken = value.user?.uid;
                                  Get.off(()=>  ExploreScreen(),binding: ExploreBinding());
                                }
                              });
                        } else {
                          Get.rawSnackbar(
                            backgroundColor: AppColors.staticWhite,
                            message: value,
                            messageText: Text(
                              value,
                              style: TextStyle(
                                color: AppColors.primaryTextColor,
                                fontSize: AppFontSize.cardTitle,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            icon: Image.asset(appLogo, height: 24, width: 24),
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                            duration: const Duration(seconds: 2),
                          );
                        }
                      });
                      Future.delayed(Duration(milliseconds: 1000)).then((
                        value,
                      ) {
                        controller.isLoader.value = false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
