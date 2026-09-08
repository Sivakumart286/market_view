import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../model/chart_point_model.dart';

class MarketChartController extends GetxController {
  /// Reactive state variables
  final RxBool isLoading = false.obs;
  final RxString selectedRange = '1D'.obs;
  final RxInt selectedStockIndex = 0.obs;

  /// Available stocks / indices parsed from JSON
  final RxList<StockMarketItem> stockItems = <StockMarketItem>[].obs;

  /// Active chart points and computed properties
  final RxList<ChartPointModel> currentChartPoints = <ChartPointModel>[].obs;
  final RxList<FlSpot> currentSpots = <FlSpot>[].obs;
  final RxDouble minY = 0.0.obs;
  final RxDouble maxY = 0.0.obs;
  final RxDouble yPadding = 0.0.obs;
  final RxBool isPositive = true.obs;

  /// Custom active/highlighted touched point (for interactive live stats)
  final Rxn<ChartPointModel> touchedPoint = Rxn<ChartPointModel>();

  /// Default colors
  static const Color greenPositive = Color(0xFF16C784);
  static const Color redNegative = Color(0xFFEA3943);

  @override
  void onInit() {
    super.onInit();
    loadChartData();
  }

  /// Current selected stock/index item
  StockMarketItem? get currentStock {
    if (stockItems.isEmpty) return null;
    final idx = selectedStockIndex.value.clamp(0, stockItems.length - 1);
    return stockItems[idx];
  }

  /// Current active performance metrics based on selected range
  StockPeriodPerformance? get currentPerformance {
    return currentStock?.getPerformanceForLabel(selectedRange.value);
  }

