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

      // 🔐 HARD GUARD
      if (lowStockItems.isNotEmpty &&
          !isLowStockDialogOpen.value &&
          Get.context != null) {
        _showLowStockDialog();
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
    // 🛑 Extra safety
    if (Get.isDialogOpen == true) return;

    isLowStockDialogOpen.value = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          isLowStockDialogOpen.value = false;
          return true;
        },
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "Low Stock Alert",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Obx(() {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: lowStockItems.length,
                itemBuilder: (_, index) {
                  final item = lowStockItems[index];
                  return ListTile(
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text("SKU: ${item.sku}"),
                    trailing: Text(
                      item.quantity.toString(),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A4F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                isLowStockDialogOpen.value = false;
                Get.back();
              },
              child: const Text(
                "Close",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    ).then((_) {
      // 🔁 SAFETY RESET
      isLowStockDialogOpen.value = false;
    });
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => getLowStock(),
    );
  }

  // void _showLowStockDialog() {
  //
  //   // 🛑 Extra safety
  //   if (Get.isDialogOpen == true) return;
  //
  //   isLowStockDialogOpen.value = true;
  //
  //   Get.dialog(
  //     AlertDialog(
  //       backgroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
  //       title: const Row(
  //         children: [
  //           Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
  //           SizedBox(width: 8),
  //           Text(
  //             "Low Stock Alert",
  //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  //           ),
  //         ],
  //       ),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: Obx(() {
  //           if (lowStockItems.isEmpty) {
  //             return const Padding(
  //               padding: EdgeInsets.symmetric(vertical: 20),
  //               child: Text(
  //                 "No items below threshold.",
  //                 textAlign: TextAlign.center,
  //               ),
  //             );
  //           }
  //
  //           return ListView.separated(
  //             shrinkWrap: true,
  //             itemCount: lowStockItems.length,
  //             separatorBuilder: (_, __) => const SizedBox(height: 10),
  //             itemBuilder: (context, index) {
  //               final item = lowStockItems[index];
  //               return Container(
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade50,
  //                   borderRadius: BorderRadius.circular(12),
  //                   border: Border.all(color: Colors.grey.shade200),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             item.name,
  //                             style: const TextStyle(
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: 14,
  //                             ),
  //                           ),
  //                           Text(
  //                             "SKU: ${item.sku}",
  //                             style: const TextStyle(
  //                               color: Colors.grey,
  //                               fontSize: 12,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.end,
  //                       children: [
  //                         Text(
  //                           "${item.quantity}",
  //                           style: const TextStyle(
  //                             color: Colors.red,
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 16,
  //                           ),
  //                         ),
  //                         const Text(
  //                           "IN STOCK",
  //                           style: TextStyle(
  //                             color: Colors.grey,
  //                             fontSize: 9,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           );
  //         }),
  //       ),
  //       actions: [
  //         SizedBox(
  //           width: double.infinity,
  //           child: ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF1A1A4F),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               elevation: 0,
  //             ),
  //             onPressed: () => Get.back(),
  //             child: const Text(
  //               "Close",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _startPolling() {
  //   _pollingTimer?.cancel();
  //   _pollingTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
  //     getLowStock();
  //   });
  // }

  void refreshLowStock() {
    hasShownDialog.value = false;
    getLowStock();
  }
}

// void _showLowStockDialog() {
//   Get.dialog(
//     AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: const Row(
//         children: [
//           Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
//           SizedBox(width: 12),
//           Text(
//             "Low Stock Alert ⚠️",
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
//           ),
//         ],
//       ),
//       content: SizedBox(
//         width: double.maxFinite,
//         height: 420,
//         child: Obx(() {
//           if (lowStockItems.isEmpty) {
//             return const Center(child: Text("No low stock items."));
//           }
//
//           return ListView.builder(
//             itemCount: lowStockItems.length,
//             itemBuilder: (context, index) {
//               final item = lowStockItems[index];
//
//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 6),
//                 elevation: 3,
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: item.popular ? Colors.green.shade100 : Colors.orange.shade100,
//                     child: Icon(
//                       item.popular ? Icons.star : Icons.inventory_2_outlined,
//                       color: item.popular ? Colors.green : Colors.orange,
//                     ),
//                   ),
//                   title: Text(
//                     item.name,
//                     style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("SKU: ${item.sku}"),
//                       Text("Current Stock: ${item.quantity}"),
//                       Text("Threshold: ${item.threshold}", style: TextStyle(color: Colors.red.shade700)),
//                     ],
//                   ),
//                   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                   isThreeLine: true,
//                 ),
//               );
//             },
//           );
//         }),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Get.back();
//             // अगर दोबारा दिखाना चाहते हो तो false करें
//             // hasShownDialog.value = false;
//           },
//           child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         ),
//       ],
//     ),
//     barrierDismissible: false,
//   );
// }12
