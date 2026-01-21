import 'package:dmj_stock_manager/view_models/controller/util_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerWidget extends StatefulWidget {
  const QrScannerWidget({super.key});

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  final UtilController utilController = Get.find<UtilController>();
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  double zoomLevel = 0.0;
  bool isProcessing = false; // ✅ Prevent multiple scans at once
  int scannedCount = 0; // ✅ Track scanned items

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        final Barcode barcode = capture.barcodes.first;
        if (barcode.rawValue != null) {
          await _handleScan(barcode.rawValue!.trim());
        }
      }
    }
  }

  // ✅ Handle scan without closing scanner
  Future<void> _handleScan(String code) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      await utilController.barcodeScanned(code);

      // ✅ Increment count
      setState(() {
        scannedCount++;
      });

      // ✅ Wait a bit then restart scanning
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        controller.start(); // ✅ Restart camera
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scan QR/Barcode'),
            if (scannedCount > 0)
              Text(
                'Scanned: $scannedCount items',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        actions: [
          // 📷 Gallery button
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.black),
            onPressed: _pickFromGallery,
          ),
          // 🔦 Torch button
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.black),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: MobileScanner(
                      controller: controller,
                      onDetect: (capture) async {
                        if (isProcessing) return; // ✅ Skip if already processing

                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          final raw = barcode.rawValue;
                          if (raw == null) continue;

                          // ✅ Stop camera temporarily
                          controller.stop();

                          // ✅ Process scan
                          await _handleScan(raw.trim());

                          debugPrint('💻 Scanned code: $raw');
                          break;
                        }
                      },
                    ),
                  ),
                ),

                // ✅ Processing Overlay
                if (isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 🔍 Zoom Slider
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.zoom_out),
                    Expanded(
                      child: Slider(
                        value: zoomLevel,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: "${(zoomLevel * 100).round()}%",
                        onChanged: (value) {
                          setState(() {
                            zoomLevel = value;
                          });
                          controller.setZoomScale(value);
                        },
                      ),
                    ),
                    const Icon(Icons.zoom_in),
                  ],
                ),

                // ✅ Done button (only show after scanning)
                if (scannedCount > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.check),
                      label: Text('Done ($scannedCount items)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:dmj_stock_manager/view_models/controller/util_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
//
// class QrScannerWidget extends StatefulWidget {
//   const QrScannerWidget({super.key});
//
//   @override
//   State<QrScannerWidget> createState() => _QrScannerWidgetState();
// }
//
// class _QrScannerWidgetState extends State<QrScannerWidget> {
//   final UtilController utilController = Get.find<UtilController>();
//   final MobileScannerController controller = MobileScannerController(
//     detectionSpeed: DetectionSpeed.noDuplicates, // 👈 fast focus
//     facing: CameraFacing.back,
//     torchEnabled: false,
//   );
//
//   double zoomLevel = 0.0;
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickFromGallery() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//
//     if (image != null) {
//       final BarcodeCapture? capture = await controller.analyzeImage(image.path);
//       if (capture != null && capture.barcodes.isNotEmpty) {
//         final Barcode barcode = capture.barcodes.first;
//         if (barcode.rawValue != null) {
//           final scanned = barcode.rawValue!.trim();
//           // call API and await product
//           final product = await utilController.barcodeScanned(scanned);
//           //return product model or null
//           // Get.back(result: barcode.rawValue);
//           Get.back(result: product);
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Scan QR/Barcode'),
//         backgroundColor: Colors.transparent,
//         actions: [
//           // 📷 Gallery button
//           IconButton(
//             icon: const Icon(Icons.photo_library, color: Colors.black),
//             onPressed: _pickFromGallery,
//           ),
//           // 🔦 Torch button
//           IconButton(
//             icon: const Icon(Icons.flash_on, color: Colors.black),
//             onPressed: () => controller.toggleTorch(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Center(
//               child: Container(
//                 width: 280,
//                 height: 280,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.black, width: 2),
//                 ),
//                 child: MobileScanner(
//                   controller: controller,
//                   onDetect: (capture) async {
//                     final List<Barcode> barcodes = capture.barcodes;
//                     for (final barcode in barcodes) {
//                       final raw = barcode.rawValue;
//                       if (raw == null) continue;
//                       // prevent duplicate immediate (MobileScanner may fire quickly)
//                       controller.stop(); // stop camera detection while processing
//                       final product = await utilController.barcodeScanned(raw.trim());
//                       // debugPrint('💻 Scanned code: ${barcode.rawValue}');
//                       debugPrint('💻 Scanned code: $raw');
//                       // if you want to return the model
//                       Get.back(result: product);
//                       break;
//                     }
//                   },
//                 ),
//               ),
//             ),
//           ),
//
//           // 🔍 Zoom Slider
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 const Icon(Icons.zoom_out),
//                 Expanded(
//                   child: Slider(
//                     value: zoomLevel,
//                     min: 0.0,
//                     max: 1.0,
//                     divisions: 10,
//                     label: "${(zoomLevel * 100).round()}%",
//                     onChanged: (value) {
//                       setState(() {
//                         zoomLevel = value;
//                       });
//                       controller.setZoomScale(value);
//                     },
//                   ),
//                 ),
//                 const Icon(Icons.zoom_in),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//

//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
//
// class QrScannerWidget extends StatelessWidget {
//   const QrScannerWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(title: const Text('Scan QR/Barcode'), backgroundColor: Colors.transparent,),
//       body: Center(
//         child: Container(
//           width: 250,
//           height: 250,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.black, width: 2),
//           ),
//           child: MobileScanner(
//             onDetect: (capture) {
//               final List<Barcode> barcodes = capture.barcodes;
//               for (final barcode in barcodes) {
//                 debugPrint('💻Scanned code: ${barcode.rawValue}');
//                 Get.back(result: barcode.rawValue);
//                 break;
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
