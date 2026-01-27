import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../model/bill_response_model.dart';
import '../../view_models/controller/item_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PdfInvoiceHelper {
  static Future<void> generateAndShare(BillModel bill) async {
    final pdf = await _buildPdf(bill);
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice_${bill.id}.pdf');
  }

  static Future<void> generateAndDownload(BillModel bill) async {
    final pdf = await _buildPdf(bill);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<pw.Document> _buildPdf(BillModel bill) async {
    final pdf = pw.Document();

    // Get ItemController to find HSN Code
    final ItemController itemController = Get.find<ItemController>();
    final box = GetStorage();
    final companyName = box.read('companyName') ?? 'Your Company Name';
    final gstNumber = box.read('gstNumber') ?? 'GST: Not Set';
    final address = box.read('address') ?? 'Address: Not Set';
    final contactNumber = box.read('contactNumber') ?? 'Contact: Not Set';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // --- HEADER ---
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('TAX INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.Text('Invoice No.: ${bill.id.toString().padLeft(6, '0')}'),
                  pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(companyName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(
                    height: 30, // Limit height to roughly 2 lines of text
                    child: pw.Text(address, softWrap: true),
                  ),
                  pw.Text('GSTIN: $gstNumber'),
                  pw.Text(contactNumber),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),

          // --- CUSTOMER INFO ---
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text(bill.customerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Phone: ${bill.countryCode} ${bill.mobile}'),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('PAYMENT STATUS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text(bill.paidStatus.toUpperCase(),
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: bill.paidStatus.toLowerCase() == 'paid' ? PdfColors.green : PdfColors.red
                        )
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // --- ITEMS TABLE WITH HSN ---
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
            cellHeight: 30,
            columnWidths: {
              0: const pw.FlexColumnWidth(3), // Product Name
              1: const pw.FlexColumnWidth(1.5), // HSN
              2: const pw.FlexColumnWidth(1), // Qty
              3: const pw.FlexColumnWidth(1.5), // Price
              4: const pw.FlexColumnWidth(1.5), // Total
            },
            headers: ['Product Name', 'HSN/SAC', 'Qty', 'Unit Price', 'Total'],
            data: bill.items.map((item) {
              // --- HSN LOOKUP LOGIC ---
              String hsnCode = "N/A";
              if (item.product.hsn != null) {
                final hsnModel = itemController.hsnList.firstWhereOrNull(
                      (h) => h.id == item.product.hsn,
                );
                hsnCode = hsnModel?.hsnCode ?? "N/A";
              }

              return [
                item.product.name,
                hsnCode,
                item.quantity.toString(),
                'Rs. ${item.unitPrice.toStringAsFixed(2)}',
                'Rs. ${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
              ];
            }).toList(),
          ),

          // --- SUMMARY ---
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                width: 200,
                child: pw.Column(
                  children: [
                    _buildSummaryRow('Subtotal', 'Rs. ${bill.subtotal.toStringAsFixed(2)}'),
                    _buildSummaryRow('GST Amount', 'Rs. ${bill.gstAmount.toStringAsFixed(2)}'),
                    pw.Divider(),
                    _buildSummaryRow('Grand Total', 'Rs. ${bill.grandTotal.toStringAsFixed(2)}', isBold: true),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 50),
          pw.Text('Remarks: ${bill.remarks ?? "N/A"}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Spacer(),
          pw.Divider(),
          pw.Center(child: pw.Text('This is a computer generated invoice.', style: const pw.TextStyle(fontSize: 10))),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}