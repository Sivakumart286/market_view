
import 'package:get/get.dart';
import 'package:market_view/feature/homepage/controller/home_controller.dart';
import 'package:market_view/feature/market_view/controller/market_chart_controller.dart';

import 'package:market_view/feature/stocks/controller/stock_controller.dart';

class ExploreBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<MarketChartController>(() => MarketChartController(), fenix: true);
    Get.lazyPut<StockController>(() => StockController(), fenix: true);
  }
}
