import 'package:dmj_stock_manager/model/stock_inventory_models/inventory_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/services/stock_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../model/product_models/product_model.dart';

class StockController extends GetxController with BaseController{
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
      final List<dynamic> data = response;
      inventoryList.value = data
          .map((item) => InventoryModel.formJson(item))
          .toList();

      inventoryList.sort((a, b)=> b.id.compareTo(a.id));
    } catch (e) {
      print("Error fetching Inventory: $e");
      handleError(e, onRetry: ()=> fetchInventoryList());
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
      final product = InventoryModel.formJson(response);
      inventoryList.add(product);
      fetchInventoryList();
      AppAlerts.success("Quantity added successfully");
    }catch (e) {
      if (kDebugMode) {
        print("🚩 Add Inventory Error ❌ Exception Details: $e"); // full stack ya raw details
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
    Map data = {
      "sku": sku,
      "delta": delta,
      "reason": reason,
      "note": note ?? " ",
    };

    try {
      final response = await stockService.inventoryAdjustApi(data);
      if (response["new_quantity"] != null) {
        AppAlerts.success("Inventory adjusted. New qty: ${response["new_quantity"]}");
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
}
