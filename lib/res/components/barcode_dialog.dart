import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/barcode_utils.dart';

void showBarcodeDialog(
  BuildContext context,
  String sku,
  String barcodeImageUrl,
) {
  final qtyController = TextEditingController(text: "1",); // 👈 default 1 quantity

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        titlePadding: const EdgeInsets.only(
          top: 12,
          left: 12,
          right: 12,
          bottom: 4,
        ),
        title: Stack(
          alignment: Alignment.center,
          children: [
            const Center(
              child: Text(
                "Product Barcode",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SKU show
            Text(
              sku,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Barcode image from API
            SizedBox(
              width: 250,
              height: 120,
              child: Image.network(
                "https://traders.testwebs.in/$barcodeImageUrl",
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 15),
            // Quantity Input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Quantity: "),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Buttons Row (Print + Share)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final qty = int.tryParse(qtyController.text) ?? 1;
                      final fullUrl =
                          "https://traders.testwebs.in/$barcodeImageUrl";

                      final response = await NetworkAssetBundle(
                        Uri.parse(fullUrl),
                      ).load("");
                      final bytes = response.buffer.asUint8List();

                      // Check if it’s a valid PNG
                      if (bytes.length < 10 ||
                          bytes[0] != 137 ||
                          bytes[1] != 80) {
                        debugPrint("❌ Not a valid PNG image");
                        return;
                      }

                      // ✅ Call controller function
                      await Get.find<ItemController>().printBarcode(
                        bytes,
                        quantity: qty,
                      );
                    } catch (e) {
                      debugPrint("Error: $e");
                    }

                    // final qty = int.tryParse(qtyController.text) ?? 1;
                    // final fullUrl = "https://traders.testwebs.in/$barcodeImageUrl";
                    // final response = await NetworkAssetBundle(Uri.parse(fullUrl)).load("");
                    // final bytes = response.buffer.asUint8List(); // 👇 same barcode multiple times print
                    //     for (int i = 0; i < qty; i++) {
                    //       await Get.find<ItemController>().printBarcode(bytes); }
                  },
                  icon: const Icon(Icons.print, color: Colors.white),
                  label: const Text(
                    "Print",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A4F),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final qty = int.tryParse(qtyController.text) ?? 1;
                    final fullUrl =
                        "https://traders.testwebs.in/$barcodeImageUrl";
                    final response = await NetworkAssetBundle(
                      Uri.parse(fullUrl),
                    ).load("");
                    final bytes = response.buffer.asUint8List();

                    // 👇 share only one file but mention qty in text
                    final tempFile = await XFile.fromData(
                      bytes,
                      name: "$sku.png",
                      mimeType: "image/png",
                    );

                    await Share.shareXFiles([
                      tempFile,
                    ], text: "SKU: $sku (x$qty)");
                  },
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    "Share",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}



// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
// import 'package:share_plus/share_plus.dart'; // 👈 import
//
// void showBarcodeDialog(BuildContext context, String sku, String barcodeImageUrl) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         titlePadding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 4),
//         title: Stack(
//           alignment: Alignment.center,
//           children: [
//             const Center(
//               child: Text(
//                 "Product Barcode",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             Positioned(
//               right: 0,
//               child: IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () {
//                   Get.back();
//                 },
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // SKU show
//             Text(
//               sku,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 10),
//
//             // Barcode image from API
//             SizedBox(
//               width: 250,
//               height: 120,
//               child: Image.network(
//                 "https://traders.testwebs.in/$barcodeImageUrl",
//                 fit: BoxFit.contain,
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Buttons Row (Print + Share)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () async {
//                     final fullUrl = "https://traders.testwebs.in/$barcodeImageUrl";
//                     final response = await NetworkAssetBundle(Uri.parse(fullUrl)).load("");
//                     final bytes = response.buffer.asUint8List();
//                     Get.find<ItemController>().printBarcode(bytes);
//                   },
//                   icon: const Icon(Icons.print, color: Colors.white),
//                   label: const Text("Print", style: TextStyle(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1A1A4F),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () async {
//                     final fullUrl = "https://traders.testwebs.in/$barcodeImageUrl";
//                     final response = await NetworkAssetBundle(Uri.parse(fullUrl)).load("");
//                     final bytes = response.buffer.asUint8List();
//
//                     final tempFile = await XFile.fromData(
//                       bytes,
//                       name: "$sku.png",
//                       mimeType: "image/png",
//                     );
//
//                     await Share.shareXFiles([tempFile], text: "SKU: $sku");
//                   },
//                   icon: const Icon(Icons.share, color: Colors.white),
//                   label: const Text("Share", style: TextStyle(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
//
//
//
// // import 'dart:typed_data';
// // import 'package:dmj_stock_manager/utils/barcode_utils.dart';
// // import 'package:dmj_stock_manager/view_models/controller/home_controller.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// //  // if you have one
//
// // void showBarcodeDialog(BuildContext context, String data) async {
// //   Uint8List barcodeBytes = await generateBarcodePng(data);
//
// //   showDialog(
// //     context: context,
// //     builder: (context) {
// //       return AlertDialog(
// //         title: const Text("Product Barcode" , textAlign: TextAlign.center,),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Image.memory(barcodeBytes, width: 200),
// //             const SizedBox(height: 20),
// //             ElevatedButton.icon(
// //               onPressed: () {
// //                 // If you have a PrinterController in GetX:
// //                 Get.find<HomeController>().printBarcode(barcodeBytes);
//
// //                 // Or directly call your printer function:
//
// //               },
// //               icon: const Icon(Icons.print , color: Colors.white),
// //               label: const Text("Print Barcode", style: TextStyle(color: Colors.white)),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: const Color(0xFF1A1A4F),
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     },
// //   );
// // }
