import 'package:get/get_instance/src/bindings_interface.dart';
import '../view_models/controller/auth/auth_controller.dart';
import 'package:get/get.dart';

import '../view_models/controller/billing_controller.dart';
import '../view_models/controller/purchase_controller.dart';
import '../view_models/controller/util_controller.dart';

class InitialBinding extends Bindings{
  @override
  void dependencies(){
    Get.put(AuthController(), permanent: true);
    Get.put(UtilController(), permanent: true);
    // Get.put(PurchaseController(),permanent: true);
    // Get.put(BillingController(), permanent: true);
  }
}