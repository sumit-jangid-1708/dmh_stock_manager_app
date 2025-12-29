import '../view_models/controller/purchase_controller.dart';
import 'package:get/get.dart';

import '../view_models/controller/util_controller.dart';

class BillingBinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(()=> PurchaseController());
    Get.lazyPut(()=> UtilController());
  }
}