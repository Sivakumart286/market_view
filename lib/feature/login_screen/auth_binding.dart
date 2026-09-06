
import 'package:get/get.dart';
import 'package:market_view/feature/login_screen/login_controller.dart';

class AuthBinding implements Bindings{
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(()=> LoginController(), fenix: true);
  }

}