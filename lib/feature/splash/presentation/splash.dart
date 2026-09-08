
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/constant.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_preference.dart';
import 'package:market_view/feature/explore_page/presentation/explore_page.dart';
import 'package:market_view/feature/onboarding/presentation/pages/get_started_page.dart';
import '../../../core/utils/app_images.dart';
import '../../authentication/binding/auth_binding.dart';
import '../../authentication/presentation/login_screen.dart';
import '../../explore_page/binding/explore_binding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppPreference appPreference = Get.find();
  @override
  void initState() {
    Future.delayed(Duration(milliseconds:2000)).then((value){
      if(!appPreference.isAlreadyLogin!) {
        Get.off(()=> const GetStartedPage(), binding: AuthBinding());
      } else if(appPreference.authToken!.isNotEmpty){
        Get.off(()=>  ExploreScreen(),binding: ExploreBinding());
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
