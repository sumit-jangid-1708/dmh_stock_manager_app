import 'package:dmj_stock_manager/model/order_model.dart';
import 'package:dmj_stock_manager/view_models/controller/home_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../res/components/widgets/create_bill_dialog_widget.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args == null || args is! OrderDetailModel) {
      return const Scaffold(body: Center(child: Text("Order details missing")));
    }
    final order = args as OrderDetailModel;
    final orderController = Get.find<OrderController>();
    final homeController = Get.find<HomeController>();
    final vendorController = Get.find<VendorController>();

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => await orderController.getOrderList(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎨 Header with Back & Create Bill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 20),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => showCreateBillDialog(context, order.id),
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: const Text("Create Bill"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A4F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 📝 Order Header
                const Text(
                  "Order Details",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Order #${order.id} • ${order.createdAt.toLocal().toString().split(' ')[0]}",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 20),

                // 📊 Gradient Stats Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("Total Items", order.items.length.toString(), Icons.shopping_bag),
                      _buildDivider(),
                      _buildStatItem("Channel", homeController.getChannelNameById(order.channel), Icons.store),
                      _buildDivider(),
                      _buildStatItem("Total", "₹${calculateTotalAmount(order).toStringAsFixed(2)}", Icons.currency_rupee),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 👤 Customer Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Customer Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildInfoRow("Name", order.customerName),
                      _buildInfoRow("Mobile", "${order.countryCode ?? ''}${order.mobile ?? ''}"),
                      _buildInfoRow("Remarks", order.remarks ?? "No remarks"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 📦 Items List Header
                const Text(
                  "Ordered Items",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 📋 Items List (Beautiful Cards like LowStockScreen)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    final product = item.product;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                if (product.productImageVariants.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      "https://traders.testwebs.in${product.productImageVariants.first}",
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 70,
                                        width: 70,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name ?? "Unnamed Product",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text("SKU: ${product.sku}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                      Text("Vendor: ${vendorController.getVendorNameById(product.vendor)}",
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                      Text("Size: ${product.size} | Color: ${product.color} | Material: ${product.material}",
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Quantity", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    Text("${item.quantity}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Unit Price", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    Text("₹${item.unitPrice}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Subtotal", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    Text("₹${(double.tryParse(item.unitPrice.toString()) ?? 0) * (item.quantity ?? 0)}",
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F))),
                                  ],
                                ),
                              ],
                            ),
                            if (product.barcodeImage != null && product.barcodeImage!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Image.network(
                                    "https://traders.testwebs.in${product.barcodeImage!}",
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🔄 Return Buttons (Same style as LowStockScreen)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => showReturnDialog(context, order, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A4F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Courier Return", style: TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => showReturnDialog(context, order, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A4F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Customer Return", style: TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets (Same as LowStockScreen)
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildDivider() => Container(height: 40, width: 1, color: Colors.white24);

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value.isEmpty ? "-" : value),
          ],
        ),
      ),
    );
  }
}
//
// double calculateTotalAmount(OrderDetailModel order) {
//   double total = 0;
//   for (var item in order.items) {
//     final unitPrice = double.tryParse(item.unitPrice.toString()) ?? 0;
//     final quantity = item.quantity ?? 0;
//     total += unitPrice * quantity;
//   }
//   return total;
// }

// showReturnDialog function same as before (you can keep it)

double calculateTotalAmount(OrderDetailModel order) {
  double total = 0;
  for (var item in order.items) {
    final unitPrice = double.tryParse(item.unitPrice.toString()) ?? 0;
    final quantity = item.quantity ?? 0;
    total += unitPrice * quantity;
  }
  return total;
}

