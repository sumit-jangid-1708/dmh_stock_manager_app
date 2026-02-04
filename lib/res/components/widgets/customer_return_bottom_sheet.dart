import 'package:dmj_stock_manager/model/customer_return/customer_return_enum.dart';
import 'package:dmj_stock_manager/model/customer_return/customer_return_request.dart';
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
  final reasonController = TextEditingController();

  final condition = Rx<CustomerReturnCondition?>(null);
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
                refundAmountController.text = "0";
                reasonController.clear();
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
                refundAmountController.text="";
              },
            )),

            const SizedBox(height: 16),

            // Refund Amount
            AppTextField(
              controller: refundAmountController,
              hintText: "Refund Amount *",
              prefixIcon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Reason
            AppTextField(
              controller: reasonController,
              hintText: "Reason for Return *",
              prefixIcon: Icons.note_outlined,
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
                        isSafe ? Icons.info_outline : Icons.warning_amber_rounded,
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
                  final refundText = refundAmountController.text.trim();
                  if (refundText.isEmpty) {
                    AppAlerts.error("Please enter refund amount");
                    return;
                  }
                  final refundAmount = double.parse(refundText);

                  if (refundAmount <= 0) {
                    AppAlerts.error("Refund amount must be greater than 0");
                    return;
                  }

                  if (reasonController.text.trim().isEmpty) {
                    AppAlerts.error("Please provide reason for return");
                    return;
                  }

                  // Create CustomerReturnRequest
                  final request = CustomerReturnRequest(
                    orderId: order.id,
                    productId: selectedProduct.value!.product.id,
                    channelId: order.channel,
                    quantity: qty,
                    condition: condition.value!,
                    refundAmount: refundAmount,
                    reason: reasonController.text.trim(),
                  );

                  // ✅ Call ReturnController API with callback to refresh orders
                  await returnController.customerReturn(
                    request: request,
                    onSuccess: () {
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