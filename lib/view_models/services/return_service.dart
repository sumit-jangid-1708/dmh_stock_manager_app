import 'package:dmj_stock_manager/model/courier_return/courier_return_list_model.dart';

import '../../data/network/network_api_service.dart';
import '../../model/courier_return/courier_return_response.dart';
import '../../model/customer_return/customer_return_response.dart';
import '../../res/app_url/app_url.dart';

class ReturnService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<CourierReturnResponse> courierReturnApi(
    Map<String, dynamic> body,
  ) async {
    final response = await _apiServices.postApi(body, AppUrl.courierReturn);
    return CourierReturnResponse.fromJson(response);
  }

  Future<CustomerReturnResponse> customerReturnApi(
    Map<String, dynamic> body,
  ) async {
    final response = await _apiServices.postApi(body, AppUrl.customerReturn);
    return CustomerReturnResponse.fromJson(response);
  }

  Future<List<dynamic>> courierReturnList({
    String? condition,
    String? claimStatus,
    String? claimResult,
  }) async {
    String url = AppUrl.courierReturnList;
    final queryParams = <String, String>{};
    if (condition != null) {
      queryParams['condition'] = condition;
    }
    if (claimStatus != null) {
      queryParams['claim_status'] = claimStatus;
    }
    if (claimResult != null) {
      queryParams['claim_result'] = claimResult;
    }
    if (queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      url = '$url?$queryString';
    }
    final response = await _apiServices.getApi(url);
    return response as List<dynamic>;
  }

  Future<List<dynamic>> customerReturnList({
    String? condition,
    String? refundStatus,
  }) async {
    String url = AppUrl.customerReturnList;

    final queryParams = <String, String>{};

    if (condition != null) {
      queryParams['condition'] = condition;
    }

    if (refundStatus != null) {
      queryParams['refund_status'] = refundStatus;
    }

    if (queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => "${e.key}=${e.value}")
          .join("&");
      url = "$url?$queryString";
    }
    final response = await _apiServices.getApi(url);
    return response;
  }
}
