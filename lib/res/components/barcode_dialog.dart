import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:dmj_stock_manager/res/components/sku_qr_widget.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient _button.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';

import '../../model/order_models/order_detail_model.dart';
import '../../view_models/services/other_services/thermal_label_service.dart';

void showBarcodeDialog(BuildContext context, String sku, String name) {
  final qtyController = TextEditingController(text: "1");
  const Color primaryColor = Color(0xFF1A1A4F);
  final selectedMode = "Thermal Label".obs;

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

            // Print Mode Dropdown
            const Text(
              "Print Mode:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMode.value,
                      isExpanded: true,
                      items: ["Thermal Label", "A4 Sheet"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) selectedMode.value = val;
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 16),

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

                if (selectedMode.value == "Thermal Label") {
                  await ThermalPrintService.printSkuLabels(
                    context,
                    sku,
                    name,
                    qty,
                  );
                } else {
                  await printA4SkuLabels(sku, name, qty);
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Print Logic (A4 Sheet with grid and borders) ──────────────────────────

Future<void> printA4SkuLabels(String sku, String name, int qty) async {
  try {
    // Show Loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final pdf = pw.Document();
    final Uint8List qrBytes = await SkuQrWidget.toImageBytes(sku, size: 300);

    // Grid configuration for A4
    const int columns = 4;
    const int rowsPerPage = 7;
    const int itemsPerPage = columns * rowsPerPage;

    final int pageCount = (qty / itemsPerPage).ceil();

    for (int p = 0; p < pageCount; p++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(8 * PdfPageFormat.mm),
          build: (context) {
            final int startIdx = p * itemsPerPage;
            final int endIdx = (startIdx + itemsPerPage < qty)
                ? (startIdx + itemsPerPage)
                : qty;
            final int pageQty = endIdx - startIdx;

            return pw.GridView(
              crossAxisCount: columns,
              childAspectRatio: 0.8,
              children: List.generate(pageQty, (index) {
                return pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Image(
                        pw.MemoryImage(qrBytes),
                        width: 32 * PdfPageFormat.mm,
                        height: 32 * PdfPageFormat.mm,
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        name,
                        textAlign: pw.TextAlign.center,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        sku,
                        style: const pw.TextStyle(
                          fontSize: 6.5,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      );
    }

    Get.back(); // Close loading
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: "A4_Labels_$sku",
      format: PdfPageFormat.a4,
    );
  } catch (e) {
    if (Get.isDialogOpen ?? false) Get.back(); // Close loading
    AppAlerts.error("Printing failed: $e");
  }
}

// ── Order QR Printing Dialog ──────────────────────────────────────────────

void showOrderBarcodeDialog(BuildContext context, OrderDetailsModel order) {
  final qtyController = TextEditingController(text: "1");
  const Color primaryColor = Color(0xFF1A1A4F);
  final selectedMode = "Thermal Label".obs;

  // Calculate total serials
  int totalSerials = 0;
  for (var item in order.items) {
    totalSerials += item.serials.length;
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Print Order Serials",
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
            const SizedBox(height: 10),

            Text(
              "Order ID: #${order.orderId}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              "Total Serials to print: $totalSerials",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),

            const SizedBox(height: 20),
            const Text(
              "Print Mode:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMode.value,
                      isExpanded: true,
                      items: ["Thermal Label", "A4 Sheet"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) selectedMode.value = val;
                      },
                    ),
                  ),
                )),

            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  "Copies (per serial):",
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
            const SizedBox(height: 24),

            AppGradientButton(
              width: double.infinity,
              icon: Icons.print,
              text: "Start Printing",
              onPressed: () async {
                final qty = int.tryParse(qtyController.text) ?? 1;
                if (qty <= 0) {
                  AppAlerts.error("Please enter a valid quantity");
                  return;
                }

                if (selectedMode.value == "Thermal Label") {
                  await ThermalPrintService.printOrderLabels(context, order);
                } else {
                  await printA4OrderSerials(order, qty);
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> printA4OrderSerials(OrderDetailsModel order, int copies) async {
  try {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final pdf = pw.Document();

    final List<Map<String, dynamic>> entries = [];
    for (var item in order.items) {
      if (item.serials.isNotEmpty) {
        final Uint8List qrBytes = await SkuQrWidget.toImageBytes(
          item.serials.first.serialNumber, // Fallback logic or loop serials
          size: 300,
        );
        
        for (var serial in item.serials) {
           final Uint8List currentQrBytes = await SkuQrWidget.toImageBytes(
            serial.serialNumber,
            size: 300,
          );
          for (int i = 0; i < copies; i++) {
            entries.add({
              'sku': serial.serialNumber,
              'name': item.productName,
              'qr': currentQrBytes,
            });
          }
        }
      }
    }

    if (entries.isEmpty) {
      Get.back();
      AppAlerts.error("No serials found to print");
      return;
    }

    const int columns = 4;
    const int rowsPerPage = 7;
    const int itemsPerPage = columns * rowsPerPage;
    final int pageCount = (entries.length / itemsPerPage).ceil();

    for (int p = 0; p < pageCount; p++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(8 * PdfPageFormat.mm),
          build: (context) {
            final int startIdx = p * itemsPerPage;
            final int endIdx = (startIdx + itemsPerPage < entries.length)
                ? (startIdx + itemsPerPage)
                : entries.length;

            return pw.GridView(
              crossAxisCount: columns,
              childAspectRatio: 0.8,
              children: List.generate(endIdx - startIdx, (index) {
                final entry = entries[startIdx + index];
                return pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  margin: const pw.EdgeInsets.all(2),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Image(
                        pw.MemoryImage(entry['qr']),
                        width: 32 * PdfPageFormat.mm,
                        height: 32 * PdfPageFormat.mm,
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        entry['name'],
                        textAlign: pw.TextAlign.center,
                        maxLines: 2,
                        style: pw.TextStyle(
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        entry['sku'],
                        style: const pw.TextStyle(
                          fontSize: 6.5,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      );
    }

    Get.back();
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: "Order_${order.orderId}_A4_Serials",
      format: PdfPageFormat.a4,
    );
  } catch (e) {
    if (Get.isDialogOpen ?? false) Get.back();
    AppAlerts.error("Printing failed: $e");
  }
}
