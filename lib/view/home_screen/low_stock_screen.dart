import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/bestselling_products_model.dart';
import '../../model/stock_details_model.dart';
import '../../view_models/controller/home_controller.dart';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // 🎨 Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Back Button & Title
                  Row(
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
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Low Stock Items",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Items need restocking",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 🔍 Source Tabs (Stock Details vs Best Selling)
                  Obx(() {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildSourceTab(
                            label: "Stock Details",
                            isSelected: homeController.selectedStockSource.value == "stock",
                            onTap: () => homeController.selectedStockSource.value = "stock",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSourceTab(
                            label: "Best Selling",
                            isSelected: homeController.selectedStockSource.value == "bestselling",
                            onTap: () => homeController.selectedStockSource.value = "bestselling",
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 15),

                  // 🔍 Filter Chips Row (Only for Best Selling)
                  Obx(() {
                    if (homeController.selectedStockSource.value != "bestselling") {
                      return const SizedBox.shrink();
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: "All",
                            count: homeController.bestSellingProducts.length,
                            isSelected: homeController.selectedLowStockFilter.value == "all",
                            onTap: () => homeController.selectedLowStockFilter.value = "all",
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: "Critical",
                            count: homeController.bestSellingProducts
                                .where((p) => p.quantity == 0)
                                .length,
                            isSelected: homeController.selectedLowStockFilter.value == "critical",
                            onTap: () => homeController.selectedLowStockFilter.value = "critical",
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: "Low",
                            count: homeController.bestSellingProducts
                                .where((p) => p.quantity > 0 && p.quantity <= p.threshold)
                                .length,
                            isSelected: homeController.selectedLowStockFilter.value == "low",
                            onTap: () => homeController.selectedLowStockFilter.value = "low",
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: "Popular",
                            count: homeController.bestSellingProducts
                                .where((p) => p.popular)
                                .length,
                            isSelected: homeController.selectedLowStockFilter.value == "popular",
                            onTap: () => homeController.selectedLowStockFilter.value = "popular",
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // 📊 Stats Bar (Different for each source)
            Obx(() {
              if (homeController.selectedStockSource.value == "bestselling") {
                final products = homeController.bestSellingProducts;
                final criticalCount = products.where((p) => p.quantity == 0).length;
                final lowCount = products.where((p) => p.quantity > 0 && p.quantity <= p.threshold).length;

                return Container(
                  margin: const EdgeInsets.all(16),
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
                      _buildStatItem("Total", products.length.toString(), Icons.inventory_2),
                      _buildDivider(),
                      _buildStatItem("Critical", criticalCount.toString(), Icons.error_outline, Colors.red.shade300),
                      _buildDivider(),
                      _buildStatItem("Low", lowCount.toString(), Icons.warning_amber, Colors.orange.shade300),
                    ],
                  ),
                );
              } else {
                // Stock Details Stats
                final lowStockItems = homeController.stockDetails
                    .where((stock) => (stock.inventoryQuantity ?? 0) < 50)
                    .toList();

                return Container(
                  margin: const EdgeInsets.all(16),
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
                      _buildStatItem("Total Items", homeController.stockDetails.length.toString(), Icons.inventory_2),
                      _buildDivider(),
                      _buildStatItem("Low Stock", lowStockItems.length.toString(), Icons.warning_amber, Colors.orange.shade300),
                    ],
                  ),
                );
              }
            }),

            // 📦 Products List (Switch between sources)
            Expanded(
              child: Obx(() {
                if (homeController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Switch between Stock Details and Best Selling
                if (homeController.selectedStockSource.value == "stock") {
                  return _buildStockDetailsList(homeController);
                } else {
                  return _buildBestSellingList(homeController);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 🏷️ Source Tab Widget
  Widget _buildSourceTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A4F) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A1A4F) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // 📋 Stock Details List (Original API)
  Widget _buildStockDetailsList(HomeController homeController) {
    final lowStockItems = homeController.stockDetails
        .where((stock) => (stock.inventoryQuantity ?? 0) < 50)
        .toList();

    if (lowStockItems.isEmpty) {
      return _buildEmptyState("No low stock items in inventory");
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: lowStockItems.length,
      itemBuilder: (context, index) {
        final stock = lowStockItems[index];
        return _buildStockDetailsCard(stock);
      },
    );
  }

  // 🎯 Best Selling List (New API)
  Widget _buildBestSellingList(HomeController homeController) {
    List<BestSellingProductModel> filteredProducts = homeController.bestSellingProducts;

    // Apply filters
    switch (homeController.selectedLowStockFilter.value) {
      case "critical":
        filteredProducts = filteredProducts.where((p) => p.quantity == 0).toList();
        break;
      case "low":
        filteredProducts = filteredProducts.where((p) => p.quantity > 0 && p.quantity <= p.threshold).toList();
        break;
      case "popular":
        filteredProducts = filteredProducts.where((p) => p.popular).toList();
        break;
      default:
      // "all" - no filter
    }

    if (filteredProducts.isEmpty) {
      return _buildEmptyState("No items found");
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildBestSellingCard(product);
      },
    );
  }

  // 🎴 Stock Details Card (Original Design)
  Widget _buildStockDetailsCard(StockDetail stock) {
    final quantity = stock.inventoryQuantity ?? 0;
    final isCritical = quantity == 0;
    final isLow = quantity > 0 && quantity < 50;

    Color statusColor = isCritical ? Colors.red : isLow ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical ? Colors.red.shade100 : Colors.grey.shade200,
          width: isCritical ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.name ?? "N/A",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("SKU: ${stock.sku ?? 'N/A'}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            Text("Size: ${stock.size ?? '-'}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            Text("Price: ₹${stock.unitPurchasePrice ?? '0.00'}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Available Quantity:",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    quantity.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎴 Best Selling Product Card (New Design)
  Widget _buildBestSellingCard(BestSellingProductModel product) {
    bool isCritical = product.quantity == 0;
    bool isLow = product.quantity > 0 && product.quantity <= product.threshold;

    Color statusColor = isCritical ? Colors.red : isLow ? Colors.orange : Colors.green;
    String statusText = isCritical ? "OUT OF STOCK" : isLow ? "LOW STOCK" : "IN STOCK";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical ? Colors.red.shade100 : Colors.grey.shade200,
          width: isCritical ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("SKU: ${product.sku}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                if (product.popular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.purple),
                        const SizedBox(width: 4),
                        Text("Popular", style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Available", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            const SizedBox(height: 2),
                            Text(product.quantity.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: statusColor)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(6)),
                          child: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text("Threshold", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      const SizedBox(height: 2),
                      Text(product.threshold.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 Filter Chip Widget
  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? const Color(0xFF1A1A4F)) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? (color ?? const Color(0xFF1A1A4F)) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 📊 Stat Item Widget
  Widget _buildStatItem(String label, String value, IconData icon, [Color? iconColor]) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.white24);
  }

  // 🚫 Empty State Widget
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../view_models/controller/home_controller.dart';
//
// class LowStockScreen extends StatelessWidget {
//   const LowStockScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final HomeController homeController = Get.find<HomeController>();
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🔙 Back button
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 40,
//                     margin: const EdgeInsets.only(top: 20),
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         width: 1,
//                         color: Colors.grey.shade500,
//                       ),
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     alignment: Alignment.topLeft,
//                     child: IconButton(
//                       icon: const Icon(Icons.arrow_back),
//                       onPressed: () {
//                         Get.back();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//
//               const Text(
//                 "Low Stock",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//
//               // 🔄 Low Stock List
//               Expanded(
//                 child: Obx(() {
//                   if (homeController.isLoading.value) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   // Filter items with low stock
//                   final lowStockItems = homeController.stockDetails
//                       .where((stock) => (stock.inventoryQuantity ?? 0) < 50)
//                       .toList();
//
//                   if (lowStockItems.isEmpty) {
//                     return const Center(child: Text("No low stock items"));
//                   }
//
//                   return ListView.builder(
//                     itemCount: lowStockItems.length,
//                     itemBuilder: (context, index) {
//                       final stock = lowStockItems[index];
//                       return _buildStockCard(
//                         name: stock.name ?? "N/A",
//                         sku: stock.sku ?? "N/A",
//                         size: stock.size ?? "-",
//                         price: stock.unitPurchasePrice ?? "0.00",
//                         quantity: stock.inventoryQuantity ?? 0,
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// 🟢 Inline Stock Card
//   Widget _buildStockCard({
//     required String name,
//     required String sku,
//     required String size,
//     required String price,
//     required int quantity,
//   }) {
//     return Card(
//       color: Colors.white,
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(name,
//                 style: const TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 6),
//             Text("SKU: $sku", style: const TextStyle(fontSize: 13)),
//             Text("Size: $size", style: const TextStyle(fontSize: 13)),
//             Text("Price: ₹$price", style: const TextStyle(fontSize: 13)),
//             const SizedBox(height: 6),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Available Quantity:",
//                     style: TextStyle(
//                         fontSize: 14, fontWeight: FontWeight.w500)),
//                 Text(
//                   quantity.toString(),
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.orange, // 🟠 Low stock ko orange dikhayenge
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
