import 'dart:convert';
import 'dart:io';

import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ItemService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> showProducts() async {
    dynamic response = await _apiServices.getApi(AppUrl.product);
    return response;
  }

  Future<dynamic> addProductApi({
    required Map<String, dynamic> fields,
    required List<File> images,
  }) async {
    final storage = GetStorage();
    final token = storage.read("access_token");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrl.product),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    // ✅ Add fields
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // ✅ Add images with error handling
    for (var i = 0; i < images.length; i++) {
      try {
        final image = images[i];

        // ✅ Check if file exists
        if (!await image.exists()) {
          throw Exception("Image file not found: ${image.path}");
        }

        // ✅ Check file size (optional, max 10MB)
        final fileSize = await image.length();
        if (fileSize > 10 * 1024 * 1024) {
          throw Exception("Image file too large (max 10MB): ${image.path}");
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'product_image',
            image.path,
          ),
        );

        if (kDebugMode) {
          print("✅ Added image ${i + 1}: ${image.path}");
        }
      } catch (e) {
        if (kDebugMode) {
          print("❌ Error adding image ${i + 1}: $e");
        }
        rethrow;
      }
    }

    if (kDebugMode) {
      print("📤 Sending request with ${images.length} images");
    }

    http.StreamedResponse response = await request.send();
    final resStr = await response.stream.bytesToString();

    if (kDebugMode) {
      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: $resStr");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(resStr);
    } else {
      // ✅ Better error message
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


// Future<dynamic> addProductApi(data) async {
  //   dynamic response = await _apiServices.postApi(data, AppUrl.product);
  //   return response;
  // }

  Future<dynamic> hsnCodeList() async{
    dynamic response = await _apiServices.getApi(AppUrl.hsnCode);
    return response;
  }

  Future<dynamic> addHsn(data)async{
    dynamic response = await _apiServices.postApi(data, AppUrl.hsnCode);
    return response;
  }

  Future<dynamic> editProduct({
    required Map<String, dynamic> fields,
    required List<File> images,
    required int productId,
  }) async {
    final storage = GetStorage();
    final token = storage.read("access_token");

    var request = http.MultipartRequest(
      'PUT', // ✅ Using PUT method
      Uri.parse("${AppUrl.editProduct}/$productId"),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    // ✅ Add fields
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // ✅ Add images (only if new images selected)
    if (images.isNotEmpty) {
      for (var i = 0; i < images.length; i++) {
        try {
          final image = images[i];

          if (!await image.exists()) {
            throw Exception("Image file not found: ${image.path}");
          }

          final fileSize = await image.length();
          if (fileSize > 10 * 1024 * 1024) {
            throw Exception("Image file too large (max 10MB): ${image.path}");
          }

          request.files.add(
            await http.MultipartFile.fromPath(
              'product_image',
              image.path,
            ),
          );

          if (kDebugMode) {
            print("✅ Added image ${i + 1}: ${image.path}");
          }
        } catch (e) {
          if (kDebugMode) {
            print("❌ Error adding image ${i + 1}: $e");
          }
          rethrow;
        }
      }
    }

    if (kDebugMode) {
      print("📤 Sending edit request for product ID: $productId");
      print("📤 Fields: $fields");
      print("📤 Images: ${images.length}");
    }

    http.StreamedResponse response = await request.send();
    final resStr = await response.stream.bytesToString();

    if (kDebugMode) {
      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: $resStr");
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
}
