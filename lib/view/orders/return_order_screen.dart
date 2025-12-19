import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/controller/home_controller.dart';
import '../../view_models/controller/order_controller.dart';

class ReturnOrderHistoryScreen extends StatelessWidget {
  ReturnOrderHistoryScreen({super.key});

  final OrderController controller = Get.find<OrderController>();
  final HomeController homeController = Get.find<HomeController>();
  final ItemController itemController = Get.find<ItemController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey.shade500),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                "Return Orders History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // 🔽 Filter Row
              Row(
                children: [
                  // Condition Dropdown
                  Obx(() {
                    return DropdownButton<String>(
                      value: controller.selectedCondition.value.isEmpty
                          ? null
                          : controller.selectedCondition.value,
                      hint: const Text("Condition"),
                      items: ["OK", "DAMAGED", "LOST"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) {
                        controller.selectedCondition.value = val ?? "";
                        controller.getReturnOrderHistory(
                          controller.selectedReason.value,
                          controller.selectedCondition.value,
                        );
                      },
                    );
                  }),
                  const SizedBox(width: 15),

                  // Reason Dropdown
                  Obx(() {
                    return DropdownButton<String>(
                      value: controller.selectedReason.value.isEmpty
                          ? null
                          : controller.selectedReason.value,
                      hint: const Text("Reason"),
                      items: ["RETURN", "WPS"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) {
                        controller.selectedReason.value = val ?? "";
                        controller.getReturnOrderHistory(
                          controller.selectedReason.value,
                          controller.selectedCondition.value,
                        );
                      },
                    );
                  }),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      controller.selectedReason.value = "";
                      controller.selectedCondition.value = "";
                      controller.returnOrders.clear();
                    },
                    child: const Text("Clear Filter"),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 🔄 List of Return Orders
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.returnOrders.isEmpty) {
                    return const Center(child: Text("No return orders found"));
                  }

                  return ListView.builder(
                    itemCount: controller.returnOrders.length,
                    itemBuilder: (context, index) {
                      final order = controller.returnOrders[index];
                      final productName =
                          itemController.products
                              .firstWhereOrNull((p) => p.id == order.product)
                              ?.name ??
                          "Product #${order.product}";

                      // ✅ channel name resolve via homeController
                      final channelName =
                          homeController.getChannelNameById(
                            order.channel ?? -1,
                          ) ??
                          "N/A";
                      final dateTime = DateTime.parse(order.createdAt ?? "");

                      // Format: DD-MM-YYYY, HH:MM
                      final formattedDate =
                          "${dateTime.day.toString().padLeft(2, '0')}-"
                          "${dateTime.month.toString().padLeft(2, '0')}-"
                          "${dateTime.year}, "
                          "${dateTime.hour.toString().padLeft(2, '0')}:"
                          "${dateTime.minute.toString().padLeft(2, '0')}";

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Product: $productName",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Channel: $channelName"),
                              const SizedBox(height: 6),
                              Text("Condition: ${order.condition}"),
                              Text("Reason: ${order.reason}"),
                              Text("Quantity: ${order.delta}"),
                              Text("Date: $formattedDate")
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
