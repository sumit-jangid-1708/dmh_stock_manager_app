import 'package:dmj_stock_manager/view_models/controller/billing_controller.dart';

import '../view_models/controller/purchase_controller.dart';
import 'package:get/get.dart';

import '../view_models/controller/util_controller.dart';

class BillingBinding extends Bindings{
  @override
  void dependencies(){
    Get.put(()=> BillingController());
    Get.lazyPut(()=> PurchaseController());

  }
}