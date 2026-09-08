import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/utils/app_preference.dart';
import 'package:google_sign_in/google_sign_in.dart';


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
      throw Exception(e.message);
    }
  }

  Future<UserCredential?> signWithGoogle() async{
    try{
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken,);
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.toString());
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

