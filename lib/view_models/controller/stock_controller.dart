import 'package:dmj_stock_manager/model/stock_inventory_models/inventory_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/utils/response_list.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/services/stock_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../model/product_models/product_model.dart';

class StockController extends GetxController with BaseController {
  //form key
  final StockService stockService = StockService();
  final formKey = GlobalKey<FormState>();
  final inventoryList = <InventoryModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInventoryList();
  }

  Future<void> fetchInventoryList() async {
    isLoading.value = true;
    try {
      final response = await stockService.fetchInventoryApi();
      final data = responseList(response);
      inventoryList.value =
          data.map((item) => InventoryModel.fromJson(item)).toList();

      inventoryList.sort(
        (a, b) => (b.id ?? 0).compareTo(a.id ?? 0),
      );
    } catch (e, s) {
      print("❌❌❌Error fetching Inventory: $e $s");
      handleError(e, onRetry: () => fetchInventoryList());
    } finally {
      isLoading.value = false;
    }
  }

  ProductModel? getProductById(int id) {
    final product = Get.find<ItemController>().products.firstWhereOrNull(
          (p) => p.id == id,
        );
    // return product?.name ?? "Unknown Product";
    return product;
  }

  Future<void> addInventory({
    required int productId,
    required int quantity,
  }) async {
    isLoading.value = true;
    try {
      Map data = {"product": productId, "quantity": quantity};
      final response = await stockService.addProductQuantity(data);
      final product = InventoryModel.fromJson(response);
      inventoryList.add(product);
      fetchInventoryList();
      AppAlerts.success("Quantity added successfully");
    } catch (e, s) {
      if (kDebugMode) {
        print(
            "🚩 Add Inventory Error ❌ Exception Details: $e $s"); // full stack ya raw details
      }
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> adjustInventoryStock({
    required String sku,
    required int delta,
    required String reason,
    required String note,
  }) async {
    isLoading.value = true;
    final apiReason = _inventoryReasonForApi(reason);
    final cleanNote = note.trim();
    final apiNote = apiReason == reason
        ? cleanNote
        : [
            "Selected reason: $reason",
            if (cleanNote.isNotEmpty) cleanNote,
          ].join(" - ");
    Map data = {
      "sku": sku,
      "delta": delta,
      "reason": apiReason,
      "note": apiNote.isEmpty ? " " : apiNote,
    };

    try {
      final response = await stockService.inventoryAdjustApi(data);
      if (response["new_quantity"] != null) {
        AppAlerts.success(
            "Inventory adjusted. New qty: ${response["new_quantity"]}");
      }
      fetchInventoryList();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e");
      }
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  String _inventoryReasonForApi(String reason) {
    final normalized = reason.trim().toUpperCase().replaceAll(" ", "_");
    const validReasons = {"ORDER", "PURCHASE", "RETURN", "WPS", "ADJUST"};
    if (validReasons.contains(normalized)) {
      return normalized;
    }
    if (normalized == "OTHER" || normalized == "DAMAGED") {
      return "ADJUST";
    }
    return "ADJUST";
  }
}
