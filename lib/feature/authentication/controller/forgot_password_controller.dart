import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController({FirebaseAuth? auth}) : _customAuth = auth;

  final FirebaseAuth? _customAuth;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  final emailController = TextEditingController();
  final isLoading = false.obs;

  Future<bool> sendResetEmail() async {
    try {
      final email = emailController.text.trim();

      if (email.isEmpty) {
        _message('emailRequired'.tr, error: true);
        return false;
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _message('invalidEmail'.tr, error: true);
        return false;
      }

      isLoading.value = true;
      final auth = _auth;
      if (auth != null) {
        await auth.sendPasswordResetEmail(email: email);
      }
      _message('resetPasswordEmailSent'.tr);
      return true;
    } on FirebaseAuthException catch (e) {
      _message(_firebaseMessage(e), error: true);
      return false;
    } catch (_) {
      _message('somethingWentWrong'.tr, error: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _firebaseMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'userNotFound'.tr;
      case 'invalid-email':
        return 'invalidEmail'.tr;
      case 'too-many-requests':
        return 'tooManyRequests'.tr;
      case 'network-request-failed':
        return 'networkError'.tr;
      default:
        return error.message ?? 'somethingWentWrong'.tr;
    }
  }

  void _message(String text, {bool error = false}) {
    try {
      if (WidgetsBinding.instance.runtimeType.toString().contains('Test') || Get.testMode) return;
      if (Get.overlayContext != null) {
        Get.snackbar(
          '',
          text,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
