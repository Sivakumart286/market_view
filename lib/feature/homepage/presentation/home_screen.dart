import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/constant.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_font_size.dart';
import 'package:market_view/core/widget/custom_text.dart';
import 'package:market_view/feature/homepage/controller/home_controller.dart';
import 'package:market_view/feature/homepage/model/stock_model.dart';
import 'package:market_view/feature/stocks/controller/stock_controller.dart';
import 'package:market_view/feature/stocks/model/chart_data_model.dart';
import 'package:market_view/feature/stocks/model/stock_model.dart';
import 'package:market_view/feature/stocks/view/stock_chart_screen.dart';
import 'package:market_view/feature/stocks/widget/stock_card.dart';
import 'package:market_view/feature/stocks/widget/stock_chart.dart';
import '../widget/zero_brokerage_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.find();
  final StockController stockController = Get.put(StockController());

  @override
  void initState() {
    controller.isLoading.value = true;
    controller.getMarketIndexData();
    controller.getUserData().then((value) {
      controller.userModel.value = value;
    });
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2)).then((value) {
        controller.isLoading.value = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBGColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          final userModel = controller.userModel.value;
          return ListView(
            children: [
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryColor,
                    ),
                    alignment: Alignment.center,
                    child: CustomText(
                      text: userModel?.name.isNotEmpty == true
                          ? userModel!.name[0].toUpperCase()
                          : '',
                      fontSize: 30,
                      fontWeight: AppFontWidth.bold,
                      textColor: AppColors.staticWhite,
                      align: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'label_hi'.tr,
                              style: TextStyle(
                                fontSize: AppFontSize.sectionTitle,
                                fontWeight: AppFontWidth.bold,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                            const TextSpan(
                              text: ' 👋',
                              style: TextStyle(
                                fontSize: AppFontSize.sectionTitle,
                                fontWeight: AppFontWidth.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomText(
                        text: userModel?.name ?? '',
                        fontSize: AppFontSize.bodyText,
                        fontWeight: AppFontWidth.medium,
                        textColor: AppColors.primaryTextColor,
                      ),
                    ],
                  ),
                ],
              ),
              ZeroBrokerageBanner(
                onTap: () {
                  currentIndex.value = 1;
                },
              ),
              topStock(),
              const SizedBox(height: 16),
              Obx(() {
                final stocks = stockController.homeStocks;
                if (stockController.isLoading.value && stocks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSeeAllSection(),
                    const SizedBox(height: 6),
                    ...stocks.map((stock) => StockCard(stock: stock)),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSeeAllSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'label_stocks'.tr,
            style: TextStyle(
              fontFamily: AppFontFamily.fontFamily,
              fontSize: AppFontSize.sectionTitle,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryTextColor,
            ),
          ),
          GestureDetector(
            onTap: () {
              stockController.navigateToAllStocks();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'label_see_all'.tr,
                    style: TextStyle(
                      fontFamily: AppFontFamily.fontFamily,
                      fontSize: AppFontSize.caption + 1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 11,
                    color: AppColors.secondaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget topStock() {
    return Obx(() {
      final stocks = controller.indexList;
      if (stocks.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 10),
            child: Text(
              'label_market_indices'.tr,
              style: TextStyle(
                fontFamily: AppFontFamily.fontFamily,
                fontSize: AppFontSize.sectionTitle,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTextColor,
              ),
            ),
          ),
          SizedBox(
            height: 190,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: stocks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => stockCard(stocks[index]),
            ),
          ),
        ],
      );
    });
  }

  Widget stockCard(MarketIndex model) {
    final List<ChartDataPoint> oneYearPoints =
        (model.chartData?.oneYear ?? []).map((p) {
      final t = p.t ?? '';
      return ChartDataPoint(
        time: DateTime.tryParse(t) ?? DateTime.now(),
        price: p.price ?? 0.0,
        rawTime: t,
      );
    }).toList();

    final bool isPositive = (model.changePercent ?? 0.0) >= 0;
    final Color changeColor =
        isPositive ? AppColors.positiveColor : AppColors.negativeColor;
    final cardWidth = ((Get.width - 52) / 2).clamp(160.0, 220.0);

    return GestureDetector(
      onTap: () {
        final stockModel = StockModel.fromMarketIndex(model);
        stockController.setSelectedStock(stockModel);
        Get.to(
          () => const StockChartScreen(),
          arguments: stockModel,
        );
      },
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.staticWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.cardBorderColor,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.lightShadow,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top title and arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    model.symbol ?? '',
                    style: TextStyle(
                      fontFamily: AppFontFamily.fontFamily,
                      fontSize: AppFontSize.cardTitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: changeColor,
                  size: 32,
                ),
              ],
            ),

            const SizedBox(height: 4),

            /// Index value
            Text(
              StockController.formatStockPrice(model.currentPrice ?? 0.0),
              style: TextStyle(
                fontFamily: AppFontFamily.fontFamily,
                fontSize: AppFontSize.bodyText,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTextColor,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 6),

            /// Profit / Percentage
            Text(
              '${model.exchange ?? ''} (${isPositive ? '+' : ''}${model.changePercent?.toStringAsFixed(2) ?? '0.00'}%)',
              style: TextStyle(
                fontFamily: AppFontFamily.fontFamily,
                fontSize: AppFontSize.caption - 0.5,
                fontWeight: FontWeight.w700,
                color: changeColor,
              ),
            ),

            const Spacer(),

            /// 1-Year Mini Graph
            SizedBox(
              height: 48,
              width: double.infinity,
              child: StockChart(
                points: oneYearPoints,
                range: '1Y',
                isMiniChart: true,
                height: 48,
                isPositive: isPositive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
