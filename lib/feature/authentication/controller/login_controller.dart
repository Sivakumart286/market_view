import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/utils/app_preference.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_font_size.dart';
import '../../../core/utils/app_images.dart';


class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final RxBool isDisable = true.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<UserCredential?> loginWithEmail({required String email, required String password}) async{
    try{
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      AppPreference().authToken = userCredential.user?.uid;
      return userCredential;
    } on FirebaseAuthException catch(e){
      Get.rawSnackbar(
        backgroundColor: AppColors.staticWhite,
        message: e.message,
        messageText: Text(
          e.message.toString(),
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
      throw Exception(e.message);
    }
  }

  Future<String> validateRegistrationForm() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty) {
      return "validation_email_required".tr;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return "validation_email_invalid".tr;
    }

    if (password.isEmpty) {
      return "validation_password_required".tr;
    }

    if (password.length < 8) {
      return "validation_password_min_length".tr;
    }


    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialCharacter =
    RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=]')
        .hasMatch(password);

    if (!hasUppercase ||
        !hasLowercase ||
        !hasNumber ||
        !hasSpecialCharacter) {
      return "validation_password_invalid".tr;
    }

    return "";
  }


  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}

