/// Represents an individual chart data point with timestamp and price.
class ChartDataPoint {
  final DateTime time;
  final double price;
  final String rawTime;

  const ChartDataPoint({
    required this.time,
    required this.price,
    this.rawTime = '',
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    final rawT = json['t']?.toString() ?? '';
    final rawPrice = json['price'];

    double parsedPrice = 0.0;
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice) ?? 0.0;
    }

    DateTime parsedDate;
    try {
      parsedDate = DateTime.tryParse(rawT) ?? DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return ChartDataPoint(
      time: parsedDate,
      price: parsedPrice,
      rawTime: rawT,
    );
  }

  Map<String, dynamic> toJson() => {
    't': rawTime.isNotEmpty ? rawTime : time.toIso8601String(),
    'price': price,
  };

  static List<ChartDataPoint> fromJsonList(dynamic jsonList) {
    if (jsonList is! List) return const <ChartDataPoint>[];
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map((e) => ChartDataPoint.fromJson(e))
        .toList();
  }

  @override
  String toString() => 'ChartDataPoint(time: $time, price: $price)';
}

/// Holds all historical chart periods for a stock.
class StockChartData {
  final List<ChartDataPoint> oneDay;
  final List<ChartDataPoint> oneWeek;
  final List<ChartDataPoint> oneMonth;
  final List<ChartDataPoint> oneYear;

  const StockChartData({
    this.oneDay = const [],
    this.oneWeek = const [],
    this.oneMonth = const [],
    this.oneYear = const [],
  });

  factory StockChartData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StockChartData();
    return StockChartData(
      oneDay: ChartDataPoint.fromJsonList(json['oneDay']),
      oneWeek: ChartDataPoint.fromJsonList(json['oneWeek']),
      oneMonth: ChartDataPoint.fromJsonList(json['oneMonth']),
      oneYear: ChartDataPoint.fromJsonList(json['oneYear']),
    );
  }

  /// Maps range string ('1D', '1W', '1M', '1Y') dynamically to points
  List<ChartDataPoint> getPointsForRange(String range) {
    switch (range.toUpperCase()) {
      case '1D':
        return oneDay;
      case '1W':
        return oneWeek;
      case '1M':
        return oneMonth;
      case '1Y':
        return oneYear;
      default:
        return oneDay;
    }
  }

  Map<String, dynamic> toJson() => {
    'oneDay': oneDay.map((e) => e.toJson()).toList(),
    'oneWeek': oneWeek.map((e) => e.toJson()).toList(),
    'oneMonth': oneMonth.map((e) => e.toJson()).toList(),
    'oneYear': oneYear.map((e) => e.toJson()).toList(),
  };
}
