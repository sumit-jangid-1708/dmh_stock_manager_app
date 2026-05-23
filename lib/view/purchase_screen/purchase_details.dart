import 'package:dmj_stock_manager/model/purchase_models/purchase_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchaseDetails extends StatelessWidget {
  final PurchaseBillModel purchase;
  const PurchaseDetails({super.key, required this.purchase});

  double _amt(String? v) => double.tryParse(v ?? '0') ?? 0.0;
  String _fmt(double v) => NumberFormat('#,##,###.##').format(v);
  String _date(String? s) {
    if (s == null || s.isEmpty) return '-';
    try { return DateFormat('dd MMM, yyyy').format(DateTime.parse(s)); }
    catch (_) { return s; }
  }

  String _initials(String name) {
    final w = name.trim().split(' ');
    return w.length >= 2
        ? '${w[0][0]}${w[1][0]}'.toUpperCase()
        : name.substring(0, 1).toUpperCase();
  }

  Color _statusColor(String? s) {
    switch ((s ?? '').toUpperCase()) {
      case 'PAID':         return Colors.green;
      case 'UNPAID':       return Colors.orange;
      case 'PARTIAL PAID': return Colors.blue;
      default:             return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = purchase.vendor;
    final total  = _amt(purchase.totalAmount);
    final paid   = _amt(purchase.paidAmount);
    final due    = total - paid;
    final tax    = purchase.taxFields;
    final isGst  = (purchase.gstType ?? '').toLowerCase().contains('with');

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(children: [

          // ── Header ──────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text("Purchase Bill Details",
                      style: TextStyle(color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(purchase.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor(purchase.status)),
                  ),
                  child: Text((purchase.status ?? '').toUpperCase(),
                      style: TextStyle(color: _statusColor(purchase.status),
                          fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 12),
              // Bill no + date
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(purchase.billNumber ?? '-',
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(_date(purchase.billDate),
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ]),
          ),

          // ── Body ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Vendor
                  _card(Column(children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A4F).withOpacity(0.06),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF1A1A4F),
                          child: Text(_initials(vendor?.name ?? 'V'),
                              style: const TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vendor?.name ?? '-',
                                style: const TextStyle(fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Text('ID: ${vendor?.id ?? '-'}  •  ${vendor?.mobile ?? '-'}',
                                style: TextStyle(color: Colors.grey.shade600,
                                    fontSize: 12)),
                          ],
                        )),
                      ]),
                    ),
                  ])),
                  const SizedBox(height: 14),

                  // Bill Info
                  _card(_section("Bill Info", [
                    if ((purchase.placeOfSupply ?? '').isNotEmpty)
                      _row("Place of Supply", purchase.placeOfSupply!),
                    _row("Bill Date", _date(purchase.billDate)),
                    if ((purchase.paidDate ?? '').isNotEmpty)
                      _row("Payment Date", _date(purchase.paidDate)),
                  ])),
                  const SizedBox(height: 14),

                  // Financial Summary
                  _card(_section("Financial Summary", [
                    if (_amt(purchase.subtotal) > 0)
                      _row("Subtotal", "₹ ${_fmt(_amt(purchase.subtotal))}"),
                    if (_amt(purchase.discount) > 0)
                      _row("Discount", "- ₹ ${_fmt(_amt(purchase.discount))}",
                          valueColor: Colors.green.shade700),
                    if (_amt(purchase.shipping) > 0)
                      _row("Shipping", "₹ ${_fmt(_amt(purchase.shipping))}"),
                    if (_amt(purchase.otherExpense) > 0)
                      _row("Other Expense", "₹ ${_fmt(_amt(purchase.otherExpense))}"),
                    if (_amt(purchase.roundOff) != 0)
                      _row("Round Off", "₹ ${_fmt(_amt(purchase.roundOff))}"),
                    const Divider(height: 20),
                    _row("Total Amount", "₹ ${_fmt(total)}",
                        bold: true, valueColor: const Color(0xFF1A1A4F)),
                    const SizedBox(height: 6),
                    _row("Paid Amount", "₹ ${_fmt(paid)}",
                        valueColor: Colors.green.shade700),
                    _row("Outstanding", "₹ ${_fmt(due)}",
                        bold: true, valueColor: Colors.red.shade700),
                    if ((purchase.remainingAmount ?? 0) > 0)
                      _row("Remaining",
                          "₹ ${_fmt(purchase.remainingAmount ?? 0)}",
                          valueColor: Colors.orange.shade700),
                  ])),
                  const SizedBox(height: 14),

                  // Tax
                  _card(_section("Tax & GST", [
                    _row("GST Type", isGst ? "With GST" : "No GST"),
                    if (isGst && tax != null) ...[
                      if ((tax.sgstPercent ?? 0) > 0)
                        _row("SGST", "${tax.sgstPercent}%"),
                      if ((tax.cgstPercent ?? 0) > 0)
                        _row("CGST", "${tax.cgstPercent}%"),
                      if ((tax.igstPercent ?? 0) > 0)
                        _row("IGST", "${tax.igstPercent}%"),
                      if ((tax.taxAmount ?? 0) > 0)
                        _row("Tax Amount", "₹ ${_fmt(tax.taxAmount ?? 0)}",
                            bold: true),
                    ],
                  ])),
                  const SizedBox(height: 14),

                  // Payment Mode
                  if ((purchase.paymentMode ?? '').isNotEmpty ||
                      (purchase.transactionId ?? '').isNotEmpty)
                    _card(_section("Payment Details", [
                      if ((purchase.paymentMode ?? '').isNotEmpty)
                        _row("Mode",
                            (purchase.paymentMode ?? '').toUpperCase()),
                      if ((purchase.transactionId ?? '').isNotEmpty)
                        _row("Transaction ID", purchase.transactionId!),
                    ])),
                  if ((purchase.paymentMode ?? '').isNotEmpty ||
                      (purchase.transactionId ?? '').isNotEmpty)
                    const SizedBox(height: 14),

                  // Items header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Purchased Items",
                          style: TextStyle(fontSize: 17,
                              fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A4F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                            "${purchase.items?.length ?? 0} Items",
                            style: const TextStyle(color: Colors.white,
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Items list
                  ...?(purchase.items?.asMap().entries.map((e) =>
                      PurchaseItemCard(item: e.value, index: e.key))),

                  // Description
                  if ((purchase.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Note",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700)),
                          const SizedBox(height: 6),
                          Text(purchase.description!,
                              style: TextStyle(color: Colors.blue.shade900,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _card(Widget child) => Container(
    width: double.infinity,
    margin: EdgeInsets.zero,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
          blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: child,
  );

  Widget _section(String title, List<Widget> rows) => Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                color: Colors.blueGrey.shade600, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        ...rows,
      ],
    ),
  );

  Widget _row(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}

// ── Item Card ─────────────────────────────────────────────────────────────────
class PurchaseItemCard extends StatelessWidget {
  final PurchaseItemModel item;
  final int index;
  const PurchaseItemCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final price = item.unitPrice ?? 0.0;
    final qty   = item.quantity ?? 0;
    final total = (item.totalPrice ?? 0.0) > 0
        ? (item.totalPrice ?? 0.0)
        : price * qty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        // Name + SKU
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF1A1A4F),
              child: Text("${index + 1}",
                  style: const TextStyle(color: Colors.white,
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 14),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                Text("SKU: ${item.productSku ?? '-'}",
                    style: TextStyle(color: Colors.grey.shade500,
                        fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ],
            )),
          ]),
        ),

        // Price row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("₹${price.toStringAsFixed(2)} × $qty",
                  style: TextStyle(color: Colors.grey.shade600,
                      fontSize: 13)),
              Text("₹ ${total.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 15, color: Color(0xFF1A1A4F))),
            ],
          ),
        ),
      ]),
    );
  }
}