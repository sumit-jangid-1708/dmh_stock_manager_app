import 'package:dmj_stock_manager/view_models/controller/purchase_controller.dart';
import 'package:get/get.dart';


class PurchaseBinding extends Bindings{
  @override
  void dependencies(){
    Get.put(PurchaseController(), permanent: true);
  }
}