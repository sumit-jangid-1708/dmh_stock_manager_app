import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

class HomeService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> addChannelApi(data) async {
    dynamic response = _apiServices.postApi(data, AppUrl.channels);
    return response;
  }

  Future<dynamic> getChannelApi() async {
    dynamic response = _apiServices.getApi(AppUrl.channels);
    return response;
  }

  Future<dynamic> stockDetailsApi() async {
    dynamic response = _apiServices.getApi(AppUrl.stockDetails);
    return response;
  }


}
