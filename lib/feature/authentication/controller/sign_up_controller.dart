import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/feature/authentication/model/create_user_model.dart';


class SignUpController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode phoneNumberFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  final RxBool isPassword = true.obs;
  final RxBool isConfirmPassword = true.obs;
  final RxBool isLoader = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> createUser({required String email, required String password}) async{
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> storeUserData({
    required UserModel model,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> userReference =
      FirebaseFirestore.instance
          .collection('users')
          .doc(model.uid);

      await userReference.set({"profile":model.toJson()});

    } on FirebaseException catch (e) {
      debugPrint('Firestore Error: ${e.code}');
      debugPrint('Firestore Message: ${e.message}');
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<String> validateRegistrationForm() async {
    final name = nameController.text.trim();
    final phone = phoneNumberController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty) {
      return "validation_name_required".tr;
    }

    if (name.length < 3) {
      return "validation_name_min_length".tr;
    }

    if (phone.isEmpty) {
      return "validation_phone_required".tr;
    }

    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return "validation_phone_digits_only".tr;
    }

    if (phone.length < 3) {
      return "validation_phone_min_length".tr;
    }

    if (phone.length > 15) {
      return "validation_phone_max_length".tr;
    }

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

    if (confirmPassword.isEmpty) {
      return "validation_confirm_password_required".tr;
    }

    if (password != confirmPassword) {
      return "validation_password_mismatch".tr;
    }

    return "";
  }



  @override
  void onClose() {
    nameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocus.dispose();
    phoneNumberFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.onClose();
  }
}
