import 'package:get/get.dart';
import '../controller/market_chart_controller.dart';

class MarketBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarketChartController>(() => MarketChartController(), fenix: true);
  }
}
