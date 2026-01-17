import 'dart:typed_data';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/util_controller.dart';
import 'package:share_plus/share_plus.dart';

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
                try {
                  final qty = int.tryParse(qtyController.text) ?? 1;
                  if (qty <= 0) {
                    Get.snackbar(
                      "Invalid",
                      "Quantity must be greater than 0",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  Get.dialog(
                    const Center(child: CircularProgressIndicator()),
                    barrierDismissible: false,
                  );
                  final utilController = Get.find<UtilController>();
                  await utilController.generateBarcode(productId, qty);
                  final barcodes =
                      utilController.generatedBarcodes.value?.barcodes;
                  if (barcodes == null || barcodes.isEmpty) {
                    Get.back();
                    Get.snackbar(
                      "Error",
                      "No barcodes generated",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  List<Uint8List> barcodeImages = [];
                  for (var barcode in barcodes) {
                    if (barcode.image != null) {
                      try {
                        final response = await NetworkAssetBundle(
                          Uri.parse(barcode.image!),
                        ).load("");
                        final bytes = response.buffer.asUint8List();
                        if (bytes.length >= 10 &&
                            bytes[0] == 137 &&
                            bytes[1] == 80)
                          barcodeImages.add(bytes);
                      } catch (e) {
                        debugPrint("Error downloading: $e");
                      }
                    }
                  }
                  if (barcodeImages.isEmpty) {
                    Get.back();
                    Get.snackbar(
                      "Error",
                      "Failed to download barcodes",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  final itemController = Get.find<ItemController>();
                  await itemController.printMultipleBarcodes(barcodeImages);
                  Get.back();
                  Get.back();
                  Get.snackbar(
                    "Success",
                    "Printed ${barcodeImages.length} barcode(s)",
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.back();
                  Get.snackbar(
                    "Error",
                    "Failed to print",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

// onPressed: () async {
//Share Logic kept exactly same
//try {
//final qty = int.tryParse(qtyController.text) ?? 1;
//final fullUrl = "https://traders.testwebs.in/$barcodeImageUrl";
//final response = await NetworkAssetBundle(Uri.parse(fullUrl)).load("");
//final bytes = response.buffer.asUint8List();
//final tempFile = await XFile.fromData(bytes, name: "$sku.png", mimeType: "image/png");
//await Share.shareXFiles([tempFile], text: "SKU: $sku (x$qty)");
// } catch (e) { Get.snackbar("Error", "Failed to share", backgroundColor: Colors.red, colorText: Colors.white); }
//},
