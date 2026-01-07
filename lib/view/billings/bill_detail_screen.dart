import 'package:dmj_stock_manager/view/billings/pdf_invoice_helper.dart';
import 'package:dmj_stock_manager/view_models/controller/billing_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/bill_response_model.dart';

class BillDetailScreen extends StatelessWidget {
  BillDetailScreen({super.key});
  final BillingController billingController = Get.find<BillingController>();
  final ItemController itemController = Get.find<ItemController>();

  @override
  Widget build(BuildContext context) {
    final BillModel bill = Get.arguments as BillModel;

    DateTime createdDate;
    try {
      createdDate = DateTime.parse(bill.createdAt);
    } catch (e) {
      createdDate = DateTime.now();
    }

    String hsnDisplay = "N/A";
    int? hsnId = bill.items.first.product.hsn;

    if (hsnId != null) {
      final hsnModel = itemController.hsnList.firstWhereOrNull(
        (h) => h.id == hsnId,
      );
      hsnDisplay = hsnModel?.hsnCode ?? "HSN ID: $hsnId";
    }
    // ✅ Payment Status Logic
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
        ? 'PAID'
        : isPartiallyPaid
        ? 'PARTIALLY PAID'
        : 'PENDING';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // 🎨 Gradient Header with Status
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1A1A4F).withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Row
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: () => Get.back(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invoice #${bill.id.toString().padLeft(6, '0')}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy, hh:mm a',
                                ).format(createdDate),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () async {
                            await PdfInvoiceHelper.generateAndShare(bill);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.download, color: Colors.white),
                          onPressed: () async {
                            await PdfInvoiceHelper.generateAndDownload(bill);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Amount Display
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Bill Amount',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₹${bill.grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPaid ? Icons.check_circle : Icons.pending,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 📋 Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 👤 Customer Information
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      title: 'Customer Information',
                      color: Colors.blue,
                      children: [
                        _buildDetailRow(
                          'Name',
                          bill.customerName,
                          Icons.person,
                        ),
                        Divider(height: 20),
                        _buildDetailRow(
                          'Mobile',
                          '${bill.countryCode} ${bill.mobile}',
                          Icons.phone,
                        ),
                        if (bill.remarks != null &&
                            bill.remarks!.isNotEmpty) ...[
                          Divider(height: 20),
                          _buildDetailRow(
                            'Remarks',
                            bill.remarks!,
                            Icons.note,
                            maxLines: 3,
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 16),

                    // 💰 Payment Information
                    _buildInfoCard(
                      icon: Icons.payment,
                      title: 'Payment Details',
                      color: statusColor,
                      children: [
                        _buildAmountRow('Subtotal', bill.subtotal),
                        Divider(height: 20),
                        _buildAmountRow(
                          'GST Amount',
                          bill.gstAmount,
                          color: Colors.orange,
                        ),
                        Divider(height: 20),
                        _buildAmountRow(
                          'Grand Total',
                          bill.grandTotal,
                          isBold: true,
                        ),
                        if (bill.paymentMethod != null) ...[
                          Divider(height: 20),
                          _buildDetailRow(
                            'Payment Method',
                            _formatPaymentMethod(bill.paymentMethod!),
                            Icons.account_balance_wallet,
                          ),
                        ],
                        if (bill.paymentDate != null) ...[
                          Divider(height: 20),
                          _buildDetailRow(
                            'Payment Date',
                            _formatDate(bill.paymentDate!),
                            Icons.calendar_today,
                          ),
                        ],
                        if (bill.transactionId != null) ...[
                          Divider(height: 20),
                          _buildDetailRow(
                            'Transaction ID',
                            bill.transactionId!,
                            Icons.receipt_long,
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 16),

                    // 📦 Items Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF1A1A4F).withOpacity(0.1),
                                  Color(0xFF2D2D7F).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1A1A4F).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: Color(0xFF1A1A4F),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Sold Items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A4F),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1A1A4F),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${bill.items.length} Items',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Items List
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: bill.items.length,
                              separatorBuilder: (_, __) => SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildItemCard(bill.items[index], index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Color(0xFF1A1A4F) : Colors.grey.shade700,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? (isBold ? Color(0xFF1A1A4F) : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(BillItemModel item, int index) {
    final product = item.product;
    final totalPrice = item.quantity * item.unitPrice;

    // Get first image if available
    String? imageUrl;
    if (product.imageVariants.isNotEmpty) {
      imageUrl = product.imageVariants[0];
    }

    // ✅ HSN Code Lookup from hsnList
    String hsnDisplay = "N/A";
    if (product.hsn != null) {
      final hsnModel = itemController.hsnList.firstWhereOrNull(
        (h) => h.id == product.hsn,
      );
      hsnDisplay = hsnModel?.hsnCode ?? "HSN ID: ${product.hsn}";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade200,
                              Colors.grey.shade100,
                            ],
                          ),
                        ),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                'https://traders.testwebs.in$imageUrl',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.image, color: Colors.grey),
                              )
                            : Icon(
                                Icons.image_outlined,
                                color: Colors.grey.shade400,
                                size: 35,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A1A4F),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.qr_code, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.sku,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),

                      // ✅ Attributes + HSN Code Chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (product.size.isNotEmpty)
                            _buildAttributeChip(
                              product.size,
                              Icons.straighten,
                              Colors.blue,
                            ),
                          if (product.color.isNotEmpty)
                            _buildAttributeChip(
                              product.color,
                              Icons.palette,
                              Colors.red,
                            ),
                          if (product.material.isNotEmpty)
                            _buildAttributeChip(
                              product.material,
                              Icons.category,
                              Colors.brown,
                            ),
                          // ✅ HSN Code Chip
                          if (product.hsn != null)
                            _buildAttributeChip(
                              hsnDisplay,
                              Icons.code,
                              Colors.purple,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Price Section
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Unit Price: ₹${item.unitPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1A4F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Qty: ${item.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF1A1A4F),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1A1A4F).withOpacity(0.1),
                        Color(0xFF2D2D7F).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Item Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A4F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HSN Chip के लिए helper
  Widget _buildAttributeChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

// Widget _buildAttributeChip(String label, IconData icon, Color color) {
//   return Container(
//     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//     decoration: BoxDecoration(
//       color: color.withOpacity(0.1),
//       borderRadius: BorderRadius.circular(6),
//       border: Border.all(color: color.withOpacity(0.3)),
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 10, color: color),
//         SizedBox(width: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//             color: color,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
//
// import '../../model/bill_response_model.dart';
//
// class BillDetailScreen extends StatelessWidget {
//   const BillDetailScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get bill from arguments
//     final bill = Get.arguments; // BillModel
//
//     if (bill == null) {
//       return Scaffold(
//         body: const Center(child: Text('No bill data found')),
//       );
//     }
//
//     DateTime createdDate;
//     try {
//       createdDate = DateTime.parse(bill.createdAt);
//     } catch (e) {
//       createdDate = DateTime.now();
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text('Bill #${bill.id}'),
//         backgroundColor: const Color(0xFF1A1A4F),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () {
//               // TODO: Implement share functionality
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: () {
//               // TODO: Implement download PDF
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // ✅ Header Card
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: Color(0xFF1A1A4F),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(30),
//                   bottomRight: Radius.circular(30),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     'Total Amount',
//                     style: TextStyle(color: Colors.white70, fontSize: 14),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '₹${bill.grandTotal.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Text(
//                       'PAID',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // ✅ Customer Info Card
//             _buildInfoCard(
//               title: 'Customer Information',
//               children: [
//                 _buildInfoRow(Icons.person, 'Name', bill.customerName),
//                 const Divider(),
//                 _buildInfoRow(Icons.phone, 'Mobile', bill.mobile),
//                 const Divider(),
//                 _buildInfoRow(
//                   Icons.calendar_today,
//                   'Date',
//                   DateFormat('dd MMM yyyy, hh:mm a').format(createdDate),
//                 ),
//                 if (bill.remarks != null && bill.remarks!.isNotEmpty) ...[
//                   const Divider(),
//                   _buildInfoRow(Icons.note, 'Remarks', bill.remarks!),
//                 ],
//               ],
//             ),
//
//             const SizedBox(height: 16),
//
//             // ✅ Bill Summary Card
//             _buildInfoCard(
//               title: 'Bill Summary',
//               children: [
//                 _buildAmountRow('Subtotal', bill.subtotal),
//                 const Divider(),
//                 _buildAmountRow(
//                   'GST (${bill.gstPercentage}%)',
//                   bill.gstAmount,
//                 ),
//                 const Divider(),
//                 _buildAmountRow(
//                   'Grand Total',
//                   bill.grandTotal,
//                   isBold: true,
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 16),
//
//             // ✅ Items Card
//             _buildInfoCard(
//               title: 'Items (${bill.items.length})',
//               children: bill.items.map<Widget>((BillItemModel item) {
//                 return Column(
//                   children: [
//                     _buildItemCard(item),
//                     if (bill.items.last != item) const SizedBox(height: 12),
//                   ],
//                 );
//               }).toList(),
//
//             ),
//
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoCard({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1A1A4F),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey[600]),
//           const SizedBox(width: 12),
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAmountRow(String label, double amount, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isBold ? 16 : 14,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: isBold ? const Color(0xFF1A1A4F) : Colors.grey[700],
//             ),
//           ),
//           Text(
//             '₹${amount.toStringAsFixed(2)}',
//             style: TextStyle(
//               fontSize: isBold ? 18 : 14,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
//               color: isBold ? const Color(0xFF1A1A4F) : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItemCard(BillItemModel item) {
//     final product = item.product;
//     final imageUrl = product.image;
//     final totalPrice = item.quantity * item.unitPrice;
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(8),
//               image: imageUrl != null
//                   ? DecorationImage(
//                 image: NetworkImage("https://traders.testwebs.in$imageUrl"),
//                 fit: BoxFit.cover,
//               )
//                   : null,
//             ),
//             child: imageUrl == null
//                 ? const Icon(Icons.image, color: Colors.grey)
//                 : null,
//           ),
//
//           const SizedBox(width: 12),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   product.name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "${product.size} • ${product.color} • ${product.material}",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Qty: ${item.quantity}",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Text(
//                       "₹${item.unitPrice.toStringAsFixed(2)} each",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: Text(
//                     "₹${totalPrice.toStringAsFixed(2)}",
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1A1A4F),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
