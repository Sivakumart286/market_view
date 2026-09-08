
import 'package:get/get.dart';
import 'package:market_view/feature/authentication/model/create_user_model.dart';

double deviceHeight = Get.height;
double deviceWidth = Get.width;
RxString selectedCountryCode = '+91'.obs;
RxString selectedCountryFlag = '🇮🇳'.obs;
RxInt currentIndex = 0.obs;
UserModel? userModel;