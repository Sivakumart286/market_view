
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_images.dart';
import 'package:market_view/feature/homepage/presentation/home_screen.dart';
import 'package:market_view/feature/market_news/presentation/market_news.dart';
import 'package:market_view/feature/profile/presentation/profile_screen.dart';

import 'package:market_view/feature/stocks/view/all_stocks_screen.dart';

import '../../../core/constant.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {


  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const AllStocksScreen(),
    const MarketNewsScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppColors.screenBGColor,
      body: Obx(() =>
          Container(
            color: AppColors.screenBGColor,
            child: _widgetOptions.elementAt(currentIndex.value),
          ),
      ),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex: currentIndex.value,

          onTap: (index) {
            currentIndex.value = index;
          },
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: Colors.grey,

          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                currentIndex.value != 0 ? outlineHomeIcon : homeIcon,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                currentIndex.value != 1
                    ? outlineMarketListIcon
                    : marketListIcon,
              ),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                currentIndex.value != 2
                    ? outlineMarketNewsIcon
                    : marketNewsIcon,
              ),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                currentIndex.value != 3
                    ? outlineProfileIcon
                    : profileIcon,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
