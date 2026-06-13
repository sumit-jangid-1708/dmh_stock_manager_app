import 'package:dmj_stock_manager/model/purchase_models/purchase_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient _button.dart';
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
    final PurchaseController purchaseController = Get.find<PurchaseController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => purchaseController.getPurchaseList(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A4F),
                            ),
                          ),
                          Text(
                            "Manage all vendor purchases",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                          onChanged: (value) {
                            purchaseController.searchQuery.value = value;
                          },
                          decoration: Utils.inputDecoration(
                            "Search bills, vendors...",
                            Icons.search,
                          ).copyWith(
                            fillColor: Colors.white,
                            filled: true,
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
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                const SizedBox(height: 25),
                const Text(
                  "Recent Purchase Bills",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A4F),
                  ),
                ),
                const SizedBox(height: 12),
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
                              Icons.receipt_long_outlined,
                              size: 70,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              purchaseController.searchQuery.value.isEmpty
                                  ? "No Purchase Bills Found"
                                  : "No matching bills found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
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
                      return PurchaseListCard(purchase: listToShow[index]);
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
        return const Color(0xFF2E7D32);
      case 'UNPAID':
        return const Color(0xFFD84315);
      case 'PARTIAL PAID':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  double _parseAmount(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final vendorName = purchase.vendor?.name ?? 'Unknown Vendor';
    final itemCount = purchase.items?.length ?? 0;
    final totalAmount = _parseAmount(purchase.totalAmount);
    final paidAmount = _parseAmount(purchase.paidAmount);
    final outstanding = totalAmount - paidAmount;
    final statusColor = _getStatusColor(purchase.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => PurchaseDetails(purchase: purchase)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A4F), Color(0xFF3F3F8F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getVendorInitials(vendorName),
                      style: const TextStyle(
                        fontSize: 16,
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
                        Text(
                          vendorName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A4F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (purchase.status ?? 'N/A').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            if ((purchase.gstType ?? '').toLowerCase().contains('with')) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "GST",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _actionButton(
                        icon: Icons.edit_outlined,
                        color: const Color(0xFF1A1A4F),
                        onTap: () {
                          final controller = Get.find<PurchaseController>();
                          controller.populateFormForEdit(purchase);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => AddPurchaseBottomSheet(),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      _actionButton(
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        onTap: () => _showDeleteDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoTile(Icons.receipt_outlined, purchase.billNumber ?? '-'),
                  _infoTile(Icons.calendar_today_outlined, purchase.billDate ?? '-'),
                  _infoTile(Icons.inventory_2_outlined, "$itemCount Items"),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Amount", style: TextStyle(fontSize: 10, color: Colors.blueGrey)),
                          Text(
                            "₹${NumberFormat('#,##,###').format(totalAmount)}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A4F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (outstanding > 0) ...[
                      Container(width: 1, height: 25, color: Colors.blueGrey.withOpacity(0.2)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Balance Due", style: TextStyle(fontSize: 10, color: Colors.red.shade400)),
                            Text(
                              "₹${NumberFormat('#,##,###').format(outstanding)}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.blueGrey.shade300),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.blueGrey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final controller = Get.find<PurchaseController>();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Bill?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Kya aap bill '${purchase.billNumber}' ko delete karna chahte hain?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Nahi", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              controller.deletePurchaseBill(purchase.id!);
            },
            child: const Text("Haan, Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
