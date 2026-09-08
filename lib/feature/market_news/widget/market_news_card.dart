import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_size.dart';
import '../model/market_news_model.dart';
import '../presentation/market_news_detail_screen.dart';

/// Professional card widget for displaying a single market news article in the list.
/// Shows strictly the News Image and News Title, with graceful image loading and error fallbacks.
class MarketNewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback? onTap;

  const MarketNewsCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.newsCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorderColor,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ??
              () {
                Get.to(
                  () => MarketNewsDetailScreen(article: article),
                  arguments: article,
                );
              },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// News Image Header
              _buildImageHeader(),

              /// News Title & Metadata
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.displayTitle,
                      style: TextStyle(
                        fontFamily: AppFontFamily.fontFamily,
                        fontSize: AppFontSize.cardTitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.newsTitleColor,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (article.sourceName != null &&
                        article.sourceName!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 13,
                            color: AppColors.newsTimeColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${article.sourceName}${article.formattedDate.isNotEmpty ? ' • ${article.formattedDate}' : ''}',
                              style: TextStyle(
                                fontFamily: AppFontFamily.fontFamily,
                                fontSize: AppFontSize.caption - 1,
                                fontWeight: FontWeight.w600,
                                color: AppColors.newsTimeColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top news image with loading, error, and placeholder states
  Widget _buildImageHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 185,
        width: double.infinity,
        child: article.hasValidImage
            ? Image.network(
                article.imageUrl!,
                height: 185,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 185,
                    width: double.infinity,
                    color: AppColors.newsPlaceholderColor,
                    child: const Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  /// Fallback placeholder when image is null, invalid, or fails to load
  Widget _buildPlaceholderImage() {
    return Container(
      height: 185,
      width: double.infinity,
      color: AppColors.newsPlaceholderColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper_rounded,
              size: 44,
              color: AppColors.hintColor,
            ),
            const SizedBox(height: 8),
            Text(
              article.sourceName ?? 'Market News',
              style: TextStyle(
                fontFamily: AppFontFamily.fontFamily,
                fontSize: AppFontSize.caption,
                fontWeight: FontWeight.w600,
                color: AppColors.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
