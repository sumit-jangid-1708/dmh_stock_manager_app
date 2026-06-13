import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';
import 'package:dmj_stock_manager/utils/response_list.dart';

class PurchaseService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> addPurchaseBill(data) async {
    final response = await _apiServices.postApi(data, AppUrl.purchaseItem);
    return response;
  }

  Future<List<dynamic>> getPurchaseListApi() async {
    final response = await _apiServices.getApi(AppUrl.getPurchaseDetails);
    return responseList(response);
  }

  Future<dynamic> updatePurchase(int purchaseId, var data) async {
    final response = await _apiServices.putApi(
        data, "${AppUrl.updatePurchase}/$purchaseId/");
    return response;
  }

  Future<dynamic> deletePurchase(int purchaseId) async {
    final response =
        await _apiServices.deleteApi("${AppUrl.deletePurchase}/$purchaseId/");
    return response;
  }
}
