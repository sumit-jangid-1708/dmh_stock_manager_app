import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

class PurchaseService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> addPurchaseBill(data) async {
    final response = await _apiServices.postApi(data, AppUrl.purchaseItem);
    return response;
  }

  Future<List<dynamic>> getPurchaseListApi() async {
    final response = await _apiServices.getApi(AppUrl.getPurchaseDetails);

    // Handle paginated response { count: ..., results: [...] }
    if (response is Map<String, dynamic> &&
        response.containsKey('results')) {
      return response['results'] as List<dynamic>;
    }

    // Handle plain list response
    if (response is List<dynamic>) {
      return response;
    }

    return [];
  }

  Future<dynamic> updatePurchase(int purchaseId, var data) async {
    final response = await _apiServices.putApi(data, "${AppUrl.updatePurchase}/$purchaseId/");
    return response;
  }
  Future<dynamic> deletePurchase(int purchaseId) async {
    final response = await _apiServices.deleteApi("${AppUrl.deletePurchase}/$purchaseId/");
    return response;
  }

}