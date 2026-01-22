import 'package:get/get.dart';

import '../view_models/controller/order_controller.dart';
import '../view_models/controller/util_controller.dart';

class UtilBinding extends Bindings{
  @override
  void dependencies(){
    // Get.put(UtilController(), permanent: true);
    Get.lazyPut(()=> OrderController());
  }
}