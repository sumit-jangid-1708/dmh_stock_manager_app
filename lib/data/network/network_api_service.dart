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
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (!url.contains(AppUrl.loginOtp) && !url.contains(AppUrl.appLogin)) {
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
      final uri = Uri.parse(url);
      final response = await _sendWithRetry(
        () => http.get(uri, headers: headers),
        timeout: const Duration(seconds: 30),
      );
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
      final uri = Uri.parse(url);
      final body = jsonEncode(data);
      final response = await _sendWithRetry(
        () => http.post(uri, body: body, headers: mergedHeaders),
        timeout: const Duration(seconds: 40),
      );
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
      final uri = Uri.parse(url);
      final body = jsonEncode(data);
      final response = await _sendWithRetry(
        () => http.put(uri, body: body, headers: mergedHeaders),
        timeout: const Duration(seconds: 40),
      );
      return _returnResponse(response);
    } on SocketException {
      throw InternetExceptions();
    } on TimeoutException {
      throw RequestTimeOut();
    }
  }

  @override
  Future<dynamic> deleteApi(String url, {Map<String, String>? headers}) async {
    if (kDebugMode) print('🌐 DELETE → $url');
    try {
      final mergedHeaders = await _getHeaders(url, extra: headers);
      final uri = Uri.parse(url);
      final response = await _sendWithRetry(
        () => http.delete(uri, headers: mergedHeaders),
        timeout: const Duration(seconds: 40),
      );
      return _returnResponse(response);
    } on SocketException {
      throw InternetExceptions();
    } on TimeoutException {
      throw RequestTimeOut();
    }
  }

  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function() send, {
    required Duration timeout,
  }) async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await send().timeout(timeout);
        if (!_shouldRetry(response) || attempt == maxAttempts) {
          return response;
        }
        if (kDebugMode) {
          print(
            '🌐 Retry $attempt/$maxAttempts after gateway response '
            '${response.statusCode}',
          );
        }
      } on SocketException {
        if (attempt == maxAttempts) rethrow;
        if (kDebugMode)
          print('🌐 Retry $attempt/$maxAttempts after socket error');
      } on TimeoutException {
        if (attempt == maxAttempts) rethrow;
        if (kDebugMode) print('🌐 Retry $attempt/$maxAttempts after timeout');
      }
      await Future.delayed(Duration(milliseconds: 500 * attempt));
    }
    throw RequestTimeOut();
  }

  bool _shouldRetry(http.Response response) {
    if (response.statusCode == 502 ||
        response.statusCode == 503 ||
        response.statusCode == 504) {
      return true;
    }
    final body = response.body.toLowerCase();
    return body.contains('err_ngrok_3004') ||
        body.contains('ngrok gateway error');
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

    final isJson = contentType.contains('application/json') ||
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
      case 301:
      case 302:
      case 303:
      case 307:
      case 308:
        final location = response.headers['location'] ?? '';
        if (location.contains('/login')) {
          throw UnauthorizedException();
        }
        throw AppExceptions('Request was redirected. Please try again.');
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
        throw UnauthorizedException();
      case 403:
        final body = safeDecodeBody();
        if (body is Map) {
          final detail = body['detail'] ?? body['message'] ?? body['error'];
          if (detail != null) throw AppExceptions(detail.toString());
        }
        throw AppExceptions('Aapko is action ki permission nahi hai.');
      case 404:
        throw AppExceptions('Resource not found (404)');
      case 500:
        final body = safeDecodeBody();
        if (body is Map) {
          final details = body['details']?.toString();
          final message = body['message']?.toString();
          final error = body['error']?.toString();

          if (details != null && details.isNotEmpty) {
            if (details.contains('stock_error')) {
              final match = RegExp(r"string='([^']+)'").firstMatch(details);
              if (match != null) throw AppExceptions(match.group(1));
            }
            throw AppExceptions(details);
          }
          if (message != null && message.isNotEmpty)
            throw AppExceptions(message);
          if (error != null && error != 'Something went wrong')
            throw AppExceptions(error);
        }
        throw ServerException(); // generic fallback

      // ✅ 502, 503, 504 bhi ServerException throw karo — ye sab server issues hain
      case 502:
      case 503:
      case 504:
        throw ServerException(
          'Server is currently unavailable. Please try again later.',
        );
      // case 502:
      //   throw AppExceptions(
      //     'Server gateway error (502). Please try again later.',
      //   );
      // case 503:
      //   throw AppExceptions(
      //     'Server is temporarily unavailable (503). Please try again later.',
      //   );
      // case 504:
      //   throw AppExceptions('Server timed out (504). Please try again later.');
      default:
        throw AppExceptions('Unexpected error ($statusCode)');
    }
  }
}
