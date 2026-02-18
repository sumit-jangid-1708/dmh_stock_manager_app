// lib/res/components/widgets/barcode_dialog.dart (ya jahan bhi ye file hai)

import 'dart:typed_data';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/util_controller.dart';

void showBarcodeDialog(
    BuildContext context,
    int productId,
    String sku,
    String barcodeImageUrl,
    ) {
  final qtyController = TextEditingController(text: "1");
  const Color primaryColor = Color(0xFF1A1A4F);

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Product Barcode",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            // ── SKU Badge ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sku,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Product Barcode Image (existing) ──────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Image.network(
                "https://192.168.1.8:8000/$barcodeImageUrl",
                // "https://traders.testwebs.in/$barcodeImageUrl",
                height: 80,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.barcode_reader,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Quantity Input ────────────────────────────────────
            Row(
              children: [
                const Text(
                  "Quantity:",
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Generate Button ───────────────────────────────────
            AppGradientButton(
              width: double.infinity,
              icon: Icons.generating_tokens_outlined,
              text: "Generate Serials",
              onPressed: () async {
                final utilController = Get.find<UtilController>();
                final qty = int.tryParse(qtyController.text) ?? 1;

                if (qty <= 0) {
                  AppAlerts.error("Quantity must be greater than 0");
                  return;
                }

                try {
                  utilController.progress.value = 0;
                  utilController.progressText.value = "Generating serials...";
                  _showProgressDialog();

                  await utilController.generateBarcode(productId, qty);

                  if (Get.isDialogOpen ?? false) Get.back(); // progress dialog close

                  final result = utilController.generatedBarcodes.value;
                  if (result == null || result.serials.isEmpty) {
                    AppAlerts.error("No serials generated");
                    return;
                  }

                  // ── Show serials result dialog ──
                  _showSerialsResultDialog(context, result);
                } catch (e) {
                  if (Get.isDialogOpen ?? false) Get.back();
                  debugPrint("Generate error: $e");
                  // Error already handled in controller
                }
              },
            ),

            const SizedBox(height: 10),

            // ── Print Button (existing flow) ──────────────────────
            AppGradientButton(
              width: double.infinity,
              icon: Icons.print,
              text: "Print",
              onPressed: () async {
                final utilController = Get.find<UtilController>();
                try {
                  final qty = int.tryParse(qtyController.text) ?? 1;
                  if (qty <= 0) {
                    AppAlerts.error("Quantity must be greater than 0");
                    return;
                  }

                  utilController.progress.value = 0;
                  utilController.progressText.value = "Generating serials...";
                  _showProgressDialog();

                  await utilController.generateBarcode(productId, qty);

                  final result = utilController.generatedBarcodes.value;
                  if (result == null || result.serials.isEmpty) {
                    if (Get.isDialogOpen ?? false) Get.back();
                    AppAlerts.error("No serials generated");
                    return;
                  }

                  utilController.progressText.value = "Downloading barcode images...";
                  List<Uint8List> barcodeImages = [];
                  final serials = result.serials;
                  final total = serials.length;

                  for (int i = 0; i < total; i++) {
                    final imageUrl = serials[i].barcodeImage;
                    if (imageUrl.isNotEmpty) {
                      try {
                        final response = await NetworkAssetBundle(
                          Uri.parse(imageUrl),
                        ).load("");
                        final bytes = response.buffer.asUint8List();

                        // PNG validation
                        if (bytes.length >= 10 && bytes[0] == 137 && bytes[1] == 80) {
                          barcodeImages.add(bytes);
                        }

                        utilController.progress.value = (((i + 1) / total) * 100).toInt();
                      } catch (e) {
                        debugPrint("Image download error: $e");
                      }
                    }
                  }

                  if (barcodeImages.isEmpty) {
                    if (Get.isDialogOpen ?? false) Get.back();
                    AppAlerts.error("Failed to download barcode images");
                    return;
                  }

                  utilController.progressText.value = "Sending to printer...";
                  utilController.progress.value = 100;

                  final itemController = Get.find<ItemController>();
                  await itemController.printMultipleBarcodes(barcodeImages);

                  if (Get.isDialogOpen ?? false) Get.back(); // progress
                  Get.back(); // barcode dialog

                  AppAlerts.success("Printed ${barcodeImages.length} barcode(s)");
                } catch (e) {
                  if (Get.isDialogOpen ?? false) Get.back();
                  debugPrint("Print error: $e");
                  AppAlerts.error("Failed to print barcodes");
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Serials Result Dialog ──────────────────────────────────────────────────
void _showSerialsResultDialog(BuildContext context, result) {
  const Color primaryColor = Color(0xFF1A1A4F);

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.productSku,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),

            // ── Stock Info Bar ──────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stockStat("Available", "${result.totalAvailable}", Colors.blue),
                  _vDivider(),
                  _stockStat("Returned", "${result.returnedCount}", Colors.orange),
                  _vDivider(),
                  _stockStat("Remaining", "${result.remainingStock}", Colors.green),
                  _vDivider(),
                  _stockStat("Generated", "${result.serials.length}", primaryColor),
                ],
              ),
            ),

            const Divider(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "Serials (${result.serials.length})",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),

            // ── Serials Scrollable List ─────────────────────────
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: result.serials.length,
                itemBuilder: (context, index) {
                  final serial = result.serials[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Barcode Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            serial.barcodeImage,
                            height: 50,
                            width: 110,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const SizedBox(
                                height: 50,
                                width: 110,
                                child: Center(
                                  child: SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stack) {
                              return const SizedBox(
                                height: 50,
                                width: 110,
                                child: Center(
                                  child: Icon(Icons.image_not_supported_outlined,
                                      color: Colors.grey, size: 28),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Serial Number
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Serial #${index + 1}",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                serial.serialNumber,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Print All Button ────────────────────────────────
            AppGradientButton(
              width: double.infinity,
              icon: Icons.print,
              text: "Print All ${result.serials.length} Serials",
              onPressed: () async {
                final utilController = Get.find<UtilController>();

                utilController.progress.value = 0;
                utilController.progressText.value = "Downloading barcode images...";
                Get.back(); // close this dialog
                _showProgressDialog();

                try {
                  List<Uint8List> barcodeImages = [];
                  final serials = result.serials;
                  final total = serials.length;

                  for (int i = 0; i < total; i++) {
                    final imageUrl = serials[i].barcodeImage;
                    if (imageUrl.isNotEmpty) {
                      try {
                        final response = await NetworkAssetBundle(
                          Uri.parse(imageUrl),
                        ).load("");
                        final bytes = response.buffer.asUint8List();
                        if (bytes.length >= 10 && bytes[0] == 137 && bytes[1] == 80) {
                          barcodeImages.add(bytes);
                        }
                        utilController.progress.value = (((i + 1) / total) * 100).toInt();
                      } catch (e) {
                        debugPrint("Image error: $e");
                      }
                    }
                  }

                  if (barcodeImages.isEmpty) {
                    if (Get.isDialogOpen ?? false) Get.back();
                    AppAlerts.error("Failed to download images");
                    return;
                  }

                  utilController.progressText.value = "Sending to printer...";
                  utilController.progress.value = 100;

                  final itemController = Get.find<ItemController>();
                  await itemController.printMultipleBarcodes(barcodeImages);

                  if (Get.isDialogOpen ?? false) Get.back();
                  if (Get.isDialogOpen ?? false) Get.back(); // barcode dialog bhi close

                  AppAlerts.success("Printed ${barcodeImages.length} barcode(s)");
                } catch (e) {
                  if (Get.isDialogOpen ?? false) Get.back();
                  AppAlerts.error("Print failed");
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Progress Dialog ────────────────────────────────────────────────────────
void _showProgressDialog() {
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Obx(() {
          final utilController = Get.find<UtilController>();
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: utilController.progress.value / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A1A4F)),
                      ),
                    ),
                    Text(
                      "${utilController.progress.value}%",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A4F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  utilController.progressText.value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Please wait...",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }),
      ),
    ),
    barrierDismissible: false,
  );
}

// ── Helpers ────────────────────────────────────────────────────────────────
Widget _stockStat(String label, String value, Color color) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    ],
  );
}

Widget _vDivider() => Container(
  height: 30,
  width: 1,
  color: Colors.grey.shade300,
);