import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_size.dart';
import '../controller/stock_controller.dart';
import '../model/chart_data_model.dart';
import '../model/stock_model.dart';
import '../widget/stock_chart.dart';

/// Professional stock trading chart screen displaying dynamic historical charts,
/// dynamic range-based Market Summary (Open, Close, High, Low, Price Change, % Change).
/// Completely removes any save/bookmark actions.
class StockChartScreen extends StatefulWidget {
  final dynamic stock;

  const StockChartScreen({
    super.key,
    this.stock,
  });

  @override
  State<StockChartScreen> createState() => _StockChartScreenState();
}

class _StockChartScreenState extends State<StockChartScreen> {
  late final StockController controller;
  late final StockModel stock;
  final Rxn<ChartDataPoint> touchedPoint = Rxn<ChartDataPoint>();

  static const List<String> availableRanges = ['1D', '1W', '1M', '1Y'];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<StockController>()
        ? Get.find<StockController>()
        : Get.put(StockController());

    // Resolve stock from widget or Get.arguments (supports StockModel & MarketIndex)
    final rawArg = widget.stock ?? Get.arguments;
    if (rawArg is StockModel) {
      stock = rawArg;
    } else if (rawArg != null) {
      stock = StockModel.fromMarketIndex(rawArg);
    } else {
      stock = const StockModel(
        symbol: 'STOCK',
        companyName: 'Market View Stock',
        stockPrice: 0.0,
        currentChange: 0.0,
        image: '',
      );
    }

    // Set active stock and calculate initial 1D metrics
    controller.setSelectedStock(stock);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBGColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const BouncingScrollPhysics(),
          children: [
            /// Stock Header Card with dynamic price and range trend
            _buildStockHeader(),

            const SizedBox(height: 16),

            /// Main Chart Container Card
            _buildChartCard(),

            const SizedBox(height: 16),

            /// Dynamic Market Summary (Open, Close, High, Low, Price Change, % Change)
            _buildMarketSummaryCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// App Bar: Strictly without Save/Bookmark option
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.staticWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: AppColors.primaryTextColor,
        ),
        onPressed: () => Get.back(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniLogo(),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stock.symbol,
                style: TextStyle(
                  fontFamily: AppFontFamily.fontFamily,
                  fontSize: AppFontSize.cardTitle - 1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTextColor,
                ),
              ),
              Text(
                stock.companyName,
                style: TextStyle(
                  fontFamily: AppFontFamily.fontFamily,
                  fontSize: AppFontSize.caption - 1,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: false,
      // Save action completely removed
    );
  }

