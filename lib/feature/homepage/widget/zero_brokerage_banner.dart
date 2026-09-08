import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_size.dart';

/// Reusable, modern trading-app promotional banner communicating Zero Brokerage.
/// Designed with a premium dark gradient, prominent ₹0 highlight, decorative chart lines,
/// and responsive layout without text collision or overflow.
class ZeroBrokerageBanner extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? highlightText;
  final String? buttonText;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  const ZeroBrokerageBanner({
    super.key,
    this.title,
    this.subtitle,
    this.highlightText,
    this.buttonText,
    this.onTap,
    this.margin = const EdgeInsets.only(top: 18, bottom: 6),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? 'zero_brokerage_title'.tr;
    final effectiveSubtitle = subtitle ?? 'zero_brokerage_description'.tr;
    final effectiveHighlight = highlightText ?? 'zero_brokerage'.tr;
    final effectiveButtonText = buttonText ?? 'start_trading'.tr;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bannerPrimaryColor,
            AppColors.bannerSecondaryColor,
          ],
        ),
        border: Border.all(
          color: AppColors.bannerBorderColor,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Stack(
              children: [
                /// Decorative Trading Chart & Candlestick Canvas
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BannerChartPainter(
                      chartColor: AppColors.bannerAccentColor,
                    ),
                  ),
                ),

                /// Subtle ₹0 Watermark on the Right Background
                Positioned(
                  right: 14,
                  bottom: -10,
                  child: IgnorePointer(
                    child: Text(
                      '₹0',
                      style: TextStyle(
                        fontFamily: AppFontFamily.fontFamily,
                        fontSize: 90,
                        fontWeight: FontWeight.w900,
                        color: AppColors.bannerAccentColor.withValues(alpha: 0.07),
                        height: 1,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                ),

                /// Foreground Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// ₹0 BROKERAGE Pill Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bannerBadgeBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.bannerAccentColor
                                      .withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    size: 13,
                                    color: AppColors.bannerAccentColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    effectiveHighlight,
                                    style: TextStyle(
                                      fontFamily: AppFontFamily.fontFamily,
                                      fontSize: AppFontSize.caption - 1,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.bannerAccentColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// Title: Trade More. Pay Less.
                            Text(
                              effectiveTitle,
                              style: TextStyle(
                                fontFamily: AppFontFamily.fontFamily,
                                fontSize: AppFontSize.sectionTitle + 2,
                                fontWeight: FontWeight.w800,
                                color: AppColors.bannerTextColor,
                                height: 1.2,
                                letterSpacing: -0.2,
                              ),
                            ),

                            const SizedBox(height: 6),

                            /// Subtitle: Invest and trade smarter with zero brokerage charges.
                            Text(
                              effectiveSubtitle,
                              style: TextStyle(
                                fontFamily: AppFontFamily.fontFamily,
                                fontSize: AppFontSize.caption + 0.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.bannerSubtitleColor,
                                height: 1.35,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 14),

                            /// Call to Action Button: Start Trading →
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bannerButtonBg,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.bannerAccentColor
                                        .withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    effectiveButtonText,
                                    style: TextStyle(
                                      fontFamily: AppFontFamily.fontFamily,
                                      fontSize: AppFontSize.caption + 0.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.bannerButtonTextColor,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: AppColors.bannerButtonTextColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for subtle trading line chart and candlestick decorative elements.
class _BannerChartPainter extends CustomPainter {
  final Color chartColor;

  _BannerChartPainter({required this.chartColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Upward trending smooth curve on right half
    final path = Path();
    path.moveTo(w * 0.45, h * 0.85);
    path.cubicTo(
      w * 0.60,
      h * 0.80,
      w * 0.70,
      h * 0.45,
      w * 0.82,
      h * 0.50,
    );
    path.cubicTo(
      w * 0.90,
      h * 0.55,
      w * 0.93,
      h * 0.22,
      w * 1.02,
      h * 0.15,
    );

    // Stroke line
    final linePaint = Paint()
      ..color = chartColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // Filled gradient area below line
    final fillPath = Path.from(path)
      ..lineTo(w * 1.02, h)
      ..lineTo(w * 0.45, h)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          chartColor.withValues(alpha: 0.15),
          chartColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(w * 0.45, 0, w * 0.57, h));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Subtle candlestick accents
    final candlePaint = Paint()
      ..color = chartColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    // Candle 1
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.72, h * 0.32, 6, 26),
        const Radius.circular(2),
      ),
      candlePaint,
    );
    // Wick 1
    canvas.drawLine(
      Offset(w * 0.72 + 3, h * 0.24),
      Offset(w * 0.72 + 3, h * 0.62),
      linePaint..strokeWidth = 1.0,
    );

    // Candle 2
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.86, h * 0.18, 6, 22),
        const Radius.circular(2),
      ),
      candlePaint,
    );
    // Wick 2
    canvas.drawLine(
      Offset(w * 0.86 + 3, h * 0.10),
      Offset(w * 0.86 + 3, h * 0.45),
      linePaint..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
