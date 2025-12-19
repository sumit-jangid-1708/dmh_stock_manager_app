import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

class BillingService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> getBills({required int page}) async {
    final response = await _apiServices.getApi('${AppUrl.allBills}?"page=$page');
    return response;
  }
 }