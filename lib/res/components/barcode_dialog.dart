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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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

            // SKU Badge
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
            const SizedBox(height: 20),

            // Barcode Image Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Image.network(
                "https://traders.testwebs.in/$barcodeImageUrl",
                height: 100,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.barcode_reader,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quantity Input
            Row(
              children: [
                const Text(
                  "Set Quantity:",
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
            const SizedBox(height: 24),

            // Action Buttons
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

                  // ✅ Reset progress and show progress dialog
                  utilController.progress.value = 0;
                  utilController.progressText.value = "Generating barcodes...";
                  _showProgressDialog();

                  // ✅ Step 1: Generate barcodes
                  await utilController.generateBarcode(productId, qty);

                  final barcodes =
                      utilController.generatedBarcodes.value?.barcodes;

                  if (barcodes == null || barcodes.isEmpty) {
                    Get.back(); // Close progress dialog
                    AppAlerts.error("No barcodes generated");
                    return;
                  }

                  // ✅ Step 2: Download barcodes with progress
                  utilController.progressText.value = "Downloading barcodes...";
                  List<Uint8List> barcodeImages = [];

                  final total = barcodes.length;

                  for (int i = 0; i < total; i++) {
                    final barcode = barcodes[i];
                    if (barcode.image != null) {
                      try {
                        final response = await NetworkAssetBundle(
                          Uri.parse(barcode.image!),
                        ).load("");
                        final bytes = response.buffer.asUint8List();

                        // Validate PNG
                        if (bytes.length >= 10 &&
                            bytes[0] == 137 &&
                            bytes[1] == 80) {
                          barcodeImages.add(bytes);
                        }

                        // ✅ Update progress
                        utilController.progress.value =
                            (((i + 1) / total) * 100).toInt();
                      } catch (e) {
                        debugPrint("Error downloading barcode: $e");
                      }
                    }
                  }

                  if (barcodeImages.isEmpty) {
                    Get.back(); // Close progress dialog
                    AppAlerts.error("Failed to download barcodes");
                    return;
                  }

                  // ✅ Step 3: Send to printer
                  utilController.progressText.value = "Sending to printer...";
                  utilController.progress.value = 100;

                  final itemController = Get.find<ItemController>();
                  await itemController.printMultipleBarcodes(barcodeImages);

                  Get.back(); // Close progress dialog
                  Get.back(); // Close barcode dialog

                  AppAlerts.success(
                    "Printed ${barcodeImages.length} barcode(s)",
                  );
                } catch (e) {
                  if (Get.isDialogOpen ?? false) {
                    Get.back(); // Close progress dialog
                  }
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

// ✅ Progress Dialog Widget
void _showProgressDialog() {
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false, // Prevent dismissing
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Obx(() {
          final utilController = Get.find<UtilController>();
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circular Progress Indicator
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
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1A1A4F),
                        ),
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

                // Progress Text
                Text(
                  utilController.progressText.value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Tip Text
                Text(
                  "Please wait...",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
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