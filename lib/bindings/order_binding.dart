import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:get/get.dart';

import '../view_models/controller/item_controller.dart';
import '../view_models/controller/vendor_controller.dart';
class OrderBinding extends Bindings{
  @override
  void dependencies (){
    Get.lazyPut(()=> OrderController());
    Get.lazyPut(()=> ItemController());
    Get.lazyPut(()=> VendorController());
  }
}