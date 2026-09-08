
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../authentication/model/create_user_model.dart';
import '../model/stock_model.dart';

class HomeController extends GetxController{

  RxBool isLoading = false.obs;
  final Rxn<UserModel> userModel = Rxn<UserModel>();

  RxList<MarketIndex> indexList = <MarketIndex>[].obs;

  Future<UserModel?> getUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      final String uid = user.uid;

      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!snapshot.exists) {
        debugPrint('User data not found');
        return null;
      }

      final data = snapshot.data();

      if (data == null || data['profile'] == null) {
        debugPrint('Profile data not found');
        return null;
      }

      final Map<String, dynamic> profile =
      Map<String, dynamic>.from(data['profile']);

      final UserModel userModel = UserModel.fromJson(profile);

      debugPrint('Name: ${userModel.name}');
      debugPrint('Phone: ${userModel.phone}');
      debugPrint('Email: ${userModel.email}');
      debugPrint('UID: ${userModel.uid}');
      return userModel;
    } on FirebaseException catch (e) {
      debugPrint('Firestore Error: ${e.code}');
      debugPrint('Firestore Message: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }


  Future<void> getMarketIndexData() async {
    try {
      final String response = await rootBundle.loadString(
        'data/nifty_sensex.json',
      );

      final Map<String, dynamic> jsonData =
      jsonDecode(response);

      final MarketIndexResponse marketResponse =
      MarketIndexResponse.fromJson(jsonData);

      indexList.assignAll(
        marketResponse.indices ?? [],
      );

      debugPrint(
        'Market Index Count: ${indexList.length}',
      );
    } catch (e) {
      debugPrint(
        'Error loading market data: $e',
      );
    }
  }
}