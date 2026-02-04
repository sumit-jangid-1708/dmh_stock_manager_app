import 'package:dmj_stock_manager/model/courier_return/courier_enums.dart';
import 'package:dmj_stock_manager/model/courier_return/courier_return_request.dart';
import 'package:dmj_stock_manager/model/order_models/order_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/utils/utils.dart';
import 'package:dmj_stock_manager/view_models/controller/return_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_text_field.dart';

void showCourierReturnDialog(BuildContext context, OrderDetailModel order) {
  final returnController = Get.find<ReturnController>();
  final orderController = Get.find<OrderController>();

  final selectedProduct = Rx<OrderItem?>(null);
  final qtyController = TextEditingController();
  final claimAmountController = TextEditingController();
  final remarksController = TextEditingController();

  final condition = Rx<ReturnCondition?>(null);
  final claimStatus = Rx<ClaimStatus?>(null);
  final claimResult = Rx<ClaimResult?>(null);

  final conditions = [ReturnCondition.safe, ReturnCondition.damaged];
  final claimStatuses = [ClaimStatus.claimed, ClaimStatus.notClaimed];
  final claimResults = [ClaimResult.received, ClaimResult.rejected];

  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header
            const Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFF1A1A4F),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  "Courier Return",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A4F),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Product Selection Dropdown
            Obx(() => DropdownButtonFormField<OrderItem>(
              value: selectedProduct.value,
              decoration: Utils.inputDecoration(
                "Select Product *",
                Icons.inventory_2_outlined,
              ),
              hint: const Text("Choose a product"),
              items: order.items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    "${item.product.name} (Qty: ${item.quantity})",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                selectedProduct.value = val;
                qtyController.clear();
                condition.value = null;
                claimStatus.value = null;
                claimResult.value = null;
                claimAmountController.clear();
                remarksController.clear();
              },
            )),

            const SizedBox(height: 16),

            // Return Quantity
            AppTextField(
              controller: qtyController,
              hintText: "Return Quantity *",
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Condition Dropdown
            Obx(() => DropdownButtonFormField<ReturnCondition>(
              value: condition.value,
              decoration: Utils.inputDecoration(
                "Condition *",
                Icons.info_outline,
              ),
              hint: const Text("Select condition"),
              items: conditions.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c.apiValue),
                );
              }).toList(),
              onChanged: (val) {
                condition.value = val;
                if (val == ReturnCondition.safe) {
                  claimStatus.value = null;
                  claimResult.value = null;
                  claimAmountController.clear();
                  remarksController.clear();
                }
              },
            )),

            // Show additional fields only for DAMAGED condition
            Obx(() {
              if (condition.value == ReturnCondition.damaged) {
                return Column(
                  children: [
                    const SizedBox(height: 16),

                    // Claim Status Dropdown
                    DropdownButtonFormField<ClaimStatus>(
                      value: claimStatus.value,
                      decoration: Utils.inputDecoration(
                        "Claim Status *",
                        Icons.verified_outlined,
                      ),
                      hint: const Text("Select claim status"),
                      items: claimStatuses.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.apiValue),
                        );
                      }).toList(),
                      onChanged: (val) {
                        claimStatus.value = val;
                        claimResult.value = null;
                        claimAmountController.clear();
                        remarksController.clear();
                      },
                    ),

                    // Show fields based on claim status
                    if (claimStatus.value == ClaimStatus.claimed) ...[
                      const SizedBox(height: 16),

                      // Claim Result Dropdown
                      DropdownButtonFormField<ClaimResult>(
                        value: claimResult.value,
                        decoration: Utils.inputDecoration(
                          "Claim Result *",
                          Icons.assignment_turned_in_outlined,
                        ),
                        hint: const Text("Select claim result"),
                        items: claimResults.map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(r.apiValue),
                          );
                        }).toList(),
                        onChanged: (val) {
                          claimResult.value = val;
                          claimAmountController.clear();
                        },
                      ),

                      // Show Claim Amount only if RECEIVED
                      if (claimResult.value == ClaimResult.received) ...[
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: claimAmountController,
                          hintText: "Claim Amount *",
                          prefixIcon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ],

                    // Show Remarks field if NOT_CLAIMED
                    if (claimStatus.value == ClaimStatus.notClaimed) ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: remarksController,
                        hintText: "Remarks (Mandatory) *",
                        prefixIcon: Icons.note_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 24),

            // Submit Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: returnController.isLoading.value
                    ? null
                    : () async {
                  // Validation
                  if (selectedProduct.value == null) {
                    AppAlerts.error("Please select a product");
                    return;
                  }

                  final qty = int.tryParse(qtyController.text) ?? 0;
                  if (qty <= 0) {
                    AppAlerts.error("Please enter valid quantity");
                    return;
                  }

                  if (condition.value == null) {
                    AppAlerts.error("Please select condition");
                    return;
                  }

                  // Additional validation for DAMAGED
                  if (condition.value == ReturnCondition.damaged) {
                    if (claimStatus.value == null) {
                      AppAlerts.error("Please select claim status");
                      return;
                    }

                    if (claimStatus.value == ClaimStatus.claimed) {
                      if (claimResult.value == null) {
                        AppAlerts.error("Please select claim result");
                        return;
                      }

                      if (claimResult.value == ClaimResult.received) {
                        final claimAmount =
                            int.tryParse(claimAmountController.text) ??
                                0;
                        if (claimAmount <= 0) {
                          AppAlerts.error(
                              "Please enter valid claim amount");
                          return;
                        }
                      }
                    }

                    if (claimStatus.value == ClaimStatus.notClaimed) {
                      if (remarksController.text.trim().isEmpty) {
                        AppAlerts.error(
                            "Remarks are mandatory for NOT CLAIMED status");
                        return;
                      }
                    }
                  }

                  // Create CourierReturnRequest
                  try {
                    final request = CourierReturnRequest(
                      order: order.id,
                      product: selectedProduct.value!.product.id,
                      quantity: qty,
                      condition: condition.value!,
                      claimStatus: claimStatus.value,
                      claimResult: claimResult.value,
                      claimAmount:
                      claimResult.value == ClaimResult.received
                          ? int.tryParse(claimAmountController.text)
                          : null,
                      remarks:
                      claimStatus.value == ClaimStatus.notClaimed
                          ? remarksController.text.trim()
                          : null,
                    );

                    // Convert to JSON and call API
                    final payload = request.toJson();

                    // ✅ Call ReturnController API with callback to refresh orders
                    await returnController.courierReturn(
                      body: payload,
                      onSuccess: () {
                        // Refresh order list after success
                        orderController.getOrderList();
                      },
                    );
                  } catch (e) {
                    AppAlerts.error(e.toString());
                  }
                },
                child: returnController.isLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "Submit Courier Return",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    isDismissible: true,
  );
}