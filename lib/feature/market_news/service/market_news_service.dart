import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/market_news_model.dart';

/// Service responsible for fetching live market news from NewsData.io API using http package.
class MarketNewsService {
  static const String apiKey = 'pub_6bc5182df7644544833aefbe5b1eca2e';
  static const String baseUrl = 'https://newsdata.io/api/1/latest';
  static const String defaultQuery = 'stock market';

  static Uri buildNewsUri({String query = defaultQuery}) {
    return Uri.parse('$baseUrl?apikey=$apiKey&q=${Uri.encodeComponent(query)}');
  }

  /// Fetches market news articles with thorough HTTP status code and network exception handling.
  Future<MarketNewsResponse> fetchMarketNews({
    String query = defaultQuery,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    final uri = buildNewsUri(query: query);

    try {
      final response = await httpClient
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return MarketNewsResponse.fromJson(decoded);
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 400) {
        throw Exception('Bad request to news service');
      } else if (response.statusCode == 401) {
        throw Exception('api_auth_failed'.tr);
      } else if (response.statusCode == 429) {
        throw Exception('api_rate_limit_exceeded'.tr);
      } else if (response.statusCode >= 500) {
        throw Exception('something_went_wrong'.tr);
      } else {
        throw Exception('Failed to load news (HTTP ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('no_internet_connection'.tr);
    } on TimeoutException {
      throw Exception('something_went_wrong'.tr);
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      // If already has user-friendly translated text, preserve it
      final errStr = e.toString().replaceFirst('Exception: ', '');
      throw Exception(errStr);
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}
