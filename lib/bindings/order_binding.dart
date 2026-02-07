import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/return_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
import 'package:get/get.dart';
import '../view_models/controller/billing_controller.dart';
import '../view_models/controller/item_controller.dart';
import '../view_models/controller/util_controller.dart';
import '../view_models/controller/vendor_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<UtilController>(() => UtilController());
    Get.lazyPut<ItemController>(() => ItemController());
    Get.lazyPut<VendorController>(() => VendorController());
    Get.lazyPut<ReturnController>(()=> ReturnController());
    Get.lazyPut<StockController>(()=> StockController() );
  }
}

// class OrderBinding extends Bindings{
//   @override
//   void dependencies (){
//     Get.put(BillingController(), permanent: true);
//     Get.put(OrderController(), permanent: true);
//     Get.lazyPut(()=> ItemController());
//     Get.lazyPut(()=> VendorController());
//   }
// }