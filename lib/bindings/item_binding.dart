import 'package:get/get.dart';

import '../view_models/controller/item_controller.dart';

class ItemBinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(()=> ItemController());
  }
}