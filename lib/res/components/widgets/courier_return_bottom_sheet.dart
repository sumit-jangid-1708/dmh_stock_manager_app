import 'package:dmj_stock_manager/model/courier_return/courier_enums.dart';
import 'package:dmj_stock_manager/model/order_models/order_model.dart';
import 'package:dmj_stock_manager/res/routes/routes_names.dart';
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
  final returnChargesController = TextEditingController();
  final remarksController = TextEditingController();
  final reasonDetailsController = TextEditingController();

  final condition = Rx<ReturnCondition?>(null);
  final claimStatus = "NOT_CLAIMED".obs;
  final approvalStatus = "APPROVED".obs;
  final receiveDate = Rx<DateTime?>(DateTime.now());
  final returnReason = "".obs;

  final conditions = [ReturnCondition.safe, ReturnCondition.damaged];

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
            Obx(
              () => DropdownButtonFormField<OrderItem>(
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
                      "${item.name} (Qty: ${item.quantity})",
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedProduct.value = val;
                  qtyController.clear();
                  condition.value = null;
                  claimStatus.value = "NOT_CLAIMED";
                  approvalStatus.value = "APPROVED";
                  claimAmountController.clear();
                  returnChargesController.clear();
                  reasonDetailsController.clear();
                  remarksController.clear();
                },
              ),
            ),

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
            Obx(
              () => DropdownButtonFormField<ReturnCondition>(
                value: condition.value,
                decoration: Utils.inputDecoration(
                  "Condition *",
                  Icons.info_outline,
                ),
                hint: const Text("Select condition"),
                items: conditions.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c.apiValue));
                }).toList(),
                onChanged: (val) {
                  condition.value = val;
                  claimStatus.value = "NOT_CLAIMED";
                  approvalStatus.value = "APPROVED";
                  claimAmountController.clear();
                  returnChargesController.clear();
                  reasonDetailsController.clear();
                  remarksController.clear();
                },
              ),
            ),

            const SizedBox(height: 16),

            Obx(() => DropdownButtonFormField<String>(
                  value: claimStatus.value,
                  decoration: Utils.inputDecoration(
                    "Claim Status *",
                    Icons.verified_outlined,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "NOT_CLAIMED",
                      child: Text("Not Claimed"),
                    ),
                    DropdownMenuItem(value: "CLAIMED", child: Text("Claimed")),
                  ],
                  onChanged: (val) {
                    if (val == null) return;
                    claimStatus.value = val;
                    approvalStatus.value = "APPROVED";
                    claimAmountController.clear();
                  },
                )),

            Obx(() {
              if (claimStatus.value != "CLAIMED") {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: DropdownButtonFormField<String>(
                  value: approvalStatus.value,
                  decoration: Utils.inputDecoration(
                    "Approval Status *",
                    Icons.assignment_turned_in_outlined,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "APPROVED",
                      child: Text("Approved"),
                    ),
                    DropdownMenuItem(
                      value: "NOT_APPROVED",
                      child: Text("Not Approved"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) approvalStatus.value = val;
                  },
                ),
              );
            }),

            const SizedBox(height: 16),
            AppTextField(
              controller: claimAmountController,
              hintText: "Return Amount",
              prefixIcon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),
            AppTextField(
              controller: returnChargesController,
              hintText: "Return Charges",
              prefixIcon: Icons.receipt_long_outlined,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),
            Obx(
              () => InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: receiveDate.value ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) receiveDate.value = picked;
                },
                child: InputDecorator(
                  decoration: Utils.inputDecoration(
                    "Receive Date",
                    Icons.calendar_today_outlined,
                  ),
                  child: Text(
                    receiveDate.value == null
                        ? "Select date"
                        : "${receiveDate.value!.year.toString().padLeft(4, '0')}-${receiveDate.value!.month.toString().padLeft(2, '0')}-${receiveDate.value!.day.toString().padLeft(2, '0')}",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
                  value: returnReason.value.isEmpty ? null : returnReason.value,
                  decoration: Utils.inputDecoration(
                    "Return Reason",
                    Icons.report_problem_outlined,
                  ),
                  hint: const Text("Select Return Reason"),
                  items: const [
                    DropdownMenuItem(
                      value: "AGENT_ERROR",
                      child: Text("Agent Error"),
                    ),
                    DropdownMenuItem(
                      value: "LACK_OF_STOCK",
                      child: Text("Lack of Stock"),
                    ),
                  ],
                  onChanged: (val) => returnReason.value = val ?? "",
                )),

            const SizedBox(height: 16),
            AppTextField(
              controller: reasonDetailsController,
              hintText: "Optional reason details",
              prefixIcon: Icons.note_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 16),
            AppTextField(
              controller: remarksController,
              hintText: "Remarks",
              prefixIcon: Icons.edit_note_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Submit Button
            Obx(
              () => SizedBox(
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

                          try {
                            final reasonText =
                                reasonDetailsController.text.trim();
                            final payload = <String, dynamic>{
                              "order": order.id,
                              "product": selectedProduct.value!.productId,
                              "quantity": qty,
                              "condition": condition.value!.apiValue,
                              "claim_status": claimStatus.value,
                              if (claimStatus.value == "CLAIMED")
                                "claim": approvalStatus.value
                                    .toLowerCase()
                                    .replaceAll("_", " "),
                              if (claimAmountController.text.trim().isNotEmpty)
                                "claim_amount": double.tryParse(
                                      claimAmountController.text.trim(),
                                    ) ??
                                    0,
                              if (returnChargesController.text
                                  .trim()
                                  .isNotEmpty)
                                "return_charges": double.tryParse(
                                      returnChargesController.text.trim(),
                                    ) ??
                                    0,
                              if (receiveDate.value != null)
                                "return_recive_date":
                                    "${receiveDate.value!.year.toString().padLeft(4, '0')}-${receiveDate.value!.month.toString().padLeft(2, '0')}-${receiveDate.value!.day.toString().padLeft(2, '0')}",
                              if (returnReason.value == "AGENT_ERROR")
                                "agent_error": reasonText.isEmpty
                                    ? "Agent error"
                                    : reasonText,
                              if (returnReason.value == "LACK_OF_STOCK")
                                "lack_of_stock": reasonText.isEmpty
                                    ? "Lack of stock"
                                    : reasonText,
                              if (remarksController.text.trim().isNotEmpty)
                                "rmark": remarksController.text.trim(),
                            };

                            // ✅ Call ReturnController API with callback to refresh orders
                            await returnController.courierReturn(
                              body: payload,
                              onSuccess: () {
                                orderController.updateOrderStatus(
                                  orderId: order.id,
                                  status: 6,
                                  note: "Courier Return",
                                );
                                // Refresh order list after success
                                orderController.getOrderList();
                                Get.toNamed(RouteName.returnScreen);
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
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    isDismissible: true,
  );
}
