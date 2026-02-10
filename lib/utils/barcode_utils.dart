import 'dart:typed_data';
import 'package:barcode/barcode.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart' as img;

/// ✅ Generate barcode PNG image from SKU
Future<Uint8List> generateBarcodePng(String sku) async {
  final barcode = Barcode.code128();

  // ✅ Create white background image
  final image = img.Image(width: 400, height: 120);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));

  // ✅ Draw barcode on image
  drawBarcode(
    image,
    barcode,
    sku,
    font: img.arial24,
  );

  // ✅ Return PNG bytes
  return Uint8List.fromList(img.encodePng(image));
}


// import 'dart:typed_data';
// import 'package:barcode_image/barcode_image.dart';
// import 'package:image/image.dart' as img;
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// Future<Uint8List> generateBarcodePng(String data) async {
//   final barcode = Barcode.code128();
//   final image = img.Image(width: 400, height: 150);
//   img.fill(image, color: img.ColorRgb8(255, 255, 255));
//
//   drawBarcode(image, barcode, data, font: img.arial24);
//
//   return Uint8List.fromList(img.encodePng(image));
// }
//
// Future<Uint8List> generateBarcodePdf(Uint8List barcodeBytes, int quantity) async {
//   final pdf = pw.Document();
//   final image = pw.MemoryImage(barcodeBytes);
//
//   const int columns = 3; // number of barcodes per row
//   const double spacing = 15; // spacing between barcodes
//
//   pdf.addPage(
//     pw.MultiPage(
//       pageFormat: PdfPageFormat.a4,
//       build: (pw.Context context) {
//         final barcodeWidgets = List.generate(quantity, (i) {
//           return pw.Container(
//             margin: const pw.EdgeInsets.all(4),
//             child: pw.Image(image, width: 150, height: 60),
//           );
//         });
//
//         return [
//           pw.Wrap(
//             spacing: spacing,
//             runSpacing: spacing,
//             children: barcodeWidgets,
//           )
//         ];
//       },
//     ),
//   );
//
//   return pdf.save();
// }



// import 'dart:typed_data';
// import 'package:barcode/barcode.dart';
// import 'package:barcode_image/barcode_image.dart';
// import 'package:image/image.dart' as img;

// Future<Uint8List> generateBarcodePng(String data) async {
//   final barcode = Barcode.code128();
//   final image = img.Image( width: 400, height: 150);
//   img.fill(image, color: img.ColorRgb8(255, 255, 255));

//   drawBarcode(image, barcode, data, font: img.arial24);

//   return Uint8List.fromList(img.encodePng(image));
// }