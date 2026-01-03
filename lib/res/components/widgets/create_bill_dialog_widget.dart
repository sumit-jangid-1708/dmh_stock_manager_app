import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


void showCreateBillDialog(BuildContext context, int orderId) {
  final OrderController controller = Get.put(OrderController());
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  bool isTablet = screenWidth > 600;

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.only(left: 20, right: 5, top: 15, bottom: 10),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Create Bill",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          )
        ],
      ),
      content: Obx(() {
        // ✅ Show loading indicator when API is calling
        if (controller.isLoading.value) {
          return SizedBox(
            width: isTablet ? screenWidth * 0.4 : screenWidth * 0.8,
            height: 200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Creating bill..."),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          width: isTablet ? screenWidth * 0.4 : screenWidth * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Payment Method
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Payment Method",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Column(
                  children: [
                    _paymentRadio(controller, "NET_BANKING", "Net Banking"),
                    _paymentRadio(controller, "UPI", "UPI"),
                    _paymentRadio(controller, "CASH", "Cash"),
                  ],
                ),

                const SizedBox(height: 8),

                // Payment Date Picker
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: controller.paymentDate.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        controller.paymentDate.value = pickedDate;
                      }
                    },
                    child: Text(
                      "Select Date: ${DateFormat('yyyy-MM-dd').format(controller.paymentDate.value)}",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Paid Status
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Paid Status",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Column(
                  children: [
                    _statusRadio(controller, "PAID", "Paid"),
                    _statusRadio(controller, "UNPAID", "Unpaid"),
                  ],
                ),

                const SizedBox(height: 10),

                // Transaction ID (Optional)
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Transaction ID (Optional)",
                    border: OutlineInputBorder(),
                    hintText: "Enter transaction ID",
                  ),
                  onChanged: (value) => controller.transactionId.value = value,
                ),
              ],
            ),
          ),
        );
      }),

      actions: [
        Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A4F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: isTablet ? 16 : 12,
            ),
          ),
          // ✅ Disable button when loading
          onPressed: controller.isLoading.value
              ? null
              : () async {
            debugPrint("Submitted Data:");
            debugPrint("Payment Method: ${controller.selectedMethod.value}");
            debugPrint("Date: ${controller.paymentDate.value}");
            debugPrint("Status: ${controller.paidStatus.value}");
            debugPrint("Transaction ID: ${controller.transactionId.value}");

            // ✅ Call API - dialog will auto close in controller
            await controller.createOrderBill(orderId);

            Get.back();
          },
          child: controller.isLoading.value
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Text(
            "Create Bill",
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 16 : 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        )),
      ],
    ),
  );
}

Widget _paymentRadio(OrderController controller, String value, String text) {
  return RadioListTile(
    value: value,
    groupValue: controller.selectedMethod.value,
    onChanged: (v) => controller.selectedMethod.value = v.toString(),
    title: Text(text),
  );
}

Widget _statusRadio(OrderController controller, String value, String text) {
  return RadioListTile(
    value: value,
    groupValue: controller.paidStatus.value,
    onChanged: (v) => controller.paidStatus.value = v.toString(),
    title: Text(text),
  );
}