import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/purchase_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:get/get.dart';
import '../view_models/controller/billing_controller.dart';
import '../view_models/controller/dashboard_controller.dart';
import '../view_models/controller/home_controller.dart';
import '../view_models/controller/order_controller.dart';
import '../view_models/controller/util_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.put(BillingController(), );
    Get.put<UtilController>(UtilController(), permanent: true);
    Get.put(OrderController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => VendorController());
    Get.lazyPut(() => ItemController());
    Get.lazyPut(() => StockController());
    Get.lazyPut(() => PurchaseController());
  }
}
