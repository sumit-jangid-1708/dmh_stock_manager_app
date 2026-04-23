import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SkuQrWidget extends StatelessWidget {
  const SkuQrWidget({
    super.key,
    required this.sku,
    this.size = 120,
    this.showLabel = true,
    this.backgroundColor = Colors.white,
  });

  final String sku;
  final double size;
  final bool showLabel;
  final Color backgroundColor;

  // ✅ Static method — QR widget ko image bytes mein convert karo (printing ke liye)
  static Future<Uint8List> toImageBytes(String sku, {double size = 300}) async {
    final qrPainter = QrPainter(
      data: sku,
      version: QrVersions.auto,
      // ✅ H = highest error correction (30%) — long SKU ke liye best
      errorCorrectionLevel: QrErrorCorrectLevel.H,
      color: const ui.Color(0xFF000000),
      emptyColor: const ui.Color(0xFFFFFFFF),
    );

    final image = await qrPainter.toImage(size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: backgroundColor,
          padding: const EdgeInsets.all(4),
          child: QrImageView(
            data: sku,
            version: QrVersions.auto,
            // ✅ H level — scannable even if 30% of QR is damaged/small
            errorCorrectionLevel: QrErrorCorrectLevel.H,
            size: size,
            backgroundColor: backgroundColor,
            // ✅ Quiet zone — QR scanner ke liye required white border
            padding: const EdgeInsets.all(6),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: size,
            child: Text(
              sku,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ],
    );
  }
}