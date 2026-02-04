import 'package:dmj_stock_manager/model/purchase_models/purchase_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/utils/utils.dart';
import 'package:dmj_stock_manager/view/purchase_screen/add_purchase_bottom_sheet.dart';
import 'package:dmj_stock_manager/view/purchase_screen/purchase_details.dart';
import 'package:dmj_stock_manager/view_models/controller/purchase_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PurchaseController purchaseController =
        Get.find<PurchaseController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => purchaseController.getPurchaseList(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // 🎨 Header with Title
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
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Purchase Bills",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Manage all vendor purchases",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔍 Search Bar + Add Button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          purchaseController.searchQuery.value =
                              value; // ← This triggers filtering
                        },
                        decoration: Utils.inputDecoration(
                          "Search bills, vendors, status...",
                          Icons.search,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppGradientButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) => AddPurchaseBottomSheet(),
                        );
                      },
                      icon: Icons.add,
                      width: 50,
                      height: 50,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 📜 Recent Purchases Title
                const Text(
                  "Recent Purchase Bills",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 📦 Purchase List
                Obx(() {
                  if (purchaseController.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final listToShow = purchaseController.filteredPurchaseList;
                  if (listToShow.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              purchaseController.searchQuery.value.isEmpty
                                  ? "No Purchase Bills Found"
                                  : "No matching bills found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listToShow.length,
                    itemBuilder: (context, index) {
                      final purchase = listToShow[index];
                      return PurchaseListCard(purchase: purchase);
                    },
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, [
    Color? iconColor,
  ]) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Colors.white70, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class PurchaseListCard extends StatelessWidget {
  final PurchaseBillModel purchase;

  const PurchaseListCard({super.key, required this.purchase});

  String _getVendorInitials(String name) {
    if (name.isEmpty) return "V";
    final words = name.split(' ');
    if (words.length >= 2) {
      return "${words[0][0]}${words[1][0]}".toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return Colors.green;
      case 'UNPAID':
        return Colors.orange;
      case 'PARTIAL PAID':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = purchase.vendor;
    final itemCount = purchase.items.length;
    final outstanding = purchase.totalAmount - purchase.paidAmount;

    return InkWell(
      onTap: () => Get.to(() => PurchaseDetails(purchase: purchase)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Vendor Avatar
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                _getVendorInitials(vendor.name),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Name & Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.firmName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A4F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            purchase.status,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getStatusColor(purchase.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          purchase.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(purchase.status),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Bill Number & Items
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        purchase.billNumber,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$itemCount Items",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Amount Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Total Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            "₹${purchase.totalAmount.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A4F),
                            ),
                          ),
                        ],
                      ),

                      // Outstanding (if any)
                      if (outstanding > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Due",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red.shade700,
                              ),
                            ),
                            Text(
                              "₹${outstanding.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

// 📊 Stats Cards
// Obx(() {
//   if (!purchaseController.isLoading.value &&
//       purchaseController.purchaseList.isNotEmpty) {
//     final totalBills = purchaseController.purchaseList.length;
//     final paidBills = purchaseController.purchaseList
//         .where((b) => b.status.toUpperCase() == 'PAID')
//         .length;
//     final unpaidBills = purchaseController.purchaseList
//         .where((b) => b.status.toUpperCase() == 'UNPAID')
//         .length;
//     final totalAmount = purchaseController.purchaseList
//         .fold<double>(0, (sum, bill) => sum + bill.totalAmount);
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF1A1A4F).withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatItem(
//                   "Total Bills",
//                   totalBills.toString(),
//                   Icons.receipt_long,
//                 ),
//               ),
//               Container(
//                 height: 50,
//                 width: 1,
//                 color: Colors.white24,
//               ),
//               Expanded(
//                 child: _buildStatItem(
//                   "Total Amount",
//                   "₹${NumberFormat('#,##,###').format(totalAmount)}",
//                   Icons.currency_rupee,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatItem(
//                   "Paid",
//                   paidBills.toString(),
//                   Icons.check_circle,
//                   Colors.green.shade300,
//                 ),
//               ),
//               Container(
//                 height: 50,
//                 width: 1,
//                 color: Colors.white24,
//               ),
//               Expanded(
//                 child: _buildStatItem(
//                   "Unpaid",
//                   unpaidBills.toString(),
//                   Icons.pending,
//                   Colors.orange.shade300,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//   return const SizedBox.shrink();
// }),
// const SizedBox(height: 20),
