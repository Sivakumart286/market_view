
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/constant.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_preference.dart';
import 'package:market_view/feature/login_screen/login_screen.dart';
import 'package:market_view/feature/onboarding/presentation/pages/get_started_page.dart';

import '../../core/utils/app_images.dart';
import '../login_screen/auth_binding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    Future.delayed(Duration(milliseconds:4000)).then((value){
      if(!AppPreference().isAlreadyLogin!) {
        Get.off(()=> const GetStartedPage(), binding: AuthBinding());
        Get.to(GetStartedPage());
      } else {
        Get.off(() => const LoginScreen(),binding: AuthBinding());
      }
    });
        super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: deviceHeight,
      width: deviceWidth,
      color: AppColors.staticWhite,
      alignment: Alignment.center,
      child: Image.asset(appLogo,height: 150,width: 150,fit: BoxFit.contain,),
    );
  }
}
