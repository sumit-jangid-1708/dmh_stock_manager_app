import 'dart:convert';
import 'dart:io';

import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ItemService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> showProducts() async {
    dynamic response = await _apiServices.getApi(AppUrl.product);
    return response;
  }

  Future<dynamic> addProductApi({
    required Map<String, String> fields,
    required List<File> images,
  }) async {
    final storage = GetStorage();
    final token = storage.read("access_token");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrl.product),
    );

    // ✅ ADD AUTH HEADER (THIS WAS MISSING)
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      // ❌ Content-Type manually mat lagana (Multipart khud set karta hai)
    });

    // add fields
    request.fields.addAll(fields);

    // add images
    for (var image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'product_image',
          image.path,
        ),
      );
    }

    http.StreamedResponse response = await request.send();
    final resStr = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(resStr);
    } else {
      // 🔥 DEBUG ke liye body bhi print karo
      throw Exception(
        "Failed to add product: ${response.statusCode} → $resStr",
      );
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
}
