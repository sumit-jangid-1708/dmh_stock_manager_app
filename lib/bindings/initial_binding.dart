import 'package:get/get_instance/src/bindings_interface.dart';
import '../view_models/controller/auth/auth_controller.dart';
import 'package:get/get.dart';

import '../view_models/controller/billing_controller.dart';
import '../view_models/controller/order_controller.dart';
import '../view_models/controller/purchase_controller.dart';
import '../view_models/controller/util_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Put AuthController first (standard practice)
    Get.put(AuthController(), permanent: true);
    // 2. Put OrderController BEFORE UtilController
    // Note: Use OrderController() directly, NOT a lambda function () => ...
    Get.put(OrderController(), permanent: true);
    // 3. Now put UtilController (It will now find OrderController successfully)
    Get.put(UtilController(), permanent: true);
    // Other controllers...
    // Get.put(PurchaseController(), permanent: true);
    // Get.put(BillingController(), permanent: true);
  }
}