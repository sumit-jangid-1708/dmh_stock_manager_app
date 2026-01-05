import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/controller/home_controller.dart';

class TotalStockScreen extends StatelessWidget {
  const TotalStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Premium Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  _buildBackButton(),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Stock",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A4F),
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        "Overview of current inventory levels",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Stock List Section ---
            Expanded(
              child: Obx(() {
                if (homeController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A1A4F)),
                  );
                }

                if (homeController.stockDetails.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: const Color(0xFF1A1A4F),
                  onRefresh: () async => await homeController.refreshAllData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
                    itemCount: homeController.stockDetails.length,
                    itemBuilder: (context, index) {
                      final stock = homeController.stockDetails[index];
                      return _buildStockCard(
                        name: stock.name ?? "N/A",
                        sku: stock.sku ?? "N/A",
                        size: stock.size ?? "-",
                        price: stock.unitPurchasePrice ?? "0.00",
                        quantity: stock.inventoryQuantity ?? 0,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF1A1A4F),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildStockCard({
    required String name,
    required String sku,
    required String size,
    required String price,
    required int quantity,
  }) {
    bool isLowStock = quantity <= 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Product Icon Container
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A4F).withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF1A1A4F),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildMiniInfo(Icons.qr_code, sku),
                      const SizedBox(width: 10),
                      _buildMiniInfo(Icons.straighten, size),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "₹$price",
                    style: const TextStyle(
                      color: Color(0xFF1A1A4F),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isLowStock ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isLowStock ? Colors.red.shade100 : Colors.green.shade100,
                    ),
                  ),
                  child: Text(
                    "$quantity Units",
                    style: TextStyle(
                      color: isLowStock ? Colors.red : Colors.green.shade700,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (isLowStock)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      "Low Stock",
                      style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No stock available",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}