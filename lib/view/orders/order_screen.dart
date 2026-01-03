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
      backgroundColor: Colors.grey.shade50,
      // Using a Floating Action Button to keep the top of the screen completely clean
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A1A4F),
        onPressed: () => _showCreateOrderSheet(context),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Minimalist Text Header ---
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Orders",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A4F),
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    "View and manage your recent transactions",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // --- Orders List ---
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF1A1A4F),
                onRefresh: () async => await orderController.getOrderList(),
                child: Obx(() {
                  if (orderController.isLoading.value && orderController.orders.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (orderController.orders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: orderController.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderController.orders[index];
                      return _buildOrderCard(order);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        onTap: () => Get.to(() => const OrderDetailScreen(), arguments: order),
        // Circle leading with Order Initial
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A4F).withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.receipt_long_rounded, color: Color(0xFF1A1A4F)),
          ),
        ),
        title: Text(
          order.customerName ?? "Unknown Customer",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ID: #${order.id} • ${order.createdAt.toLocal().toString().split(' ')[0]}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              // Tiny status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.remarks?.toUpperCase() ?? "COMPLETED",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No orders found",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showCreateOrderSheet(BuildContext context) {
    Get.bottomSheet(
      OrderCreateBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
    );
  }
}



// import 'package:dmj_stock_manager/view/orders/order_detail_screen.dart';
// import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import 'order_create_bottom_sheet.dart';
//
// class OrderScreen extends StatelessWidget {
//   final OrderController orderController = Get.put(OrderController());
//   OrderScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             await orderController.getOrderList();
//           },
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 20.0,
//                 vertical: 20.0,
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // Container(
//                       //   width: 40,
//                       //   height: 40,
//                       //   decoration: BoxDecoration(
//                       //     border: Border.all(
//                       //       width: 1,
//                       //       color: Colors.grey.shade500,
//                       //     ),
//                       //     borderRadius: BorderRadius.circular(50),
//                       //   ),
//                       //   child: IconButton(
//                       //     icon: const Icon(Icons.arrow_back),
//                       //     onPressed: () {
//                       //       Get.back();
//                       //     },
//                       //   ),
//                       // ),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF1A1A4F),
//                           fixedSize: const Size(100, 40),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () {
//                           showModalBottomSheet(
//                             elevation: 10,
//                             context: context,
//                             isScrollControlled:
//                                 true, // for full screen height support
//                             shape: const RoundedRectangleBorder(
//                               borderRadius: BorderRadius.vertical(
//                                 top: Radius.circular(20),
//                               ),
//                             ),
//                             builder: (context) {
//                               return OrderCreateBottomSheet();
//                             },
//                           );
//                         },
//                         child: const Text(
//                           "Create",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     height: 60,
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: const Row(
//                       children: [
//                         Text(
//                           "Orders List",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Obx(() {
//                     if (orderController.isLoading.value) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//
//                     if (orderController.orders.isEmpty) {
//                       return const Center(child: Text("No orders found"));
//                     }
//
//                     return ListView.builder(
//                       shrinkWrap: true, // 👈 important
//                       physics:
//                           const NeverScrollableScrollPhysics(), // 👈 disable inner scroll
//                       // padding: const EdgeInsets.all(12),
//                       itemCount: orderController.orders.length,
//                       itemBuilder: (context, index) {
//                         final order = orderController.orders[index];
//                         return _buildOrderCard(order);
//                         // return Card(
//                         //   color: Colors.white,
//                         //   // margin: const EdgeInsets.only(bottom: 12),
//                         //   shape: RoundedRectangleBorder(
//                         //     borderRadius: BorderRadius.circular(12),
//                         //   ),
//                         //   child: ListTile(
//                         //     title: Text(
//                         //       "Order #${order.id}",
//                         //       style: const TextStyle(
//                         //         fontSize: 16,
//                         //         color: Colors.black,
//                         //         fontWeight: FontWeight.w500,
//                         //       ),
//                         //     ),
//                         //     subtitle: Text(
//                         //       "Customer: ${order.customerName}\n"
//                         //       "${(order.mobile != null && order.mobile != '0') ? "Mobile: ${(order.countryCode ?? '')}${order.mobile}\n" : ""}"
//                         //       "Date: ${order.createdAt.toLocal().toString().split(' ')[0]}",
//                         //     ),
//                         //     trailing: Text(
//                         //       order.remarks,
//                         //       style: const TextStyle(
//                         //         color: Colors.green,
//                         //         fontWeight: FontWeight.bold,
//                         //       ),
//                         //     ),
//                         //     onTap: () {
//                         //       if (order != null) {
//                         //         // Make sure 'order' is an OrderDetailModel, not OrderModel
//                         //         Get.to(
//                         //           () => const OrderDetailScreen(),
//                         //           arguments: order,
//                         //         );
//                         //       } else {
//                         //         Get.snackbar("Error", "Order details missing");
//                         //       }
//                         //     },
//                         //   ),
//                         // );
//                       },
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderCard(dynamic order) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 20,
//           vertical: 10,
//         ),
//         onTap: () => Get.to(() => const OrderDetailScreen(), arguments: order),
//         // Circle leading with Order Initial
//         leading: Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: const Color(0xFF1A1A4F).withOpacity(0.05),
//             shape: BoxShape.circle,
//           ),
//           child: const Center(
//             child: Icon(Icons.receipt_long_rounded, color: Color(0xFF1A1A4F)),
//           ),
//         ),
//         title: Text(
//           order.customerName ?? "Unknown Customer",
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: Colors.black87,
//           ),
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "ID: #${order.id} • ${order.createdAt.toLocal().toString().split(' ')[0]}",
//                 style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//               ),
//               const SizedBox(height: 8),
//               // Tiny status pill
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   order.remarks?.toUpperCase() ?? "COMPLETED",
//                   style: const TextStyle(
//                     color: Colors.green,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//       ),
//     );
//   }
// }
