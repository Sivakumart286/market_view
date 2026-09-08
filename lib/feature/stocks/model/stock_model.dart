import 'chart_data_model.dart';

/// Stock model strictly containing required fields:
/// - symbol
/// - companyName
/// - stockPrice
/// - currentChange
/// - image
/// plus chartData for the chart screen navigation.
class StockModel {
  final String symbol;
  final String companyName;
  final double stockPrice;
  final double currentChange;
  final String image;
  final StockChartData? chartData;

  const StockModel({
    required this.symbol,
    required this.companyName,
    required this.stockPrice,
    required this.currentChange,
    required this.image,
    this.chartData,
  });

  /// Factory constructor to parse stock items from indian_stocks_professional.json
  factory StockModel.fromJson(Map<String, dynamic> json) {
    // 1. Symbol
    final symbol = json['symbol']?.toString() ?? '';

    // 2. Company Name
    final companyName = json['companyName']?.toString() ?? symbol;

    // 3. Stock Price (from 'currentPrice' or 'stockPrice' or 'price')
    double price = 0.0;
    final rawPrice = json['currentPrice'] ?? json['stockPrice'] ?? json['price'];
    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else if (rawPrice is String) {
      price = double.tryParse(rawPrice.replaceAll(',', '')) ?? 0.0;
    }

    // 4. Current Change (from 'changePercent' or 'currentChange')
    double change = 0.0;
    final rawChange = json['changePercent'] ?? json['currentChange'];
    if (rawChange is num) {
      change = rawChange.toDouble();
    } else if (rawChange is String) {
      // Clean string from '+' or '%' signs e.g. "+1.25" -> 1.25, "-0.30" -> -0.30
      final cleaned = rawChange.replaceAll('+', '').replaceAll('%', '').trim();
      change = double.tryParse(cleaned) ?? 0.0;
    }

    // 5. Image (from 'logoUrl' or 'logoUrlHighRes' or 'image')
    String img = json['logoUrl']?.toString() ??
        json['logoUrlHighRes']?.toString() ??
        json['image']?.toString() ??
        '';

    // 6. Chart Data
    StockChartData? chart;
    if (json['chartData'] is Map<String, dynamic>) {
      chart = StockChartData.fromJson(json['chartData'] as Map<String, dynamic>);
    }

    return StockModel(
      symbol: symbol,
      companyName: companyName,
      stockPrice: price,
      currentChange: change,
      image: img,
      chartData: chart,
    );
  }

  /// Factory constructor to adapt MarketIndex (e.g. NIFTY 50, SENSEX) to StockModel
  factory StockModel.fromMarketIndex(dynamic index) {
    final symbol = index.symbol?.toString() ?? '';
    final company = index.companyName?.toString() ?? symbol;
    final price = (index.currentPrice as num?)?.toDouble() ?? 0.0;
    final change = (index.changePercent as num?)?.toDouble() ?? 0.0;
    final logo = index.logoUrl?.toString() ?? '';

    List<ChartDataPoint> mapPoints(dynamic pointsList) {
      if (pointsList == null || pointsList is! List) return const [];
      return pointsList.map<ChartDataPoint>((p) {
        final t = p.t?.toString() ?? '';
        final ptPrice = (p.price as num?)?.toDouble() ?? 0.0;
        return ChartDataPoint(
          time: DateTime.tryParse(t) ?? DateTime.now(),
          price: ptPrice,
          rawTime: t,
        );
      }).toList();
    }

    StockChartData? chart;
    if (index.chartData != null) {
      chart = StockChartData(
        oneDay: mapPoints(index.chartData.oneDay),
        oneWeek: mapPoints(index.chartData.oneWeek),
        oneMonth: mapPoints(index.chartData.oneMonth),
        oneYear: mapPoints(index.chartData.oneYear),
      );
    }

    return StockModel(
      symbol: symbol,
      companyName: company,
      stockPrice: price,
      currentChange: change,
      image: logo,
      chartData: chart,
    );
  }

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'companyName': companyName,
    'currentPrice': stockPrice,
    'changePercent': currentChange,
    'logoUrl': image,
    'chartData': chartData?.toJson(),
  };

  /// Helper getter to determine positive/neutral vs negative
  bool get isPositive => currentChange >= 0;

  @override
  String toString() =>
      'StockModel(symbol: $symbol, price: $stockPrice, change: $currentChange%)';
}
