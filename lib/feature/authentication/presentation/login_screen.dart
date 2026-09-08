import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/constant.dart';
import 'package:market_view/core/enum/button_type.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_images.dart';
import 'package:market_view/core/widget/custom_buttons.dart';
import 'package:market_view/core/widget/custom_text.dart';
import 'package:market_view/core/widget/custom_text_field.dart';
import 'package:market_view/feature/authentication/presentation/sign_up_screen.dart';
import 'package:market_view/feature/explore_page/presentation/explore_page.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.isRegistered<LoginController>()
      ? Get.find<LoginController>()
      : Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.screenBGColor,
        body: Stack(
          children: [
            Container(
              height: deviceHeight,
              width: deviceWidth,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(loginBGPng),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(loginImagePng),
            ),
            Positioned(
              bottom: Get.height * 0.05,
              left: Get.width * 0.05,
              right: Get.width * 0.05,
              child: Container(
                height: Get.height * 0.5,
                width: Get.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: AppColors.staticWhite,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextFiled(
                      textEditingController: controller.emailController,
                      focusNode: controller.emailFocus,
                      title: "label_email".tr,
                      textInputType: TextInputType.emailAddress,
                      onSubmit: (value) {
                        FocusScope.of(context).unfocus();
                        FocusScope.of(
                          context,
                        ).requestFocus(controller.passwordFocus);
                      },
                      isPrefix: true,
                      inputIcon: Icon(
                        Icons.email_rounded,
                        color: AppColors.hintColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(height: 10),
                    Obx(
                      () => CustomTextFiled(
                        textEditingController: controller.passwordController,
                        focusNode: controller.passwordFocus,
                        title: "label_password".tr,
                        isObscureText: controller.isDisable.value,
                        textInputType: TextInputType.visiblePassword,
                        onSubmit: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        isPrefix: true,
                        inputIcon: InkWell(
                          onTap: () {
                            controller.isDisable.value =
                                !controller.isDisable.value;
                          },
                          splashColor: Colors.transparent,
                          child: Icon(
                            controller.isDisable.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: AppColors.hintColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: CustomText(
                            text: "label_forget_password".tr,
                            textColor: AppColors.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      buttonText: "label_login".tr,
                      buttonType: CustomButtonType.secondary,
                      buttonHeight: 50,
                      buttonWidth: Get.width * 0.8,
                      showSuffixIcon: true,
                      buttonIcon: Icon(
                        Icons.arrow_forward,
                        color: AppColors.staticWhite,
                      ),
                      onTap: (){
                        controller.loginWithEmail(
                            email: controller.emailController.text.trim(),
                            password: controller.passwordController.text.trim()).then((value){
                          print("===>>>---calling_email ${value?.user}");
                          Get.off(ExploreScreen());
                        });
                      },
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.all(10),
                            height: 1,
                            width: 50,
                            color: AppColors.staticBlack,
                          ),
                          CustomText(text: "or"),
                          Container(
                            margin: EdgeInsets.all(10),
                            height: 1,
                            width: 50,
                            color: AppColors.staticBlack,
                          ),
                        ],
                      ),
                    ),
                    CustomButton(
                      showLeadingIcon: true,
                      buttonIcon: Image.asset(
                        googleIcon,
                        height: 25,
                        width: 25,
                      ),
                      buttonText: "Continue with Gmail",
                      buttonType: CustomButtonType.outline,
                      buttonHeight: 50,
                      buttonWidth: Get.width * 0.8,
                      onTap: (){
                        controller.signWithGoogle().then((value){
                          print("===>>>---calling_value ${value?.user}");
                          Get.off(ExploreScreen());
                        });
                      }
                    ),
                    SizedBox(height: 15),
                    RichText(text: TextSpan(
                      children: [
                      TextSpan(
                        text: "${"label_sign_up_content".tr} ",
                        style: TextStyle(
                          color: AppColors.primaryTextColor
                        )
                      ),
                         TextSpan(
                           text: "label_sign_up".tr,
                           style: TextStyle(
                             color: AppColors.secondaryColor
                           ),
                           recognizer: TapGestureRecognizer()
                             ..onTap = (){
                             Get.to(() => const SignUpScreen());
                             }
                         )
                      ]
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
