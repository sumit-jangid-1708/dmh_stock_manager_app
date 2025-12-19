import 'package:dmj_stock_manager/view_models/controller/billing_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../res/components/widgets/billing_filter_bottom_sheet.dart';
import '../../res/components/widgets/billng_cards_widget.dart';
import 'bill_detail_screen.dart';

class BillingScreen extends StatelessWidget {
  BillingScreen({super.key});

  final BillingController billingController = Get.put(BillingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ✅ Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey.shade500),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 22),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Billings",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Summary Cards (Optional - you can keep your BillingCardsList here)
            BillingCardsList(),

            // ✅ Search + Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: billingController.searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Obx(() => billingController.searchQuery.value.isNotEmpty
                            ? IconButton(
                          onPressed: () {
                            billingController.searchController.clear();
                            billingController.searchBills('');
                          },
                          icon: const Icon(Icons.close),
                        )
                            : const SizedBox()),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Search by customer, mobile...",
                      ),
                      onChanged: (value) => billingController.searchBills(value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: const BillingFilterBottomSheet(),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A4F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.filter,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✅ Bills List with Pagination
            Expanded(
              child: Obx(() {
                if (billingController.isLoading.value &&
                    billingController.bills.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (billingController.bills.isEmpty) {
                  return const Center(
                    child: Text(
                      "No bills found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final displayBills = billingController.filteredBills;

                return RefreshIndicator(
                  onRefresh: billingController.refreshBills,
                  child: ListView.builder(
                    controller: billingController.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    itemCount: displayBills.length + 1,
                    itemBuilder: (context, index) {
                      // ✅ Loading indicator at bottom
                      if (index == displayBills.length) {
                        return Obx(() => billingController.isLoadingMore.value
                            ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                            : const SizedBox());
                      }

                      final bill = displayBills[index];
                      return BillingCardWidget(
                        bill: bill,
                        onTap: () {
                          // ✅ Use Get.to instead of Get.toNamed
                          Get.to(() => const BillDetailScreen(), arguments: bill);
                        },
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
}

// ✅ Original Design Billing Card Widget with Outstanding Amount
class BillingCardWidget extends StatelessWidget {
  final dynamic bill; // BillModel
  final VoidCallback onTap;

  const BillingCardWidget({
    Key? key,
    required this.bill,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse date
    DateTime? createdDate;
    try {
      createdDate = DateTime.parse(bill.createdAt);
    } catch (e) {
      createdDate = DateTime.now();
    }

    // ✅ Calculate Outstanding Amount (Grand Total - Paid Amount)
    // If paidAmount field exists in model, use it, otherwise default to 0
    double paidAmount = 0.0; // bill.paidAmount ?? 0.0; // Use this if model has paidAmount
    double outstandingAmount = bill.grandTotal - paidAmount;

    // ✅ Determine status
    String status = outstandingAmount > 0 ? 'Pending' : 'Paid';
    Color statusColor = outstandingAmount > 0 ? Colors.orange : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header Row - Invoice ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INV-${bill.id.toString().padLeft(6, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A4F),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ✅ Customer Name
            Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bill.customerName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ✅ Bill Details Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildAmountRow('Bill Amount', bill.grandTotal),
                  const SizedBox(height: 8),
                  _buildAmountRow('Paid Amount', paidAmount, color: Colors.green),
                  const Divider(height: 16),
                  _buildAmountRow(
                    'Outstanding',
                    outstandingAmount,
                    color: Colors.red,
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Date: ${DateFormat('dd/MM/yyyy').format(createdDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Due: ${DateFormat('dd/MM/yyyy').format(createdDate.add(const Duration(days: 30)))}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ✅ View Detail Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            color: Colors.grey[700],
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}