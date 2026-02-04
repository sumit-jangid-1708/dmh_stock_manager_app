import 'package:dmj_stock_manager/view_models/controller/billing_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../model/bills_model/bill_response_model.dart';
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
                      borderRadius: BorderRadius.circular(12),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Summary Cards (Optional - you can keep your BillingCardsList here)
            // BillingCardsList(),

            // ✅ Search + Filter
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: billingController.searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Obx(
                          () => billingController.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    billingController.searchController.clear();
                                    billingController.searchBills('');
                                  },
                                  icon: const Icon(Icons.close),
                                )
                              : const SizedBox(),
                        ),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Search by customer, mobile...",
                      ),
                      onChanged: (value) =>
                          billingController.searchBills(value),
                    ),
                  ),
                  // const SizedBox(width: 10),
                  // SizedBox(
                  //   height: 48,
                  //   width: 48,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       showModalBottomSheet(
                  //         context: context,
                  //         isScrollControlled: true,
                  //         shape: const RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.vertical(
                  //             top: Radius.circular(20),
                  //           ),
                  //         ),
                  //         builder: (BuildContext context) {
                  //           return Padding(
                  //             padding: EdgeInsets.only(
                  //               bottom: MediaQuery.of(
                  //                 context,
                  //               ).viewInsets.bottom,
                  //             ),
                  //             child: const BillingFilterBottomSheet(),
                  //           );
                  //         },
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: const Color(0xFF1A1A4F),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       padding: EdgeInsets.zero,
                  //     ),
                  //     child: const FaIcon(
                  //       FontAwesomeIcons.filter,
                  //       color: Colors.white,
                  //       size: 22,
                  //     ),
                  //   ),
                  // ),
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
                        return Obx(
                          () => billingController.isLoadingMore.value
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox(),
                        );
                      }

                      final bill = displayBills[index];
                      return BillingCardWidget(
                        bill: bill,
                        onTap: () {
                          // ✅ Use Get.to instead of Get.toNamed
                          Get.to(
                            () => BillDetailScreen(),
                            arguments: bill,
                          );
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

class BillingCardWidget extends StatelessWidget {
  final BillModel bill;
  final VoidCallback onTap;

  const BillingCardWidget({super.key, required this.bill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    DateTime createdDate;
    try {
      createdDate = DateTime.parse(bill.createdAt);
    } catch (e) {
      createdDate = DateTime.now();
    }

    // ✅ Payment Status from API
    bool isPaid = bill.paidStatus.toLowerCase() == 'paid';
    bool isPartiallyPaid = bill.paidStatus.toLowerCase() == 'partially_paid';
    bool isPending =
        bill.paidStatus.toLowerCase() == 'pending' ||
        bill.paidStatus.toLowerCase() == 'unpaid';

    Color statusColor = isPaid
        ? Colors.green
        : isPartiallyPaid
        ? Colors.orange
        : Colors.red;

    String statusText = isPaid
        ? 'Paid'
        : isPartiallyPaid
        ? 'Partially Paid'
        : 'Pending';

    IconData statusIcon = isPaid
        ? Icons.check_circle
        : isPartiallyPaid
        ? Icons.hourglass_bottom
        : Icons.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Header Row - Invoice ID, Status & Items Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INV-${bill.id.toString().padLeft(6, '0')}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A4F),
                            ),
                          ),
                          Text(
                            '${bill.items.length} items',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ✅ Customer Info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.customerName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            '${bill.countryCode} ${bill.mobile}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Amount Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1A1A4F).withOpacity(0.05),
                      Color(0xFF2D2D7F).withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFF1A1A4F).withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '₹${bill.subtotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GST',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '₹${bill.gstAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 16, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A4F),
                          ),
                        ),
                        Text(
                          '₹${bill.grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A4F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Date & Payment Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy').format(createdDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (bill.paymentMethod != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.payment, size: 12, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            _formatPaymentMethod(bill.paymentMethod!),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ✅ View Details Button
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1A4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
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
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'upi':
        return 'UPI';
      case 'card':
        return 'Card';
      case 'net_banking':
        return 'Net Banking';
      default:
        return method;
    }
  }
}
