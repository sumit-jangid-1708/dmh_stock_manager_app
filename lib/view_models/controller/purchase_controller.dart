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
import 'item_controller.dart';

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

  var isEditMode = false.obs;
  var editingPurchaseId = 0.obs;

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
    isEditMode.value = false; // ✅ add
    editingPurchaseId.value = 0;
    purchaseItems.clear();
    selectedVendor.value = null;
    billDate.value = DateTime.now();
    paidDate.value = null;
    billNumberController.clear();
    billNumberController.text = "PB-";
    paidAmountController.clear();
    descriptionController.clear();
    selectedStatus.value = "UNPAID";
    paymentMode.value = "CASH"; // ✅ add
    transactionIdController.clear(); // ✅ add
    placeOfSupplyController.clear(); // ✅ add
    discountController.clear(); // ✅ add
    shippingController.clear(); // ✅ add
    otherChargesController.clear(); // ✅ add
    roundOffController.clear(); // ✅ add
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
    placeOfSupplyController.dispose(); // ✅ add
    discountController.dispose(); // ✅ add
    shippingController.dispose(); // ✅ add
    otherChargesController.dispose(); // ✅ add
    roundOffController.dispose(); // ✅ add
    transactionIdController.dispose(); // ✅ add
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
    } catch (e, s) {
      if (kDebugMode) print("❌ Error fetching purchase list: $e $s");
      handleError(e, onRetry: () => getPurchaseList());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPurchaseBill({VoidCallback? onSuccess}) async {
    try {
      isLoading.value = true;

      if (selectedVendor.value == null) {
        isLoading.value = false; // ✅
        AppAlerts.error("Please select a vendor");
        return;
      }
      if (billNumberController.text.trim() == "PB-" ||
          billNumberController.text.trim().isEmpty) {
        isLoading.value = false; // ✅
        AppAlerts.error("Please enter a valid bill number");
        return;
      }

      final itemList = purchaseItems
          .map(
            (item) => {
              "product": item.selectedProduct.value?.id,
              "quantity": int.tryParse(item.quantityController.text) ?? 0,
              "unit_price":
                  double.tryParse(item.unitPriceController.text) ?? 0.0,
            },
          )
          .toList();

      if (itemList.isEmpty || itemList.any((i) => i["product"] == null)) {
        isLoading.value = false; // ✅
        AppAlerts.error("Please select products for all rows");
        return;
      }

      final formattedBillDate = billDate.value != null
          ? DateFormat('yyyy-MM-dd').format(billDate.value!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      final gstTypeForApi = selectedPurchaseType.value == 'WITH_GST'
          ? 'with_gst'
          : 'no_gst';

      final Map<String, dynamic> data = {
        "vendor": selectedVendor.value!.id,
        "bill_date": formattedBillDate,
        "place_of_supply": placeOfSupplyController.text.trim(),
        "gst_type": gstTypeForApi,
        "description": descriptionController.text.trim(),
        "items": itemList,
        "discount": double.tryParse(discountController.text) ?? 0,
        "shipping": double.tryParse(shippingController.text) ?? 0,
        "other_expense": double.tryParse(otherChargesController.text) ?? 0,
        "round_off": double.tryParse(roundOffController.text) ?? 0,
        "payment_mode": paymentMode.value.toLowerCase(),
        "transaction_id": transactionIdController.text.trim(),
      };

      if (selectedPurchaseType.value == 'WITH_GST') {
        if (selectedGstType.value == 'SGST_CGST') {
          data["sgst_percent"] = double.tryParse(sgstController.text) ?? 0;
          data["cgst_percent"] = double.tryParse(cgstController.text) ?? 0;
          data["igst_percent"] = 0;
        } else {
          data["sgst_percent"] = 0;
          data["cgst_percent"] = 0;
          data["igst_percent"] = double.tryParse(igstController.text) ?? 0;
        }
      } else {
        data["sgst_percent"] = 0;
        data["cgst_percent"] = 0;
        data["igst_percent"] = 0;
      }

      if (paidAmountController.text.isNotEmpty) {
        data["paid_amount"] = double.tryParse(paidAmountController.text) ?? 0.0;
      }
      if (paidDate.value != null) {
        data["paid_date"] = DateFormat('yyyy-MM-dd').format(paidDate.value!);
      }

      if (kDebugMode) print("🚀 Purchase Bill Request: $data");

      await purchaseService.addPurchaseBill(data);

      // ✅ PEHLE close karo
      if (onSuccess != null) {
        onSuccess();
      } else {
        Get.back();
      }

      // ✅ PHIR success + refresh
      await Future.delayed(const Duration(milliseconds: 300));
      AppAlerts.success('Purchase bill created successfully ✅');
      clearForm();
      getPurchaseList();
    } catch (e, s) {
      if (kDebugMode) print("❌ Error: $e\n$s");
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void populateFormForEdit(PurchaseBillModel purchase) {
    isEditMode.value = true;
    editingPurchaseId.value = purchase.id ?? 0;

    // Vendor
    final vendor = purchase.vendor;
    if (vendor != null) {
      selectedVendor.value = vendorFromPurchase(vendor);
    }

    // Bill info
    billNumberController.text = purchase.billNumber ?? 'PB-';
    billDate.value = purchase.billDate != null
        ? DateTime.tryParse(purchase.billDate!) ?? DateTime.now()
        : DateTime.now();
    placeOfSupplyController.text = purchase.placeOfSupply ?? '';
    descriptionController.text = purchase.description ?? '';

    // GST type
    final gstType = purchase.gstType ?? 'no_gst';
    if (gstType.contains('with')) {
      selectedPurchaseType.value = 'WITH_GST';
      final tax = purchase.taxFields;
      if (tax != null) {
        if ((tax.igstPercent ?? 0) > 0) {
          selectedGstType.value = 'IGST';
          igstController.text = tax.igstPercent?.toString() ?? '';
        } else {
          selectedGstType.value = 'SGST_CGST';
          sgstController.text = tax.sgstPercent?.toString() ?? '';
          cgstController.text = tax.cgstPercent?.toString() ?? '';
        }
      }
    } else {
      selectedPurchaseType.value = 'WITHOUT_GST';
    }

    // Charges
    discountController.text = purchase.discount ?? '';
    shippingController.text = purchase.shipping ?? '';
    otherChargesController.text = purchase.otherExpense ?? '';
    roundOffController.text = purchase.roundOff ?? '';

    // Payment
    selectedStatus.value = purchase.status ?? 'UNPAID';
    paymentMode.value = (purchase.paymentMode ?? 'cash').toUpperCase();
    paidAmountController.text = purchase.paidAmount ?? '';
    transactionIdController.text = purchase.transactionId ?? '';
    if (purchase.paidDate != null && purchase.paidDate!.isNotEmpty) {
      paidDate.value = DateTime.tryParse(purchase.paidDate!);
    }

    // Items with product auto-select
    for (var item in purchaseItems) item.dispose();
    purchaseItems.clear();

    final ItemController itemCtrl = Get.find<ItemController>();
    final allProducts = itemCtrl.products;

    final items = purchase.items ?? [];
    if (items.isEmpty) {
      addNewItem();
    } else {
      for (final purchaseItem in items) {
        final pi = PurchaseItem();

        final matched = allProducts.firstWhereOrNull(
          (p) => p.id == purchaseItem.productId,
        );

        // ✅ Mila toh set karo, nahi mila toh null rehega (user manually select karega)
        pi.selectedProduct.value = matched;

        pi.quantityController.text = purchaseItem.quantity?.toString() ?? '';
        pi.unitPriceController.text = purchaseItem.unitPrice?.toString() ?? '';

        purchaseItems.add(pi);
      }
    }
  }

  // Helper — PurchaseVendorModel se VendorModel banana
  VendorModel? vendorFromPurchase(PurchaseVendorModel pv) {
    try {
      return VendorModel(
        id: pv.id ?? 0,
        vendorName: pv.name ?? '',
        phoneNumber: pv.mobile ?? '',
        countryCode: '',
        email: '',
        address: '',
        city: '',
        state: '',
        pinCode: '',
        country: '',
        withGst: false,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> savePurchaseBill({VoidCallback? onSuccess}) async {
    if (isEditMode.value) {
      await updatePurchaseBill(onSuccess: onSuccess);
    } else {
      await addPurchaseBill(onSuccess: onSuccess);
    }
  }

  Future<void> updatePurchaseBill({VoidCallback? onSuccess}) async {
    try {
      isLoading.value = true;

      final itemList = purchaseItems
          .map(
            (item) => {
              "product": item.selectedProduct.value?.id,
              "quantity": int.tryParse(item.quantityController.text) ?? 0,
              "unit_price":
                  double.tryParse(item.unitPriceController.text) ?? 0.0,
            },
          )
          .toList();

      if (itemList.any((i) => i["product"] == null)) {
        isLoading.value = false;
        AppAlerts.error("Please select products for all rows");
        return;
      }

      final formattedBillDate = billDate.value != null
          ? DateFormat('yyyy-MM-dd').format(billDate.value!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      final gstTypeForApi = selectedPurchaseType.value == 'WITH_GST'
          ? 'with_gst'
          : 'no_gst';

      final Map<String, dynamic> data = {
        "bill_date": formattedBillDate,
        "place_of_supply": placeOfSupplyController.text.trim(),
        "gst_type": gstTypeForApi,
        "description": descriptionController.text.trim(),
        "items": itemList,
        "discount": double.tryParse(discountController.text) ?? 0,
        "shipping": double.tryParse(shippingController.text) ?? 0,
        "other_expense": double.tryParse(otherChargesController.text) ?? 0,
        "round_off": double.tryParse(roundOffController.text) ?? 0,
        "payment_mode": paymentMode.value.toLowerCase(),
        "transaction_id": transactionIdController.text.trim(),
      };

      if (selectedPurchaseType.value == 'WITH_GST') {
        if (selectedGstType.value == 'SGST_CGST') {
          data["sgst_percent"] = double.tryParse(sgstController.text) ?? 0;
          data["cgst_percent"] = double.tryParse(cgstController.text) ?? 0;
          data["igst_percent"] = 0;
        } else {
          data["sgst_percent"] = 0;
          data["cgst_percent"] = 0;
          data["igst_percent"] = double.tryParse(igstController.text) ?? 0;
        }
      } else {
        data["sgst_percent"] = 0;
        data["cgst_percent"] = 0;
        data["igst_percent"] = 0;
      }

      if (paidAmountController.text.isNotEmpty) {
        data["paid_amount"] = double.tryParse(paidAmountController.text) ?? 0.0;
      }
      if (paidDate.value != null) {
        data["paid_date"] = DateFormat('yyyy-MM-dd').format(paidDate.value!);
      }

      if (kDebugMode) print("🚀 Update Purchase Request: $data");

      await purchaseService.updatePurchase(editingPurchaseId.value, data);

      // ✅ Pehle close
      if (onSuccess != null) {
        onSuccess();
      } else {
        Get.back();
      }

      await Future.delayed(const Duration(milliseconds: 300));
      AppAlerts.success('Purchase bill updated successfully ✅');
      clearForm();
      getPurchaseList();
    } catch (e, s) {
      if (kDebugMode) print("❌ Update Error: $e\n$s");
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePurchaseBill(int purchaseId) async {
    try {
      isLoading.value = true;
      await purchaseService.deletePurchase(purchaseId);

      // List se remove karo
      purchaseList.removeWhere((p) => p.id == purchaseId);
      filteredPurchaseList.removeWhere((p) => p.id == purchaseId);

      AppAlerts.success('Purchase bill deleted successfully');
    } catch (e) {
      if (kDebugMode) print("❌ Delete Error: $e");
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