  Widget _buildMiniLogo() {
    final hasImage = stock.image.isNotEmpty && stock.image.startsWith('http');
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.containerBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorderColor),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              stock.image,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildFallbackText(),
            )
          : _buildFallbackText(),
    );
  }

  Widget _buildFallbackText() {
    final sym = stock.symbol;
    final initial = sym.isNotEmpty ? sym.substring(0, min(2, sym.length)) : 'S';
    return Text(
      initial,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.initialsTextColor,
      ),
    );
  }

  /// Header displaying Price and dynamic range movement
  Widget _buildStockHeader() {
    return Obx(() {
      final touched = touchedPoint.value;
      final isPos = controller.isRangePositive.value;
      final Color trendColor =
          isPos ? AppColors.primaryColor : AppColors.negativeColor;

      final currentDisplayPrice = touched != null
          ? touched.price
          : (controller.closePrice.value > 0
              ? controller.closePrice.value
              : stock.stockPrice);

      final displayPercentChange = controller.percentageChange.value;
      final displayPriceChange = controller.priceChange.value;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.staticWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorderColor),
          boxShadow: const [
            BoxShadow(
              color: AppColors.lightShadow,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: TextStyle(
                        fontFamily: AppFontFamily.fontFamily,
                        fontSize: AppFontSize.mainHeading,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryTextColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stock.companyName,
                      style: TextStyle(
                        fontFamily: AppFontFamily.fontFamily,
                        fontSize: AppFontSize.secondaryText,
                        color: AppColors.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPos ? Icons.trending_up : Icons.trending_down,
                        size: 18,
                        color: trendColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPos ? '+' : ''}${displayPercentChange.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontFamily: AppFontFamily.fontFamily,
                          fontSize: AppFontSize.caption,
                          fontWeight: FontWeight.w700,
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  StockController.formatStockPrice(currentDisplayPrice),
                  style: TextStyle(
                    fontFamily: AppFontFamily.fontFamily,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTextColor,
                    letterSpacing: -0.5,
                  ),
                ),
                if (touched != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    '(${touched.rawTime})',
                    style: TextStyle(
                      fontFamily: AppFontFamily.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.hintColor,
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 10),
                  Text(
                    '${isPos ? '+' : ''}${StockController.formatStockPrice(displayPriceChange)}',
                    style: TextStyle(
                      fontFamily: AppFontFamily.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: trendColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Main Chart Card
  Widget _buildChartCard() {
    return Obx(() {
      final range = controller.selectedChartRange.value;
      final points = controller.activeChartPoints;
      final isPos = controller.isRangePositive.value;
      final Color trendColor =
          isPos ? AppColors.primaryColor : AppColors.negativeColor;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.staticWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorderColor),
          boxShadow: const [
            BoxShadow(
              color: AppColors.lightShadow,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            /// Stock Chart Widget
            StockChart(
              points: points,
              range: range,
              isPositive: isPos,
              height: 260,
              onTouchPoint: (point) {
                touchedPoint.value = point;
              },
            ),

            const SizedBox(height: 18),

            /// Range Selector: 1D, 1W, 1M, 1Y
            _buildRangeSelector(trendColor),
          ],
        ),
      );
    });
  }

  Widget _buildRangeSelector(Color activeColor) {
    return Obx(() {
      final current = controller.selectedChartRange.value;

      return Container(
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.containerBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputBorderColor),
        ),
        child: Row(
          children: availableRanges.map((r) {
            final isSelected = r == current;
            final localizedLabel = _getRangeLocalizedText(r);

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  touchedPoint.value = null;
                  controller.changeChartRange(r);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.staticWhite : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: AppColors.lightShadow,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    localizedLabel,
                    style: TextStyle(
                      fontFamily: AppFontFamily.fontFamily,
                      fontSize: AppFontSize.caption,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? activeColor
                          : AppColors.secondaryTextColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  String _getRangeLocalizedText(String r) {
    switch (r) {
      case '1D':
        return 'range_1d'.tr;
      case '1W':
        return 'range_1w'.tr;
      case '1M':
        return 'range_1m'.tr;
      case '1Y':
        return 'range_1y'.tr;
      default:
        return r;
    }
  }

  /// Dynamic Market Summary Card: Open, Close, High, Low, Price Change, % Change
  Widget _buildMarketSummaryCard() {
    return Obx(() {
      final range = controller.selectedChartRange.value;
      final open = controller.openPrice.value;
      final close = controller.closePrice.value;
      final high = controller.highPrice.value;
      final low = controller.lowPrice.value;
      final pChange = controller.priceChange.value;
      final pctChange = controller.percentageChange.value;
      final isPos = controller.isRangePositive.value;
      final Color trendColor =
          isPos ? AppColors.primaryColor : AppColors.negativeColor;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.staticWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorderColor),
          boxShadow: const [
            BoxShadow(
              color: AppColors.lightShadow,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'market_summary'.tr} ($range)',
                  style: TextStyle(
                    fontFamily: AppFontFamily.fontFamily,
                    fontSize: AppFontSize.cardTitle - 1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                Text(
                  '${isPos ? '+' : ''}${pctChange.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontFamily: AppFontFamily.fontFamily,
                    fontSize: AppFontSize.caption + 1,
                    fontWeight: FontWeight.w700,
                    color: trendColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.cardBorderColor, height: 1),
            const SizedBox(height: 14),

            /// Row 1: Open, Close, High, Low
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryMetric('label_open'.tr, StockController.formatStockPrice(open)),
                _buildSummaryMetric('label_close'.tr, StockController.formatStockPrice(close)),
                _buildSummaryMetric('label_high'.tr, StockController.formatStockPrice(high)),
                _buildSummaryMetric('label_low'.tr, StockController.formatStockPrice(low)),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: AppColors.cardBorderColor, height: 1),
            const SizedBox(height: 14),

            /// Row 2: Price Change and Percentage Change
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryMetric(
                  'price_change'.tr,
                  '${isPos ? '+' : ''}${StockController.formatStockPrice(pChange)}',
                  valueColor: trendColor,
                ),
                _buildSummaryMetric(
                  'percentage_change'.tr,
                  '${isPos ? '+' : ''}${pctChange.toStringAsFixed(2)}%',
                  valueColor: trendColor,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryMetric(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFontFamily.fontFamily,
            fontSize: 11,
            color: AppColors.hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFontFamily.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.detailValueColor,
          ),
        ),
      ],
    );
  }
}
