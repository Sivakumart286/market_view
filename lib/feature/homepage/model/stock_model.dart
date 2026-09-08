class MarketIndexResponse {
  Meta? meta;
  List<MarketIndex>? indices;

  MarketIndexResponse({this.meta, this.indices});

  MarketIndexResponse.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;

    if (json['indices'] != null) {
      indices = <MarketIndex>[];

      json['indices'].forEach((v) {
        indices!.add(MarketIndex.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (meta != null) {
      data['meta'] = meta!.toJson();
    }

    if (indices != null) {
      data['indices'] = indices!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Meta {
  String? description;
  String? currency;
  bool? isSampleData;
  String? note;
  String? lastUpdated;

  Meta({
    this.description,
    this.currency,
    this.isSampleData,
    this.note,
    this.lastUpdated,
  });

  Meta.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    currency = json['currency'];
    isSampleData = json['isSampleData'];
    note = json['note'];
    lastUpdated = json['lastUpdated'];
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'currency': currency,
      'isSampleData': isSampleData,
      'note': note,
      'lastUpdated': lastUpdated,
    };
  }
}

class MarketIndex {
  String? symbol;
  String? companyName;
  String? exchange;
  String? domain;
  String? logoUrl;
  String? logoUrlHighRes;
  double? currentPrice;
  double? changePercent;
  Performance? performance;
  ChartData? chartData;

  MarketIndex({
    this.symbol,
    this.companyName,
    this.exchange,
    this.domain,
    this.logoUrl,
    this.logoUrlHighRes,
    this.currentPrice,
    this.changePercent,
    this.performance,
    this.chartData,
  });

  MarketIndex.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol'];
    companyName = json['companyName'];
    exchange = json['exchange'];
    domain = json['domain'];
    logoUrl = json['logoUrl'];
    logoUrlHighRes = json['logoUrlHighRes'];

    currentPrice = json['currentPrice'] != null
        ? (json['currentPrice'] as num).toDouble()
        : null;

    changePercent = json['changePercent'] != null
        ? (json['changePercent'] as num).toDouble()
        : null;

    performance = json['performance'] != null
        ? Performance.fromJson(json['performance'])
        : null;

    chartData = json['chartData'] != null
        ? ChartData.fromJson(json['chartData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'companyName': companyName,
      'exchange': exchange,
      'domain': domain,
      'logoUrl': logoUrl,
      'logoUrlHighRes': logoUrlHighRes,
      'currentPrice': currentPrice,
      'changePercent': changePercent,
      'performance': performance?.toJson(),
      'chartData': chartData?.toJson(),
    };
  }
}

class Performance {
  PerformancePeriod? oneDay;
  PerformancePeriod? oneWeek;
  PerformancePeriod? oneMonth;
  PerformancePeriod? oneYear;

  Performance({this.oneDay, this.oneWeek, this.oneMonth, this.oneYear});

  Performance.fromJson(Map<String, dynamic> json) {
    oneDay = json['oneDay'] != null
        ? PerformancePeriod.fromJson(json['oneDay'])
        : null;

    oneWeek = json['oneWeek'] != null
        ? PerformancePeriod.fromJson(json['oneWeek'])
        : null;

    oneMonth = json['oneMonth'] != null
        ? PerformancePeriod.fromJson(json['oneMonth'])
        : null;

    oneYear = json['oneYear'] != null
        ? PerformancePeriod.fromJson(json['oneYear'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'oneDay': oneDay?.toJson(),
      'oneWeek': oneWeek?.toJson(),
      'oneMonth': oneMonth?.toJson(),
      'oneYear': oneYear?.toJson(),
    };
  }
}

class PerformancePeriod {
  double? open;
  double? close;
  double? high;
  double? low;
  double? changePercent;

  PerformancePeriod({
    this.open,
    this.close,
    this.high,
    this.low,
    this.changePercent,
  });

  PerformancePeriod.fromJson(Map<String, dynamic> json) {
    open = json['open'] != null ? (json['open'] as num).toDouble() : null;

    close = json['close'] != null ? (json['close'] as num).toDouble() : null;

    high = json['high'] != null ? (json['high'] as num).toDouble() : null;

    low = json['low'] != null ? (json['low'] as num).toDouble() : null;

    changePercent = json['changePercent'] != null
        ? (json['changePercent'] as num).toDouble()
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'close': close,
      'high': high,
      'low': low,
      'changePercent': changePercent,
    };
  }
}

class ChartData {
  List<ChartPoint>? oneDay;
  List<ChartPoint>? oneWeek;
  List<ChartPoint>? oneMonth;
  List<ChartPoint>? oneYear;

  ChartData({this.oneDay, this.oneWeek, this.oneMonth, this.oneYear});

  ChartData.fromJson(Map<String, dynamic> json) {
    if (json['oneDay'] != null) {
      oneDay = <ChartPoint>[];

      json['oneDay'].forEach((v) {
        oneDay!.add(ChartPoint.fromJson(v));
      });
    }

    if (json['oneWeek'] != null) {
      oneWeek = <ChartPoint>[];

      json['oneWeek'].forEach((v) {
        oneWeek!.add(ChartPoint.fromJson(v));
      });
    }

    if (json['oneMonth'] != null) {
      oneMonth = <ChartPoint>[];

      json['oneMonth'].forEach((v) {
        oneMonth!.add(ChartPoint.fromJson(v));
      });
    }

    if (json['oneYear'] != null) {
      oneYear = <ChartPoint>[];

      json['oneYear'].forEach((v) {
        oneYear!.add(ChartPoint.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'oneDay': oneDay?.map((v) => v.toJson()).toList(),
      'oneWeek': oneWeek?.map((v) => v.toJson()).toList(),
      'oneMonth': oneMonth?.map((v) => v.toJson()).toList(),
      'oneYear': oneYear?.map((v) => v.toJson()).toList(),
    };
  }
}

class ChartPoint {
  String? t;
  double? price;

  ChartPoint({this.t, this.price});

  ChartPoint.fromJson(Map<String, dynamic> json) {
    t = json['t'];

    price = json['price'] != null ? (json['price'] as num).toDouble() : null;
  }

  Map<String, dynamic> toJson() {
    return {'t': t, 'price': price};
  }
}
