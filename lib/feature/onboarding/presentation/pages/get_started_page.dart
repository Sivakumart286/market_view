import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/enum/button_type.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_font_size.dart';
import 'package:market_view/core/utils/app_images.dart';
import 'package:market_view/core/widget/custom_buttons.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 40),
              Image.asset(appLogo, height: 150, width: 150),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Market",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: "View",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "stock_description".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              Image.asset(getStartedImage, height: 500, width: 500),
              Text("app_description".tr, textAlign: TextAlign.center),
              SizedBox(height: 15),
              CustomButton(
                buttonText: 'get_start_button'.tr,
                buttonType: CustomButtonType.primary,
                buttonHeight: 50,
                fontSize: AppFontSize.cardTitle,
                isSufficesIcon: true,
                buttonIcon: Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: AppColors.staticWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
