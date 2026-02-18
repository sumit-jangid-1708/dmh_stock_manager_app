// lib/view_models/controller/return_controller.dart

import 'dart:ui';
import 'package:dmj_stock_manager/model/courier_return/courier_return_list_model.dart';
import 'package:dmj_stock_manager/model/courier_return/courier_return_response.dart';
import 'package:dmj_stock_manager/model/customer_return/customer_return_list_model.dart';
import 'package:dmj_stock_manager/model/customer_return/customer_return_request.dart';
import 'package:dmj_stock_manager/model/customer_return/customer_return_response.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/services/return_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReturnController extends GetxController with BaseController {
  final ReturnService returnService = ReturnService();
  var isLoading = false.obs;
  final courierReturnList = <CourierReturnListModel>[].obs;
  final customerReturnList = <CustomerReturnListModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCourierReturnList();
    getCustomerReturnList();
  }

  /// ✅ Courier Return API
  Future<void> courierReturn({
    required Map<String, dynamic> body,
    VoidCallback? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      final CourierReturnResponse response =
      await returnService.courierReturnApi(body);

      // ✅ Close return form dialog
      Get.back();

      // ✅ Show serial result dialog
      _showReturnResultDialog(
        title: "Courier Return Successful",
        condition: response.condition,
        serialsProcessed: response.serialsProcessed,
        newStatus: response.newStatus,
        isCourier: true,
      );

      onSuccess?.call();
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Customer Return API
  Future<void> customerReturn({
    required CustomerReturnRequest request,
    VoidCallback? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      final CustomerReturnResponse response =
      await returnService.customerReturnApi(request.toJson());

      // ✅ Close return form dialog
      Get.back();

      // ✅ Show serial result dialog
      _showReturnResultDialog(
        title: "Customer Return Successful",
        condition: response.condition,
        serialsProcessed: response.serialsProcessed,
        newStatus: response.newStatus,
        isCourier: false,
      );

      onSuccess?.call();
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Get Courier Return List
  Future<void> getCourierReturnList({
    String? condition,
    String? claimStatus,
    String? claimResult,
  }) async {
    try {
      isLoading.value = true;
      final response = await returnService.courierReturnList(
        condition: condition,
        claimStatus: claimStatus,
        claimResult: claimResult,
      );
      courierReturnList.value =
          response.map((v) => CourierReturnListModel.fromJson(v)).toList();
    } catch (e) {
      handleError(e);
      debugPrint("Courier Return List Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Get Customer Return List
  Future<void> getCustomerReturnList({
    String? condition,
    String? refundStatus,
  }) async {
    try {
      isLoading.value = true;
      final response = await returnService.customerReturnList(
        condition: condition,
        refundStatus: refundStatus,
      );
      customerReturnList.value =
          response.map((e) => CustomerReturnListModel.fromJson(e)).toList();
    } catch (e) {
      handleError(e);
      debugPrint("Customer Return List Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearHistory() {
    courierReturnList.clear();
    customerReturnList.clear();
  }

  // ── Serial Result Dialog ────────────────────────────────────────────────
  void _showReturnResultDialog({
    required String title,
    required String condition,
    required List<String> serialsProcessed,
    required String newStatus,
    required bool isCourier,
  }) {
    const Color primaryColor = Color(0xFF1A1A4F);

    // Status color
    final Color statusColor = newStatus == "in_stock"
        ? Colors.green
        : newStatus == "damaged"
        ? Colors.orange
        : Colors.grey;

    // Condition color
    final Color conditionColor = condition == "SAFE"
        ? Colors.green
        : condition == "DAMAGED"
        ? Colors.orange
        : Colors.red;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle,
                        color: Colors.green.shade600, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const Divider(height: 20),

              // ── Condition + New Status ───────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _statusChip(
                      label: "Condition",
                      value: condition,
                      color: conditionColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statusChip(
                      label: "Serial Status",
                      value: newStatus.replaceAll("_", " ").toUpperCase(),
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Serials Processed ────────────────────────────────
              Row(
                children: [
                  Icon(Icons.numbers, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    "Serials Processed (${serialsProcessed.length})",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Scrollable serial list
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: serialsProcessed.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "No serials were processed",
                      style:
                      TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                      : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: serialsProcessed.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.grey.shade200, height: 1),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius:
                                BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                serialsProcessed[index],
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            // Status dot
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Close Button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}



// import 'dart:ui';
// import 'package:dmj_stock_manager/model/courier_return/courier_return_list_model.dart';
// import 'package:dmj_stock_manager/model/courier_return/courier_return_response.dart';
// import 'package:dmj_stock_manager/model/customer_return/customer_return_list_model.dart';
// import 'package:dmj_stock_manager/model/customer_return/customer_return_request.dart';
// import 'package:dmj_stock_manager/model/customer_return/customer_return_response.dart';
// import 'package:dmj_stock_manager/utils/app_alerts.dart';
// import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
// import 'package:dmj_stock_manager/view_models/services/return_service.dart';
// import 'package:get/get.dart';
//
// class ReturnController extends GetxController with BaseController {
//   final ReturnService returnService = ReturnService();
//   var isLoading = false.obs;
//   final courierReturnList = <CourierReturnListModel>[].obs;
//   final customerReturnList = <CustomerReturnListModel>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     getCourierReturnList();
//     getCustomerReturnList();
//   }
//
//   /// ✅ Courier Return API
//   Future<void> courierReturn({
//     required Map<String, dynamic> body,
//     VoidCallback? onSuccess,
//   }) async {
//     try {
//       isLoading.value = true;
//       final CourierReturnResponse response = await returnService
//           .courierReturnApi(body);
//       // ✅ Close dialog
//       Get.back();
//       // ✅ Show success message
//       AppAlerts.success(response.message);
//       // ✅ Call onSuccess callback if provided
//       onSuccess?.call();
//     } catch (e) {
//       handleError(e);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// ✅ Customer Return API
//   Future<void> customerReturn({
//     required CustomerReturnRequest request,
//     VoidCallback? onSuccess,
//   }) async {
//     try {
//       isLoading.value = true;
//       final CustomerReturnResponse response = await returnService
//           .customerReturnApi(request.toJson());
//       // ✅ Close dialog
//       Get.back();
//       // ✅ Show success message
//       AppAlerts.success(response.message);
//       // ✅ Call onSuccess callback if provided
//       onSuccess?.call();
//     } catch (e) {
//       handleError(e);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// ✅ Get Courier Return List
//   Future<void> getCourierReturnList({
//     String? condition,
//     String? claimStatus,
//     String? claimResult,
//   }) async {
//     try {
//       isLoading.value = true;
//       final response = await returnService.courierReturnList(
//         condition: condition,
//         claimStatus: claimStatus,
//         claimResult: claimResult,
//       );
//       courierReturnList.value = response
//           .map((v) => CourierReturnListModel.fromJson(v))
//           .toList();
//     } catch (e) {
//       handleError(e);
//       print("👌👌👌👌 Courier Return Error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// ✅ Get Customer Return List
//   Future<void> getCustomerReturnList({
//     String? condition,
//     String? refundStatus,
//   }) async {
//     try {
//       isLoading.value = true;
//       final response = await returnService.customerReturnList(
//         condition: condition,
//         refundStatus: refundStatus,
//       );
//
//       customerReturnList.value = response
//           .map((e) => CustomerReturnListModel.fromJson(e))
//           .toList();
//     } catch (e) {
//       handleError(e);
//       print("🤖🤖🤖🤖 Customer Return Error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void clearHistory() {
//     courierReturnList.clear();
//     customerReturnList.clear();
//   }
// }
