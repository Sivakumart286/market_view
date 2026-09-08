import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_font_size.dart';
import '../../controller/market_chart_controller.dart';
import '../../model/chart_point_model.dart';

/// Reusable and modular Stock Chart Widget built using fl_chart.
/// Accepts any list of [ChartPointModel] dynamically and adapts responsively.
class StockChartWidget extends StatelessWidget {
  final List<ChartPointModel> points;
  final String range;
  final bool? isPositive;
  final double height;
  final bool showTitles;
  final bool isInteractive;
  final ValueChanged<ChartPointModel?>? onTouchPoint;
  final Color? positiveColor;
  final Color? negativeColor;

  const StockChartWidget({
    super.key,
    required this.points,
    this.range = '1D',
    this.isPositive,
    this.height = 280,
    this.showTitles = true,
    this.isInteractive = true,
    this.onTouchPoint,
    this.positiveColor,
    this.negativeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No chart data available',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ),
      );
    }

    // Determine positive/negative chart color dynamically
    final isPos = isPositive ??
        (points.length >= 2 ? points.last.price >= points.first.price : true);
    final chartColor = isPos
        ? (positiveColor ?? MarketChartController.greenPositive)
        : (negativeColor ?? MarketChartController.redNegative);

    // Convert points dynamically into FlSpot(index, price)
    final spots = List<FlSpot>.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i].price),
      growable: false,
    );

    // Calculate dynamic min/max and padding
    double minVal = points.first.price;
    double maxVal = points.first.price;
    for (int i = 1; i < points.length; i++) {
      final p = points[i].price;
      if (p < minVal) minVal = p;
      if (p > maxVal) maxVal = p;
    }

    final priceDiff = maxVal - minVal;
    final yPadding = priceDiff > 0 ? (priceDiff * 0.12) : (minVal > 0 ? minVal * 0.05 : 10.0);
    final effectiveMinY = max(0.0, minVal - yPadding);
    final effectiveMaxY = maxVal + yPadding;

    // Y-axis interval calculation for 4-5 horizontal grid lines
    final ySpan = effectiveMaxY - effectiveMinY;
    final yInterval = ySpan > 0 ? (ySpan / 4) : 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Adjust X-axis label count based on screen width (mobile vs tablet)
        final bool isTablet = availableWidth > 600;
        final int targetLabelCount = isTablet ? 7 : 4;
        final double xInterval = (points.length / targetLabelCount).clamp(1.0, double.infinity);

        return SizedBox(
          height: height,
          width: double.infinity,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (points.length - 1).toDouble(),
              minY: effectiveMinY,
              maxY: effectiveMaxY,
              clipData: const FlClipData.all(),

              // Subtle horizontal grid lines only, no vertical lines
              gridData: FlGridData(
                show: showTitles,
                drawVerticalLine: false,
                drawHorizontalLine: true,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (value) => const FlLine(
                  color: Color(0xFFF1F5F9),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),

              // Hide unnecessary borders
              borderData: FlBorderData(show: false),

              // Titles: right Y-axis formatted prices, bottom X-axis formatted dates/times
              titlesData: FlTitlesData(
                show: showTitles,
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: showTitles,
                    reservedSize: 58,
                    interval: yInterval,
                    getTitlesWidget: (value, meta) {
                      // Avoid printing outside bounds
                      if (value < effectiveMinY || value > effectiveMaxY) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: 6,
                        child: Text(
                          _formatYAxisPrice(value),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFontFamily.fontFamily,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: showTitles,
                    reservedSize: 28,
                    interval: xInterval,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }

                      // Only draw when index matches interval or is last point
                      final isLast = index == points.length - 1;
                      final isFirst = index == 0;
                      final matchesInterval = (index % xInterval.round()) == 0;

                      if (!matchesInterval && !isLast && !isFirst) {
                        return const SizedBox.shrink();
                      }

                      final label = _formatXAxisLabel(points[index].timestamp, range);
                      return SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFontFamily.fontFamily,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Touch interaction & Tooltip
              lineTouchData: LineTouchData(
                enabled: isInteractive,
                handleBuiltInTouches: true,
                touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                  if (onTouchPoint == null) return;
                  if (response == null || response.lineBarSpots == null || response.lineBarSpots!.isEmpty) {
                    if (event is FlTapUpEvent || event is FlPanEndEvent) {
                      onTouchPoint!(null);
                    }
                    return;
                  }
                  final spotIndex = response.lineBarSpots!.first.spotIndex;
                  if (spotIndex >= 0 && spotIndex < points.length) {
                    onTouchPoint!(points[spotIndex]);
                  }
                },
                getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: chartColor.withValues(alpha: 0.7),
                        strokeWidth: 1.5,
                        dashArray: [3, 3],
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, idx) => FlDotCirclePainter(
                          radius: 5.5,
                          color: chartColor,
                          strokeWidth: 2.5,
                          strokeColor: Colors.white,
                        ),
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => const Color(0xFF0F172A),
                  tooltipRoundedRadius: 10,
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  tooltipMargin: 12,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      final index = touchedSpot.x.round();
                      if (index < 0 || index >= points.length) return null;

                      final point = points[index];
                      final formattedPrice = MarketChartController.formatCurrency(point.price);
                      final dt = point.timestamp;
                      final formattedDate = _formatTooltipDate(dt);
                      final formattedTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

                      return LineTooltipItem(
                        '$formattedPrice\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          fontFamily: AppFontFamily.fontFamily,
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(
                            text: '$formattedDate • $formattedTime',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontWeight: FontWeight.normal,
                              fontSize: 10.5,
                              fontFamily: AppFontFamily.fontFamily,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),

              // Smooth curved line chart data
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.25,
                  color: chartColor,
                  barWidth: 2.2,
                  isStrokeCapRound: true,
                  // Hide dots by default for clean trading view appearance
                  dotData: const FlDotData(show: false),
                  // Subtle gradient area fill below chart line
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        chartColor.withValues(alpha: 0.22),
                        chartColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // Formatters
  // ===========================================================================
  static String _formatYAxisPrice(double price) {
    if (price >= 100000) {
      return '${(price / 1000).toStringAsFixed(1)}k';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}k';
    } else if (price >= 100) {
      return price.toStringAsFixed(0);
    }
    return price.toStringAsFixed(1);
  }

  static String _formatXAxisLabel(DateTime dt, String rangeLabel) {
    switch (rangeLabel.toUpperCase()) {
      case '1D':
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      case '1W':
      case '1M':
        return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
      case '1Y':
        final shortYear = (dt.year % 100).toString().padLeft(2, '0');
        return '${dt.month.toString().padLeft(2, '0')}/$shortYear';
      default:
        return '${dt.day}/${dt.month}';
    }
  }

  static String _formatTooltipDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }
}
