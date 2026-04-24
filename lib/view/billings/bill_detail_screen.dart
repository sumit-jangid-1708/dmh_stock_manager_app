// lib/view/billings/bill_detail_screen.dart

import 'package:dmj_stock_manager/view/billings/pdf_invoice_helper.dart';
import 'package:dmj_stock_manager/view_models/controller/billing_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/bills_model/bill_response_model.dart';
import '../../res/components/widgets/company_details_form_sheet.dart';

class BillDetailScreen extends StatelessWidget {
  BillDetailScreen({super.key});

  final BillingController billingController = Get.find<BillingController>();
  final ItemController itemController = Get.find<ItemController>();

  // ── PDF action handler ───────────────────────────────────────────────────

  /// Intercepts Share / Download button taps.
  ///
  /// 1. Opens [CompanyDetailsFormSheet] to collect company info.
  /// 2. If user submits valid details, generates the PDF.
  /// 3. Shows a loader overlay while generating.
  Future<void> _handlePdfAction(
      BuildContext context,
      BillModel bill,
      String action, // 'share' | 'download'
      ) async {
    // Open bottom sheet — pre-fill with last used details from this session.
    final details = await CompanyDetailsFormSheet.show(
      context,
      prefill: billingController.lastCompanyDetails,
    );

    // User dismissed the sheet without submitting.
    if (details == null) return;

    // Trigger PDF generation via controller.
    await billingController.generateInvoiceWithCompanyDetails(
      bill: bill,
      company: details,
      action: action,
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final BillModel bill = Get.arguments as BillModel;

    DateTime createdDate;
    try {
      createdDate = DateTime.parse(bill.createdAt);
    } catch (_) {
      createdDate = DateTime.now();
    }

    // ── Payment status ───────────────────────────────────────────────────
    final bool isPaid = bill.paidStatus.toLowerCase() == 'paid';
    final bool isPartiallyPaid =
        bill.paidStatus.toLowerCase() == 'partially_paid';

    final Color statusColor = isPaid
        ? Colors.green
        : isPartiallyPaid
        ? Colors.orange
        : Colors.red;

    final String statusText = isPaid
        ? 'PAID'
        : isPartiallyPaid
        ? 'PARTIALLY PAID'
        : 'PENDING';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // ── Gradient header ────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A1A4F).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── App bar row ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Back button
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

                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invoice #${bill.id.toString().padLeft(6, '0')}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a')
                                    .format(createdDate),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Share button (intercepted) ─────────────
                        Obx(
                              () => _HeaderIconButton(
                            icon: Icons.share_rounded,
                            isLoading: billingController.isGeneratingPdf.value,
                            onPressed: () =>
                                _handlePdfAction(context, bill, 'share'),
                          ),
                        ),

                        // ── Download button (intercepted) ──────────
                        Obx(
                              () => _HeaderIconButton(
                            icon: Icons.download_rounded,
                            isLoading: billingController.isGeneratingPdf.value,
                            onPressed: () =>
                                _handlePdfAction(context, bill, 'download'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Amount + status chip ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        const Text(
                          'Bill Amount',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${bill.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
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
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPaid
                                    ? Icons.check_circle
                                    : Icons.pending_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                statusText,
                                style: const TextStyle(
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

            // ── Scrollable content ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ── Customer information ───────────────────────
                    _buildInfoCard(
                      icon: Icons.person_outline_rounded,
                      title: 'Customer Information',
                      color: Colors.blue,
                      children: [
                        _buildDetailRow(
                          'Name',
                          bill.customerName,
                          Icons.person_rounded,
                        ),
                        const Divider(height: 20),
                        _buildDetailRow(
                          'Mobile',
                          '${bill.countryCode} ${bill.mobile}',
                          Icons.phone_rounded,
                        ),
                        if (bill.remarks != null &&
                            bill.remarks!.isNotEmpty) ...[
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Remarks',
                            bill.remarks is List
                                ? (bill.remarks as List).join('\n')
                                : bill.remarks.toString(),
                            Icons.note_rounded,
                            maxLines: 3,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Payment information ────────────────────────
                    _buildInfoCard(
                      icon: Icons.payment_rounded,
                      title: 'Payment Details',
                      color: statusColor,
                      children: [
                        _buildAmountRow('Subtotal', bill.subtotal),
                        const Divider(height: 20),
                        _buildAmountRow(
                          'GST Amount',
                          bill.gstAmount,
                          color: Colors.orange,
                        ),
                        const Divider(height: 20),
                        _buildAmountRow(
                          'Grand Total',
                          bill.grandTotal,
                          isBold: true,
                        ),
                        if (bill.paymentMethod != null) ...[
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Payment Method',
                            _formatPaymentMethod(bill.paymentMethod!),
                            Icons.account_balance_wallet_rounded,
                          ),
                        ],
                        if (bill.paymentDate != null) ...[
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Payment Date',
                            _formatDate(bill.paymentDate!),
                            Icons.calendar_today_rounded,
                          ),
                        ],
                        if (bill.transactionId != null) ...[
                          const Divider(height: 20),
                          _buildDetailRow(
                            'Transaction ID',
                            bill.transactionId!,
                            Icons.receipt_long_rounded,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Items section ──────────────────────────────
                    _buildItemsSection(bill),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable card ────────────────────────────────────────────────────────

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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.04),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Card body
          Padding(
            padding: const EdgeInsets.all(16),
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
        const SizedBox(width: 12),
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
            style: const TextStyle(
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
            color: isBold ? const Color(0xFF1A1A4F) : Colors.grey.shade700,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? (isBold ? const Color(0xFF1A1A4F) : Colors.black87),
          ),
        ),
      ],
    );
  }

  // ── Items section ────────────────────────────────────────────────────────

  Widget _buildItemsSection(BillModel bill) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1A4F).withOpacity(0.08),
                  const Color(0xFF2D2D7F).withOpacity(0.04),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A4F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: Color(0xFF1A1A4F),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sold Items',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A4F),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A4F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${bill.items.length} Items',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items list
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bill.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildItemCard(bill.items[index], index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BillItemModel item, int index) {
    final product = item.product;
    final totalPrice = item.quantity * item.unitPrice;

    final String? imageUrl =
    product.imageVariants.isNotEmpty ? product.imageVariants[0] : null;

    // HSN lookup
    String hsnDisplay = 'N/A';
    if (product.hsn != null) {
      final hsnModel = itemController.hsnList.firstWhereOrNull(
            (h) => h.id == product.hsn,
      );
      hsnDisplay = hsnModel?.hsnCode ?? 'HSN ID: ${product.hsn}';
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
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image with index badge
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
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported_rounded,
                            color: Colors.grey,
                          ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A4F),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.qr_code, size: 12,
                              color: Colors.grey),
                          const SizedBox(width: 4),
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
                      const SizedBox(height: 6),

                      // Attribute chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (product.size.isNotEmpty)
                            _attributeChip(
                                product.size, Icons.straighten, Colors.blue),
                          if (product.color.isNotEmpty)
                            _attributeChip(
                                product.color, Icons.palette, Colors.red),
                          if (product.material.isNotEmpty)
                            _attributeChip(
                                product.material, Icons.category, Colors.brown),
                          if (product.hsn != null)
                            _attributeChip(
                                hsnDisplay, Icons.code, Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Price footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A4F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Qty: ${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF1A1A4F),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1A1A4F).withOpacity(0.08),
                        const Color(0xFF2D2D7F).withOpacity(0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Item Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
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

  Widget _attributeChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
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

  // ── Formatters ───────────────────────────────────────────────────────────

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
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }
}

// ── _HeaderIconButton ──────────────────────────────────────────────────────
// Small icon button in the header that disables itself while PDF is generating.

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Padding(
      padding: EdgeInsets.all(12),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white70,
        ),
      ),
    )
        : IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onPressed,
    );
  }
}