import 'dart:convert';
import 'dart:io';

import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';
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
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrl.product), // 👈 your product API endpoint
    );

    // add fields
    request.fields.addAll(fields);

    // add images
    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath(
        'product_image', // 👈 must match backend field name
        image.path,
      ));
    }
    // send request
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resStr = await response.stream.bytesToString();
      return jsonDecode(resStr); // return JSON to controller
    } else {
      throw Exception("Failed to add product: ${response.reasonPhrase}");
    }
  }
// Future<dynamic> addProductApi(data) async {
  //   dynamic response = await _apiServices.postApi(data, AppUrl.product);
  //   return response;
  // }
}
