import 'package:dmj_stock_manager/view/orders/order_detail_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'order_create_bottom_sheet.dart';

class OrderScreen extends StatelessWidget {
  final OrderController orderController = Get.put(OrderController());
  OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await orderController.getOrderList();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Container(
                      //   width: 40,
                      //   height: 40,
                      //   decoration: BoxDecoration(
                      //     border: Border.all(
                      //       width: 1,
                      //       color: Colors.grey.shade500,
                      //     ),
                      //     borderRadius: BorderRadius.circular(50),
                      //   ),
                      //   child: IconButton(
                      //     icon: const Icon(Icons.arrow_back),
                      //     onPressed: () {
                      //       Get.back();
                      //     },
                      //   ),
                      // ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A4F),
                          fixedSize: const Size(100, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            elevation: 10,
                            context: context,
                            isScrollControlled:
                                true, // for full screen height support
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return OrderCreateBottomSheet();
                            },
                          );
                        },
                        child: const Text(
                          "Create",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 60,
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "Orders List",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    if (orderController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (orderController.orders.isEmpty) {
                      return const Center(child: Text("No orders found"));
                    }

                    return ListView.builder(
                      shrinkWrap: true, // 👈 important
                      physics:
                          const NeverScrollableScrollPhysics(), // 👈 disable inner scroll
                      // padding: const EdgeInsets.all(12),
                      itemCount: orderController.orders.length,
                      itemBuilder: (context, index) {
                        final order = orderController.orders[index];
                        return Card(
                          color: Colors.white,
                          // margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              "Order #${order.id}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              "Customer: ${order.customerName}\n"
                              "${(order.mobile != null && order.mobile != '0') ? "Mobile: ${(order.countryCode ?? '')}${order.mobile}\n" : ""}"
                              "Date: ${order.createdAt.toLocal().toString().split(' ')[0]}",
                            ),
                            trailing: Text(
                              order.remarks,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              if (order != null) {
                                // Make sure 'order' is an OrderDetailModel, not OrderModel
                                Get.to(
                                  () => const OrderDetailScreen(),
                                  arguments: order,
                                );
                              } else {
                                Get.snackbar("Error", "Order details missing");
                              }
                            },
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