  // ===========================================================================
  // 1. REUSABLE COMMON METHOD: Loading chart data
  // ===========================================================================
  Future<void> loadChartData({
    String assetPath = 'data/nifty_sensex.json',
  }) async {
    isLoading.value = true;
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<StockMarketItem> items = parseJsonData(jsonString);
      stockItems.assignAll(items);

      if (stockItems.isNotEmpty) {
        // Refresh active chart data for default selection
        updateActiveChartData();
      }
    } catch (e) {
      debugPrint('Error loading stock chart data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================================================
  // 2. REUSABLE COMMON METHOD: Parsing JSON data
  // ===========================================================================
  List<StockMarketItem> parseJsonData(String jsonString) {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        final indices = decoded['indices'];
        if (indices is List) {
          return indices
              .whereType<Map<String, dynamic>>()
              .map((item) => StockMarketItem.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error parsing stock JSON data: $e');
    }
    return <StockMarketItem>[];
  }

  // ===========================================================================
  // 3. REUSABLE COMMON METHOD: Changing chart range (using dynamic mapping)
  // ===========================================================================
  void changeChartRange(String rangeLabel) {
    if (!ChartRangeConstants.chartRangeMap.containsKey(rangeLabel)) {
      debugPrint('Invalid chart range: $rangeLabel');
      return;
    }

    selectedRange.value = rangeLabel;
    touchedPoint.value = null;
    updateActiveChartData();
  }

  /// Select a different stock or index (e.g. 0 for NIFTY50, 1 for SENSEX)
  void selectStockIndex(int index) {
    if (index >= 0 && index < stockItems.length) {
      selectedStockIndex.value = index;
      touchedPoint.value = null;
      updateActiveChartData();
    }
  }

  /// Updates current chart points, spots, bounds, padding, and color
  void updateActiveChartData() {
    final stock = currentStock;
    if (stock == null) return;

    final points = stock.chartData.getPointsByLabel(selectedRange.value);
    currentChartPoints.assignAll(points);

    // 4. Generate spots
    currentSpots.assignAll(generateSpots(points));

    // 5. Min & Max calculation
    final minMax = calculateMinMaxPrice(points);

    // 6. Dynamic padding calculation (so line never clips top or bottom)
    final padding = calculateChartPadding(minMax.min, minMax.max);
    yPadding.value = padding;

    minY.value = max(0.0, minMax.min - padding);
    maxY.value = minMax.max + padding;

    // 7. Dynamic positive/negative color determination
    isPositive.value = isDataPositive(points);
  }

  // ===========================================================================
  // 4. REUSABLE COMMON METHOD: Generating FlSpot data
  // ===========================================================================
  List<FlSpot> generateSpots(List<ChartPointModel> points) {
    if (points.isEmpty) return const <FlSpot>[];
    return List<FlSpot>.generate(
      points.length,
      (index) => FlSpot(index.toDouble(), points[index].price),
      growable: false,
    );
  }

  // ===========================================================================
  // 5. REUSABLE COMMON METHOD: Calculating minimum and maximum price
  // ===========================================================================
  ({double min, double max}) calculateMinMaxPrice(
    List<ChartPointModel> points,
  ) {
    if (points.isEmpty) return (min: 0.0, max: 100.0);

    double minVal = points.first.price;
    double maxVal = points.first.price;

    for (int i = 1; i < points.length; i++) {
      final p = points[i].price;
      if (p < minVal) minVal = p;
      if (p > maxVal) maxVal = p;
    }

    return (min: minVal, max: maxVal);
  }

  // ===========================================================================
  // 6. REUSABLE COMMON METHOD: Calculating chart padding
  // ===========================================================================
  double calculateChartPadding(
    double min,
    double max, {
    double paddingRatio = 0.12,
  }) {
    final diff = max - min;
    if (diff <= 0.0) {
      return (min > 0.0) ? (min * 0.05) : 10.0;
    }
    return diff * paddingRatio;
  }

  // ===========================================================================
  // 7. REUSABLE COMMON METHOD: Determining positive/negative chart color
  // ===========================================================================
  bool isDataPositive(List<ChartPointModel> points) {
    if (points.length < 2) return true;
    final firstPrice = points.first.price;
    final latestPrice = points.last.price;
    return latestPrice >= firstPrice;
  }

  Color determineChartColor(List<ChartPointModel> points) {
    return isDataPositive(points) ? greenPositive : redNegative;
  }

  // ===========================================================================
  // 8. REUSABLE COMMON METHOD: Formatting X-axis labels based on range
  // ===========================================================================
  String formatXAxisLabel(
    int index,
    String rangeLabel,
    List<ChartPointModel> points,
  ) {
    if (index < 0 || index >= points.length) return '';
    final dt = points[index].timestamp;

    switch (rangeLabel) {
      case '1D':
        // HH:mm format
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      case '1W':
      case '1M':
        // DD/MM format
        return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
      case '1Y':
        // MM/YY format
        final shortYear = (dt.year % 100).toString().padLeft(2, '0');
        return '${dt.month.toString().padLeft(2, '0')}/$shortYear';
      default:
        return '${dt.day}/${dt.month}';
    }
  }

  // ===========================================================================
  // 9. REUSABLE COMMON METHOD: Formatting tooltip date and time
  // ===========================================================================
  ({String price, String date, String time}) formatTooltipData(
    ChartPointModel point, {
    String rangeLabel = '1D',
  }) {
    final dt = point.timestamp;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final monthName = months[dt.month - 1];
    final formattedDate = '${dt.day.toString().padLeft(2, '0')} $monthName ${dt.year}';
    final formattedTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final formattedPrice = formatCurrency(point.price);

    return (
      price: formattedPrice,
      date: formattedDate,
      time: formattedTime,
    );
  }

  // ===========================================================================
  // REUSABLE HELPER: Currency and Number Formatting
  // ===========================================================================
  static String formatCurrency(double price, {bool showSymbol = true}) {
    final isNegative = price < 0;
    final absVal = price.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Format with commas according to Indian numbering style (e.g. 23,897.70)
    final formattedInt = _formatWithCommas(intPart);
    final prefix = showSymbol ? '₹' : '';
    final sign = isNegative ? '-' : '';
    return '$sign$prefix$formattedInt.$decPart';
  }

  static String _formatWithCommas(String intString) {
    if (intString.length <= 3) return intString;
    final last3 = intString.substring(intString.length - 3);
    var remaining = intString.substring(0, intString.length - 3);
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
