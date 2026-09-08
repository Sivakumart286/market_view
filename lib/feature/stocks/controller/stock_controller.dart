import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constant.dart' as app_const;
import '../model/chart_data_model.dart';
import '../model/stock_model.dart';
import '../view/all_stocks_screen.dart';

class StockController extends GetxController {
  /// Reactive state variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<StockModel> stockList = <StockModel>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxString selectedChartRange = '1D'.obs;
  final RxString searchQuery = ''.obs;

  /// Selected stock for the active chart screen
  final Rxn<StockModel> selectedStock = Rxn<StockModel>();

  /// Dynamic chart & Market Summary calculations based on selected range
  final RxList<ChartDataPoint> activeChartPoints = <ChartDataPoint>[].obs;
  final RxDouble openPrice = 0.0.obs;
  final RxDouble closePrice = 0.0.obs;
  final RxDouble highPrice = 0.0.obs;
  final RxDouble lowPrice = 0.0.obs;
  final RxDouble priceChange = 0.0.obs;
  final RxDouble percentageChange = 0.0.obs;
  final RxBool isRangePositive = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Sync with global constant currentIndex
    currentIndex.value = app_const.currentIndex.value;
    loadStocksFromJson();
  }

  /// Initial stock display: exactly first 5 stocks from JSON
  List<StockModel> get homeStocks {
    return stockList.take(5).toList();
  }

  /// Filtered stocks based on user search in All Stocks screen
  List<StockModel> get filteredStocks {
    if (searchQuery.value.trim().isEmpty) {
      return stockList;
    }
    final q = searchQuery.value.trim().toLowerCase();
    return stockList.where((stock) {
      final sym = stock.symbol.toLowerCase();
      final name = stock.companyName.toLowerCase();
      return sym.contains(q) || name.contains(q);
    }).toList();
  }

  Future<void> loadStocksFromJson({
    String assetPath = 'data/indian_stocks_professional.json',
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final dynamic decoded = jsonDecode(jsonString);

      List<dynamic> listToParse = [];
      if (decoded is Map<String, dynamic>) {
        if (decoded['stocks'] is List) {
          listToParse = decoded['stocks'];
        }
      } else if (decoded is List) {
        listToParse = decoded;
      }

      final parsed = listToParse
          .whereType<Map<String, dynamic>>()
          .map((item) => StockModel.fromJson(item))
          .toList();

      stockList.assignAll(parsed);
      debugPrint('Loaded ${stockList.length} stocks from $assetPath');
    } catch (e) {
      errorMessage.value = 'Failed to load stocks: $e';
      debugPrint('Error loading stocks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
    app_const.currentIndex.value = index;
  }

  /// Handled when "See All" is clicked
  void navigateToAllStocks({bool pushRouteFallback = false}) {
    changeTabIndex(1);

    if (pushRouteFallback) {
      Get.to(() => const AllStocksScreen());
    }
  }

  void setSelectedStock(StockModel stock) {
    selectedStock.value = stock;
    updateChartRange(selectedChartRange.value);
  }

  void changeChartRange(String range) {
    updateChartRange(range);
  }

  void updateChartRange(String range) {
    selectedChartRange.value = range.toUpperCase();
    final stock = selectedStock.value;
    if (stock == null || stock.chartData == null) {
      activeChartPoints.clear();
      openPrice.value = 0.0;
      closePrice.value = 0.0;
      highPrice.value = 0.0;
      lowPrice.value = 0.0;
      priceChange.value = 0.0;
      percentageChange.value = 0.0;
      isRangePositive.value = true;
      return;
    }

    final points = stock.chartData!.getPointsForRange(selectedChartRange.value);
    activeChartPoints.assignAll(points);

    if (points.isNotEmpty) {
      // 1. Open: first available price in selected time range
      openPrice.value = points.first.price;
      // 2. Close: last available price in selected time range
      closePrice.value = points.last.price;
      // 3. High: maximum price in selected time range
      double maxVal = points.first.price;
      double minVal = points.first.price;
      for (final p in points) {
        if (p.price > maxVal) maxVal = p.price;
        if (p.price < minVal) minVal = p.price;
      }
      highPrice.value = maxVal;
      // 4. Low: minimum price in selected time range
      lowPrice.value = minVal;
      // 5. Price Change = Close - Open
      priceChange.value = closePrice.value - openPrice.value;
      // 6. Percentage Change = ((Close - Open) / Open) * 100
      percentageChange.value = openPrice.value != 0
          ? ((closePrice.value - openPrice.value) / openPrice.value) * 100
          : 0.0;
      // 7. Trend
      isRangePositive.value = priceChange.value >= 0;
    } else {
      openPrice.value = stock.stockPrice;
      closePrice.value = stock.stockPrice;
      highPrice.value = stock.stockPrice;
      lowPrice.value = stock.stockPrice;
      priceChange.value = 0.0;
      percentageChange.value = stock.currentChange;
      isRangePositive.value = stock.isPositive;
    }
  }

  /// Get chart data points for the currently selected stock and range
  List<ChartDataPoint> getSelectedStockChartPoints() {
    final stock = selectedStock.value;
    if (stock == null || stock.chartData == null) {
      return const [];
    }
    return stock.chartData!.getPointsForRange(selectedChartRange.value);
  }

  // ===========================================================================
  // 4. FORMATTING HELPER
  // ===========================================================================
  static String formatStockPrice(double price) {
    final isNegative = price < 0;
    final absVal = price.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final formattedInt = _formatCommas(intPart);
    final sign = isNegative ? '-' : '';
    return '$sign₹ $formattedInt.$decPart';
  }

  static String _formatCommas(String s) {
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    var remaining = s.substring(0, s.length - 3);
    final buffer = StringBuffer();

    while (remaining.length > 2) {
      buffer.write(',${remaining.substring(remaining.length - 2)}');
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      return '$remaining$buffer,$last3';
    }
    return '${buffer.toString().replaceFirst(',', '')},$last3';
  }
}
