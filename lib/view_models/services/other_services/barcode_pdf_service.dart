// lib/utils/barcode_pdf_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../model/order_models/order_detail_model.dart';


class BarcodePdfService {
  /// ✅ PDF bytes generate karo (print + download dono ke liye use hoga)
  static Future<Uint8List> generateSerialBarcodePdf(
      OrderDetailsModel order,
      ) async {
    final pdf = pw.Document();

    // ── Sab serials collect karo (sabhi items ke) ──
    final List<_SerialEntry> allSerials = [];
    for (final item in order.items) {
      for (final serial in item.serials) {
        allSerials.add(_SerialEntry(
          productName: item.productName,
          productSku: item.productSku,
          serialNumber: serial.serialNumber,
          barcodeImageUrl: serial.barcodeImage,
        ));
      }
    }

    if (allSerials.isEmpty) {
      // Koi serial nahi — blank page with message
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Text(
              "No serials found for this order.",
              style: pw.TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
      return pdf.save();
    }

    // ── Barcode images fetch karo (parallel) ──
    final List<pw.ImageProvider?> barcodeImages = await Future.wait(
      allSerials.map((entry) => _fetchImage(entry.barcodeImageUrl)),
    );

    // ── PDF pages banao — 4 serials per page ──
    const int perPage = 4;
    for (int pageStart = 0; pageStart < allSerials.length; pageStart += perPage) {
      final pageItems = allSerials.sublist(
        pageStart,
        (pageStart + perPage).clamp(0, allSerials.length),
      );
      final pageImages = barcodeImages.sublist(
        pageStart,
        (pageStart + perPage).clamp(0, barcodeImages.length),
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ── Page Header ──
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#1A1A4F'),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Order #${order.orderId} — Serial Barcodes",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "${order.customerName}  |  ${order.createdAt.toLocal().toString().split(' ')[0]}",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 16),

                // ── Serial Cards ──
                pw.Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(pageItems.length, (i) {
                    final entry = pageItems[i];
                    final image = pageImages[i];

                    return pw.Container(
                      width: 240,
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColor.fromHex('#CCCCDD'), width: 1),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          pw.Text(
                            entry.productName,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#1A1A4F'),
                            ),
                            maxLines: 1,
                          ),
                          pw.SizedBox(height: 2),

                          // SKU
                          pw.Text(
                            "SKU: ${entry.productSku}",
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey600,
                            ),
                          ),
                          pw.SizedBox(height: 6),

                          // Barcode Image
                          if (image != null)
                            pw.Center(
                              child: pw.Image(image, height: 55, fit: pw.BoxFit.contain),
                            )
                          else
                            pw.Container(
                              height: 55,
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                "Image unavailable",
                                style: const pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.grey,
                                ),
                              ),
                            ),

                          pw.SizedBox(height: 6),

                          // Serial Number box
                          pw.Container(
                            width: double.infinity,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#EEF2FF'),
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Text(
                              entry.serialNumber,
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#1A1A4F'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                pw.Spacer(),

                // ── Footer ──
                pw.Divider(color: PdfColors.grey300),
                pw.Text(
                  "Page ${(pageStart ~/ perPage) + 1} of ${((allSerials.length - 1) ~/ perPage) + 1}   |   Total Serials: ${allSerials.length}",
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  /// ✅ Print dialog open karo
  static Future<void> printBarcodePdf(
      BuildContext context,
      OrderDetailsModel order,
      ) async {
    try {
      final pdfBytes = await generateSerialBarcodePdf(order);
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: "Order_${order.orderId}_Serials",
      );
    } catch (e) {
      debugPrint("❌ Print error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Print failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  /// ✅ PDF file download/save karo
  static Future<void> downloadBarcodePdf(
      BuildContext context,
      OrderDetailsModel order,
      ) async {
    try {
      final pdfBytes = await generateSerialBarcodePdf(order);

      // Downloads folder ya temp directory
      final Directory dir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      if (!await dir.exists()) await dir.create(recursive: true);

      final String fileName = "Order_${order.orderId}_Serials_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final File file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      debugPrint("✅ PDF saved: ${file.path}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Saved: $fileName"),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: "Share",
            textColor: Colors.white,
            onPressed: () {
              // Share via printing package
              Printing.sharePdf(
                bytes: pdfBytes,
                filename: fileName,
              );
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint("❌ Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  /// Helper — URL se image bytes fetch karo
  static Future<pw.ImageProvider?> _fetchImage(String url) async {
    if (url.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (e) {
      debugPrint("⚠️ Image fetch failed for $url: $e");
    }
    return null;
  }
}

// ── Internal helper class ──────────────────────────
class _SerialEntry {
  final String productName;
  final String productSku;
  final String serialNumber;
  final String barcodeImageUrl;

  _SerialEntry({
    required this.productName,
    required this.productSku,
    required this.serialNumber,
    required this.barcodeImageUrl,
  });
}