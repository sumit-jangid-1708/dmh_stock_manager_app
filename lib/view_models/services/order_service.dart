import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

class OrderService{
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> getOrderDetailApi ()async{
    dynamic response = await _apiServices.getApi(AppUrl.orders);
    return response;
  }

  Future<dynamic> createOrderApi (data) async {
    dynamic response = await _apiServices.postApi(data, AppUrl.orders);
    return response;
  }

  Future<dynamic> wpsReturnApi (data) async {
    dynamic response = await _apiServices.postApi(data, AppUrl.wpsReturn);
    return response;
  }

  Future<dynamic> customerReturnApi (data) async{
    dynamic response = await _apiServices.postApi(data, AppUrl.customerReturn);
    return response;
  }

  Future<dynamic> returnOrderHistory(String reason, String condition) async {
    dynamic response = _apiServices.getApi(
      "${AppUrl.returnOrders}?reason=$reason&condition=$condition",
    );
    return response;
  }

  Future<dynamic> createBill(data, int id) async{
    dynamic response = _apiServices.postApi(data, "${AppUrl.createBill}/$id/");
    return response;
  }
}