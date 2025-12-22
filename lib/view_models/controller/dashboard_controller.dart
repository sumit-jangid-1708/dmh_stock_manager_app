import 'dart:async';
import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:dmj_stock_manager/view_models/services/dashbord_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../model/low_stock_product_model.dart';

class DashboardController extends GetxController with WidgetsBindingObserver {
  final VendorController vendorController = Get.find();
  final DashbordService dashboardService = DashbordService();

  final lowStockItems = <StockAlertItemModel>[].obs;
  var isLoading = false.obs;

  var currentIndex = 0.obs;
  final selectedVendorName = "".obs;
  final selectedVendorId = "".obs;

  Timer? _pollingTimer;
  var hasShownDialog = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    vendorController.getVendors();
    getLowStock();
    _startPolling();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _startPolling();
    } else if (state == AppLifecycleState.paused) {
      _pollingTimer?.cancel();
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void setSelectedVendor(String id, String name) {
    selectedVendorId.value = id;
    selectedVendorName.value = name;
    if (kDebugMode) {
      print("✅ Selected Vendor ID: $id");
      print("✅ Selected Vendor Name: $name");
    }
  }

  Future<void> getLowStock() async {
    try {
      isLoading.value = true;

      final response = await dashboardService.lowStockapi();


      final stockAlertResponse = StockAlertResponseModel.fromJson(response);


      lowStockItems.assignAll(stockAlertResponse.results);

      if (kDebugMode) {
        print("✅ Low Stock Items fetched: ${lowStockItems.length} items");
      }


      if (lowStockItems.isNotEmpty && Get.context != null) {
        _showLowStockDialog();
      }
    } on AppExceptions catch (e) {
      if (kDebugMode) print("❌ Low Stock API Exception: $e");
      Get.snackbar("Error", e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } catch (e) {
      if (kDebugMode) print("❌ Low Stock Error: $e");
      Get.snackbar("Error", "Failed to load Low Stock Products",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _showLowStockDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text(
              "Low Stock Alert ⚠️",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 420,
          child: Obx(() {
            if (lowStockItems.isEmpty) {
              return const Center(child: Text("No low stock items."));
            }

            return ListView.builder(
              itemCount: lowStockItems.length,
              itemBuilder: (context, index) {
                final item = lowStockItems[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.popular ? Colors.green.shade100 : Colors.orange.shade100,
                      child: Icon(
                        item.popular ? Icons.star : Icons.inventory_2_outlined,
                        color: item.popular ? Colors.green : Colors.orange,
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("SKU: ${item.sku}"),
                        Text("Current Stock: ${item.quantity}"),
                        Text("Threshold: ${item.threshold}", style: TextStyle(color: Colors.red.shade700)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // अगर दोबारा दिखाना चाहते हो तो false करें
              // hasShownDialog.value = false;
            },
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      getLowStock();
    });
  }


  void refreshLowStock() {
    hasShownDialog.value = false;
    getLowStock();
  }
}