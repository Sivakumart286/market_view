import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_size.dart';
import '../../../../core/widget/custom_text.dart';
import '../controller/market_chart_controller.dart';
import '../model/chart_point_model.dart';
import 'widget/chart_range_selector.dart';
import 'widget/stock_chart_widget.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late final MarketChartController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MarketChartController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBGColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.stockItems.isEmpty) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          if (controller.stockItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No market data found',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: AppFontSize.bodyText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => controller.loadChartData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final currentStock = controller.currentStock;
          if (currentStock == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildTopHeader(),
              const SizedBox(height: 16),
              _buildIndexSelector(),
              const SizedBox(height: 16),
              _buildMainChartCard(currentStock),
              const SizedBox(height: 16),
              _buildPerformanceMetrics(currentStock),
              const SizedBox(height: 20),
              _buildMarketListSection(),
              const SizedBox(height: 20),
            ],
          );
        }),
      ),
    );
  }

  /// Top Screen Header with Title and Live Badge
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Market View',
              fontSize: AppFontSize.mainHeading,
              fontWeight: AppFontWidth.bold,
              textColor: AppColors.primaryTextColor,
            ),
            const SizedBox(height: 2),
            const Text(
              'Real-time Market & Historical Charts',
              style: TextStyle(
                fontSize: AppFontSize.caption,
                color: Color(0xFF64748B),
                fontWeight: AppFontWidth.medium,
                fontFamily: AppFontFamily.fontFamily,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF16C784).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF16C784).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF16C784),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'LIVE',
                style: TextStyle(
                  color: Color(0xFF16C784),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Index Switcher Tabs (e.g. NIFTY 50 vs SENSEX)
  Widget _buildIndexSelector() {
    return Obx(() {
      return SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.stockItems.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final item = controller.stockItems[index];
            final isSelected = controller.selectedStockIndex.value == index;

            return GestureDetector(
              onTap: () => controller.selectStockIndex(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryTextColor : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryTextColor
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.symbol,
                      style: TextStyle(
                        fontFamily: AppFontFamily.fontFamily,
                        fontSize: AppFontSize.caption + 1,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.primaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.changePercent >= 0 ? '+' : ''}${item.changePercent}%',
                      style: TextStyle(
                        fontFamily: AppFontFamily.fontFamily,
                        fontSize: AppFontSize.caption,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? (item.changePercent >= 0
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFF87171))
                            : (item.changePercent >= 0
                                ? const Color(0xFF16C784)
                                : const Color(0xFFEA3943)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  /// Main Chart Card with Price Header, Chart, and Range Selector
  Widget _buildMainChartCard(StockMarketItem stock) {
    return Obx(() {
      final touched = controller.touchedPoint.value;
      final displayPrice = touched != null ? touched.price : stock.currentPrice;
      final isPos = controller.isPositive.value;
      final changeColor = isPos ? const Color(0xFF16C784) : const Color(0xFFEA3943);

      return Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFF0F0F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Stock Title & Exchange Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            stock.symbol,
                            style: const TextStyle(
                              fontSize: AppFontSize.sectionTitle,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              stock.exchange,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stock.companyName,
                        style: const TextStyle(
                          fontSize: AppFontSize.secondaryText,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                /// Trend badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPos ? Icons.trending_up : Icons.trending_down,
                        color: changeColor,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stock.changePercent >= 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: changeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// Live / Active Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  MarketChartController.formatCurrency(displayPrice),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                if (touched != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    '(${touched.rawTimestamp.contains('T') ? touched.rawTimestamp.split('T').last : touched.rawTimestamp})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 18),

            /// The Reusable Line Chart
            StockChartWidget(
              points: controller.currentChartPoints,
              range: controller.selectedRange.value,
              isPositive: isPos,
              height: 250,
              showTitles: true,
              isInteractive: true,
              onTouchPoint: (point) {
                controller.touchedPoint.value = point;
              },
            ),

            const SizedBox(height: 16),

            /// Range Selector: 1D, 1W, 1M, 1Y
            ChartRangeSelector(
              selectedRange: controller.selectedRange.value,
              activeColor: changeColor,
              onRangeChanged: (range) {
                controller.changeChartRange(range);
              },
            ),
          ],
        ),
      );
    });
  }

  /// Performance Metrics for Selected Period (Open, High, Low, Close, Change%)
  Widget _buildPerformanceMetrics(StockMarketItem stock) {
    return Obx(() {
      final perf = controller.currentPerformance;
      final range = controller.selectedRange.value;

      if (perf == null) return const SizedBox.shrink();

      final isPos = perf.changePercent >= 0;
      final perfColor = isPos ? const Color(0xFF16C784) : const Color(0xFFEA3943);

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
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
                  '$range Performance Overview',
                  style: const TextStyle(
                    fontSize: AppFontSize.cardTitle,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  '${isPos ? '+' : ''}${perf.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: AppFontSize.caption + 1,
                    fontWeight: FontWeight.w700,
                    color: perfColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem('Open', MarketChartController.formatCurrency(perf.open)),
                _buildMetricItem('High', MarketChartController.formatCurrency(perf.high)),
                _buildMetricItem('Low', MarketChartController.formatCurrency(perf.low)),
                _buildMetricItem('Close', MarketChartController.formatCurrency(perf.close)),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
            fontFamily: AppFontFamily.fontFamily,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            fontFamily: AppFontFamily.fontFamily,
          ),
        ),
      ],
    );
  }

  /// Market Watchlist / Indices List
  Widget _buildMarketListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'All Market Indices',
            style: TextStyle(
              fontSize: AppFontSize.cardTitle,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...controller.stockItems.asMap().entries.map((entry) {
          final index = entry.key;
          final stock = entry.value;
          final isSelected = controller.selectedStockIndex.value == index;
          final isPos = stock.changePercent >= 0;
          final color = isPos ? const Color(0xFF16C784) : const Color(0xFFEA3943);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.secondaryColor : const Color(0xFFF1F5F9),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              onTap: () => controller.selectStockIndex(index),
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: Text(
                  stock.symbol.isNotEmpty ? stock.symbol.substring(0, min(3, stock.symbol.length)) : '',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              title: Text(
                stock.symbol,
                style: const TextStyle(
                  fontSize: AppFontSize.bodyText,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                '${stock.companyName} • ${stock.exchange}',
                style: const TextStyle(
                  fontSize: AppFontSize.caption,
                  color: Color(0xFF64748B),
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    MarketChartController.formatCurrency(stock.currentPrice),
                    style: const TextStyle(
                      fontSize: AppFontSize.bodyText,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isPos ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: AppFontSize.caption,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
