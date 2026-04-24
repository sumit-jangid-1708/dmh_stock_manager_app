import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../model/order_models/order_detail_model.dart';
import '../../../res/components/sku_qr_widget.dart';

class BarcodePdfService {
  // ✅ 50x25mm — standard thermal label size
  static const PdfPageFormat _pageFormat = PdfPageFormat(
    58 * PdfPageFormat.mm,
    210 * PdfPageFormat.mm,
    marginAll: 3 * PdfPageFormat.mm,
  );

  static Future<Uint8List> generateSerialBarcodePdf(OrderDetailsModel order) async {
    final pdf = pw.Document();
    // ── Collect all serials ──
    final List<_SerialEntry> allSerials = [];
    for (final item in order.items) {
      for (final serial in item.serials) {
        allSerials.add(_SerialEntry(
          serialNumber: serial.serialNumber,
          productName: item.productName,
        ));
      }
    }

    if (allSerials.isEmpty) {
      pdf.addPage(pw.Page(
        pageFormat: _pageFormat,
        build: (_) => pw.Center(child: pw.Text("No serials found.")),
      ));
      return pdf.save();
    }

    // ✅ Generate QR bytes for all serials in parallel — no backend call
    final List<Uint8List> qrImages = await Future.wait(
      allSerials.map((e) => SkuQrWidget.toImageBytes(e.serialNumber, size: 300,)),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: _pageFormat,
        margin: const pw.EdgeInsets.all(3 * PdfPageFormat.mm),
        build: (context) {
          return List.generate(allSerials.length, (i) {
            final entry = allSerials[i];
            final qrBytes = qrImages[i];

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ── QR Code ──
                pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(qrBytes),
                    width: 40 * PdfPageFormat.mm,
                    height: 40 * PdfPageFormat.mm,
                    fit: pw.BoxFit.contain,
                  ),
                ),

                pw.SizedBox(height: 1.5 * PdfPageFormat.mm),

                // ── Serial number text ──
                pw.Text(
                  entry.serialNumber,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 5.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),

                if (i < allSerials.length - 1) ...[
                  pw.SizedBox(height: 2 * PdfPageFormat.mm),
                  pw.Divider(color: PdfColors.grey300, thickness: 0.5),
                  pw.SizedBox(height: 2 * PdfPageFormat.mm),
                ],
              ],
            );
          });
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printBarcodePdf(BuildContext context, OrderDetailsModel order) async {
    try {
      final pdfBytes = await generateSerialBarcodePdf(order);
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: "Order_${order.orderId}_Serials",
        format: _pageFormat,
      );
    } catch (e) {
      debugPrint("❌ Print error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Print failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  static Future<void> downloadBarcodePdf(BuildContext context, OrderDetailsModel order) async {
    try {
      final pdfBytes = await generateSerialBarcodePdf(order);

      final Directory dir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      if (!await dir.exists()) await dir.create(recursive: true);

      final String fileName =
          "Order_${order.orderId}_QR_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final File file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Saved: $fileName"),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: "Share",
            textColor: Colors.white,
            onPressed: () => Printing.sharePdf(bytes: pdfBytes, filename: fileName),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e"), backgroundColor: Colors.red),
      );
    }
  }
}

class _SerialEntry {
  final String serialNumber;
  final String productName;
  _SerialEntry({required this.serialNumber, required this.productName});
}



// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import '../../../model/order_models/order_detail_model.dart';
//
// class BarcodePdfService {
//
//   static const PdfPageFormat _pageFormat = PdfPageFormat(
//     58 * PdfPageFormat.mm,
//     210 * PdfPageFormat.mm,
//     marginAll: 3 * PdfPageFormat.mm,
//   );
//
//   static Future<Uint8List> generateSerialBarcodePdf(OrderDetailsModel order) async {
//     final pdf = pw.Document();
//
//     // ── Collect all serials ──
//     final List<_SerialEntry> allSerials = [];
//     for (final item in order.items) {
//       for (final serial in item.serials) {
//         allSerials.add(_SerialEntry(
//           serialNumber: serial.serialNumber,
//           barcodeImageUrl: serial.barcodeImage,
//         ));
//       }
//     }
//
//     if (allSerials.isEmpty) {
//       pdf.addPage(pw.Page(
//         pageFormat: _pageFormat,
//         build: (_) => pw.Center(child: pw.Text("No serials found.")),
//       ));
//       return pdf.save();
//     }
//
//     // ── Fetch all images in parallel ──
//     final List<pw.ImageProvider?> images = await Future.wait(
//       allSerials.map((e) => _fetchImage(e.barcodeImageUrl)),
//     );
//
//     // ✅ MultiPage
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: _pageFormat,
//         margin: const pw.EdgeInsets.all(3 * PdfPageFormat.mm),
//         build: (context) {
//           return List.generate(allSerials.length, (i) {
//             final entry = allSerials[i];
//             final image = images[i];
//
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.center,
//               children: [
//                 // ── Barcode image ──
//                 if (image != null)
//                   pw.Image(
//                     image,
//                     width: 52 * PdfPageFormat.mm,
//                     height: 18 * PdfPageFormat.mm,
//                     fit: pw.BoxFit.fill,
//                   )
//                 else
//                   pw.Container(
//                     height: 18 * PdfPageFormat.mm,
//                     alignment: pw.Alignment.center,
//                     child: pw.Text("No image",
//                         style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey)),
//                   ),
//
//                 pw.SizedBox(height: 1 * PdfPageFormat.mm),
//
//                 // ── Serial number ──
//                 pw.Text(
//                   entry.serialNumber,
//                   textAlign: pw.TextAlign.center,
//                   style: pw.TextStyle(
//                     fontSize: 6,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.black,
//                   ),
//                 ),
//
//                 // ── Divider ──
//                 if (i < allSerials.length - 1) ...[
//                   pw.SizedBox(height: 1.5 * PdfPageFormat.mm),
//                   pw.Divider(color: PdfColors.grey300, thickness: 0.5),
//                   pw.SizedBox(height: 1.5 * PdfPageFormat.mm),
//                 ],
//               ],
//             );
//           });
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
//
//   static Future<void> printBarcodePdf(BuildContext context, OrderDetailsModel order) async {
//     try {
//       final pdfBytes = await generateSerialBarcodePdf(order);
//       await Printing.layoutPdf(
//         onLayout: (_) async => pdfBytes,
//         name: "Order_${order.orderId}_Serials",
//         format: _pageFormat,
//       );
//     } catch (e) {
//       debugPrint("❌ Print error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Print failed: $e"), backgroundColor: Colors.red),
//       );
//     }
//   }
//
//   static Future<void> downloadBarcodePdf(BuildContext context, OrderDetailsModel order) async {
//     try {
//       final pdfBytes = await generateSerialBarcodePdf(order);
//
//       final Directory dir = Platform.isAndroid
//           ? Directory('/storage/emulated/0/Download')
//           : await getApplicationDocumentsDirectory();
//
//       if (!await dir.exists()) await dir.create(recursive: true);
//
//       final String fileName =
//           "Order_${order.orderId}_Serials_${DateTime.now().millisecondsSinceEpoch}.pdf";
//       final File file = File('${dir.path}/$fileName');
//       await file.writeAsBytes(pdfBytes);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Saved: $fileName"),
//           backgroundColor: Colors.green,
//           action: SnackBarAction(
//             label: "Share",
//             textColor: Colors.white,
//             onPressed: () => Printing.sharePdf(bytes: pdfBytes, filename: fileName),
//           ),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Download failed: $e"), backgroundColor: Colors.red),
//       );
//     }
//   }
//
//   static Future<pw.ImageProvider?> _fetchImage(String url) async {
//     if (url.isEmpty) return null;
//     try {
//       final response =
//       await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
//       if (response.statusCode == 200) return pw.MemoryImage(response.bodyBytes);
//     } catch (e) {
//       debugPrint("⚠️ Image fetch failed: $e");
//     }
//     return null;
//   }
// }
//
// class _SerialEntry {
//   final String serialNumber;
//   final String barcodeImageUrl;
//
//   _SerialEntry({required this.serialNumber, required this.barcodeImageUrl});
// }