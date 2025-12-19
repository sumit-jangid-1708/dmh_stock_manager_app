import 'package:dmj_stock_manager/data/app_exceptions.dart';
import 'package:dmj_stock_manager/model/vendor_model.dart';
import 'package:dmj_stock_manager/view_models/services/vendor_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorController extends GetxController {
  var expandedList = <bool>[].obs;
  final vendors = <VendorModel>[].obs; // Store vendors

  // store all vendors
  // Hardcoded vendor list

  // store filtered vendors
  var filteredVendors = <VendorModel>[].obs;
  final searchBar = TextEditingController();

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
      final List<dynamic> data = response;

      // fill vendors
      vendors.value = data.map((item) => VendorModel.fromJson(item)).toList();

      // ✅ Sort vendors by ID (latest first)
      vendors.sort((a, b) => b.id.compareTo(a.id));

      // update filtered list
      filteredVendors.assignAll(vendors);

      // update expanded list
      expandedList.value = List.generate(vendors.length, (_) => false);

      print("✅ Vendors fetched: ${vendors.length}");
    } on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
}
  