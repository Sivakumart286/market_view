
import 'package:flutter/material.dart';

class CustomScaffold extends StatefulWidget {
  final Widget body;
   const CustomScaffold({super.key,required this.body});

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext? scaffoldContext;
  Map<String, dynamic> returnMap = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Builder(builder: (BuildContext ctx){
          return widget.body;
        }),
      ),
    );
  }
}
