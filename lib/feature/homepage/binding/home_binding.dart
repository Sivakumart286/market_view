
import 'package:get/get.dart';
import 'package:market_view/feature/homepage/controller/home_controller.dart';


class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}
