
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:market_view/core/utils/app_colors.dart';
import 'package:market_view/core/utils/app_images.dart';
import 'package:market_view/feature/homepage/presentation/home_screen.dart';
import 'package:market_view/feature/market_news/presentation/market_news.dart';
import 'package:market_view/feature/market_view/presentation/market_screen.dart';
import 'package:market_view/feature/profile/presentation/profile_screen.dart';
import 'package:market_view/feature/watchlist/presentation/my_watchlist_screen.dart';

import '../../../core/constant.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {


  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const MarketScreen(),
    const MyWatchlistScreen(),
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
                    ? outlineWatchListIcon
                    : watchListIcon,
              ),
              label: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                currentIndex.value != 3
                    ? outlineMarketNewsIcon
                    : marketNewsIcon,
              ),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                currentIndex.value != 4
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
