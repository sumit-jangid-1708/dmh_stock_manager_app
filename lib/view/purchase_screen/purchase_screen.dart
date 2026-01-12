import 'package:dmj_stock_manager/model/purchase_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/view/purchase_screen/add_purchase_bottom_sheet.dart';
import 'package:dmj_stock_manager/view/purchase_screen/purchase_details.dart';
import 'package:dmj_stock_manager/view_models/controller/purchase_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PurchaseController purchaseController =
        Get.find<PurchaseController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
                        decoration: InputDecoration(
                          hintText: "Search bills, vendors...",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
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

                  if (purchaseController.purchaseList.isEmpty) {
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
                              "No Purchase Bills Found",
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
                    itemCount: purchaseController.purchaseList.length,
                    itemBuilder: (context, index) {
                      final purchase = purchaseController.purchaseList[index];
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor & Status Row
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A1A4F).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getVendorInitials(vendor.name),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vendor.firmName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    color: _getStatusColor(purchase.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getStatusColor(purchase.status),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    purchase.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(purchase.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Bill Number & Items Count
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bill Number",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              Text(
                                purchase.billNumber,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A4F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1A1A4F)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 16,
                        color: const Color(0xFF1A1A4F),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$itemCount Items",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A4F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 16),

            // Amount Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹ ${purchase.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A4F),
                      ),
                    ),
                  ],
                ),
                if (outstanding > 0)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Outstanding",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "₹ ${outstanding.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // View Details Button
            AppGradientButton(
              onPressed: () {
                Get.to(() => PurchaseDetails(purchase: purchase));
              },
              text: "View Full Details",
              width: double.infinity,
              height: 50,
            ),

          ],
        ),
      ),
    );
  }
}
