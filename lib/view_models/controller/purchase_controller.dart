import 'package:dmj_stock_manager/model/vendor_model/vendor_model.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/services/purchase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/app_exceptions.dart';
import '../../model/product_models/product_model.dart';
import '../../model/purchase_models/purchase_model.dart';
import '../../utils/app_alerts.dart';

class PurchaseItem {
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();

  void dispose() {
    quantityController.dispose();
    unitPriceController.dispose();
  }
}

class PurchaseController extends GetxController with BaseController {
  final PurchaseService purchaseService = PurchaseService();

  // Form State Variables
  final RxList<PurchaseItem> purchaseItems = <PurchaseItem>[].obs;
  final Rx<VendorModel?> selectedVendor = Rx<VendorModel?>(null);
  final Rx<DateTime?> billDate = Rx<DateTime?>(DateTime.now());
  final Rx<DateTime?> paidDate = Rx<DateTime?>(null);
  final TextEditingController billNumberController = TextEditingController(
    text: "PB-",
  );
  final TextEditingController paidAmountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxString selectedStatus = "UNPAID".obs;
  var purchaseList = <PurchaseBillModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxList<PurchaseBillModel> filteredPurchaseList =
      <PurchaseBillModel>[].obs;
  var isLoading = false.obs;

  // Add a new empty item row
  void addNewItem() {
    purchaseItems.add(PurchaseItem());
  }

  // Remove item at specific index
  void removeItem(int index) {
    if (index >= 0 && index < purchaseItems.length) {
      purchaseItems[index].dispose();
      purchaseItems.removeAt(index);
    }
  }

  // Clear form
  void clearForm() {
    for (var item in purchaseItems) {
      item.dispose();
    }
    purchaseItems.clear();
    selectedVendor.value = null;
    billDate.value = DateTime.now();
    paidDate.value = null;
    billNumberController.clear();
    billNumberController.text = "PB-";
    paidAmountController.clear();
    descriptionController.clear();
    selectedStatus.value = "UNPAID";
    addNewItem(); // Start with one empty item
  }

  @override
  void onInit() {
    super.onInit();
    addNewItem(); // Start with 1 empty item row
    getPurchaseList();
    debounce(
      searchQuery,
      (_) => _filterPurchases(),
      time: const Duration(milliseconds: 400),
    );
  }

  @override
  void onClose() {
    for (var item in purchaseItems) {
      item.dispose();
    }
    billNumberController.dispose();
    paidAmountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void _filterPurchases() {
    final query = searchQuery.value.toLowerCase().trim();

    if (query.isEmpty) {
      filteredPurchaseList.assignAll(purchaseList);
    } else {
      filteredPurchaseList.assignAll(
        purchaseList.where((purchase) {
          final billNumber = purchase.billNumber.toLowerCase();
          final vendorName = purchase.vendor.name.toLowerCase();
          final status = purchase.status.toLowerCase();

          return billNumber.contains(query) ||
              vendorName.contains(query) ||
              status.contains(query);
        }).toList(),
      );
    }
  }

  /// ✅ Add Purchase Bill Function (Similar to createOrder)
  Future<void> addPurchaseBill({VoidCallback? onSuccess}) async {
    try {
      isLoading.value = true;
      debugPrint("🚀 Starting Purchase Bill Creation...");

      // Validate vendor selection
      if (selectedVendor.value == null) {
        isLoading.value = false;
        AppAlerts.error("Please select a vendor");
        return;
      }

      // Validate bill number
      if (billNumberController.text.isEmpty) {
        isLoading.value = false;
        AppAlerts.error("Please enter a valid bill number");
        return;
      }

      // Convert purchase items into API format
      List<Map<String, dynamic>> itemList = purchaseItems.map((item) {
        final product = item.selectedProduct.value;
        final quantity = item.quantityController.text;
        final unitPrice = item.unitPriceController.text;

        return {
          "product": product?.id, // product id required
          "quantity": int.tryParse(quantity) ?? 0,
          "unit_price": double.tryParse(unitPrice) ?? 0.0,
        };
      }).toList();

      // Validate items
      if (itemList.isEmpty || itemList.any((item) => item["product"] == null)) {
        isLoading.value = false;
        AppAlerts.error("Please select products for all rows");
        return;
      }

      // Format dates to YYYY-MM-DD
      String formattedBillDate = billDate.value != null
          ? DateFormat('yyyy-MM-dd').format(billDate.value!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Build request body
      Map<String, dynamic> data = {
        "vendor": selectedVendor.value?.id,
        "bill_number": billNumberController.text,
        "bill_date": formattedBillDate,
        "status": selectedStatus.value,
        "description": descriptionController.text,
        "items": itemList,
      };
      // Add optional fields only if they have values
      if (paidDate.value != null) {
        data["paid_date"] = DateFormat('yyyy-MM-dd').format(paidDate.value!);
      }

      if (paidAmountController.text.isNotEmpty) {
        data["paid_amount"] = double.tryParse(paidAmountController.text) ?? 0.0;
      }
      debugPrint("🚀 Purchase Bill Request: $data");
      // API call
      final response = await purchaseService.addPurchaseBill(data);
      debugPrint("📦 Raw API Response: $response");
      debugPrint("📦 Response Type: ${response.runtimeType}");
      // Parse response - Handle both single object and success message
      String successMessage = 'Purchase bill added successfully ✅';
      try {
        if (response is Map<String, dynamic>) {
          // If response has the expected structure
          if (response.containsKey('message')) {
            final purchaseResponse = PurchaseBillResponseModel.fromJson(response,);
            successMessage = purchaseResponse.message.isNotEmpty
                ? purchaseResponse.message
                : successMessage;
            debugPrint("✅ Parsed Response: ${purchaseResponse.toString()}");
          } else if (response.containsKey('success')) {
            // Alternative response structure
            successMessage = response['success']?.toString() ?? successMessage;
          } else {
            // Just use first available message field
            successMessage = response.toString();
          }
        }
      } catch (parseError) {
        debugPrint("⚠️ Response parsing failed, using default message: $parseError",);
        // Continue with default success message
      }
      debugPrint("✅ Purchase Bill Created Successfully!");
      debugPrint("🎉 Showing success message and closing...");

      AppAlerts.success(successMessage);
      // Clear form first
      clearForm();
      getPurchaseList();
      // Call success callback (this will close the bottom sheet)
      if (onSuccess != null) {
        onSuccess();
      } else {
        Get.back();
      }
      // Show success message after a small delay
      await Future.delayed(const Duration(milliseconds: 100));

      debugPrint("✅ Bottom sheet closed and snackbar shown!");
    // } on AppExceptions catch (e) {
    //   debugPrint("❌ AppException caught: $e");
    //   Get.snackbar(
    //     "Error",
    //     e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
    //     duration: const Duration(seconds: 2),
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    } catch (e, stackTrace) {
      debugPrint("❌ General Exception caught: $e");
      debugPrint("❌ Stack Trace: $stackTrace");
      handleError(e);
    } finally {
      isLoading.value = false;
      debugPrint("🏁 Purchase bill creation process completed");
    }
  }

  Future<void> getPurchaseList() async {
    try {
      isLoading.value = true;
      final response = await purchaseService.getPurchaseListApi();
      final List<dynamic> data = response;
      purchaseList.value = data
          .map((item) => PurchaseBillModel.fromJson(item))
          .toList();
      _filterPurchases();
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
      handleError(e, onRetry: () => getPurchaseList());
      print("Error fetching order list $e");
    } finally {
      isLoading.value = false;
    }
  }
}
