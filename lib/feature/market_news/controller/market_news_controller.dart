import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/market_news_model.dart';
import '../service/market_news_service.dart';

/// GetX controller managing market news API state, search filtering, and user interactions.
class MarketNewsController extends GetxController {
  final MarketNewsService service;

  MarketNewsController({MarketNewsService? service})
      : service = service ?? MarketNewsService();

  /// Reactive state variables
  final RxList<NewsArticle> newsList = <NewsArticle>[].obs;
  final RxList<NewsArticle> filteredNewsList = <NewsArticle>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchMarketNews();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Fetches market news articles from API using MarketNewsService
  Future<void> fetchMarketNews() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await service.fetchMarketNews();
      newsList.assignAll(response.results);

      // Re-apply search filter if user already typed something, else show all
      if (searchQuery.value.trim().isEmpty) {
        filteredNewsList.assignAll(response.results);
      } else {
        filterNews(searchQuery.value);
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg;
    } finally {
      isLoading.value = false;
    }
  }

  /// Handles real-time search query changes dynamically without mutating original newsList
  void onSearchChanged(String query) {
    searchQuery.value = query;
    isSearching.value = query.trim().isNotEmpty;
    filterNews(query);
  }

  /// Filters news locally based on title, description, and source_name (case-insensitive)
  void filterNews(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      filteredNewsList.assignAll(newsList);
      return;
    }

    final matched = newsList.where((article) {
      final title = (article.title ?? '').toLowerCase();
      final desc = (article.description ?? '').toLowerCase();
      final source = (article.sourceName ?? '').toLowerCase();

      return title.contains(trimmed) ||
          desc.contains(trimmed) ||
          source.contains(trimmed);
    }).toList();

    filteredNewsList.assignAll(matched);
  }

  /// Clears active search and resets list
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    isSearching.value = false;
    filteredNewsList.assignAll(newsList);
  }
}
