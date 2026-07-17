import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dmj_stock_manager/model/product_models/product_model.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';
import 'package:get/get.dart';

class ProductShareService {
  static String _resolveUrl(String raw) => AppUrl.mediaUrl(raw);

  static Future<Uint8List?> _downloadImageBytes(String url) async {
    try {
      final response =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      return response.bodyBytes;
    } catch (e) {
      debugPrint("⚠️ Image download failed: $e");
      return null;
    }
  }

  /// Har product ki photo + details ko EK image me compose karta hai,
  /// taaki share karte time image aur uski detail kabhi separate na ho.
  static Future<File?> _buildProductCard(ProductModel p, String priceType) async {
    try {
      Uint8List? imgBytes;
      if (p.productImageVariants.isNotEmpty) {
        imgBytes =
        await _downloadImageBytes(_resolveUrl(p.productImageVariants.first));
      }

      const double cardWidth = 800;
      const double photoHeight = 800;
      const double footerHeight = 320; // Increased to accommodate price

      ui.Image? photo;
      if (imgBytes != null) {
        final codec = await ui.instantiateImageCodec(imgBytes);
        final frame = await codec.getNextFrame();
        photo = frame.image;
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, cardWidth, photoHeight + footerHeight),
      );

      // white background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, cardWidth, photoHeight + footerHeight),
        Paint()..color = Colors.white,
      );

      // ── photo (cover-fit) ──
      if (photo != null) {
        final dstRect = Rect.fromLTWH(0, 0, cardWidth, photoHeight);
        canvas.save();
        canvas.clipRect(dstRect);
        painting.paintImage(
          canvas: canvas,
          rect: dstRect,
          image: photo,
          fit: BoxFit.cover,
        );
        canvas.restore();
      } else {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, cardWidth, photoHeight),
          Paint()..color = Colors.grey.shade200,
        );
      }

      // ── footer with details ──
      canvas.drawRect(
        Rect.fromLTWH(0, photoHeight, cardWidth, footerHeight),
        Paint()..color = const Color(0xFF1A1A4F),
      );

      double y = photoHeight + 24;
      void drawLine(
          String text, {
            double fontSize = 26,
            FontWeight weight = FontWeight.w600,
            Color color = Colors.white,
          }) {
        final tp = TextPainter(
          text: TextSpan(
            text: text,
            style:
            TextStyle(fontSize: fontSize, fontWeight: weight, color: color),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '…',
        );
        tp.layout(maxWidth: cardWidth - 48);
        tp.paint(canvas, Offset(24, y));
        y += tp.height + 10;
      }

      drawLine(p.name.toUpperCase(), fontSize: 34, weight: FontWeight.bold);

      // Price Line
      double? selectedPrice = (priceType == "WHOLESALE") ? p.wholesalePrice : p.retailerPrice;
      String priceLabel = (priceType == "WHOLESALE") ? "Wholesale Price" : "Retail Price";
      
      if (selectedPrice != null) {
        drawLine("$priceLabel: ₹${selectedPrice.toStringAsFixed(2)}", 
                 fontSize: 30, weight: FontWeight.w900, color: Colors.yellow.shade400);
      }

      final details = <String>[];
      if (p.size.isNotEmpty) details.add("Size: ${p.size}");
      if (p.color.isNotEmpty) details.add("Color: ${p.color}");
      if (p.material.isNotEmpty) details.add("Material: ${p.material}");
      if (details.isNotEmpty) {
        drawLine(details.join("   |   "), fontSize: 22, weight: FontWeight.normal);
      }
      drawLine("SKU: ${p.sku}", fontSize: 20, weight: FontWeight.normal, color: Colors.white70);

      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(
        cardWidth.toInt(),
        (photoHeight + footerHeight).toInt(),
      );
      final byteData =
      await finalImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/card_${p.sku}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file;
    } catch (e) {
      debugPrint("⚠️ Card build failed for ${p.sku}: $e");
      return null;
    }
  }

  static Future<void> shareProductsAsWhatsappCatalogue(
      BuildContext context,
      List<ProductModel> products,
      VoidCallback onDone,
      ) async {
    if (products.isEmpty) return;

    // Show selection dialog
    String? selectedType = await Get.bottomSheet<String>(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Share Price",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Choose which price you want to show on the sharing images.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.business_outlined, color: Colors.indigo),
              title: const Text("Wholesale Price", style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Get.back(result: "WHOLESALE"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.grey.shade50,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.teal),
              title: const Text("Retailer Price", style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Get.back(result: "RETAILER"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.grey.shade50,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (selectedType == null) {
      onDone();
      return;
    }

    final overlay = OverlayEntry(
      builder: (_) => const Positioned.fill(
        child: ColoredBox(
          color: Colors.black26,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      ),
    );
    Overlay.of(context).insert(overlay);

    try {
      final List<XFile> files = [];
      for (final p in products) {
        final card = await _buildProductCard(p, selectedType);
        if (card != null) files.add(XFile(card.path));
      }

      overlay.remove();

      if (files.isEmpty) {
        debugPrint("⚠️ No product cards generated to share");
        return;
      }

      await Share.shareXFiles(
        files,
        text: products.length > 1
            ? "🛍 Product Catalogue - ${products.length} items"
            : null,
      );
    } catch (e) {
      overlay.remove();
      debugPrint("WhatsApp share failed: $e");
    } finally {
      onDone();
    }
  }
}
