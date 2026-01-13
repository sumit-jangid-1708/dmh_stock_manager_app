import 'package:get/get.dart';

import '../view_models/controller/item_controller.dart';
import '../view_models/controller/order_controller.dart';
import '../view_models/controller/util_controller.dart';

class ItemBinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(()=> ItemController());
    Get.lazyPut(()=> OrderController());
  }
}