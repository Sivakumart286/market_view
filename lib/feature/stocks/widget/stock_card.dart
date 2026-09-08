import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_size.dart';
import '../controller/stock_controller.dart';
import '../model/stock_model.dart';
import '../view/stock_chart_screen.dart';

/// Reusable stock card widget used across Home Screen and All Stocks Screen.
class StockCard extends StatelessWidget {
  final StockModel stock;
  final VoidCallback? onTap;

  const StockCard({
    super.key,
    required this.stock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPos = stock.isPositive;
    final Color changeColor =
        isPos ? AppColors.primaryColor : AppColors.negativeColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.staticWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorderColor,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ??
              () {
                // Set active stock in controller if registered
                if (Get.isRegistered<StockController>()) {
                  Get.find<StockController>().setSelectedStock(stock);
                }
                Get.to(
                  () => const StockChartScreen(),
                  arguments: stock,
                );
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                /// Company / Stock Logo
                _buildLogo(),

                const SizedBox(width: 12),

                /// Symbol & Company Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stock.symbol,
                        style: TextStyle(
                          fontFamily: AppFontFamily.fontFamily,
                          fontSize: AppFontSize.cardTitle - 1,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryTextColor,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        stock.companyName,
                        style: TextStyle(
                          fontFamily: AppFontFamily.fontFamily,
                          fontSize: AppFontSize.caption + 0.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                /// Stock Price & Current Change
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      StockController.formatStockPrice(stock.stockPrice),
                      style: TextStyle(
                        fontFamily: AppFontFamily.fontFamily,
                        fontSize: AppFontSize.cardTitle - 1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPos ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            size: 16,
                            color: changeColor,
                          ),
                          Text(
                            '${isPos ? '+' : ''}${stock.currentChange.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontFamily: AppFontFamily.fontFamily,
                              fontSize: AppFontSize.caption - 0.5,
                              fontWeight: FontWeight.w700,
                              color: changeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final hasImage = stock.image.isNotEmpty && stock.image.startsWith('http');

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.inputBorderColor,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              stock.image,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildFallbackInitials(),
            )
          : _buildFallbackInitials(),
    );
  }

  Widget _buildFallbackInitials() {
    final sym = stock.symbol;
    final initials = sym.isNotEmpty ? sym.substring(0, min(2, sym.length)) : 'ST';
    return Text(
      initials,
      style: TextStyle(
        fontFamily: AppFontFamily.fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.initialsTextColor,
      ),
    );
  }
}
