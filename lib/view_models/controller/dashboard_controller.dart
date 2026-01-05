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
  final isLowStockDialogOpen = false.obs;

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
        print("✅ Low Stock Items fetched: ${lowStockItems.length}");
      }
    } on AppExceptions catch (e) {
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) print("❌ Low Stock Error: $e");
      Get.snackbar(
        "Error",
        "Failed to load Low Stock Products",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showLowStockDialog() {
    if (Get.isDialogOpen == true) return;

    isLowStockDialogOpen.value = true;

    Get.dialog(
      PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) isLowStockDialogOpen.value = false;
        },
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              ),
              const SizedBox(height: 12),
              const Text(
                "Low Stock Alert",
                style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A1A4F), fontSize: 18),
              ),
              const Text(
                "The following items need attention",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Obx(() {
              return ListView.separated(
                shrinkWrap: true,
                itemCount: lowStockItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final item = lowStockItems[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Left Warning Accent
                          Container(
                            width: 4,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A4F)),
                                      ),
                                      Text(
                                        "SKU: ${item.sku}",
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        item.quantity.toString(),
                                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 16),
                                      ),
                                      const Text("STOCK", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            // --- Gradient Button ---
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A1A4F).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  isLowStockDialogOpen.value = false;
                  Get.back();
                },
                child: const Text(
                  "Close Alert",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    ).then((_) {
      isLowStockDialogOpen.value = false;
    });
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => getLowStock(),
    );
  }

  void openLowStockDialog() {
    if (lowStockItems.isEmpty) return;
    if (Get.isDialogOpen == true) return;

    _showLowStockDialog();
  }

  void refreshLowStock() {
    hasShownDialog.value = false;
    getLowStock();
  }
}

