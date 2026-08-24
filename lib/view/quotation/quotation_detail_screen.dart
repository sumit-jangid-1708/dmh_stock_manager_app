import 'package:dmj_stock_manager/model/quotation_models/quotation_detail_model.dart';
import 'package:dmj_stock_manager/view/quotation/create_quotation_screen.dart';
import 'package:dmj_stock_manager/view/quotation/quotation_preview_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/quotation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class QuotationDetailScreen extends StatefulWidget {
  final int quotationId;
  const QuotationDetailScreen({super.key, required this.quotationId});

  @override
  State<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends State<QuotationDetailScreen> {
  final controller = Get.find<QuotationController>();
  static const primaryColor = Color(0xFF1A1A4F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getQuotationDetail(widget.quotationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Quotation Detail',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            final data = controller.quotationDetail.value;
            if (data == null) return const SizedBox();
            
            return Row(
              children: [
                // ✅ Edit Button
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    controller.setQuotationForEdit(data);
                    Get.to(() => CreateQuotationScreen(isEdit: true, quotId: data.id));
                  },
                  tooltip: 'Edit Quotation',
                ),
                // ✅ Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(context, data.id!),
                  tooltip: 'Delete Quotation',
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: () => Get.to(() => QuotationPreviewScreen(quotation: data)),
                  tooltip: 'Preview & Print',
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => controller.shareQuotationPdf(
                      data.pdfDownloadUrl, data.number),
                  tooltip: 'Share PDF',
                ),
                const SizedBox(width: 8),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: primaryColor));
        }

        final data = controller.quotationDetail.value;
        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text("Quotation details not found",
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.getQuotationDetail(widget.quotationId),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text("Retry", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Summary Header
              _buildSummaryHeader(data),
              const SizedBox(height: 24),

              // 2. Billing & Shipping Addresses
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildAddressCard(
                      "BILLING TO",
                      data.customerName,
                      data.customerAddress,
                      data.customerPhone,
                      data.customerEmail,
                      data.customerGstin,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAddressCard(
                      "SHIPPING TO",
                      data.consigneeName,
                      data.consigneeAddress,
                      null,
                      null,
                      data.consigneeGstin,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Items Section
              _buildSectionHeader("QUOTED ITEMS"),
              const SizedBox(height: 12),
              _buildItemsTable(data.items ?? []),
              const SizedBox(height: 24),

              // 4. Footer: Terms and Totals
              _buildFooterSection(data),
              const SizedBox(height: 30),

              // ✅ Prominent Preview & Print Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => QuotationPreviewScreen(quotation: data)),
                  icon: const Icon(Icons.print, color: Colors.white),
                  label: const Text("PREVIEW & PRINT QUOTATION", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Quotation"),
        content: const Text("Are you sure you want to delete this quotation? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await controller.deleteQuotation(id); // Call API
              Get.back(); // Return to Quotation History Screen
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(QuotationDetailModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Quotation Number",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(data.number ?? 'N/A',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primaryColor)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Quote Date",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    DateFormat('dd MMM, yyyy').format(
                        DateTime.tryParse(data.quoteDate ?? '') ??
                            DateTime.now()),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleInfo("Valid Until", 
                DateFormat('dd MMM, yyyy').format(
                  DateTime.tryParse(data.validUntil ?? '') ?? DateTime.now())),
              _buildSimpleInfo("Grand Total", "₹${data.grandTotal}", isHighlight: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInfo(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: isHighlight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isHighlight ? 18 : 14,
                color: isHighlight ? Colors.green.shade700 : Colors.black87)),
      ],
    );
  }

  Widget _buildAddressCard(String title, String? name, String? address,
      String? phone, String? email, String? gstin) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: primaryColor,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text(name ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          if (phone != null && phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(phone, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ),
          if (email != null && email.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(email, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ),
          Text(address ?? 'No address provided',
              style: const TextStyle(color: Colors.black54, fontSize: 12),
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
          if (gstin != null && gstin.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("GSTIN: $gstin",
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: Colors.blueGrey)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildItemsTable(List<QuotationItemDetailModel> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: items.map((item) {
          final index = items.indexOf(item);
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.05),
                  child: Text("${index + 1}", 
                    style: const TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                title: Text(item.productName ?? 'Unknown Product',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "SKU: ${item.sku} • ${item.quantity} ${item.unit} x ₹${item.unitPrice}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
                trailing: Text("₹${item.totalAmount}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor)),
              ),
              if (index < items.length - 1)
                Divider(height: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooterSection(QuotationDetailModel data) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Terms and Notes
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTermRow("Payment Terms", data.paymentTerms),
                    _buildTermRow("Dispatch Via", data.dispatchedThrough),
                    _buildTermRow("Destination", data.destination),
                    _buildTermRow("Delivery Terms", data.deliveryTerms),
                    if (data.notes != null && data.notes!.isNotEmpty) ...[
                      const Divider(height: 24),
                      const Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(data.notes!, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Totals
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildAmountRow("Subtotal", data.subtotal),
                    _buildAmountRow("Tax Total", data.taxTotal),
                    _buildAmountRow("Shipping", data.shippingAmount),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(),
                    ),
                    _buildAmountRow("Grand Total", data.grandTotal, isBold: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String? value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: isBold ? primaryColor : Colors.black54,
                  fontSize: isBold ? 13 : 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("₹${value ?? '0.00'}",
              style: TextStyle(
                  color: isBold ? primaryColor : Colors.black87,
                  fontSize: isBold ? 15 : 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }
}
