// lib/view/orders/order_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/color/app_colors.dart';
import '../../res/fonts/app_text_styles.dart';
import '../../res/routes/routes_names.dart';
import '../../view_models/controller/order_controller.dart';
import '../../view_models/controller/home_controller.dart';
import 'order_create_bottom_sheet.dart';
import 'order_filter_bottom_sheet.dart';

class OrderScreen extends StatelessWidget {
  final OrderController orderController = Get.put(OrderController());
  final HomeController homeController = Get.find<HomeController>();
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  OrderScreen({super.key});

  static const List<Map<String, dynamic>> _statusFilters = [
    {"label": "All", "value": -1},
    {"label": "In Process", "value": 1},
    {"label": "Packed", "value": 2},
    {"label": "In Transit", "value": 3},
    {"label": "Delivered", "value": 4},
    {"label": "Cancelled", "value": 5},
    {"label": "Courier Return", "value": 6},
    {"label": "Customer Return", "value": 7},
    {"label": "Return Received", "value": 8},
    {"label": "Not Received", "value": 9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          highlightElevation: 0,
          onPressed: () => _showCreateOrderSheet(context),
          child: const Icon(Icons.add, color: AppColors.white, size: 30),
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
                  Text(
                    "Orders",
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    "View and manage your recent transactions",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar & Filter Button ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) => orderController.filterOrders(value),
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: "Search by ID or customer name...",
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 0,
                    child: InkWell(
                      onTap: () => _showFilterBottomSheet(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Status Chips ──────────────────────────────────────────────
            _buildStatusFilterSection(),

            // ── Orders List ───────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
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

  Widget _buildStatusFilterSection() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: _statusFilters.map((f) {
              final isSelected =
                  orderController.selectedStatusFilter.value == f["value"];

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    f["label"] as String,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.grey600,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withOpacity(0.08),
                  backgroundColor: AppColors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.grey300,
                    ),
                  ),
                  onSelected: (_) {
                    orderController.selectedStatusFilter.value =
                        f["value"] as int;
                    orderController.applyFilters();
                  },
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => const OrderFilterBottomSheet(),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    String latestRemark = "NO REMARKS";
    if (order.remarks != null && order.remarks.isNotEmpty) {
      final sorted = List.from(order.remarks)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      latestRemark = sorted.first.remark;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.grey100,
        ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            order.customerName ?? "Unknown Customer",
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
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
                            style: AppTextStyles.labelSmall.copyWith(
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
                      style: AppTextStyles.bodySmall,
                    ),
                    if (latestRemark != "NO REMARKS") ...[
                      const SizedBox(height: 6),
                      Text(
                        latestRemark.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.grey500,
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

              IconButton(
                onPressed: () => _showDeleteConfirmDialog(context, order.id),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
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

  void _showDeleteConfirmDialog(BuildContext context, int orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
            SizedBox(width: 8),
            Text(
              "Delete Order",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete order #$orderId?",
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.grey600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              orderController.deleteOrderFromList(orderId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
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
          const Icon(Icons.inbox_rounded, size: 60, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            "No orders found",
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showCreateOrderSheet(BuildContext context) {
    Get.bottomSheet(
      OrderCreateBottomSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.white,
    );
  }
}
