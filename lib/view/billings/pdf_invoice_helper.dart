// lib/view/billings/pdf_invoice_helper.dart

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../model/bills_model/bill_response_model.dart';
import '../../model/bills_model/company_details_model.dart';
import '../../view_models/controller/item_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Generates and shares/downloads invoice PDFs.
///
/// [CompanyDetails] must be passed explicitly — no dependency on GetStorage
/// or any global settings. This allows per-bill company info.
class PdfInvoiceHelper {
  // Private constructor — use only static methods.
  const PdfInvoiceHelper._();

  // ── Public entry points ──────────────────────────────────────────────────

  /// Builds the PDF and triggers the OS share sheet.
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

  /// Builds the PDF and opens the print/layout dialog.
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

    // HSN lookup — ItemController must already be registered via Get.find.
    final ItemController itemController = Get.find<ItemController>();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ── HEADER ────────────────────────────────────────────────────
          _buildHeader(bill, company),
          pw.SizedBox(height: 30),

          // ── CUSTOMER INFO ─────────────────────────────────────────────
          _buildCustomerInfo(bill),
          pw.SizedBox(height: 20),

          // ── ITEMS TABLE ───────────────────────────────────────────────
          _buildItemsTable(bill, itemController),
          pw.SizedBox(height: 20),

          // ── SUMMARY ───────────────────────────────────────────────────
          _buildSummary(bill),
          pw.SizedBox(height: 50),

          pw.Text(
            'Remarks: ${bill.remarks ?? "N/A"}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.Spacer(),
          pw.Divider(),
          pw.Center(
            child: pw.Text(
              'This is a computer generated invoice.',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  // ── Section builders ─────────────────────────────────────────────────────

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
            pw.SizedBox(height: 4),
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

        // Right — company info (from CompanyDetails, NOT settings)
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
            // Only render GSTIN row when it is provided.
            if (company.gst != null && company.gst!.isNotEmpty)
              pw.Text(
                'GSTIN: ${company.gst}',
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
                      ? PdfColors.green
                      : PdfColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(
      BillModel bill,
      ItemController itemController,
      ) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(3.0),   // Product Name
        1: const pw.FlexColumnWidth(1.5),   // HSN/SAC
        2: const pw.FlexColumnWidth(1.0),   // Qty
        3: const pw.FlexColumnWidth(1.5),   // Unit Price
        4: const pw.FlexColumnWidth(1.5),   // Total
      },
      headers: ['Product Name', 'HSN/SAC', 'Qty', 'Unit Price', 'Total'],
      data: bill.items.map((item) {
        // HSN lookup
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

  static pw.Widget _buildSummary(BillModel bill) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: 210,
          child: pw.Column(
            children: [
              _summaryRow('Subtotal', 'Rs. ${bill.subtotal.toStringAsFixed(2)}'),
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
}