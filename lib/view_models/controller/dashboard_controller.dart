import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController{
 final VendorController vendorController = Get.find();

  var currentIndex = 0.obs;
  // RxBool isLogin = false.obs;
// form state
  final selectedVendorName = "".obs;
  final selectedVendorId = "".obs;

   @override
  void onInit() {
    super.onInit();
    vendorController.getVendors(); // load vendors when dashboard opens
  }

  void changeTab(int index){
    currentIndex.value = index;
  }

  void setSelectedVendor(String id, String name) {
    selectedVendorId.value = id;
    selectedVendorName.value = name;
    print("✅ Selected Vendor ID: $id");
    print("✅ Selected Vendor Name: $name");
  }

}