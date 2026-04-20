import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dmj_stock_manager/model/product_models/product_model.dart';

class ProductShareService {
  static const String _baseUrl = "https://traders.testwebs.in";

  // ── Full image URL resolve ──
  static String _resolveUrl(String raw) {
    if (raw.isEmpty) return '';
    return raw.startsWith('http') ? raw : '$_baseUrl$raw';
  }

  // ── Download image to temp file ──
  static Future<File?> _downloadImage(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/share_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (e) {
      debugPrint("⚠️ Image download failed: $e");
      return null;
    }
  }

  // ── Build text for one product (NO purchase price) ──
  static String _buildProductText(ProductModel p) {
    final buffer = StringBuffer();
    buffer.writeln("📦 *${p.name}*");
    if (p.size.isNotEmpty) buffer.writeln("📐 Size: ${p.size}");
    if (p.color.isNotEmpty) buffer.writeln("🎨 Color: ${p.color}");
    if (p.material.isNotEmpty) buffer.writeln("🧱 Material: ${p.material}");
    buffer.writeln("🔖 SKU: ${p.sku}");
    return buffer.toString();
  }

  /// ── Main share method ──
  static Future<void> shareProductsAsWhatsappCatalogue(
      BuildContext context,
      List<ProductModel> products,
      VoidCallback onDone,
      ) async {
    if (products.isEmpty) return;

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
      final List<XFile> imageFiles = [];
      final StringBuffer message = StringBuffer();

      message.writeln("🛍 *PRODUCT CATALOGUE*");
      message.writeln("────────────────────────\n");

      for (int i = 0; i < products.length; i++) {
        final p = products[i];

        message.writeln("📦 *${p.name.toUpperCase()}*");

        if (p.size.isNotEmpty) {
          message.writeln("📐 Size: ${p.size}");
        }

        if (p.color.isNotEmpty) {
          message.writeln("🎨 Color: ${p.color}");
        }

        if (p.material.isNotEmpty) {
          message.writeln("🧱 Material: ${p.material}");
        }

        message.writeln("🔖 SKU: ${p.sku}");

        // ❌ purchase price intentionally excluded

        message.writeln("\n────────────────────────\n");

        // Image download
        if (p.productImageVariants.isNotEmpty) {
          final url = _resolveUrl(p.productImageVariants.first);
          final file = await _downloadImage(url);
          if (file != null) {
            imageFiles.add(XFile(file.path));
          }
        }
      }

      overlay.remove();

      if (imageFiles.isNotEmpty) {
        await Share.shareXFiles(
          imageFiles,
          text: message.toString(),
        );
      } else {
        await Share.share(message.toString());
      }

    } catch (e) {
      overlay.remove();
      debugPrint("WhatsApp share failed: $e");
    } finally {
      onDone();
    }
  }
}
