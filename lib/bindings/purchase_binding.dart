import 'package:dmj_stock_manager/view_models/controller/purchase_controller.dart';
import 'package:get/get.dart';

import '../view_models/controller/util_controller.dart';

class PurchaseBinding extends Bindings{
  @override
  void dependencies(){
    Get.put(PurchaseController(), permanent: true);
  }
}