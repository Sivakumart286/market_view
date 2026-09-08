import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_size.dart';
import '../controller/stock_controller.dart';
import '../model/chart_data_model.dart';

/// Reusable stock line chart widget built with fl_chart.
/// Supports both Full Chart Mode and Mini Chart Mode (for Home Page index cards).
class StockChart extends StatelessWidget {
  final List<ChartDataPoint> points;
  final String range;
  final bool? isPositive;
  final double height;
  final bool isMiniChart;
  final ValueChanged<ChartDataPoint?>? onTouchPoint;

  const StockChart({
    super.key,
    required this.points,
    this.range = '1D',
    this.isPositive,
    this.height = 260,
    this.isMiniChart = false,
    this.onTouchPoint,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'no_chart_data'.tr,
            style: TextStyle(
              color: AppColors.hintColor,
              fontSize: AppFontSize.caption,
            ),
          ),
        ),
      );
    }

    // Determine trend color from AppColors
    final bool isPos = isPositive ??
        (points.length >= 2 ? points.last.price >= points.first.price : true);
    final Color chartColor =
        isPos ? AppColors.primaryColor : AppColors.negativeColor;

    // Convert to FlSpots
    final spots = List<FlSpot>.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i].price),
      growable: false,
    );

    // Min & Max calculations
    double minVal = points.first.price;
    double maxVal = points.first.price;
    for (int i = 1; i < points.length; i++) {
      final p = points[i].price;
      if (p < minVal) minVal = p;
      if (p > maxVal) maxVal = p;
    }

    final diff = maxVal - minVal;
    final padding =
        diff > 0 ? diff * (isMiniChart ? 0.08 : 0.12) : (minVal > 0 ? minVal * 0.05 : 10.0);
    final effectiveMinY = max(0.0, minVal - padding);
    final effectiveMaxY = maxVal + padding;
    final yInterval = (effectiveMaxY - effectiveMinY) / 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final bool isTablet = availableWidth > 600;
        final int targetLabels = isTablet ? 7 : 4;
        final double xInterval =
            (points.length / targetLabels).clamp(1.0, double.infinity);

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

              // Grid lines: hide completely in mini chart mode
              gridData: FlGridData(
                show: !isMiniChart,
                drawVerticalLine: false,
                drawHorizontalLine: true,
                horizontalInterval: yInterval > 0 ? yInterval : 10.0,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.gridLineColor,
                  strokeWidth: 1,
                  dashArray: const [4, 4],
                ),
              ),

              // Hide borders
              borderData: FlBorderData(show: false),

              // Titles: hide completely in mini chart mode
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: !isMiniChart,
                    reservedSize: 58,
                    interval: yInterval > 0 ? yInterval : 10.0,
                    getTitlesWidget: (value, meta) {
                      if (value < effectiveMinY || value > effectiveMaxY) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: 6,
                        child: Text(
                          _formatYAxis(value),
                          style: TextStyle(
                            fontFamily: AppFontFamily.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.hintColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: !isMiniChart,
                    reservedSize: 26,
                    interval: xInterval,
                    getTitlesWidget: (value, meta) {
                      final idx = value.round();
                      if (idx < 0 || idx >= points.length) {
                        return const SizedBox.shrink();
                      }

                      final isFirst = idx == 0;
                      final isLast = idx == points.length - 1;
                      final matches = (idx % xInterval.round()) == 0;

                      if (!matches && !isFirst && !isLast) {
                        return const SizedBox.shrink();
                      }

                      return SideTitleWidget(
                        meta: meta,
                        space: 6,
                        child: Text(
                          _formatXAxis(points[idx].time, range),
                          style: TextStyle(
                            fontFamily: AppFontFamily.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Touch interaction: disabled in mini chart mode
              lineTouchData: LineTouchData(
                enabled: !isMiniChart,
                handleBuiltInTouches: !isMiniChart,
                touchCallback: (event, response) {
                  if (onTouchPoint == null || isMiniChart) return;
                  if (response == null ||
                      response.lineBarSpots == null ||
                      response.lineBarSpots!.isEmpty) {
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
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes.map((idx) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: chartColor.withValues(alpha: 0.6),
                        strokeWidth: 1.5,
                        dashArray: const [3, 3],
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, i) =>
                            FlDotCirclePainter(
                          radius: 5,
                          color: chartColor,
                          strokeWidth: 2,
                          strokeColor: AppColors.staticWhite,
                        ),
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.tooltipBackground,
                  tooltipRoundedRadius: 10,
                  tooltipPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  tooltipMargin: 12,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final idx = spot.x.round();
                      if (idx < 0 || idx >= points.length) return null;

                      final point = points[idx];
                      final dt = point.time;
                      final formattedPrice =
                          StockController.formatStockPrice(point.price);
                      final formattedDate = _formatTooltipDate(dt);
                      final formattedTime =
                          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

                      return LineTooltipItem(
                        '$formattedPrice\n',
                        TextStyle(
                          color: AppColors.staticWhite,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          fontFamily: AppFontFamily.fontFamily,
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(
                            text: '$formattedDate • $formattedTime',
                            style: TextStyle(
                              color: AppColors.staticWhite.withValues(alpha: 0.75),
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

              // Curved line and gradient area fill
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.25,
                  color: chartColor,
                  barWidth: isMiniChart ? 1.8 : 2.2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        chartColor.withValues(alpha: isMiniChart ? 0.18 : 0.22),
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

  static String _formatYAxis(double p) {
    if (p >= 1000) {
      return '${(p / 1000).toStringAsFixed(1)}k';
    } else if (p >= 100) {
      return p.toStringAsFixed(0);
    }
    return p.toStringAsFixed(1);
  }

  static String _formatXAxis(DateTime dt, String range) {
    switch (range.toUpperCase()) {
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
