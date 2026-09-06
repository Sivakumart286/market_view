import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/feature/base_controller.dart';

class LoginController extends BaseController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  RxBool isDisable = true.obs;
}
