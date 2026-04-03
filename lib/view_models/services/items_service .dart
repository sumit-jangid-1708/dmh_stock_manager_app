import 'dart:convert';
import 'dart:io';

import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ItemService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  // ✅ Base URL — relative paths ko full URL banane ke liye
  static const String _baseUrl = "https://traders.testwebs.in";

  Future<dynamic> showProducts() async {
    dynamic response = await _apiServices.getApi(AppUrl.product);
    return response;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Upload single image → returns relative path string
  //    POST /upload-image/
  //    Response: { "path": "/media/products/xyz.png" }
  // ─────────────────────────────────────────────────────────────────────────
  Future<String> uploadImage(File image) async {
    final storage = GetStorage();
    final token = storage.read("access_token");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrl.uploadImage),
    );
    request.headers['Authorization'] = 'Bearer $token';

    if (!await image.exists()) {
      throw Exception("Image file not found: ${image.path}");
    }
    final fileSize = await image.length();
    if (fileSize > 10 * 1024 * 1024) {
      throw Exception("Image file too large (max 10MB): ${image.path}");
    }

    request.files.add(
      await http.MultipartFile.fromPath('image', image.path),
    );

    if (kDebugMode) print("📤 Uploading: ${image.path}");

    final streamedResponse = await request.send();
    final resStr = await streamedResponse.stream.bytesToString();

    if (kDebugMode) {
      print("📥 Upload Status: ${streamedResponse.statusCode}");
      print("📥 Upload Body: $resStr");
    }

    if (streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 201) {
      final decoded = jsonDecode(resStr);
      final path = decoded['path'] as String?;
      if (path == null || path.isEmpty) {
        throw Exception("No path returned from upload API");
      }
      // Returns relative path e.g. "/media/products/xyz.png"
      return path;
    } else {
      throw Exception(
        "Image upload failed — status: ${streamedResponse.statusCode}. Body: $resStr",
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Helper — relative path → full URL
  //    "/media/products/xyz.png" → "https://traders.testwebs.in/media/products/xyz.png"
  //    already full URL → unchanged
  // ─────────────────────────────────────────────────────────────────────────
  static String toFullUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$_baseUrl$path';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Add product
  //    imagePaths — relative paths from uploadImage()
  //    Sent to backend as: product_image_variants = '["url1","url2"]'
  // ─────────────────────────────────────────────────────────────────────────
  Future<dynamic> addProductApi({
    required Map<String, dynamic> fields,
    required List<String> imagePaths,
  }) async {
    final storage = GetStorage();
    final token = storage.read("access_token");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrl.product),
    );
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // ✅ Convert relative paths → full URLs → JSON array string
    // Backend expects: ["https://.../img1.jpg", "https://.../img2.jpg"]
    final List<String> fullUrls = imagePaths.map(toFullUrl).toList();
    request.fields['product_image_variants'] = jsonEncode(fullUrls);

    if (kDebugMode) {
      print("📤 Add product — image_variants: ${jsonEncode(fullUrls)}");
      print("📤 Fields: $fields");
    }

    final response = await request.send();
    final resStr = await response.stream.bytesToString();

    if (kDebugMode) {
      print("📥 Add Product Status: ${response.statusCode}");
      print("📥 Add Product Body: $resStr");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(resStr);
    } else {
      final decoded = jsonDecode(resStr);
      String errorMessage = "Failed to add product";
      if (decoded is Map && decoded.containsKey('product_image')) {
        errorMessage = decoded['product_image'][0];
      } else if (decoded is Map && decoded.containsKey('message')) {
        errorMessage = decoded['message'];
      }
      throw Exception(errorMessage);
    }
  }

  Future<dynamic> hsnCodeList() async {
    dynamic response = await _apiServices.getApi(AppUrl.hsnCode);
    return response;
  }

  Future<dynamic> addHsn(data) async {
    dynamic response = await _apiServices.postApi(data, AppUrl.hsnCode);
    return response;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Edit product
  //    imagePaths — relative paths (empty list = keep existing images)
  //    Sent as: product_image_variants = '["url1","url2"]'
  // ─────────────────────────────────────────────────────────────────────────
  Future<dynamic> editProduct({
    required Map<String, dynamic> fields,
    required List<String> imagePaths,
    required int productId,
  }) async {
    final storage = GetStorage();
    final token = storage.read("access_token");

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse("${AppUrl.editProduct}/$productId"),
    );
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // ✅ Only send image_variants if new images were uploaded
    if (imagePaths.isNotEmpty) {
      final List<String> fullUrls = imagePaths.map(toFullUrl).toList();
      request.fields['product_image_variants'] = jsonEncode(fullUrls);

      if (kDebugMode) {
        print("📤 Edit product — image_variants: ${jsonEncode(fullUrls)}");
      }
    } else {
      if (kDebugMode) print("⚠️ No new images — keeping existing on backend.");
    }

    if (kDebugMode) {
      print("📤 Edit product ID $productId — fields: $fields");
    }

    final response = await request.send();
    final resStr = await response.stream.bytesToString();

    if (kDebugMode) {
      print("📥 Edit Product Status: ${response.statusCode}");
      print("📥 Edit Product Body: $resStr");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(resStr);
    } else {
      final decoded = jsonDecode(resStr);
      String errorMessage = "Failed to update product";
      if (decoded is Map && decoded.containsKey('message')) {
        errorMessage = decoded['message'];
      }
      throw Exception(errorMessage);
    }
  }

  /// ✅ Delete Product API
  Future<dynamic> deleteProduct(int productId) async {
    final url = "${AppUrl.deleteProduct}/$productId/";
    if (kDebugMode) print("🗑️ DELETE $url");
    dynamic response = await _apiServices.deleteApi(url);
    if (kDebugMode) print("✅ Deleted: $response");
    return response;
  }
}