import '../view_models/controller/util_controller.dart';
import '../view_models/controller/vendor_controller.dart';
import 'package:get/get.dart';

class VendorBinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(()=> VendorController());
  }
}