import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_size.dart';
import '../../model/chart_point_model.dart';

/// Professional segmented range selector for stock charts.
class ChartRangeSelector extends StatelessWidget {
  final String selectedRange;
  final ValueChanged<String> onRangeChanged;
  final List<String> ranges;
  final Color? activeColor;
  final Color? backgroundColor;

  const ChartRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    this.ranges = ChartRangeConstants.availableRanges,
    this.activeColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primaryColor;
    final effectiveBg = backgroundColor ?? const Color(0xFFF1F5F9);

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: ranges.map((range) {
          final isSelected = range.toUpperCase() == selectedRange.toUpperCase();
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onRangeChanged(range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  range,
                  style: TextStyle(
                    fontFamily: AppFontFamily.fontFamily,
                    fontSize: AppFontSize.caption + 1,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? effectiveActiveColor
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
