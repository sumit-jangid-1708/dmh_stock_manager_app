import 'package:dmj_stock_manager/model/order_model.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';
import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/components/widgets/create_bill_dialog_widget.dart';
import '../../view_models/controller/home_controller.dart';
import '../../view_models/controller/order_controller.dart' show OrderController;

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args == null || args is! OrderDetailModel) {
      return const Scaffold(
        body: Center(child: Text("Order details missing")),
      );
    }
    final order = args as OrderDetailModel;
    final orderController = Get.find<OrderController>();
    final homeController = Get.find<HomeController>();
    final vendorController = Get.find<VendorController>();

    // Get screen dimensions for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600; // Adjust threshold as needed

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await orderController.getOrderList();
          },
          child: Obx(() {
            if (orderController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02, // 2% of screen height
                horizontal: screenWidth * 0.04, // 4% of screen width
              ),
              child: Column(
                children: [
                  // 🔙 Back Button and Share Invoice Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: isTablet ? 48 : 40, // Larger on tablets
                        height: isTablet ? 48 : 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade500,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          iconSize: isTablet ? 24 : 20,
                          onPressed: () => Get.back(),
                        ),
                      ),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.5, // Max 50% of screen width
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
                              showCreateBillDialog(context, order.id);
                            },
                            child: Text(
                              "Create Bill",
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
                  SizedBox(height: screenHeight * 0.02),

                  // 📝 Order Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "Order Details",
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  // 📦 Order Info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf3f3f3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Id: #${order.id}",
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Customer Name: ${order.customerName}",
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          (order.mobile != null && order.mobile != '0')
                              ? "Mobile: ${(order.countryCode ?? '')}${order.mobile}"
                              : "",
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Channel: ${homeController.getChannelNameById(order.channel)}",
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Created At: ${order.createdAt.toLocal().toString().split(' ')[0]}",
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Remarks: ${order.remarks}",
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Items List Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "Items",
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  // Items List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      final product = item.product;
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: const Color(0xffefefef),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                if (product.productImageVariants.isNotEmpty)
                                  Container(
                                    margin: EdgeInsets.only(right: screenWidth * 0.02),
                                    child: Image.network(
                                      "https://traders.testwebs.in${product.productImageVariants.first}",
                                      height: isTablet ? 48 : 40,
                                      width: isTablet ? 48 : 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) => const Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                // Product Name
                                Expanded(
                                  child: Text(
                                    product.name ?? "Unnamed Product",
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Serial and Quantity
                                Text(
                                  "Serial: ${product.serial} | Qty: ${item.quantity}",
                                  style: TextStyle(fontSize: isTablet ? 14 : 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              "vendor : ${vendorController.getVendorNameById(product.vendor)}",
                              style: TextStyle(fontSize: isTablet ? 14 : 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Size: ${product.size} | Color: ${product.color} | Material: ${product.material}",
                              style: TextStyle(fontSize: isTablet ? 14 : 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "SKU: ${product.sku}",
                              style: TextStyle(fontSize: isTablet ? 14 : 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Unit Price: ${item.unitPrice}",
                              style: TextStyle(fontSize: isTablet ? 14 : 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Subtotal: ${(double.tryParse(item.unitPrice.toString()) ?? 0) * (item.quantity ?? 0)}",
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (product!.barcodeImage!.isNotEmpty)
                                  Image.network(
                                    "https://traders.testwebs.in${product.barcodeImage!}",
                                    height: isTablet ? 48 : 40,
                                    width: isTablet ? 120 : 100,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stack) => const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // 📑 Footer
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Total Items: ${order.items.length}",
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Total Amount: ₹${calculateTotalAmount(order).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Action Buttons
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          spacing: screenWidth * 0.04,
                          runSpacing: screenHeight * 0.02,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 150,
                                maxWidth: constraints.maxWidth * 0.45,
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
                                  showReturnDialog(context, order, true);
                                },
                                child: Text(
                                  "Courier Return",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 150,
                                maxWidth: constraints.maxWidth * 0.45,
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
                                  showReturnDialog(context, order, false);
                                },
                                child: Text(
                                  "Customer Return",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

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
