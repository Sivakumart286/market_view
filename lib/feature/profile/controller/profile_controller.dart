import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/utils/app_localization.dart';
import 'package:market_view/core/utils/app_preference.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_font_size.dart';
import '../../../core/utils/app_images.dart';
import '../../authentication/binding/auth_binding.dart';
import '../../authentication/model/create_user_model.dart';
import '../../authentication/presentation/login_screen.dart';
import '../../homepage/controller/home_controller.dart';

class ProfileController extends GetxController {
  ProfileController({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _customAuth = auth,
      _customFirestore = firestore;

  final FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final selectedLanguage = AppPreference().selectedLanguage.obs;
  final isUpdatingProfile = false.obs;
  final isChangingPassword = false.obs;
  final isDeletingAccount = false.obs;
  final isSigningOut = false.obs;

  final current = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();

  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isPasswordFormValid = false.obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _profileSubscription;

  String get avatarLetter {
    final value = userName.value.trim();
    return value.isEmpty ? 'S' : value.characters.first.toUpperCase();
  }

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void validatePasswordForm() {
    final cur = current.text.trim();
    final pwd = password.text;
    final conf = confirmation.text;

    final isValid = cur.isNotEmpty &&
        pwd.isNotEmpty &&
        conf.isNotEmpty &&
        pwd.length >= 6 &&
        pwd == conf &&
        !isChangingPassword.value;

    isPasswordFormValid.value = isValid;
  }

  void clearPasswordFields() {
    current.clear();
    password.clear();
    confirmation.clear();
    isCurrentPasswordVisible.value = false;
    isNewPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    isPasswordFormValid.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    _watchProfile();
    current.addListener(validatePasswordForm);
    password.addListener(validatePasswordForm);
    confirmation.addListener(validatePasswordForm);
  }

  void _watchProfile() {
    final user = _auth?.currentUser;
    if (user == null) return;
    userEmail.value = user.email ?? '';
    userPhone.value = user.phoneNumber ?? '';
    userName.value = user.displayName ?? '';
    final firestore = _firestore;
    if (firestore == null) return;
    _profileSubscription = firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
          final data = snapshot.data();
          if (data == null) return;
          final profile = (data['profile'] is Map)
              ? Map<String, dynamic>.from(data['profile'] as Map)
              : null;
          userName.value = (profile?['name'] ?? data['name'] ?? userName.value).toString();
          userEmail.value = (profile?['email'] ?? data['email'] ?? userEmail.value).toString();
          userPhone.value =
              (profile?['phone'] ?? profile?['phoneNumber'] ?? data['phone'] ?? data['phoneNumber'] ?? userPhone.value)
                  .toString();
        });
  }

  Future<void> updateProfileName(String value) async {
    final name = value.trim();
    if (name.isEmpty) {
      _message('requiredField'.tr, error: true);
      return;
    }
    final user = _auth?.currentUser;
    if (user == null) return _message('recentLoginRequired'.tr, error: true);
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      isUpdatingProfile.value = true;
      await firestore.collection('users').doc(user.uid).set({
        'name': name,
        'profile': {
          'name': name,
        },
      }, SetOptions(merge: true));
      await user.updateDisplayName(name);
      userName.value = name;
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        final current = homeController.userModel.value;
        if (current != null) {
          homeController.userModel.value = UserModel(
            uid: current.uid,
            name: name,
            phone: current.phone,
            email: current.email,
          );
        } else {
          homeController.userModel.value = UserModel(
            uid: user.uid,
            name: name,
            phone: userPhone.value,
            email: userEmail.value,
          );
        }
      }
      _message('profileUpdatedSuccessfully'.tr);
    } on FirebaseException catch (error) {
      _message(_firebaseMessage(error), error: true);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  Future<void> selectLanguage(String language) async {
    selectedLanguage.value = language;
    await AppPreference().setSelectedLanguage(language);
    LocalizationService().changeLocale(language);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) async {
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmation.isEmpty) {
      return _message('requiredField'.tr, error: true);
    }
    if (newPassword.length < 6) {
      return _message('passwordTooShort'.tr, error: true);
    }
    if (newPassword != confirmation) {
      return _message('passwordMismatch'.tr, error: true);
    }
    final user = _auth?.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      return _message('recentLoginRequired'.tr, error: true);
    }
    try {
      isChangingPassword.value = true;
      validatePasswordForm();
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: currentPassword),
      );
      await user.updatePassword(newPassword);
      _message('passwordChangedSuccessfully'.tr);
      clearPasswordFields();
      Get.back();
    } on FirebaseAuthException catch (error) {
      _message(_firebaseMessage(error), error: true);
    } finally {
      isChangingPassword.value = false;
      validatePasswordForm();
    }
  }

  Future<void> deleteAccount(String password) async {
    final user = _auth?.currentUser;
    final email = user?.email;
    if (password.isEmpty) {
      return _message('requiredField'.tr, error: true);
    }
    if (user == null || email == null) {
      return _message('recentLoginRequired'.tr, error: true);
    }
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      isDeletingAccount.value = true;
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
      await firestore.collection('users').doc(user.uid).delete();
      await user.delete();
      await _clearSession();
    } on FirebaseAuthException catch (error) {
      _message(_firebaseMessage(error), error: true);
    } on FirebaseException catch (error) {
      _message(_firebaseMessage(error), error: true);
    } finally {
      isDeletingAccount.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isSigningOut.value = true;
      await _auth?.signOut();
      await _clearSession();
    } on FirebaseAuthException catch (error) {
      _message(_firebaseMessage(error), error: true);
    } finally {
      isSigningOut.value = false;
    }
  }

  Future<void> _clearSession() async {
    await AppPreference().clearUserData();
    _profileSubscription?.cancel();
    userName.value = '';
    userEmail.value = '';
    userPhone.value = '';
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().userModel.value = null;
    }
    Get.offAll(() => const LoginScreen(), binding: AuthBinding());
  }

  String _firebaseMessage(FirebaseException error) {
    switch (error.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'wrongCurrentPassword'.tr;
      case 'weak-password':
        return 'passwordTooShort'.tr;
      case 'requires-recent-login':
        return 'recentLoginRequired'.tr;
      case 'network-request-failed':
        return 'networkError'.tr;
      default:
        return 'somethingWentWrong'.tr;
    }
  }

  void _message(String text, {bool error = false}) {
    try {
      if (WidgetsBinding.instance.runtimeType.toString().contains('Test') || Get.testMode) return;
      if (Get.overlayContext != null) {
        Get.rawSnackbar(
          backgroundColor: AppColors.staticWhite,
          message: text,
          messageText: Text(
            text,
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
    } catch (_) {}
  }

  @override
  void onClose() {
    current.removeListener(validatePasswordForm);
    password.removeListener(validatePasswordForm);
    confirmation.removeListener(validatePasswordForm);
    current.dispose();
    password.dispose();
    confirmation.dispose();
    _profileSubscription?.cancel();
    super.onClose();
  }
}
