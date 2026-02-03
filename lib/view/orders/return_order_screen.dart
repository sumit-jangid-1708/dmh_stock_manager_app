import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/return_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/controller/home_controller.dart';

class ReturnOrderHistoryScreen extends StatelessWidget {
  ReturnOrderHistoryScreen({super.key});

  final ReturnController controller = Get.put(ReturnController());
  final HomeController homeController = Get.find<HomeController>();
  final ItemController itemController = Get.find<ItemController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A4F), Color(0xFF32328C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    // bottom: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // --- Back Button & Title ---
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20,),
                            onPressed: () => Get.back(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Return History",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "Track your returns effortlessly",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // --- Modern Segmented Tab Bar ---
                    Container(
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: const Color(0xFF1A1A4F),
                        unselectedLabelColor: Colors.white70,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_shipping_outlined, size: 18),
                                SizedBox(width: 8),
                                Text("Courier"),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_outline, size: 18),
                                SizedBox(width: 8),
                                Text("Customer"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    // Courier Returns Tab
                    CourierReturnsTab(
                      controller: controller,
                      homeController: homeController,
                      itemController: itemController,
                    ),

                    // Customer Returns Tab
                    CustomerReturnsTab(
                      controller: controller,
                      homeController: homeController,
                      itemController: itemController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== COURIER RETURNS TAB ==========
class CourierReturnsTab extends StatelessWidget {
  final ReturnController controller;
  final HomeController homeController;
  final ItemController itemController;

  const CourierReturnsTab({
    super.key,
    required this.controller,
    required this.homeController,
    required this.itemController,
  });

  @override
  Widget build(BuildContext context) {
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.courierReturnList.isEmpty) {
        controller.getCourierReturnList();
      }
    });

    return Column(
      children: [
        // Filters Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filters",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A4F),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("All", () {controller.getCourierReturnList();
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip("SAFE", () {controller.getCourierReturnList(
                      condition: "SAFE",
                    );
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip("DAMAGED", () {controller.getCourierReturnList(
                      condition: "DAMAGED",
                    );
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip("CLAIMED RECEIVED", () {controller.getCourierReturnList(
                      claimStatus: "CLAIMED",
                      claimResult: "RECEIVED",
                    );
                    }), const SizedBox(width: 8),
                    _buildFilterChip("CLAIMED REJECTED", () {controller.getCourierReturnList(
                      claimStatus: "CLAIMED",
                      claimResult: "REJECTED",
                    );
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip("NOT CLAIMED", () {controller.getCourierReturnList(
                      claimStatus: "NOT_CLAIMED"
                    );}),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Returns List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A1A4F)),
              );
            }

            if (controller.courierReturnList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No courier returns found",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.getCourierReturnList(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.courierReturnList.length,
                itemBuilder: (context, index) {
                  final returnItem = controller.courierReturnList[index];
                  final product = itemController.products.firstWhereOrNull(
                    (p) => p.id == returnItem.productId,
                  );

                  return _CourierReturnCard(
                    returnItem: returnItem,
                    productName:
                        product?.name ?? "Product #${returnItem.productId}",
                    productSku: product?.sku ?? "N/A",
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A4F),
          ),
        ),
      ),
    );
  }
}

// ========== CUSTOMER RETURNS TAB ==========
class CustomerReturnsTab extends StatelessWidget {
  final ReturnController controller;
  final HomeController homeController;
  final ItemController itemController;

  const CustomerReturnsTab({
    super.key,
    required this.controller,
    required this.homeController,
    required this.itemController,
  });

  @override
  Widget build(BuildContext context) {
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.customerReturnList.isEmpty) {
        controller.getCustomerReturnList();
      }
    });

    return Column(
      children: [
        // Filters Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filters",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A4F),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("All", () {controller.getCustomerReturnList();}),
                    const SizedBox(width: 8),
                    _buildFilterChip("SAFE", () {controller.getCustomerReturnList(
                      condition: "SAFE",
                    );}),
                    const SizedBox(width: 8),
                    _buildFilterChip("DAMAGED", () {
                      controller.getCustomerReturnList(
                        condition: "DAMAGED",
                      );
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip("LOST", () {
                      controller.getCustomerReturnList(
                        condition: "LOST"
                      );
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip("PENDING", () {
                      controller.getCustomerReturnList(
                        refundStatus: "PENDING",
                      );
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip("REFUNDED", () {
                      controller.getCustomerReturnList(
                        refundStatus: "REFUNDED"
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Returns List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A1A4F)),
              );
            }

            if (controller.customerReturnList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No customer returns found",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.getCustomerReturnList(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.customerReturnList.length,
                itemBuilder: (context, index) {
                  final returnItem = controller.customerReturnList[index];

                  return _CustomerReturnCard(returnItem: returnItem);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A4F),
          ),
        ),
      ),
    );
  }
}

// ========== COURIER RETURN CARD ==========
class _CourierReturnCard extends StatelessWidget {
  final dynamic returnItem;
  final String productName;
  final String productSku;

  const _CourierReturnCard({
    required this.returnItem,
    required this.productName,
    required this.productSku,
  });

  Color _getConditionColor(String condition) {
    switch (condition.toUpperCase()) {
      case 'SAFE':
        return Colors.green;
      case 'DAMAGED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final conditionColor = _getConditionColor(returnItem.condition);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A4F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "SKU: $productSku",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: conditionColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: conditionColor),
                  ),
                  child: Text(
                    returnItem.condition,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: conditionColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 12),

            // Details Grid
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    "Order ID",
                    "#${returnItem.orderId}",
                    Icons.receipt_outlined,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    "Quantity",
                    "${returnItem.quantity}",
                    Icons.inventory_2_outlined,
                  ),
                ),
              ],
            ),

            if (returnItem.claimStatus != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Claim Status: ${returnItem.claimStatus}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (returnItem.claimResult != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Result: ${returnItem.claimResult}",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                    if (returnItem.claimAmount != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Amount: ₹${returnItem.claimAmount}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            if (returnItem.remarks != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        returnItem.remarks,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  _formatDate(returnItem.receivedAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A4F),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.year}, "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }
}

// ========== CUSTOMER RETURN CARD ==========
class _CustomerReturnCard extends StatelessWidget {
  final dynamic returnItem;

  const _CustomerReturnCard({required this.returnItem});

  Color _getConditionColor(String condition) {
    switch (condition.toUpperCase()) {
      case 'SAFE':
        return Colors.green;
      case 'DAMAGED':
        return Colors.orange;
      case 'LOST':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRefundStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'REFUNDED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final conditionColor = _getConditionColor(returnItem.condition);
    final refundColor = _getRefundStatusColor(returnItem.refundStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: conditionColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: conditionColor),
                  ),
                  child: Text(
                    returnItem.condition,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: conditionColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: refundColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: refundColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        returnItem.refundStatus == "REFUNDED"
                            ? Icons.check_circle
                            : Icons.pending,
                        size: 12,
                        color: refundColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        returnItem.refundStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: refundColor,
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

            // Details Grid
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    "Quantity",
                    "${returnItem.quantity}",
                    Icons.inventory_2_outlined,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    "Refund",
                    "₹${returnItem.refundAmount}",
                    Icons.currency_rupee,
                  ),
                ),
              ],
            ),

            if (returnItem.reason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        returnItem.reason,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
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
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A4F),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
