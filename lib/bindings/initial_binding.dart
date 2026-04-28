import '../view_models/controller/auth/auth_controller.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    // Get.put(OrderController(),);
    // Get.put(UtilController());
  }
}