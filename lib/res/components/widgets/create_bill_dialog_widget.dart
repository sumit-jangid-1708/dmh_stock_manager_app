import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

void showCreateBillDialog(BuildContext context, int orderId) {
  final OrderController controller = Get.put(OrderController());
  double screenWidth = MediaQuery.of(context).size.width;
  bool isTablet = screenWidth > 600;
  const Color primaryColor = Color(0xFF1A1A4F);

  Get.dialog(
    AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 12, 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Create Bill",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Get.back(),
            )
          ],
        ),
      ),
      content: Obx(() {
        if (controller.isLoading.value) {
          return SizedBox(
            width: isTablet ? screenWidth * 0.4 : screenWidth * 0.85,
            height: 250,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 20),
                  Text("Processing Transaction...", style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          width: isTablet ? screenWidth * 0.4 : screenWidth * 0.85,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Method Section
                _sectionHeader("Payment Method"),
                const SizedBox(height: 10),
                _buildPaymentOption(controller, "NET_BANKING", "Net Banking", Icons.account_balance_outlined),
                _buildPaymentOption(controller, "UPI", "UPI Transfer", Icons.qr_code_scanner_rounded),
                _buildPaymentOption(controller, "CASH", "Cash Payment", Icons.payments_outlined),

                const SizedBox(height: 20),

                // Date Selection
                _sectionHeader("Transaction Date"),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: controller.paymentDate.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) controller.paymentDate.value = pickedDate;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18, color: primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd MMMM, yyyy').format(controller.paymentDate.value),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Status Selection
                _sectionHeader("Payment Status"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildStatusChip(controller, "PAID", "Paid", Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatusChip(controller, "UNPAID", "Unpaid", Colors.orange)),
                  ],
                ),

                const SizedBox(height: 24),

                // Transaction ID
                TextField(
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: "Transaction ID (Optional)",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.receipt_long_outlined, color: primaryColor),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 1.5),
                    ),
                    hintText: "Enter ID if available",
                  ),
                  onChanged: (value) => controller.transactionId.value = value,
                ),
              ],
            ),
          ),
        );
      }),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: AppGradientButton(
            onPressed: controller.isLoading.value ? null : () async {
              await controller.createOrderBill(orderId);
              Get.back();
            },
            text: "Generate Invoice",
          ),
        ))
      ],
    ),
  );
}

// Attractive Header Helper
Widget _sectionHeader(String title) {
  return Text(
    title.toUpperCase(),
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: Colors.grey.shade600,
      letterSpacing: 1.1,
    ),
  );
}

// Attractive Payment Tile Helper
Widget _buildPaymentOption(OrderController controller, String value, String text, IconData icon) {
  bool isSelected = controller.selectedMethod.value == value;
  const Color primaryColor = Color(0xFF1A1A4F);

  return GestureDetector(
    onTap: () => controller.selectedMethod.value = value,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? primaryColor : Colors.grey),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? primaryColor : Colors.black87,
            ),
          ),
          const Spacer(),
          if (isSelected) const Icon(Icons.check_circle, color: primaryColor, size: 20),
        ],
      ),
    ),
  );
}

// Attractive Status Chip Helper
Widget _buildStatusChip(OrderController controller, String value, String text, Color color) {
  bool isSelected = controller.paidStatus.value == value;

  return GestureDetector(
    onTap: () => controller.paidStatus.value = value,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}