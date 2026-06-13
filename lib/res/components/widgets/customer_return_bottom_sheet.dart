import 'package:dmj_stock_manager/model/customer_return/customer_return_enum.dart';
import 'package:dmj_stock_manager/model/order_models/order_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/utils/utils.dart';
import 'package:dmj_stock_manager/view_models/controller/return_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes_names.dart';
import 'custom_text_field.dart';

void showCustomerReturnDialog(BuildContext context, OrderDetailModel order) {
  final returnController = Get.find<ReturnController>();
  final orderController = Get.find<OrderController>();

  final selectedProduct = Rx<OrderItem?>(null);
  final qtyController = TextEditingController();
  final refundAmountController = TextEditingController();
  final returnChargesController = TextEditingController();
  final reasonController = TextEditingController();
  final remarksController = TextEditingController();

  final condition = Rx<CustomerReturnCondition?>(null);
  final claimStatus = "NOT_CLAIMED".obs;
  final approvalStatus = "APPROVED".obs;
  final receiveDate = Rx<DateTime?>(DateTime.now());
  final returnReason = "".obs;
  final conditions = [
    CustomerReturnCondition.safe,
    CustomerReturnCondition.damaged,
    CustomerReturnCondition.lost,
  ];

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
                  Icons.person_outline,
                  color: Color(0xFF1A1A4F),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  "Customer Return",
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
                isExpanded: true,
                value: selectedProduct.value,
                decoration: Utils.inputDecoration(
                  "Select Product *",
                  Icons.inventory_2_outlined,
                ),
                hint: const Text("Choose a product"),
                items: order.items.map((item) {
                  return DropdownMenuItem<OrderItem>(
                    value: item,
                    child: Text(
                      "${item.name} (Qty: ${item.quantity})",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedProduct.value = val;
                  qtyController.clear();
                  condition.value = null;
                  refundAmountController.text = "0";
                  returnChargesController.clear();
                  reasonController.clear();
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
            Obx(() => DropdownButtonFormField<CustomerReturnCondition>(
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
                    refundAmountController.text = "";
                    returnChargesController.clear();
                    reasonController.clear();
                    remarksController.clear();
                  },
                )),

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

            // Refund Amount
            AppTextField(
              controller: refundAmountController,
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
                    DropdownMenuItem(
                      value: "CUSTOMER_ERROR",
                      child: Text("Customer Error"),
                    ),
                  ],
                  onChanged: (val) => returnReason.value = val ?? "",
                )),

            const SizedBox(height: 16),

            // Reason
            AppTextField(
              controller: reasonController,
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

            // Info Card
            Obx(() {
              if (condition.value != null) {
                final isSafe = condition.value == CustomerReturnCondition.safe;
                return Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSafe ? Colors.blue.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSafe
                          ? Colors.blue.shade200
                          : Colors.orange.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSafe
                            ? Icons.info_outline
                            : Icons.warning_amber_rounded,
                        color: isSafe
                            ? Colors.blue.shade700
                            : Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${condition.value!.apiValue}: Enter refund amount and reason",
                          style: TextStyle(
                            fontSize: 12,
                            color: isSafe
                                ? Colors.blue.shade700
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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

                            // final refundAmount =
                            //     double.tryParse(refundAmountController.text) ?? 0;
                            final reasonText = reasonController.text.trim();
                            final selectedReason = returnReason.value;
                            final body = <String, dynamic>{
                              "order_id": order.id,
                              "product_id": selectedProduct.value!.productId,
                              "quantity": qty,
                              "condition": condition.value!.apiValue,
                              "claim_status": claimStatus.value,
                              if (claimStatus.value == "CLAIMED")
                                "claim": approvalStatus.value
                                    .toLowerCase()
                                    .replaceAll("_", " "),
                              if (refundAmountController.text.trim().isNotEmpty)
                                "claim_amount": double.tryParse(
                                      refundAmountController.text.trim(),
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
                              if (selectedReason == "AGENT_ERROR")
                                "agent_error": reasonText.isEmpty
                                    ? "Agent error"
                                    : reasonText,
                              if (selectedReason == "LACK_OF_STOCK")
                                "lack_of_stock": reasonText.isEmpty
                                    ? "Lack of stock"
                                    : reasonText,
                              if (selectedReason == "CUSTOMER_ERROR")
                                "customer_error": reasonText.isEmpty
                                    ? "Customer error"
                                    : reasonText,
                              if (remarksController.text.trim().isNotEmpty)
                                "rmark": remarksController.text.trim(),
                            };

                            // ✅ Call ReturnController API with callback to refresh orders
                            await returnController.customerReturnRaw(
                              body: body,
                              onSuccess: () {
                                orderController.updateOrderStatus(
                                  orderId: order.id,
                                  status: 7,
                                  note: "Customer Return",
                                );
                                // Refresh order list after success
                                orderController.getOrderList();
                                Get.toNamed(RouteName.returnScreen);
                              },
                            );
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
                            "Submit Customer Return",
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
