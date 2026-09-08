import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_size.dart';
import '../controller/market_news_controller.dart';
import '../widget/market_news_card.dart';

/// Professional market news screen featuring real-time search, news card list,
/// pull-to-refresh, dynamic loading, empty, and error states.
class MarketNewsScreen extends StatefulWidget {
  const MarketNewsScreen({super.key});

  @override
  State<MarketNewsScreen> createState() => _MarketNewsScreenState();
}

class _MarketNewsScreenState extends State<MarketNewsScreen> {
  late final MarketNewsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MarketNewsController>()
        ? Get.find<MarketNewsController>()
        : Get.put(MarketNewsController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newsBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'market_news'.tr,
                style: TextStyle(
                  fontFamily: AppFontFamily.fontFamily,
                  fontSize: AppFontSize.mainHeading,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryTextColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),

            _buildSearchBar(),

            Expanded(
              child: Obx(() {
                // 1. Loading state on initial fetch
                if (controller.isLoading.value && controller.newsList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CupertinoActivityIndicator(radius: 14),
                        const SizedBox(height: 12),
                        Text(
                          'loading_news'.tr,
                          style: TextStyle(
                            fontFamily: AppFontFamily.fontFamily,
                            fontSize: AppFontSize.caption + 1,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // 2. Error state
                if (controller.errorMessage.value.isNotEmpty &&
                    controller.newsList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 48,
                            color: AppColors.hintColor,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            controller.errorMessage.value.isNotEmpty
                                ? controller.errorMessage.value
                                : 'something_went_wrong'.tr,
                            style: TextStyle(
                              fontFamily: AppFontFamily.fontFamily,
                              fontSize: AppFontSize.bodyText,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.fetchMarketNews(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.primaryButtonTextColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'try_again'.tr,
                              style: const TextStyle(
                                fontFamily: AppFontFamily.fontFamily,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final news = controller.filteredNewsList;

                // 3. Empty Search / No News Found state
                if (news.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.hintColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'no_news_found'.tr,
                            style: TextStyle(
                              fontFamily: AppFontFamily.fontFamily,
                              fontSize: AppFontSize.sectionTitle,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'try_another_keyword'.tr,
                            style: TextStyle(
                              fontFamily: AppFontFamily.fontFamily,
                              fontSize: AppFontSize.caption + 0.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 4. Live News List with pull-to-refresh
                return RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: () => controller.fetchMarketNews(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: news.length,
                    itemBuilder: (context, index) {
                      return MarketNewsCard(article: news[index]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the search bar input with real-time reactive filtering
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.newsBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.newsSearchBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorderColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 20,
              color: AppColors.hintColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                style: TextStyle(
                  fontFamily: AppFontFamily.fontFamily,
                  fontSize: AppFontSize.bodyText,
                  color: AppColors.primaryTextColor,
                ),
                decoration: InputDecoration(
                  hintText: 'search_market_news'.tr,
                  hintStyle: TextStyle(
                    fontFamily: AppFontFamily.fontFamily,
                    fontSize: AppFontSize.bodyText - 1,
                    color: AppColors.hintColor,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Obx(() {
              if (controller.searchQuery.value.isNotEmpty) {
                return GestureDetector(
                  onTap: () => controller.clearSearch(),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.hintColor,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
