import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/view/orders/shipping_detail_form.dart';
import 'package:dmj_stock_manager/view_models/controller/home_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/billing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/order_models/order_detail_model.dart';
import '../../res/components/widgets/courier_return_bottom_sheet.dart';
import '../../res/components/widgets/create_bill_dialog_widget.dart';
import '../../res/components/widgets/customer_return_bottom_sheet.dart';
import '../../view_models/services/other_services/barcode_pdf_service.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int orderId = int.parse(Get.parameters['id']!);

    final orderController = Get.find<OrderController>();
    final homeController = Get.find<HomeController>();
    final billingController = Get.find<BillingController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.loadOrderDetail(orderId);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Obx(() {
          if (orderController.isLoadingDetail.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A1A4F)),
            );
          }

          final order = orderController.orderDetail.value;
          if (order == null) {
            return const Center(child: Text("Order not found"));
          }

          final bool hasBill = billingController.bills.any(
            (bill) => bill.items.any((item) => item.order == orderId),
          );
          final bool isPaid = order.paidStatus.toLowerCase() == 'paid';
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
                  // ── Header ────────────────────────────────────────────────
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
                      if (showCreateBillButton)
                        AppGradientButton(
                          onPressed: () =>
                              showCreateBillDialog(context, order.orderId),
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
                            color: Colors.green,
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
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 18,
                              ),
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

                  // ── Stats Bar ─────────────────────────────────────────────
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
                          order.totalItems.toString(),
                          Icons.shopping_bag,
                        ),
                        _buildDivider(),
                        _buildStatItem("Channel", order.channel, Icons.store),
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

                  // ── Customer Info ─────────────────────────────────────────
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow("Name", order.customerName),
                        _buildInfoRow(
                          "Mobile",
                          "${order.countryCode}${order.mobile}",
                        ),
                        _buildInfoRow(
                          "Email",
                          order.customerEmail.isEmpty
                              ? "No Email"
                              : order.customerEmail,
                        ),
                        _buildInfoRow(
                          "Channel ID",
                          order.channelOrderId.isEmpty
                              ? "-"
                              : order.channelOrderId,
                        ),
                        if (order.paymentMethod != null) ...[
                          const Divider(height: 20),
                          const Text(
                            "Payment Info",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow("Method", order.paymentMethod!),
                          if (order.paymentDate != null)
                            _buildInfoRow(
                              "Date",
                              order.paymentDate!.toLocal().toString().split(
                                ' ',
                              )[0],
                            ),
                          if (order.transactionId != null)
                            _buildInfoRow(
                              "Transaction ID",
                              order.transactionId!,
                            ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Remarks Section ───────────────────────────────────────
                  _buildRemarksSection(
                    context,
                    order,
                    orderId,
                    orderController,
                  ),

                  const SizedBox(height: 20),

                  // ── Ordered Items ─────────────────────────────────────────
                  const Text(
                    "Ordered Items",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item.productImageVariants.isNotEmpty
                                        ? Image.network(
                                            item.productImageVariants.first,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  width: 70,
                                                  height: 70,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          )
                                        : Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1A4F),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            "SKU: ${item.productSku}",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.blue.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Quantity",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        "${item.orderedQuantity}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Unit Price",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        "₹${item.unitPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Subtotal",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        "₹${item.totalPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A4F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (item.productBarcode.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.qr_code,
                                            size: 16,
                                            color: Colors.grey.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Product Barcode",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item.productBarcode,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'monospace',
                                          color: Color(0xFF1A1A4F),
                                        ),
                                      ),
                                      if (item.productBarcodeImage != null &&
                                          item
                                              .productBarcodeImage!
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Center(
                                          child: Image.network(
                                            item.productBarcodeImage!,
                                            height: 60,
                                            fit: BoxFit.contain,
                                            loadingBuilder: (c, child, p) =>
                                                p == null
                                                ? child
                                                : const SizedBox(
                                                    height: 60,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                  ),
                                            errorBuilder: (c, e, s) =>
                                                const SizedBox(
                                                  height: 40,
                                                  child: Center(
                                                    child: Text(
                                                      "Image not available",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                              if (item.serials.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.numbers,
                                            size: 16,
                                            color: Colors.grey.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Serials (${item.serials.length})",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ...item.serials.map(
                                        (serial) => Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.shade200,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  serial.serialNumber,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'monospace',
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                              ),
                                              if (serial
                                                  .barcodeImage
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                Center(
                                                  child: Image.network(
                                                    serial.barcodeImage,
                                                    height: 60,
                                                    fit: BoxFit.contain,
                                                    loadingBuilder:
                                                        (
                                                          c,
                                                          child,
                                                          p,
                                                        ) => p == null
                                                        ? child
                                                        : const SizedBox(
                                                            height: 60,
                                                            child: Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                            ),
                                                          ),
                                                    errorBuilder: (c, e, s) =>
                                                        const SizedBox(
                                                          height: 40,
                                                          child: Center(
                                                            child: Text(
                                                              "Image not available",
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
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

                  // ── Barcode PDF ───────────────────────────────────────────
                  if (order.items.any((item) => item.serials.isNotEmpty)) ...[
                    Container(
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
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.print,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Serial Barcodes",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF1A1A4F),
                                        ),
                                      ),
                                    );
                                    await BarcodePdfService.printBarcodePdf(
                                      context,
                                      order,
                                    );
                                    if (context.mounted)
                                      Navigator.of(context).pop();
                                  },
                                  icon: const Icon(
                                    Icons.print_outlined,
                                    size: 18,
                                  ),
                                  label: const Text("Print"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1A1A4F),
                                    side: const BorderSide(
                                      color: Color(0xFF1A1A4F),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF1A1A4F),
                                        ),
                                      ),
                                    );
                                    await BarcodePdfService.downloadBarcodePdf(
                                      context,
                                      order,
                                    );
                                    if (context.mounted)
                                      Navigator.of(context).pop();
                                  },
                                  icon: const Icon(
                                    Icons.download_outlined,
                                    size: 18,
                                  ),
                                  label: const Text("Download PDF"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A1A4F),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Action Buttons ────────────────────────────────────────
                  AppGradientButton(
                    onPressed: () =>
                        showShippingDetailsBottomSheet(context, orderId),
                    text: "Create Shipment",
                    icon: Icons.local_shipping_outlined,
                    width: double.infinity,
                    height: 50,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppGradientButton(
                          onPressed: () {
                            final oldOrder = orderController.orders
                                .firstWhereOrNull((o) => o.id == orderId);
                            if (oldOrder != null)
                              showCourierReturnDialog(context, oldOrder);
                          },
                          text: "Courier Return",
                          height: 50,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppGradientButton(
                          onPressed: () {
                            final oldOrder = orderController.orders
                                .firstWhereOrNull((o) => o.id == orderId);
                            if (oldOrder != null)
                              showCustomerReturnDialog(context, oldOrder);
                          },
                          text: "Customer Return",
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ✅ Cancel/Delete button — always visible, no response shown
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: orderController.isCancellingOrder.value
                            ? null
                            : () => _showCancelConfirmDialog(
                                context,
                                orderId,
                                orderController,
                              ),
                        icon: orderController.isCancellingOrder.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : const Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                                size: 20,
                              ),
                        label: Text(
                          orderController.isCancellingOrder.value
                              ? "Cancelling..."
                              : "Cancel Order",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
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

  // ── Remarks Section ───────────────────────────────────────────────────────
  Widget _buildRemarksSection(
    BuildContext context,
    order,
    int orderId,
    OrderController orderController,
  ) {
    final rawRemarks = order.remarks as List? ?? [];
    final remarks = rawRemarks.map((e) {
      if (e is OrderRemark) return e;
      return OrderRemark.fromJson(e as Map<String, dynamic>);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Remarks",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Obx(
                () => TextButton.icon(
                  onPressed: orderController.isAddingRemark.value
                      ? null
                      : () => _showAddRemarkDialog(
                          context,
                          orderId,
                          orderController,
                        ),
                  icon: orderController.isAddingRemark.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1A1A4F),
                          ),
                        )
                      : const Icon(
                          Icons.add_comment_outlined,
                          size: 18,
                          color: Color(0xFF1A1A4F),
                        ),
                  label: Text(
                    orderController.isAddingRemark.value
                        ? "Adding..."
                        : "Add Remark",
                    style: const TextStyle(
                      color: Color(0xFF1A1A4F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (remarks.isEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                "No remarks yet",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const SizedBox(height: 8),
            ...remarks.map((remark) => _buildRemarkItem(remark)),
          ],
        ],
      ),
    );
  }

  Widget _buildRemarkItem(dynamic remark) {
    final formattedDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(remark.createdAt.toLocal());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A4F).withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.comment_outlined,
              size: 16,
              color: Color(0xFF1A1A4F),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remark.remark,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRemarkDialog(
    BuildContext context,
    int orderId,
    OrderController orderController,
  ) {
    final TextEditingController remarkCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.add_comment_outlined,
              color: Color(0xFF1A1A4F),
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              "Add Remark",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: TextField(
          controller: remarkCtrl,
          maxLines: 3,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter your remark...",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1A1A4F),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: orderController.isAddingRemark.value
                  ? null
                  : () async {
                      final text = remarkCtrl.text.trim();
                      if (text.isEmpty) return;
                      Navigator.of(context).pop();
                      await orderController.addRemark(orderId, text);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A4F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: orderController.isAddingRemark.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Submit",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Cancel confirm — no success response shown, just navigates back
  void _showCancelConfirmDialog(
    BuildContext context,
    int orderId,
    OrderController orderController,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text(
              "Cancel Order",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to cancel order #$orderId? This action cannot be undone.",
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "No, Keep",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
              orderController.cancelOrder(orderId); // soft delete + go back
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDivider() =>
      Container(height: 40, width: 1, color: Colors.white24);

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value.isEmpty ? "-" : value),
          ],
        ),
      ),
    );
  }

  double _calculateTotal(order) =>
      order.items.fold(0.0, (sum, item) => sum + item.totalPrice);
}
