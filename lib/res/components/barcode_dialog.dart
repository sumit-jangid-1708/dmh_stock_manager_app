import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:dmj_stock_manager/res/components/sku_qr_widget.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';

void showBarcodeDialog(BuildContext context, String sku) {
  final qtyController = TextEditingController(text: "1");
  const Color primaryColor = Color(0xFF1A1A4F);

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Print SKU Barcode",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(),

            // SKU Preview
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  SkuQrWidget(sku: sku, size: 120, showLabel: false),
                  const SizedBox(height: 8),
                  Text(
                    sku,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quantity Input
            Row(
              children: [
                const Text(
                  "Print Quantity:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Print Button
            AppGradientButton(
              width: double.infinity,
              icon: Icons.print,
              text: "Print Labels",
              onPressed: () async {
                final qty = int.tryParse(qtyController.text) ?? 0;
                if (qty <= 0) {
                  AppAlerts.error("Please enter a valid quantity");
                  return;
                }

                await printSkuLabels(sku, qty);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Print Logic (Aligned with BarcodePdfService) ──────────────────────────

Future<void> printSkuLabels(String sku, int qty) async {
  try {
    // Show Loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final pdf = pw.Document();

    // BarcodePdfService ki tarah Page Format (58mm width)
    const pageFormat = PdfPageFormat(
      58 * PdfPageFormat.mm,
      210 * PdfPageFormat.mm, // Continuous roll style
      marginAll: 3 * PdfPageFormat.mm,
    );

    // QR Image generate karna
    final Uint8List qrBytes = await SkuQrWidget.toImageBytes(sku, size: 300);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        build: (context) {
          return List.generate(qty, (index) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(qrBytes),
                    width: 40 * PdfPageFormat.mm,
                    height: 40 * PdfPageFormat.mm,
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.SizedBox(height: 1.5 * PdfPageFormat.mm),
                pw.Text(
                  sku,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                // Agar last item nahi hai toh divider add karein (Service style)
                if (index < qty - 1) ...[
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

    Get.back(); // Close loading
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: "SKU_$sku",
      format: pageFormat,
    );
  } catch (e) {
    Get.back(); // Close loading
    AppAlerts.error("Printing failed: $e");
  }
}

// // lib/res/components/widgets/barcode_dialog.dart
//
// import 'dart:typed_data';
// import 'package:dmj_stock_manager/res/components/sku_qr_widget.dart';
// import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
// import 'package:dmj_stock_manager/utils/app_alerts.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
// import 'package:dmj_stock_manager/view_models/controller/util_controller.dart';
//
// void showBarcodeDialog(
//     BuildContext context,
//     int productId,
//     String sku,
//     String barcodeImageUrl,
//     ) {
//   final qtyController = TextEditingController(text: "1");
//   const Color primaryColor = Color(0xFF1A1A4F);
//
//   showDialog(
//     context: context,
//     builder: (context) => Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       child: Container(
//         height: 500,
//         padding: const EdgeInsets.all(20),
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.85,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ── Header ───────────────────────────────────────────
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           "Product Barcode",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: primaryColor,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () => Get.back(),
//                           icon: const Icon(
//                             Icons.close_rounded,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(),
//                     const SizedBox(height: 10),
//
//                     // ── SKU Badge ─────────────────────────────────────────
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: primaryColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         sku,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: primaryColor,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//
//                     // ── QR Widget preview ────────────────────────────────
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Colors.grey[200]!),
//                       ),
//                       child: SkuQrWidget(sku: sku, size: 100, showLabel: false),
//                     ),
//                     const SizedBox(height: 16),
//
//                     // ── Quantity Input ────────────────────────────────────
//                     Row(
//                       children: [
//                         const Text(
//                           "Quantity:",
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         const Spacer(),
//                         SizedBox(
//                           width: 80,
//                           child: TextField(
//                             controller: qtyController,
//                             keyboardType: TextInputType.number,
//                             textAlign: TextAlign.center,
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.grey[100],
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 8,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//
//                     // ── Generate Button ───────────────────────────────────
//                     AppGradientButton(
//                       width: double.infinity,
//                       icon: Icons.generating_tokens_outlined,
//                       text: "Generate Serials",
//                       onPressed: () async {
//                         final utilController = Get.find<UtilController>();
//                         final qty = int.tryParse(qtyController.text) ?? 1;
//
//                         if (qty <= 0) {
//                           AppAlerts.error("Quantity must be greater than 0");
//                           return;
//                         }
//
//                         try {
//                           utilController.progress.value = 0;
//                           utilController.progressText.value =
//                           "Generating serials...";
//                           _showProgressDialog();
//
//                           await utilController.generateBarcode(productId, qty);
//
//                           if (Get.isDialogOpen ?? false) Get.back();
//
//                           final result = utilController.generatedBarcodes.value;
//                           if (result == null || result.serials.isEmpty) {
//                             AppAlerts.error("No serials generated");
//                             return;
//                           }
//
//                           _showSerialsResultDialog(context, result);
//                         } catch (e) {
//                           if (Get.isDialogOpen ?? false) Get.back();
//                           debugPrint("Generate error: $e");
//                         }
//                       },
//                     ),
//
//                     const SizedBox(height: 10),
//
//                     // ── Print Button ──────────────────────────────────────
//                     AppGradientButton(
//                       width: double.infinity,
//                       icon: Icons.print,
//                       text: "Print",
//                       onPressed: () async {
//                         final utilController = Get.find<UtilController>();
//                         try {
//                           final qty = int.tryParse(qtyController.text) ?? 1;
//                           if (qty <= 0) {
//                             AppAlerts.error("Quantity must be greater than 0");
//                             return;
//                           }
//
//                           utilController.progress.value = 0;
//                           utilController.progressText.value =
//                           "Generating serials...";
//                           _showProgressDialog();
//
//                           await utilController.generateBarcode(productId, qty);
//
//                           final result = utilController.generatedBarcodes.value;
//                           if (result == null || result.serials.isEmpty) {
//                             if (Get.isDialogOpen ?? false) Get.back();
//                             AppAlerts.error("No serials generated");
//                             return;
//                           }
//
//                           // ✅ QR bytes locally — no network download
//                           utilController.progressText.value =
//                           "Generating QR codes...";
//                           final serials = result.serials;
//                           final total = serials.length;
//
//                           final List<Uint8List> qrImages = [];
//                           for (int i = 0; i < total; i++) {
//                             final qrBytes = await SkuQrWidget.toImageBytes(
//                               serials[i].serialNumber,
//                               size: 300,
//                             );
//                             qrImages.add(qrBytes);
//                             utilController.progress.value =
//                                 (((i + 1) / total) * 100).toInt();
//                           }
//
//                           if (qrImages.isEmpty) {
//                             if (Get.isDialogOpen ?? false) Get.back();
//                             AppAlerts.error("Failed to generate QR codes");
//                             return;
//                           }
//
//                           utilController.progressText.value =
//                           "Sending to printer...";
//                           utilController.progress.value = 100;
//
//                           final itemController = Get.find<ItemController>();
//                           await itemController.printMultipleBarcodes(qrImages);
//
//                           if (Get.isDialogOpen ?? false) Get.back(); // progress
//                           Get.back(); // barcode dialog
//
//                           AppAlerts.success(
//                             "Printed ${qrImages.length} QR label(s)",
//                           );
//                         } catch (e) {
//                           if (Get.isDialogOpen ?? false) Get.back();
//                           debugPrint("Print error: $e");
//                           AppAlerts.error("Failed to print");
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// // ── Serials Result Dialog ──────────────────────────────────────────────────
// void _showSerialsResultDialog(BuildContext context, result) {
//   const Color primaryColor = Color(0xFF1A1A4F);
//
//   showDialog(
//     context: context,
//     builder: (context) => Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.85,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Header ─────────────────────────────────────────
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         result.productName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: primaryColor,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         result.productSku,
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Get.back(),
//                   icon: const Icon(Icons.close_rounded, color: Colors.grey),
//                 ),
//               ],
//             ),
//
//             // ── Stock Info Bar ──────────────────────────────────
//             Container(
//               margin: const EdgeInsets.symmetric(vertical: 10),
//               padding:
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               decoration: BoxDecoration(
//                 color: primaryColor.withOpacity(0.06),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _stockStat(
//                       "Available", "${result.totalAvailable}", Colors.blue),
//                   _vDivider(),
//                   _stockStat(
//                       "Returned", "${result.returnedCount}", Colors.orange),
//                   _vDivider(),
//                   _stockStat(
//                       "Remaining", "${result.remainingStock}", Colors.green),
//                   _vDivider(),
//                   _stockStat(
//                       "Generated", "${result.serials.length}", primaryColor),
//                 ],
//               ),
//             ),
//
//             const Divider(),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Text(
//                 "Serials (${result.serials.length})",
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: primaryColor,
//                 ),
//               ),
//             ),
//
//             // ── Serials Scrollable List ─────────────────────────
//             Flexible(
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: result.serials.length,
//                 itemBuilder: (context, index) {
//                   final serial = result.serials[index];
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 10),
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.blue.shade100),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.03),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         // ✅ QR preview instead of network barcode image
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(6),
//                           child: SkuQrWidget(
//                             sku: serial.serialNumber,
//                             size: 50,
//                             showLabel: false,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//
//                         // Serial Number
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Serial #${index + 1}",
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.grey.shade500,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 serial.serialNumber,
//                                 style: const TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: 'monospace',
//                                   color: primaryColor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // ── Print All Button ────────────────────────────────
//             AppGradientButton(
//               width: double.infinity,
//               icon: Icons.print,
//               text: "Print All ${result.serials.length} Serials",
//               onPressed: () async {
//                 final utilController = Get.find<UtilController>();
//
//                 utilController.progress.value = 0;
//                 utilController.progressText.value = "Generating QR codes...";
//                 Get.back(); // close serials dialog
//                 _showProgressDialog();
//
//                 try {
//                   final serials = result.serials;
//                   final total = serials.length;
//
//                   // ✅ QR bytes locally — no network download
//                   final List<Uint8List> qrImages = [];
//                   for (int i = 0; i < total; i++) {
//                     final qrBytes = await SkuQrWidget.toImageBytes(
//                       serials[i].serialNumber,
//                       size: 300,
//                     );
//                     qrImages.add(qrBytes);
//                     utilController.progress.value =
//                         (((i + 1) / total) * 100).toInt();
//                   }
//
//                   if (qrImages.isEmpty) {
//                     if (Get.isDialogOpen ?? false) Get.back();
//                     AppAlerts.error("Failed to generate QR codes");
//                     return;
//                   }
//
//                   utilController.progressText.value = "Sending to printer...";
//                   utilController.progress.value = 100;
//
//                   final itemController = Get.find<ItemController>();
//                   await itemController.printMultipleBarcodes(qrImages);
//
//                   if (Get.isDialogOpen ?? false) Get.back(); // progress
//                   if (Get.isDialogOpen ?? false) Get.back(); // barcode dialog
//
//                   AppAlerts.success(
//                     "Printed ${qrImages.length} QR label(s)",
//                   );
//                 } catch (e) {
//                   if (Get.isDialogOpen ?? false) Get.back();
//                   AppAlerts.error("Print failed");
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// // ── Progress Dialog ────────────────────────────────────────────────────────
// void _showProgressDialog() {
//   Get.dialog(
//     WillPopScope(
//       onWillPop: () async => false,
//       child: Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Obx(() {
//           final utilController = Get.find<UtilController>();
//           return Container(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     SizedBox(
//                       width: 80,
//                       height: 80,
//                       child: CircularProgressIndicator(
//                         value: utilController.progress.value / 100,
//                         strokeWidth: 6,
//                         backgroundColor: Colors.grey[200],
//                         valueColor: const AlwaysStoppedAnimation<Color>(
//                           Color(0xFF1A1A4F),
//                         ),
//                       ),
//                     ),
//                     Text(
//                       "${utilController.progress.value}%",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1A1A4F),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   utilController.progressText.value,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Please wait...",
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     ),
//     barrierDismissible: false,
//   );
// }
//
// // ── Helpers ────────────────────────────────────────────────────────────────
// Widget _stockStat(String label, String value, Color color) {
//   return Column(
//     children: [
//       Text(
//         value,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: color,
//         ),
//       ),
//       const SizedBox(height: 2),
//       Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
//     ],
//   );
// }
//
// Widget _vDivider() =>
//     Container(height: 30, width: 1, color: Colors.grey.shade300);
