import 'package:get/get.dart';

/// Top-level response model for NewsData.io Market News API.
class MarketNewsResponse {
  final String? status;
  final int? totalResults;
  final List<NewsArticle> results;
  final String? nextPage;

  const MarketNewsResponse({
    this.status,
    this.totalResults,
    this.results = const [],
    this.nextPage,
  });

  factory MarketNewsResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    List<NewsArticle> articles = [];

    if (rawResults is List) {
      articles = rawResults
          .whereType<Map<String, dynamic>>()
          .map((item) => NewsArticle.fromJson(item))
          .toList();
    }

    return MarketNewsResponse(
      status: json['status']?.toString(),
      totalResults: json['totalResults'] is num
          ? (json['totalResults'] as num).toInt()
          : int.tryParse(json['totalResults']?.toString() ?? ''),
      results: articles,
      nextPage: json['nextPage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'totalResults': totalResults,
    'results': results.map((a) => a.toJson()).toList(),
    'nextPage': nextPage,
  };
}

/// Model representing an individual news article safely handling null or missing values.
class NewsArticle {
  final String? articleId;
  final String? title;
  final String? description;
  final String? content;
  final String? pubDate;
  final String? imageUrl;
  final String? sourceName;
  final String? sourceIcon;
  final String? link;

  const NewsArticle({
    this.articleId,
    this.title,
    this.description,
    this.content,
    this.pubDate,
    this.imageUrl,
    this.sourceName,
    this.sourceIcon,
    this.link,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      articleId: json['article_id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      content: json['content']?.toString(),
      pubDate: json['pubDate']?.toString(),
      imageUrl: json['image_url']?.toString(),
      sourceName: json['source_name']?.toString(),
      sourceIcon: json['source_icon']?.toString(),
      link: json['link']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'article_id': articleId,
    'title': title,
    'description': description,
    'content': content,
    'pubDate': pubDate,
    'image_url': imageUrl,
    'source_name': sourceName,
    'source_icon': sourceIcon,
    'link': link,
  };

  /// Safe display title with fallback
  String get displayTitle =>
      (title != null && title!.trim().isNotEmpty) ? title!.trim() : 'Market Update';

  /// Safe display description that filters out dummy content and handles empty values
  String get displayDescription {
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    if (content != null &&
        content!.trim().isNotEmpty &&
        !content!.toUpperCase().contains('ONLY AVAILABLE IN PAID PLANS')) {
      return content!.trim();
    }
    return 'news_description_unavailable'.tr;
  }

  /// Whether the article has a valid network image url
  bool get hasValidImage =>
      imageUrl != null && imageUrl!.trim().isNotEmpty && imageUrl!.startsWith('http');

  /// Formatted date or time display
  String get formattedDate {
    if (pubDate == null || pubDate!.trim().isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(pubDate!);
      if (parsed == null) return pubDate!;
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[parsed.month - 1];
      final hour = parsed.hour.toString().padLeft(2, '0');
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '${parsed.day} $month ${parsed.year} • $hour:$minute';
    } catch (_) {
      return pubDate!;
    }
  }
}
