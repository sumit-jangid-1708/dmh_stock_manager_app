import 'package:dmj_stock_manager/model/return_order_history_model.dart';
import 'package:dmj_stock_manager/view/orders/return_order_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../view/stock/stock_screen.dart';

class StockButtonRow extends StatelessWidget {
  final DashboardController dashboardController = Get.find<DashboardController>();
  StockButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          stockButton("View Inventory", (){
            Get.to(StockScreen());
          }),
          stockButton("Sales History", (){
            dashboardController.changeTab(3);
          }),
          stockButton("Purchase History", (){
            dashboardController.changeTab(1);
          }),
          stockButton("Return Order", (){
            Get.to(ReturnOrderHistoryScreen());
          }),
        ],
      ),
    );
  }
}

Widget stockButton(String text, VoidCallback onPressed){
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 6),
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
          side: const BorderSide(color: Colors.grey),
      ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: Colors.black),)),
  );
}