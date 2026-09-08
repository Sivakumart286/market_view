import 'package:flutter/material.dart';
import 'package:market_view/core/constant.dart';

class MyWatchlistScreen extends StatefulWidget {
  const MyWatchlistScreen({super.key});

  @override
  State<MyWatchlistScreen> createState() => _MyWatchlistScreenState();
}

class _MyWatchlistScreenState extends State<MyWatchlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: deviceHeight,
      width: deviceWidth,
      color: Colors.red,
    );
  }
}
