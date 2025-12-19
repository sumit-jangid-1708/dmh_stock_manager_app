import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

class StockService{
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> fetchInventoryApi () async{
    dynamic response = await _apiService.getApi(AppUrl.inventory);
    return response;
  }

  Future<dynamic> addProductQuantity (data) async{
    dynamic response = await _apiService.postApi(data, AppUrl.inventory);
    return response;
  }

  Future<dynamic> inventoryAdjustApi (data) async{
    dynamic response = await _apiService.postApi(data, AppUrl.inventoryAdjust);
    return response;
  }
}