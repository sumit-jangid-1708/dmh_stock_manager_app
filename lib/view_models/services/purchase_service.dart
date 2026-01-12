

import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

class PurchaseService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> addPurchaseBill (data) async{
    final response = await _apiServices.postApi(data, AppUrl.purchaseItem);
    return response;
  }

  Future<dynamic> getPurchaseListApi()async{
    final response = await _apiServices.getApi(AppUrl.getPurchaseDetails);
    return response;
  }

}