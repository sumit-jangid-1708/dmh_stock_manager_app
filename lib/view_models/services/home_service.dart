import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

class HomeService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> appDashboardApi() async {
    final response = await _apiServices.getApi(AppUrl.appDashboard);
    return response;
  }

  Future<dynamic> appUsersApi({String search = "", int limit = 50}) async {
    final query = Uri(
      queryParameters: {
        if (search.trim().isNotEmpty) "search": search.trim(),
        "limit": limit.toString(),
      },
    ).query;
    final response = await _apiServices.getApi("${AppUrl.appUsers}?$query");
    return response;
  }

  Future<dynamic> addChannelApi(data) async {
    final response = await _apiServices.postApi(data, AppUrl.channels);
    return response;
  }

  Future<dynamic> getChannelApi() async {
    dynamic response = await _apiServices.getApi(AppUrl.channels);
    return response;
  }

  Future<dynamic> stockDetailsApi() async {
    dynamic response = await _apiServices.getApi(AppUrl.stockDetails);
    return response;
  }

  Future<dynamic> bestSellingProductsApi({int limit = 5}) async {
    dynamic response = await _apiServices.getApi(
        "${AppUrl.bestSellingProducts}/?best_selling=true&limit=$limit");
    return response;
  }
}
