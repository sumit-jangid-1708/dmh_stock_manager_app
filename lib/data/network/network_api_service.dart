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

  Future<Map<String, String>> _getHeaders(
    String url, {
    Map<String, String>? extra,
  }) async {
    final token = storage.read("access_token") ?? "";
    final headers = {'Content-Type': 'application/json'};
    if (!url.contains(AppUrl.loginOtp)) {
      if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    }
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  @override
  Future<dynamic> getApi(String url) async {
    if (kDebugMode) print('🌐 GET → $url');
    try {
      final headers = await _getHeaders(url);
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 20));
      return _returnResponse(response);
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
      print('🌐 POST → $url');
      print('🌐 Body  → $data');
    }
    try {
      final mergedHeaders = await _getHeaders(url, extra: headers);
      final response = await http
          .post(Uri.parse(url), body: jsonEncode(data), headers: mergedHeaders)
          .timeout(const Duration(seconds: 30));
      return _returnResponse(response);
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
      print('🌐 PUT → $url');
      print('🌐 Body → $data');
    }
    try {
      final mergedHeaders = await _getHeaders(url, extra: headers);
      final response = await http
          .put(Uri.parse(url), body: jsonEncode(data), headers: mergedHeaders)
          .timeout(const Duration(seconds: 30));
      return _returnResponse(response);
    } on SocketException {
      throw InternetExceptions();
    } on TimeoutException {
      throw RequestTimeOut();
    }
  }

  Future<dynamic> deleteApi(String url, {Map<String, String>? headers}) async {
    if (kDebugMode) print('🌐 DELETE → $url');
    try {
      final mergedHeaders = await _getHeaders(url, extra: headers);
      final response = await http
          .delete(Uri.parse(url), headers: mergedHeaders)
          .timeout(const Duration(seconds: 30));
      return _returnResponse(response);
    } on SocketException {
      throw InternetExceptions();
    } on TimeoutException {
      throw RequestTimeOut();
    }
  }

  dynamic _returnResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    final statusCode = response.statusCode;

    if (kDebugMode) {
      print('🌐 Status       → $statusCode');
      print('🌐 Content-Type → $contentType');
      print('🌐 Body         → ${response.body}');
    }

    if (contentType.contains('application/pdf')) {
      return response.bodyBytes;
    }

    final isJson =
        contentType.contains('application/json') ||
        contentType.contains('text/json');

    dynamic safeDecodeBody() {
      if (response.body.isEmpty) return {};
      if (!isJson) return {};
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {};
      }
    }

    switch (statusCode) {
      case 200:
      case 201:
        return safeDecodeBody();
      case 204:
        return {'message': 'Success'};
      case 400:
        final body = safeDecodeBody();
        if (body is Map) {
          final detail = body['detail'] ?? body['message'];
          if (detail != null) throw AppExceptions(detail.toString());
          for (final value in body.values) {
            if (value is List && value.isNotEmpty)
              throw AppExceptions(value.first.toString());
            if (value is String) throw AppExceptions(value);
          }
        }
        throw AppExceptions('Bad request (400)');
      case 401:
      case 403:
        throw UnauthorizedException();
      case 404:
        throw AppExceptions('Resource not found (404)');
      case 500:
        final body = safeDecodeBody();
        // ✅ Backend ne meaningful error diya ho to wo dikhao
        if (body is Map) {
          // "details" field mein actual error hota hai
          final details = body['details']?.toString();
          final error = body['error']?.toString();
          final message = body['message']?.toString();

          // Stock error ya koi specific error extract karo
          if (details != null && details.isNotEmpty) {
            // "stock_error" jaise nested errors handle karo
            if (details.contains('stock_error')) {
              // Extract readable part
              final match = RegExp(r"string='([^']+)'").firstMatch(details);
              if (match != null) {
                throw AppExceptions(match.group(1)); // "No inventory record found for X"
              }
            }
            throw AppExceptions(details);
          }
          if (message != null && message.isNotEmpty) throw AppExceptions(message);
          if (error != null && error != 'Something went wrong') throw AppExceptions(error);
        }
        throw ServerException(); // generic fallback
      case 502:
        throw AppExceptions(
          'Server gateway error (502). Please try again later.',
        );
      case 503:
        throw AppExceptions(
          'Server is temporarily unavailable (503). Please try again later.',
        );
      case 504:
        throw AppExceptions('Server timed out (504). Please try again later.');
      default:
        throw AppExceptions('Unexpected error ($statusCode)');
    }
  }
}
