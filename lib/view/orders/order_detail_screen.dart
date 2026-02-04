import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/view_models/controller/home_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/billing_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/order_models/order_detail_ui_model.dart';
import '../../res/components/widgets/courier_return_bottom_sheet.dart';
import '../../res/components/widgets/create_bill_dialog_widget.dart';
import '../../res/components/widgets/customer_return_bottom_sheet.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int orderId = int.parse(Get.parameters['id']!);

    final orderController = Get.find<OrderController>();
    final homeController = Get.find<HomeController>();
    final billingController = Get.find<BillingController>();

    // ✅ Load merged order detail (old + new API)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.loadOrderDetail(orderId);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Obx(() {
          // ✅ Loading state
          if (orderController.isLoadingDetail.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1A1A4F),
              ),
            );
          }

          // ✅ Get UI Model (merged data)
          final order = orderController.orderDetailUI.value;

          if (order == null) {
            return const Center(
              child: Text("Order not found"),
            );
          }

          // ✅ Check if bill already exists for this order
          final bool hasBill = billingController.bills.any(
                (bill) => bill.items.any((item) => item.order == orderId),
          );

          // ✅ Check payment status - only hide if fully PAID
          final bool isPaid = order.paidStatus.toLowerCase() == 'paid';

          // ✅ Show button only if no bill exists OR bill exists but not fully paid
          final bool showCreateBillButton = !hasBill || !isPaid;

          return RefreshIndicator(
            onRefresh: () async {
              await orderController.loadOrderDetail(orderId);
              await billingController.refreshBills();
            },
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

                      // ✅ Conditionally show Create Bill button or Paid badge
                      if (showCreateBillButton)
                        AppGradientButton(
                          onPressed: () {
                            showCreateBillDialog(context, order.orderId);
                          },
                          icon: Icons.receipt_long,
                          text: "Create Bill",
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.green, Colors.green],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                "Bill Paid",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
                    "Order #${order.orderId} • ${order.createdAt.toLocal().toString().split(' ')[0]}",
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
                        _buildStatItem(
                          "Total Items",
                          order.items.length.toString(),
                          Icons.shopping_bag,
                        ),
                        _buildDivider(),
                        _buildStatItem(
                          "Channel",
                          homeController.getChannelNameById(order.channel),
                          Icons.store,
                        ),
                        _buildDivider(),
                        _buildStatItem(
                          "Total",
                          "₹${_calculateTotal(order).toStringAsFixed(2)}",
                          Icons.currency_rupee,
                        ),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Customer Info",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow("Name", order.customerName),
                        _buildInfoRow("Mobile", "${order.countryCode}${order.mobile}"),
                        _buildInfoRow("Email", order.customerEmail ?? "No Email"),
                        _buildInfoRow("Channel ID", order.channelOrderId ?? "-"),
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

                  // 📋 Items List (from NEW API with barcodes)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    itemBuilder: (context, index) {
                      final item = order.items[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A4F),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // SKU & Stock
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "SKU: ${item.sku}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item.stockLeft > 0 ? Colors.green.shade50 : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.inventory_2,
                                          size: 12,
                                          color: item.stockLeft > 0 ? Colors.green.shade700 : Colors.red.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Stock: ${item.stockLeft}",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: item.stockLeft > 0 ? Colors.green.shade700 : Colors.red.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              Divider(color: Colors.grey.shade200, height: 1),
                              const SizedBox(height: 12),

                              // Quantity, Price, Subtotal
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
                                      Text("₹${item.unitPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Subtotal", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                      Text(
                                        "₹${(item.unitPrice * item.quantity).toStringAsFixed(2)}",
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // ✅ Barcodes Section with proper image URL handling
                              if (item.barcodes.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.qr_code, size: 16, color: Colors.grey.shade700),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Barcodes (${item.barcodes.length})",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ...item.barcodes.map((barcode) {
                                        // ✅ Construct proper image URL
                                        final imageUrl = barcode.image.startsWith('http')
                                            ? barcode.image
                                            : "https://traders.testwebs.in${barcode.image}";

                                        if (kDebugMode) {
                                          print("🖼️ Barcode: ${barcode.barcode}");
                                          print("🖼️ Image URL: $imageUrl");
                                        }

                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                barcode.barcode,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                              if (barcode.image.isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                Center(
                                                  child: Image.network(
                                                    imageUrl,
                                                    height: 60,
                                                    fit: BoxFit.contain,
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return SizedBox(
                                                        height: 60,
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            value: loadingProgress.expectedTotalBytes != null
                                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                                : null,
                                                            strokeWidth: 2,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context, error, stackTrace) {
                                                      if (kDebugMode) {
                                                        print("❌ Image load error: $error");
                                                        print("❌ Failed URL: $imageUrl");
                                                      }
                                                      return Column(
                                                        children: [
                                                          const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                                          Text(
                                                            "Image not available",
                                                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // 🔄 Return Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppGradientButton(
                          onPressed: () {
                            final oldOrder = orderController.orders.firstWhereOrNull((o) => o.id == orderId);
                            if (oldOrder != null) {
                              showCourierReturnDialog(context, oldOrder);
                            }
                          },
                          text: "Courier Return",
                          height: 50,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppGradientButton(
                          onPressed: () {
                            final oldOrder = orderController.orders.firstWhereOrNull((o) => o.id == orderId);
                            if (oldOrder != null) {
                              showCustomerReturnDialog(context, oldOrder);
                            }
                          },
                          text: "Customer Return",
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

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

  double _calculateTotal(OrderDetailUIModel order) {
    double total = 0;
    for (var item in order.items) {
      total += item.unitPrice * item.quantity;
    }
    return total;
  }
}