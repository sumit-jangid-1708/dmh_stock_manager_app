import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PurchaseController extends GetxController{
  RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;


  final List<String> product = [
    "product A",
    "product B",
    "product C",
  ];

  void addItemRow(){
    items.add({
      "product" : "".obs,
      "quantity": TextEditingController(),
      "unit": TextEditingController(),
    });
  }

  void removeItemRow(int index){
    items.removeAt(index);
  }

  void clearAll(){
    items.clear();
  }

  @override
  void onClose(){
    for (var item in items){
      (item["quantity"] as TextEditingController).dispose();
      (item["unit"] as TextEditingController).dispose();
    }
    super.onClose();
  }
}