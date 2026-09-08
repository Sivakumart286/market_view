/// Represents a single chart data point containing timestamp and price.
class ChartPointModel {
  final String rawTimestamp;
  final DateTime timestamp;
  final double price;

  const ChartPointModel({
    required this.rawTimestamp,
    required this.timestamp,
    required this.price,
  });

  /// Factory constructor to parse raw JSON map with "t" and "price".
  factory ChartPointModel.fromJson(Map<String, dynamic> json) {
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

    return ChartPointModel(
      rawTimestamp: rawT,
      timestamp: parsedDate,
      price: parsedPrice,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
    't': rawTimestamp,
    'price': price,
  };

  /// Helper to parse a list of JSON objects
  static List<ChartPointModel> fromJsonList(dynamic jsonList) {
    if (jsonList is! List) return <ChartPointModel>[];
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map((item) => ChartPointModel.fromJson(item))
        .toList();
  }

  @override
  String toString() => 'ChartPointModel(t: $rawTimestamp, price: $price)';
}

/// Enum representing supported chart ranges with labels and JSON property names.
enum ChartRange {
  oneDay('1D', 'oneDay'),
  oneWeek('1W', 'oneWeek'),
  oneMonth('1M', 'oneMonth'),
  oneYear('1Y', 'oneYear');

  final String label;
  final String jsonKey;

  const ChartRange(this.label, this.jsonKey);

  /// Find range by button label (e.g. '1D', '1W', '1M', '1Y')
  static ChartRange fromLabel(String label) {
    return ChartRange.values.firstWhere(
      (r) => r.label.toUpperCase() == label.toUpperCase(),
      orElse: () => ChartRange.oneDay,
    );
  }

  /// Find range by JSON key (e.g. 'oneDay', 'oneWeek', 'oneMonth', 'oneYear')
  static ChartRange fromJsonKey(String key) {
    return ChartRange.values.firstWhere(
      (r) => r.jsonKey.toLowerCase() == key.toLowerCase(),
      orElse: () => ChartRange.oneDay,
    );
  }
}

/// Reusable mapping constants conforming to requirements:
/// Avoids repeated if/else blocks and allows easy extensibility.
class ChartRangeConstants {
  static const Map<String, String> chartRangeMap = {
    '1D': 'oneDay',
    '1W': 'oneWeek',
    '1M': 'oneMonth',
    '1Y': 'oneYear',
  };

  static const List<String> availableRanges = ['1D', '1W', '1M', '1Y'];
}

/// Represents the historical chart collection for all ranges.
class StockChartDataModel {
  final List<ChartPointModel> oneDay;
  final List<ChartPointModel> oneWeek;
  final List<ChartPointModel> oneMonth;
  final List<ChartPointModel> oneYear;

  const StockChartDataModel({
    this.oneDay = const [],
    this.oneWeek = const [],
    this.oneMonth = const [],
    this.oneYear = const [],
  });

  factory StockChartDataModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StockChartDataModel();
    return StockChartDataModel(
      oneDay: ChartPointModel.fromJsonList(json['oneDay']),
      oneWeek: ChartPointModel.fromJsonList(json['oneWeek']),
      oneMonth: ChartPointModel.fromJsonList(json['oneMonth']),
      oneYear: ChartPointModel.fromJsonList(json['oneYear']),
    );
  }

  /// Common method to retrieve points by range key dynamically without conditional branching
  List<ChartPointModel> getPointsByRangeKey(String rangeKey) {
    switch (rangeKey) {
      case 'oneDay':
        return oneDay;
      case 'oneWeek':
        return oneWeek;
      case 'oneMonth':
        return oneMonth;
      case 'oneYear':
        return oneYear;
      default:
        return oneDay;
    }
  }

  /// Retrieve points by UI label ('1D', '1W', '1M', '1Y') using the mapping
  List<ChartPointModel> getPointsByLabel(String label) {
    final key = ChartRangeConstants.chartRangeMap[label] ?? 'oneDay';
    return getPointsByRangeKey(key);
  }
}

/// Represents stock performance metrics for a given period
class StockPeriodPerformance {
  final double open;
  final double close;
  final double high;
  final double low;
  final double changePercent;

  const StockPeriodPerformance({
    this.open = 0.0,
    this.close = 0.0,
    this.high = 0.0,
    this.low = 0.0,
    this.changePercent = 0.0,
  });

  factory StockPeriodPerformance.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StockPeriodPerformance();
    return StockPeriodPerformance(
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      close: (json['close'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Represents a market index or stock item with chart and performance data
class StockMarketItem {
  final String symbol;
  final String companyName;
  final String exchange;
  final String? domain;
  final String? logoUrl;
  final double currentPrice;
  final double changePercent;
  final Map<String, StockPeriodPerformance> performance;
  final StockChartDataModel chartData;

  const StockMarketItem({
    required this.symbol,
    required this.companyName,
    required this.exchange,
    this.domain,
    this.logoUrl,
    required this.currentPrice,
    required this.changePercent,
    required this.performance,
    required this.chartData,
  });

  factory StockMarketItem.fromJson(Map<String, dynamic> json) {
    final perfJson = json['performance'] as Map<String, dynamic>? ?? {};
    final perfMap = <String, StockPeriodPerformance>{};
    perfJson.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        perfMap[k] = StockPeriodPerformance.fromJson(v);
      }
    });

    return StockMarketItem(
      symbol: json['symbol']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      exchange: json['exchange']?.toString() ?? '',
      domain: json['domain']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
      performance: perfMap,
      chartData: StockChartDataModel.fromJson(
        json['chartData'] as Map<String, dynamic>?,
      ),
    );
  }

  /// Get performance for the given range label ('1D', '1W', etc.)
  StockPeriodPerformance? getPerformanceForLabel(String label) {
    final key = ChartRangeConstants.chartRangeMap[label] ?? 'oneDay';
    return performance[key];
  }
}
