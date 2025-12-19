import 'package:dmj_stock_manager/model/inventory_model.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/services/stock_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../model/product_model.dart';

class StockController extends GetxController {
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
      print("Error fetching Inventory: $e");
      Get.snackbar(
        'Error',
        'Failed to load Vendor List: $e',
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      await fetchInventoryList();
      Get.snackbar(
        "Success",
        "Quantity added successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on AppExceptions catch (e) {
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
    }catch (e) {
      if (kDebugMode) {
        print("🚩 Add Inventory Error ❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        'Error',
        'Failed to add quantity',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      // Agar success mila to
      if (response["new_quantity"] != null) {
        Get.snackbar(
          "Success",
          "Inventory adjusted. New qty: ${response["new_quantity"]}",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      fetchInventoryList(); // refresh karo
    }on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error", e.toString(),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      // Agar backend error deta h jaise "Cannot reduce below zero"
      Get.snackbar(
        "Error",
        e.toString().contains("Cannot reduce below zero")
            ? "Not enough stock to reduce!"
            : "Failed to adjust inventory",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("🚩 Adjust Inventory error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
