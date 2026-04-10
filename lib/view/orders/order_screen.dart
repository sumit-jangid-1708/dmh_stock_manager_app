import 'package:dmj_stock_manager/res/routes/routes_names.dart';
import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'order_create_bottom_sheet.dart';

class OrderScreen extends StatelessWidget {
  final OrderController orderController = Get.put(OrderController());
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  OrderScreen({super.key});

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "cancelled":
        return Colors.red;
      case "active":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A4F).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          onPressed: () => _showCreateOrderSheet(context),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
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
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => orderController.filterOrders(value),
                  decoration: InputDecoration(
                    hintText: "Search by ID or customer name...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF1A1A4F),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            // ── Orders List ───────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF1A1A4F),
                onRefresh: () async => await orderController.getOrderList(),
                child: Obx(() {
                  if (orderController.isLoading.value &&
                      orderController.orders.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (orderController.orders.isEmpty) {
                    return _buildEmptyState();
                  }
                  return Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 6,
                    radius: const Radius.circular(10),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
                      itemCount: orderController.filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = orderController.filteredOrders[index];
                        return _buildOrderCard(context, order);
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    // Logic for Status Colors
    final bool isActive = order.status?.toLowerCase() == "active";
    final Color statusColor = _getStatusColor(order.status);

    String latestRemark = "NO REMARKS";
    if (order.remarks != null && order.remarks.isNotEmpty) {
      final sorted = List.from(order.remarks)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      latestRemark = sorted.first.remark;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)), // Subtle border
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.toNamed(
          RouteName.orderDetailScreen,
          parameters: {'id': order.id.toString()},
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // ── Indicator Dot (Green/Red) ──────────────────
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // ── Main Content ───────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: name + status chip ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            order.customerName ?? "Unknown Customer",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF1A1A4F),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ✅ Order Status Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: order.orderStatusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: order.orderStatusColor.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            order.orderStatusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: order.orderStatusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID: #${order.id}  •  ${order.createdAt.toLocal().toString().split(' ')[0]}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    if (latestRemark != "NO REMARKS") ...[
                      const SizedBox(height: 6),
                      Text(
                        latestRemark.toUpperCase(),
                        style: TextStyle(
                          color: Colors.blueGrey.shade400,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // ── Action Button ──────────────────────────────
              IconButton(
                onPressed: () => _showDeleteConfirmDialog(context, order.id),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade300,
                  size: 22,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Confirm dialog before delete
  void _showDeleteConfirmDialog(BuildContext context, int orderId) {
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
              "Delete Order",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete order #$orderId?",
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              orderController.deleteOrderFromList(orderId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
