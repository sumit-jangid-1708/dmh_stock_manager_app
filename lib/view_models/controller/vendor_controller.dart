import 'package:dmj_stock_manager/data/app_exceptions.dart';
import 'package:dmj_stock_manager/model/vendor_model.dart';
import 'package:dmj_stock_manager/utils/utils.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/services/vendor_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/vender_overview_model.dart';

class VendorController extends GetxController with BaseController{
  var expandedList = <bool>[].obs;
  final vendors = <VendorModel>[].obs; // Store vendors
  var filteredVendors = <VendorModel>[].obs;
  final searchBar = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Rx<VendorOverviewModel?> vendorOverview = Rx<VendorOverviewModel?>(null);
  //fields
  final vendorNameController = TextEditingController().obs;
  // final phoneNumberController = TextEditingController().obs;
  var countryCode = "".obs;
  var phoneNumber = "".obs;
  final emailController = TextEditingController().obs;
  final addressController = TextEditingController().obs;
  final countryController = TextEditingController().obs;
  final cityController = TextEditingController().obs;
  final stateController = TextEditingController().obs;
  final pinCodeController = TextEditingController().obs;
  var firmNameController = TextEditingController().obs;
  var gstNumberController = TextEditingController().obs;
  var isWithGst = false.obs;
  // final searchBar = SearchController().obs;
  final VendorService _vendorService = VendorService();

  Rx<VendorModel?> selectedVendor = Rx<VendorModel?>(null);
final RxString gstError = ''.obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getVendors();
    filteredVendors.assignAll(vendors);
    expandedList.value = List.generate(vendors.length, (_) => false);

    // Search listener
    searchBar.addListener(() {
      final query = searchBar.text.toLowerCase();
      if (query.isEmpty) {
        filteredVendors.assignAll(vendors);
      } else {
        filteredVendors.assignAll(
          vendors.where(
            (vendor) =>
                vendor.vendorName.toLowerCase().contains(query) ||
                vendor.city.toLowerCase().contains(query) ||
                vendor.state.toLowerCase().contains(query),
          ),
        );
      }
    });
  }

  void validateGST(String value){
    if (value.isEmpty){
      gstError.value = '';
    }else if(value.length < 15){
      gstError.value = 'GST must be 15 Character';
    }else if(!Utils.isValidGST(value)){
      gstError.value = 'Invalid GST format';
    }else{
      gstError.value = '';
    }
  }
  bool get isGSTValid => gstError.value.isEmpty;

  void clearForm() {
    vendorNameController.value.clear();
    emailController.value.clear();
    addressController.value.clear();
    pinCodeController.value.clear();
    countryController.value.clear();
    stateController.value.clear();
    cityController.value.clear();
    firmNameController.value.clear();
    gstNumberController.value.clear();
    isWithGst.value = false;
    countryCode.value = "";
    phoneNumber.value = "";
    formKey.currentState?.reset();
  }
  // void clearSearch() {
  //   searchBar.clear();
  //   filterVendors("");
  // }

  void toggleVendor(int index) {
    expandedList[index] = !expandedList[index];
  }

  Future<void> getVendors() async {
    isLoading.value = true;
    try {
      final response = await _vendorService.getVendors();
      final List<dynamic> data = response; // fill vendors
      vendors.value = data.map((item) => VendorModel.fromJson(item)).toList();
      vendors.sort((a, b) => b.id.compareTo(a.id)); // ✅ Sort vendors by ID (latest first)
      filteredVendors.assignAll(vendors); // update filtered list
      expandedList.value = List.generate(vendors.length, (_) => false); // update expanded list
      print("✅ Vendors fetched: ${vendors.length}");
    // } on AppExceptions catch (e) {
    //   if (kDebugMode) {
    //     print("❌ Exception Details: $e"); // full stack ya raw details
    //   }
    //   Get.snackbar(
    //     "Error",
    //     e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
    //     duration: const Duration(seconds: 1),
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    } catch (e) {
      if (kDebugMode) {
        print("🚩Vendor Error ❌ Exception Details: $e");
      }
      Get.snackbar(
        'Error',
        'Failed to load Vendor List: ${e.toString().replaceAll(RegExp(r"<[^>]*>"), "")}',
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }


  //Helper: to get the vendor name by id
  String getVendorNameById(int id) {
    final vendor = vendors.firstWhereOrNull((v) => v.id == id);
    return vendor?.vendorName ?? "Unknown Vendor";
  }



  //Api to add vendor
  Future<void> addVendor() async {
    Map data = {
      "name": vendorNameController.value.text,
      "country_code": countryCode.value,
      "mobile": phoneNumber.value,
      "email": emailController.value.text,
      "address": addressController.value.text,
      "country": countryController.value.text,
      "city": cityController.value.text,
      "state": stateController.value.text,
      "pin_code": pinCodeController.value.text,
      "with_Gst": isWithGst.value,
      "firm_name": firmNameController.value.text,
      "gst_number": gstNumberController.value.text,
    };

    try {
      isLoading.value = true;
      final response = await _vendorService.addNewVendor(data);
      final vendor = VendorModel.fromJson(response);
      vendors.add(vendor);

      Get.back();
      print("Success Vendor added successfully ✅");
      Get.snackbar(
        'Success',
        'Vendor added successfully',
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear controllers after saving
      vendorNameController.value.clear();
      // phoneNumberController.value.clear();
      emailController.value.clear();
      addressController.value.clear();
      cityController.value.clear();
      stateController.value.clear();
      pinCodeController.value.clear();
      countryController.value.clear();

      getVendors();
    }on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error", e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> getVendorDetails(int vendorId) async {
    try {
      isLoading.value = true;

      final response = await _vendorService.vendorDetails(vendorId);

      // Parse the response into VendorOverviewModel
      vendorOverview.value = VendorOverviewModel.fromJson(response);

      if (kDebugMode) {
        print("✅ Vendor details fetched for ID: $vendorId");
        print("Vendor: ${vendorOverview.value?.vendor.name}");
        print("Supplied Products: ${vendorOverview.value?.suppliedProducts.length}");
        print("Past Orders: ${vendorOverview.value?.pastOrders.length}");
      }
    } on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Vendor Details Exception: $e");
      }
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Vendor Details Error: $e");
      }
      Get.snackbar(
        "Error",
        "Failed to load vendor details",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }


}
