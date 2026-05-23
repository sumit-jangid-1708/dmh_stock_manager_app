import 'package:dmj_stock_manager/model/purchase_models/purchase_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/utils/utils.dart';
import 'package:dmj_stock_manager/view/purchase_screen/add_purchase_bottom_sheet.dart';
import 'package:dmj_stock_manager/view/purchase_screen/purchase_details.dart';
import 'package:dmj_stock_manager/view_models/controller/purchase_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchaseScreen extends StatelessWidget {
  PurchaseScreen({super.key});
  final ScrollController _scrollController = ScrollController();

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

                // Header
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

                // Search Bar + Add Button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          purchaseController.searchQuery.value = value;
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

                const Text(
                  "Recent Purchase Bills",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Purchase List
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

                  return Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 6,
                    radius: const Radius.circular(10),
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listToShow.length,
                      itemBuilder: (context, index) {
                        final purchase = listToShow[index];
                        return PurchaseListCard(purchase: purchase);
                      },
                    ),
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
}

class PurchaseListCard extends StatelessWidget {
  final PurchaseBillModel purchase;

  const PurchaseListCard({super.key, required this.purchase});

  String _getVendorInitials(String name) {
    if (name.isEmpty) return "V";
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return "${words[0][0]}${words[1][0]}".toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  Color _getStatusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
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

  // ✅ Safe double parsing from String? fields
  double _parseAmount(String? value) => double.tryParse(value ?? '0') ?? 0.0;

  @override
  Widget build(BuildContext context) {
    final vendorName = purchase.vendor?.name ?? 'Unknown Vendor';
    final itemCount = purchase.items?.length ?? 0;
    final totalAmount = _parseAmount(purchase.totalAmount);
    final paidAmount = _parseAmount(purchase.paidAmount);
    final outstanding = totalAmount - paidAmount;

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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // ── Main row (tappable → detail) ──────────────────────
          InkWell(
            onTap: () => Get.to(() => PurchaseDetails(purchase: purchase)),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
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
                      _getVendorInitials(vendorName),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vendor Name & Status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                vendorName,
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
                                (purchase.status ?? '').toUpperCase(),
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

                        // Bill Number, Date & Items count
                        // ✅ AB — do alag rows
// Row 1: Bill number + GST badge
                        Row(
                          children: [
                            Icon(Icons.receipt_outlined,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                purchase.billNumber ?? '-',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if ((purchase.gstType ?? '').toLowerCase().contains('with')) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "GST",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
// Row 2: Date + Items count
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              purchase.billDate ?? '-',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.inventory_2_outlined,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              "$itemCount Items",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Amount Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                  "₹${NumberFormat('#,##,###').format(totalAmount)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A4F),
                                  ),
                                ),
                              ],
                            ),
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
                                    "₹${NumberFormat('#,##,###').format(outstanding)}",
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

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      InkWell(
                        onTap: () {
                          final controller = Get.find<PurchaseController>();
                          controller.populateFormForEdit(purchase);
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
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A4F).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Color(0xFF1A1A4F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete Button
                      InkWell(
                        onTap: () => _showDeleteDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final controller = Get.find<PurchaseController>();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Purchase Bill",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "'${purchase.billNumber ?? 'this bill'}' permanently delete karna chahte ho?",
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back(); // dialog close
              controller.deletePurchaseBill(purchase.id!);
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
