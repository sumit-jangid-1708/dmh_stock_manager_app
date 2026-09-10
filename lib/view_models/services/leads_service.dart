import 'dart:convert';
import 'dart:io';

import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/data/app_exceptions.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class LeadsService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> getLeadsOption() async {
    final response = await _apiServices.getApi(AppUrl.leadOptions);
    return response;
  }

  Future<dynamic> getLeadsStats() async {
    final response = await _apiServices.getApi(AppUrl.leadsStats);
    return response;
  }

  Future<dynamic> getLeads(Map<String, dynamic> filters) async {
    final url = Uri.parse(
      AppUrl.getLeads,
    ).replace(queryParameters: filters).toString();
    final response = await _apiServices.getApi(url);
    return response;
  }

  Future<dynamic> addLeads(Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(data, AppUrl.addLeads);
    return response;
  }

  Future<dynamic> updateLead(int id, Map<String, dynamic> data) async {
    final response = await _apiServices.putApi(data, "${AppUrl.getLeads}$id/");
    return response;
  }

  Future<dynamic> getLead(int id) async {
    final response = await _apiServices.getApi("${AppUrl.getLeads}$id/");
    return response;
  }

  Future<dynamic> changeLeadStatus(int id, Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(
      data,
      "${AppUrl.getLeads}$id/status/",
    );
    return response;
  }

  Future<dynamic> addLeadNote(int id, Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(
      data,
      "${AppUrl.getLeads}$id/note/",
    );
    return response;
  }

  Future<dynamic> addLeadFollowUp(int id, Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(
      data,
      "${AppUrl.getLeads}$id/follow-up/",
    );
    return response;
  }

  Future<dynamic> convertLead(int id, Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(
      data,
      "${AppUrl.getLeads}$id/convert/",
    );
    return response;
  }

  Future<dynamic> getLeadActivities(int id) async {
    final response = await _apiServices.getApi(
      "${AppUrl.getLeads}$id/activities/",
    );
    return response;
  }

  Future<dynamic> getLeadFollowUps(int id) async {
    final response = await _apiServices.getApi(
      "${AppUrl.getLeads}$id/follow-ups/",
    );
    return response;
  }

  Future<dynamic> getLeadNotes(int id) async {
    final response = await _apiServices.getApi("${AppUrl.getLeads}$id/notes/");
    return response;
  }

  Future<dynamic> getLeadStatusHistory(int id) async {
    final response = await _apiServices.getApi(
      "${AppUrl.getLeads}$id/status-history/",
    );
    return response;
  }

  Future<dynamic> getFollowUps(Map<String, dynamic> filters) async {
    final url = Uri.parse(
      "${AppUrl.getLeads}follow-ups/",
    ).replace(queryParameters: filters).toString();
    final response = await _apiServices.getApi(url);
    return response;
  }

  Future<dynamic> getFollowUpDetail(int id) async {
    final response = await _apiServices.getApi(
      "${AppUrl.getLeads}follow-ups/$id/",
    );
    return response;
  }

  Future<dynamic> updateFollowUp(int id, Map<String, dynamic> data) async {
    final response = await _apiServices.putApi(
      data,
      "${AppUrl.getLeads}follow-ups/$id/",
    );
    return response;
  }

  Future<dynamic> deleteFollowUp(int id) async {
    final response = await _apiServices.deleteApi(
      "${AppUrl.getLeads}follow-ups/$id/",
    );
    return response;
  }

  Future<dynamic> deleteLead(int id) async {
    final response = await _apiServices.deleteApi("${AppUrl.getLeads}$id/");
    return response;
  }

  Future<dynamic> importLeads(File file) async {
    final token = GetStorage().read('access_token') ?? '';
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrl.importLeads),
    );
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();
    final response = responseBody.isEmpty ? {} : jsonDecode(responseBody);

    if (streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 201) {
      return response;
    }

    final message = response is Map
        ? response['detail'] ?? response['message'] ?? response['error']
        : null;
    throw AppExceptions(message?.toString() ?? 'Lead import failed');
  }
}
