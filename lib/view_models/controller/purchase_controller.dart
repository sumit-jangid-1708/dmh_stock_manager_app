import 'package:dmj_stock_manager/model/vendor_model/vendor_model.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/services/purchase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  final RxString selectedPurchaseType = 'WITHOUT_GST'.obs;
  final RxString selectedGstType = 'SGST_CGST'.obs;
  final TextEditingController sgstController = TextEditingController();
  final TextEditingController cgstController = TextEditingController();
  final TextEditingController igstController = TextEditingController();

  final TextEditingController paidAmountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController placeOfSupplyController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController shippingController = TextEditingController();
  final TextEditingController otherChargesController = TextEditingController();
  final TextEditingController roundOffController = TextEditingController();
  final TextEditingController dueDate = TextEditingController();

  // Payment
  final RxString paymentMode = "CASH".obs;
  final TextEditingController transactionIdController = TextEditingController();

  final RxString selectedStatus = "UNPAID".obs;
  var purchaseList = <PurchaseBillModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxList<PurchaseBillModel> filteredPurchaseList =
      <PurchaseBillModel>[].obs;
  var isLoading = false.obs;

  void addNewItem() {
    purchaseItems.add(PurchaseItem());
  }

  void removeItem(int index) {
    if (index >= 0 && index < purchaseItems.length) {
      purchaseItems[index].dispose();
      purchaseItems.removeAt(index);
    }
  }

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
    addNewItem();
    selectedPurchaseType.value = 'WITHOUT_GST';
    selectedGstType.value = 'SGST_CGST';
    sgstController.clear();
    cgstController.clear();
    igstController.clear();
  }

  @override
  void onInit() {
    super.onInit();
    addNewItem();
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
    sgstController.dispose();
    cgstController.dispose();
    igstController.dispose();
    super.onClose();
  }

  void _filterPurchases() {
    final query = searchQuery.value.toLowerCase().trim();

    if (query.isEmpty) {
      filteredPurchaseList.assignAll(purchaseList);
    } else {
      filteredPurchaseList.assignAll(
        purchaseList.where((purchase) {
          final billNumber = purchase.billNumber?.toLowerCase() ?? '';
          final vendorName = purchase.vendor?.name?.toLowerCase() ?? '';
          final status = purchase.status?.toLowerCase() ?? '';

          return billNumber.contains(query) ||
              vendorName.contains(query) ||
              status.contains(query);
        }).toList(),
      );
    }
  }

  Future<void> getPurchaseList() async {
    try {
      isLoading.value = true;

      // ✅ Service now always returns List<dynamic>
      final List<dynamic> data = await purchaseService.getPurchaseListApi();

      purchaseList.value = data
          .map((item) => PurchaseBillModel.fromJson(item))
          .toList();

      _filterPurchases();
    } catch (e) {
      if (kDebugMode) print("❌ Error fetching purchase list: $e");
      handleError(e, onRetry: () => getPurchaseList());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPurchaseBill({VoidCallback? onSuccess}) async {
    try {
      isLoading.value = true;

      if (selectedVendor.value == null) {
        AppAlerts.error("Please select a vendor");
        return;
      }

      if (billNumberController.text.isEmpty) {
        AppAlerts.error("Please enter a valid bill number");
        return;
      }

      List<Map<String, dynamic>> itemList = purchaseItems.map((item) {
        return {
          "product": item.selectedProduct.value?.id,
          "quantity": int.tryParse(item.quantityController.text) ?? 0,
          "unit_price": double.tryParse(item.unitPriceController.text) ?? 0.0,
        };
      }).toList();

      if (itemList.isEmpty || itemList.any((item) => item["product"] == null)) {
        AppAlerts.error("Please select products for all rows");
        return;
      }

      String formattedBillDate = billDate.value != null
          ? DateFormat('yyyy-MM-dd').format(billDate.value!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      Map<String, dynamic> data = {
        "vendor": selectedVendor.value?.id,
        "bill_number": billNumberController.text,
        "bill_date": formattedBillDate,
        "status": selectedStatus.value,
        "description": descriptionController.text,
        "items": itemList,
      };

      if (paidDate.value != null) {
        data["paid_date"] = DateFormat('yyyy-MM-dd').format(paidDate.value!);
      }

      if (paidAmountController.text.isNotEmpty) {
        data["paid_amount"] = double.tryParse(paidAmountController.text) ?? 0.0;
      }

      await purchaseService.addPurchaseBill(data);

      AppAlerts.success('Purchase bill added successfully ✅');
      clearForm();
      getPurchaseList();

      if (onSuccess != null) {
        onSuccess();
      } else {
        Get.back();
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("❌ Error creating purchase bill: $e");
        print("❌ Stack Trace: $stackTrace");
      }
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