void showReturnDialog(BuildContext context, OrderDetailModel order, bool isWps) {
  final conditions = ["OK", "DAMAGED", "LOST"];
  final selectedItems = <int, Map<String, dynamic>>{}.obs;
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final isTablet = screenWidth >= 600;

  Get.bottomSheet(
    DraggableScrollableSheet(
      expand: false,
      initialChildSize: isTablet ? 0.7 : 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Return Items",
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    final qtyController = TextEditingController(text: "0");

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Obx(() {
                                  return Checkbox(
                                    value: selectedItems.containsKey(item.product.id),
                                    onChanged: (val) {
                                      if (val == true) {
                                        selectedItems[item.product.id!] = {
                                          "quantity": 0,
                                          "condition": "OK",
                                        };
                                      } else {
                                        selectedItems.remove(item.product.id!);
                                      }
                                    },
                                  );
                                }),
                                Expanded(
                                  child: Text(
                                    "${item.product.name} (Ordered: ${item.quantity})",
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextField(
                              controller: qtyController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Return Quantity",
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03,
                                  vertical: isTablet ? 12 : 8,
                                ),
                                labelStyle: TextStyle(fontSize: isTablet ? 14 : 12),
                              ),
                              style: TextStyle(fontSize: isTablet ? 14 : 12),
                              onChanged: (val) {
                                if (selectedItems.containsKey(item.product.id)) {
                                  selectedItems[item.product.id]!["quantity"] =
                                      int.tryParse(val) ?? 0;
                                }
                              },
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Obx(() {
                              return DropdownButtonFormField<String>(
                                value: selectedItems[item.product.id]?["condition"],
                                decoration: InputDecoration(
                                  labelText: "Condition",
                                  border: const OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03,
                                    vertical: isTablet ? 12 : 8,
                                  ),
                                  labelStyle: TextStyle(fontSize: isTablet ? 14 : 12),
                                ),
                                style: TextStyle(fontSize: isTablet ? 14 : 12),
                                items: conditions
                                    .map((c) => DropdownMenuItem(
                                          value: c,
                                  child: Text(
                                    c,
                                    style: TextStyle(fontSize: isTablet ? 14 : 12),
                                  ),
                                ))
                                    .toList(),
                                onChanged: (val) {
                                  if (selectedItems.containsKey(item.product.id)) {
                                    selectedItems[item.product.id]!["condition"] =
                                        val ?? "OK";
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 150,
                      maxWidth: screenWidth * 0.5,
                    ),
                    child: ElevatedButton(
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
                      onPressed: () {
                        if (selectedItems.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Please select at least one product",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        selectedItems.forEach((productId, data) {
                          final qty = data["quantity"] as int;
                          final orderId = order.id;
                          print("this is the order id 🤢🌠🌠🌠 ${orderId}");
                          final channelId = order.channel;
                          print("this is the channel id 🤢🕑👻🌠🌠🌠 ${channelId}");
                          final condition = data["condition"] as String;
                          if (isWps) {
                            Get.find<OrderController>().wpsReturn(
                              productId: productId,
                              quantity: qty,
                              condition: condition,
                              orderId: orderId,
                              channelId: channelId,
                            );
                          } else {
                            Get.find<OrderController>().customerReturn(
                              orderId: order.id!,
                              productId: productId,
                              quantity: qty,
                              condition: condition,
                              channelId: order.channel,
                            );
                          }
                        });
                        Get.back();
                        Get.snackbar("Success", "Return submitted successfully ✅");
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 16 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}

// import 'package:dmj_stock_manager/res/app_url/app_url.dart';
// import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:dmj_stock_manager/model/order_model.dart';
//
// import '../../view_models/controller/home_controller.dart';
// import '../../view_models/controller/order_controller.dart'
//     show OrderController;
//
// class OrderDetailScreen extends StatelessWidget {
//   const OrderDetailScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final args = Get.arguments;
//     if (args == null || args is! OrderDetailModel) {
//       return const Scaffold(body: Center(child: Text("Order details missing")));
//     }
//     final order = args as OrderDetailModel;
//     final orderController = Get.find<OrderController>();
//     final homeController = Get.find<HomeController>();
//     final vendorController = Get.find<VendorController>();
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             await orderController.getOrderList();
//           },
//           child: Obx(() {
//             if (orderController.isLoading.value) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             return SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//               child: Column(
//                 children: [
//                   // 🔙 Back Button
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             width: 1,
//                             color: Colors.grey.shade500,
//                           ),
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                         child: IconButton(
//                           icon: const Icon(Icons.arrow_back),
//                           onPressed: () => Get.back(),
//                         ),
//                       ),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           // fixedSize: Size(170, 50),
//                           backgroundColor: const Color(0xFF1A1A4F),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                         onPressed: () {},
//                         child: Text(
//                           "Share Invoice",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 14),
//                   // 📝 Order Header
//                   Container(
//                     height: 60,
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: const Text(
//                       "Order Details",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // 📦 Order Info
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: Color(0xFFf3f3f3),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("Order Id: #${order.id}"),
//                         Text("Customer Name: ${order.customerName}"),
//                         Text(
//                           (order.mobile != null && order.mobile != '0')
//                               ? "Mobile: ${(order.countryCode ?? '')}${order.mobile}"
//                               : "",
//                         ),
//                         Text(
//                           "Channel: ${homeController.getChannelNameById(order.channel)}",
//                         ),
//                         Text(
//                           "Created At: ${order.createdAt.toLocal().toString().split(' ')[0]}",
//                         ),
//                         Text("Remarks: ${order.remarks}"),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   // Items List
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: const Text(
//                       "Items",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 4),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: order.items.length,
//                     itemBuilder: (context, index) {
//                       final item = order.items[index];
//                       final product = item.product;
//
//                       return Container(
//                         margin: const EdgeInsets.symmetric(vertical: 4),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Color(0xffefefef),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             width: 2,
//                             color: Colors.grey.shade300,
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   product.name ?? "Unnamed Product",
//                                   // "Shirt",
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 Text(
//                                   "Serial: ${product.serial} | Qty: ${item.quantity}",
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               "vendor : ${vendorController.getVendorNameById(product.vendor)}",
//                             ),
//                             Text(
//                               "Size: ${product.size} | Color: ${product.color} | Material: ${product.material}",
//                             ),
//                             Text("SKU: ${product.sku}"),
//                             Text("Unit Price: ${item.unitPrice}"),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Subtotal: ${(double.tryParse(item.unitPrice.toString()) ?? 0) * (item.quantity ?? 0)}",
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 if (product!.barcodeImage!.isNotEmpty)
//                                   Image.network(
//                                     "https://traders.testwebs.in${product.barcodeImage!}",
//                                     height: 40,
//                                     width: 100,
//                                     fit: BoxFit.contain,
//                                   ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   // 📑 Footer
//                   Container(
//                     height: 100,
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Total Items: ${order.items.length.toString()}",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         Text(
//                           "Total Amount: ₹${calculateTotalAmount(order).toStringAsFixed(2)}",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             // fixedSize: Size(170, 50),
//                             backgroundColor: const Color(0xFF1A1A4F),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                           ),
//                           onPressed: () {
//                             showReturnDialog(context, order, true);
//                           },
//                           child: Text(
//                             "Courier Return",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             // fixedSize: Size(170, 50),
//                             backgroundColor: const Color(0xFF1A1A4F),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                           ),
//                           onPressed: () {
//                             showReturnDialog(context, order, false);
//                           },
//                           child: Text(
//                             "Customer Return",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
//
// // 👇 Helper function to calculate total
// double calculateTotalAmount(OrderDetailModel order) {
//   double total = 0;
//   for (var item in order.items) {
//     final unitPrice = double.tryParse(item.unitPrice.toString()) ?? 0;
//     final quantity = item.quantity ?? 0;
//     total += unitPrice * quantity;
//   }
//   return total;
// }
//
// void showReturnDialog(
//   BuildContext context,
//   OrderDetailModel order,
//   bool isWps,
// ) {
//   final conditions = ["OK", "DAMAGED", "LOST"];
//
//   // RxMap to store selected products
//   final selectedItems = <int, Map<String, dynamic>>{}.obs;
//
//   Get.bottomSheet(
//     DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 0.6,
//       minChildSize: 0.4,
//       maxChildSize: 0.95,
//       builder: (_, controller) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: SingleChildScrollView(
//             controller: controller,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Select Return Items",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 12),
//
//                 // Product List
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: order.items.length,
//                   itemBuilder: (context, index) {
//                     final item = order.items[index];
//                     final qtyController = TextEditingController(
//                       text: "0",
//                     ); // default 0
//
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 6),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           12,
//                         ), // 🔹 rounded corners
//                         side: const BorderSide(
//                           color: Colors.grey, // 🔹 border color
//                           width: 1.2, // 🔹 border thickness
//                         ),
//                       ),
//                       color: Colors.white,
//                       child: Padding(
//                         padding: const EdgeInsets.all(10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 // ✅ Wrap Checkbox in Obx
//                                 Obx(() {
//                                   return Checkbox(
//                                     value: selectedItems.containsKey(
//                                       item.product.id,
//                                     ),
//                                     onChanged: (val) {
//                                       if (val == true) {
//                                         selectedItems[item.product.id!] = {
//                                           "quantity": 0,
//                                           "condition": "OK",
//                                         };
//                                       } else {
//                                         selectedItems.remove(item.product.id!);
//                                       }
//                                     },
//                                   );
//                                 }),
//                                 Expanded(
//                                   child: Text(
//                                     "${item.product.name} (Ordered: ${item.quantity})",
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//
//                             // Quantity
//                             TextField(
//                               controller: qtyController,
//                               keyboardType: TextInputType.number,
//                               decoration: const InputDecoration(
//                                 labelText: "Return Quantity",
//                                 border: OutlineInputBorder(),
//                               ),
//                               onChanged: (val) {
//                                 if (selectedItems.containsKey(
//                                   item.product.id,
//                                 )) {
//                                   selectedItems[item.product.id]!["quantity"] =
//                                       int.tryParse(val) ?? 0;
//                                 }
//                               },
//                             ),
//                             const SizedBox(height: 8),
//
//                             // Condition (wrap in Obx so it reads updates)
//                             Obx(() {
//                               return DropdownButtonFormField<String>(
//                                 value:
//                                     selectedItems[item
//                                         .product
//                                         .id]?["condition"],
//                                 decoration: const InputDecoration(
//                                   labelText: "Condition",
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 items: conditions
//                                     .map(
//                                       (c) => DropdownMenuItem(
//                                         value: c,
//                                         child: Text(c),
//                                       ),
//                                     )
//                                     .toList(),
//                                 onChanged: (val) {
//                                   if (selectedItems.containsKey(
//                                     item.product.id,
//                                   )) {
//                                     selectedItems[item
//                                             .product
//                                             .id]!["condition"] =
//                                         val ?? "OK";
//                                   }
//                                 },
//                               );
//                             }),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1A1A4F),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                   onPressed: () {
//                     if (selectedItems.isEmpty) {
//                       Get.snackbar(
//                         "Error",
//                         "Please select at least one product",
//                         backgroundColor: Colors.red,
//                         colorText: Colors.white,
//                       );
//                       return;
//                     }
//
//                     // ✅ Loop through selected products
//                     selectedItems.forEach((productId, data) {
//                       final qty = data["quantity"] as int;
//                       final orderId = order.id;
//                       print("this is the order id 🤢🌠🌠🌠 ${orderId}");
//                       final channelId = order.channel;
//                       print("this is the channel id 🤢🕑👻🌠🌠🌠 ${channelId}");
//                       final condition = data["condition"] as String;
//                       if (isWps) {
//                         Get.find<OrderController>().wpsReturn(
//                           productId: productId,
//                           quantity: qty,
//                           condition: condition,
//                           orderId: orderId,
//                           channelId: channelId,
//                         );
//                       } else {
//                         Get.find<OrderController>().customerReturn(
//                           orderId: order.id!,
//                           productId: productId,
//                           quantity: qty,
//                           condition: condition,
//                           channelId: order.channel,
//                         );
//                       }
//                     });
//
//                     Get.back();
//                     Get.snackbar("Success", "Return submitted successfully ✅");
//                   },
//                   child: const Text(
//                     "Submit",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     ),
//     isScrollControlled: true,
//   );
// }
