import 'package:get/get.dart';

import '../view_models/controller/lead_controller.dart';
import '../view_models/controller/item_controller.dart';

class LeadBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ItemController>()) {
      Get.lazyPut<ItemController>(() => ItemController());
    }
    Get.lazyPut<LeadController>(() => LeadController());
  }
}
