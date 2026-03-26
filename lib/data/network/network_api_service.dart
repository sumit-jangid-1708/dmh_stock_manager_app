// Path: lib/data/network/network_api_services.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dmj_stock_manager/data/app_exceptions.dart';
import 'package:dmj_stock_manager/data/network/base_api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../res/app_url/app_url.dart';

class NetworkApiServices extends BaseApiServices {
  final storage = GetStorage();

  /// 🔥 Build Headers with Token
  Future<Map<String, String>> _getHeaders(
      String url, {
        Map<String, String>? extra,
      }) async {
    final token = storage.read("access_token") ?? "";

    final headers = {'Content-Type': 'application/json'};

    // ❌ Don't add token for login API
    if (!url.contains(AppUrl.loginOtp)) {
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    // merge extras
    if (extra != null) {
      headers.addAll(extra);
    }

    return headers;
  }

  @override
  Future<dynamic> getApi(String url) async {
    if (kDebugMode) print('🌐 GET Request URL: $url');

    try {
      final headers = await _getHeaders(url);

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 20));

      return returnResponse(response);
    } on SocketException {
      throw InternetExceptions();
    } on TimeoutException {
      throw RequestTimeOut();
    }
  }

  @override
  Future<dynamic> postApi(
      dynamic data,
      String url, {
        Map<String, String>? headers,
      }) async {
    if (kDebugMode) {
      print('🌐 POST Request URL: $url');
      print('🌐 POST Request Body: $data');
    }
    try {
      // use token headers unless custom passed
      final mergedHeaders = await _getHeaders(url, extra: headers);
      final response = await http
          .post(Uri.parse(url), body: jsonEncode(data), headers: mergedHeaders)
          .timeout(const Duration(seconds: 30));
      print("🌐 API Response Status Code: ${response.statusCode}");
      print("🌐 API Response Content-Type: $mergedHeaders");
      return jsonDecode(response.body);
    } on SocketException {
      throw InternetExceptions();
    } on TimeoutException {
      throw RequestTimeOut();
    }
  }

  @override
  Future<dynamic> putApi(
      dynamic data,
      String url, {
        Map<String, String>? headers,
      }) async {
    if (kDebugMode) {
      print('🌐 PUT Request URL: $url');
      print('🌐 PUT Request Body: $data');
    }

    try {
      final mergedHeaders = await _getHeaders(url, extra: headers);

      final response = await http
          .put(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: mergedHeaders,
      )
          .timeout(const Duration(seconds: 30));

      return returnResponse(response);
    } on SocketException {
      throw InternetExceptions();
    } on TimeoutException {
      throw RequestTimeOut();
    }
  }

  /// ✅ DELETE API Method
  Future<dynamic> deleteApi(
      String url, {
        Map<String, String>? headers,
      }) async {
    if (kDebugMode) {
      print('🌐 DELETE Request URL: $url');
    }

    try {
      final mergedHeaders = await _getHeaders(url, extra: headers);

      final response = await http
          .delete(
        Uri.parse(url),
        headers: mergedHeaders,
      )
          .timeout(const Duration(seconds: 30));

      return returnResponse(response);
    } on SocketException {
      throw InternetExceptions();
    } on TimeoutException {
      throw RequestTimeOut();
    }
  }

  dynamic returnResponse(http.Response response) {
    final contentType = response.headers['content-type'];

    if (kDebugMode) {
      print("🌐 API Response Status Code: ${response.statusCode}");
      print("🌐 API Response Content-Type: $contentType");
    }
    // PDF case
    if (contentType != null && contentType.contains('application/pdf')) {
      if (kDebugMode) print("📄 PDF response received.");
      return response.bodyBytes;
    }
    if (kDebugMode) {
      print('🌐 API Response Status Code: ${response.statusCode}');
      print('🌐 API Response Body: ${response.body}');
    }
    final responseBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    switch (response.statusCode) {
      case 200:
      case 201:
      case 204: // ✅ Added for DELETE success (No Content)
        return response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {'message': 'Success'};

      case 400:
        throw AppExceptions(responseBody);

      case 401:
      case 403:
        throw UnauthorizedException();

      case 500:
        throw ServerException();

      default:
        throw AppExceptions("Error: ${response.statusCode}");
    }
  }

  Map<String, dynamic> _tryDecodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {};
    }
  }
}