// lib/view/billings/pdf_invoice_helper.dart

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/bills_model/bill_response_model.dart';
import '../../model/bills_model/company_details_model.dart';
import '../../view_models/controller/item_controller.dart';
/// Generates and shares/downloads invoice PDFs.
///
/// [CompanyDetails] is passed explicitly per-bill — no GetStorage dependency.
class PdfInvoiceHelper {
  const PdfInvoiceHelper._();

  // ── Public entry points ──────────────────────────────────────────────────

  static Future<void> generateAndShare(
      BillModel bill,
      CompanyDetails company,
      ) async {
    final pdf = await _buildPdf(bill, company);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_${bill.id.toString().padLeft(6, '0')}.pdf',
    );
  }

  static Future<void> generateAndDownload(
      BillModel bill,
      CompanyDetails company,
      ) async {
    final pdf = await _buildPdf(bill, company);
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  // ── Core builder ─────────────────────────────────────────────────────────

  static Future<pw.Document> _buildPdf(
      BillModel bill,
      CompanyDetails company,
      ) async {
    final pdf = pw.Document();
    final ItemController itemController = Get.find<ItemController>();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(bill, company),
          pw.SizedBox(height: 30),
          _buildCustomerInfo(bill),
          pw.SizedBox(height: 20),
          _buildItemsTable(bill, itemController),
          pw.SizedBox(height: 20),
          _buildSummary(bill),
          pw.SizedBox(height: 30),
          _buildRemarksRow(bill),          // ← fixed remarks handling
          pw.Spacer(),
          pw.Divider(),
          pw.Center(
            child: pw.Text(
              'This is a computer generated invoice.',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  // ── Header ────────────────────────────────────────────────────────────────

  static pw.Widget _buildHeader(BillModel bill, CompanyDetails company) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left — invoice metadata
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'TAX INVOICE',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Invoice No.: ${bill.id.toString().padLeft(6, '0')}',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ],
        ),

        // Right — company info
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              company.name,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.SizedBox(
              width: 200,
              child: pw.Text(
                company.address,
                softWrap: true,
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.SizedBox(height: 2),

            // GST row — only rendered when provided (nullable field)
            if (company.gst != null && company.gst!.trim().isNotEmpty)
              pw.Text(
                'GSTIN: ${company.gst!.trim()}',
                style: const pw.TextStyle(fontSize: 10),
              ),

            pw.Text(
              company.phone,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  // ── Customer info ─────────────────────────────────────────────────────────

  static pw.Widget _buildCustomerInfo(BillModel bill) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BILL TO:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  bill.customerName,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Text(
                  'Phone: ${bill.countryCode} ${bill.mobile}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'PAYMENT STATUS',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                bill.paidStatus.toUpperCase(),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                  color: bill.paidStatus.toLowerCase() == 'paid'
                      ? PdfColors.green800
                      : PdfColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Items table ───────────────────────────────────────────────────────────

  static pw.Widget _buildItemsTable(
      BillModel bill,
      ItemController itemController,
      ) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 11,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellHeight: 30,
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(3.0),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.0),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      headers: ['Product Name', 'HSN/SAC', 'Qty', 'Unit Price', 'Total'],
      data: bill.items.map((item) {
        String hsnCode = 'N/A';
        if (item.product.hsn != null) {
          final hsnModel = itemController.hsnList.firstWhereOrNull(
                (h) => h.id == item.product.hsn,
          );
          hsnCode = hsnModel?.hsnCode ?? 'N/A';
        }
        return [
          item.product.name,
          hsnCode,
          item.quantity.toString(),
          'Rs. ${item.unitPrice.toStringAsFixed(2)}',
          'Rs. ${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
        ];
      }).toList(),
    );
  }

  // ── Summary ───────────────────────────────────────────────────────────────

  static pw.Widget _buildSummary(BillModel bill) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: 210,
          child: pw.Column(
            children: [
              _summaryRow(
                'Subtotal',
                'Rs. ${bill.subtotal.toStringAsFixed(2)}',
              ),
              _summaryRow(
                'GST Amount',
                'Rs. ${bill.gstAmount.toStringAsFixed(2)}',
              ),
              pw.Divider(),
              _summaryRow(
                'Grand Total',
                'Rs. ${bill.grandTotal.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _summaryRow(
      String label,
      String value, {
        bool isBold = false,
      }) {
    final style = pw.TextStyle(
      fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      fontSize: isBold ? 12 : 11,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  // ── Remarks ───────────────────────────────────────────────────────────────
  //
  // BillModel.remarks can be:
  //   • null
  //   • String         → show as-is
  //   • List<dynamic>  → join with ", "
  //
  // This helper handles all three cases safely.

  static pw.Widget _buildRemarksRow(BillModel bill) {
    final String remarksText = _resolveRemarks(bill.remarks);

    return pw.Text(
      'Remarks: $remarksText',
      style: const pw.TextStyle(
        fontSize: 10,
        color: PdfColors.grey700,
      ),
    );
  }

  /// Safely converts remarks (null / String / List) to a display string.
  static String _resolveRemarks(dynamic remarks) {
    if (remarks == null) return 'N/A';

    if (remarks is String) {
      return remarks.trim().isEmpty ? 'N/A' : remarks.trim();
    }

    if (remarks is List) {
      final parts = remarks
          .map((e) => e?.toString().trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      return parts.isEmpty ? 'N/A' : parts.join(', ');
    }

    // Fallback for any unexpected type
    return remarks.toString().trim().isEmpty
        ? 'N/A'
        : remarks.toString().trim();
  }
}