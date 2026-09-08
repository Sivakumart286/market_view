import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_size.dart';
import '../model/market_news_model.dart';

/// Professional market news detail screen featuring an expanding/collapsible
/// SliverAppBar image header and dynamically expanding reading container.
class MarketNewsDetailScreen extends StatelessWidget {
  final NewsArticle? article;

  const MarketNewsDetailScreen({
    super.key,
    this.article,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve article from widget or Get.arguments
    final resolvedArticle = article ??
        (Get.arguments is NewsArticle
            ? Get.arguments as NewsArticle
            : const NewsArticle(
                title: 'Market News',
                description: '',
              ));

    return Scaffold(
      backgroundColor: AppColors.newsBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          /// Collapsible SliverAppBar with news image background
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.newsTitleColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppColors.staticBlack.withValues(alpha: 0.45),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.staticWhite,
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  resolvedArticle.hasValidImage
                      ? Image.network(
                          resolvedArticle.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.newsPlaceholderColor,
                              child: const Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderHeader(resolvedArticle);
                          },
                        )
                      : _buildPlaceholderHeader(resolvedArticle),

                  /// Dark overlay gradient for top and bottom transitions
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.staticBlack.withValues(alpha: 0.45),
                            Colors.transparent,
                            AppColors.staticBlack.withValues(alpha: 0.55),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Dynamically sizing reading container in SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.newsCardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Source name & publication date pill badge
                  if (resolvedArticle.sourceName != null &&
                      resolvedArticle.sourceName!.trim().isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.newsBadgeBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            resolvedArticle.sourceName!,
                            style: TextStyle(
                              fontFamily: AppFontFamily.fontFamily,
                              fontSize: AppFontSize.caption,
                              fontWeight: FontWeight.w700,
                              color: AppColors.newsBadgeTextColor,
                            ),
                          ),
                        ),
                        if (resolvedArticle.formattedDate.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              resolvedArticle.formattedDate,
                              style: TextStyle(
                                fontFamily: AppFontFamily.fontFamily,
                                fontSize: AppFontSize.caption - 1,
                                fontWeight: FontWeight.w500,
                                color: AppColors.newsTimeColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  /// News Title
                  Text(
                    resolvedArticle.displayTitle,
                    style: TextStyle(
                      fontFamily: AppFontFamily.fontFamily,
                      fontSize: AppFontSize.sectionTitle + 2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.newsTitleColor,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Elegant divider
                  Divider(
                    color: AppColors.cardBorderColor,
                    height: 1,
                  ),

                  const SizedBox(height: 18),

                  /// News Full Description
                  Text(
                    resolvedArticle.displayDescription,
                    style: TextStyle(
                      fontFamily: AppFontFamily.fontFamily,
                      fontSize: AppFontSize.bodyText,
                      fontWeight: FontWeight.w400,
                      color: AppColors.newsDescriptionColor,
                      height: 1.68,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderHeader(NewsArticle article) {
    return Container(
      color: AppColors.newsPlaceholderColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper_rounded,
              size: 56,
              color: AppColors.hintColor,
            ),
            const SizedBox(height: 8),
            Text(
              article.sourceName ?? 'Market News',
              style: TextStyle(
                fontFamily: AppFontFamily.fontFamily,
                fontSize: AppFontSize.bodyText,
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
