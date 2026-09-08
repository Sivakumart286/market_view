import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_size.dart';
import '../controller/stock_controller.dart';
import '../widget/stock_card.dart';

class AllStocksScreen extends StatefulWidget {
  final bool? isFrom;
  const AllStocksScreen({super.key,this.isFrom});

  @override
  State<AllStocksScreen> createState() => _AllStocksScreenState();
}

class _AllStocksScreenState extends State<AllStocksScreen> {
  late final StockController controller;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(StockController());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBGColor,
      appBar: _buildAppBar(widget.isFrom),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.stockList.isEmpty) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty &&
                    controller.stockList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            fontFamily: AppFontFamily.fontFamily,
                            color: AppColors.secondaryTextColor,
                            fontSize: AppFontSize.bodyText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => controller.loadStocksFromJson(),
                          child: Text('retry'.tr),
                        ),
                      ],
                    ),
                  );
                }

                final stocks = controller.filteredStocks;

                if (stocks.isEmpty) {
                  return Center(
                    child: Text(
                      'no_stocks_found'.tr,
                      style: TextStyle(
                        fontFamily: AppFontFamily.fontFamily,
                        color: AppColors.hintColor,
                        fontSize: AppFontSize.bodyText,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadStocksFromJson(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: stocks.length,
                    itemBuilder: (context, index) {
                      final stock = stocks[index];
                      // Use the exact same reusable StockCard widget
                      return StockCard(stock: stock);
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

  PreferredSizeWidget _buildAppBar(bool? isFrom) {
    return AppBar(
      backgroundColor: AppColors.staticWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: isFrom != null && isFrom == true,
      title: Row(
        children: [
          Text(
            'label_all_stocks'.tr,
            style: TextStyle(
              fontFamily: AppFontFamily.fontFamily,
              fontSize: AppFontSize.mainHeading - 2,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final count = controller.stockList.length;
            if (count == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.containerBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: AppFontFamily.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryTextColor,
                ),
              ),
            );
          }),
        ],
      ),
      centerTitle: false,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.staticWhite,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
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
                controller: searchController,
                onChanged: (val) {
                  controller.searchQuery.value = val;
                },
                decoration: InputDecoration(
                  hintText: 'search_hint'.tr,
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
                  onTap: () {
                    searchController.clear();
                    controller.searchQuery.value = '';
                  },
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
