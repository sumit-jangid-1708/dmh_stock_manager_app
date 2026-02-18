import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

import '../../model/courier_return/courier_return_response.dart';
import '../../model/customer_return/customer_return_response.dart';
import '../../model/order_models/order_detail_by_id_model.dart';
import '../../model/order_models/order_detail_model.dart';

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

  Future<OrderDetailsModel> getOrderDetailById(int orderId) async {
    final response = await _apiServices.getApi("${AppUrl.orders}$orderId");
    return OrderDetailsModel.fromJson(response);
  }

  /// ✅ Updated to use OrderBarcodeResponse
  Future<OrderBarcodeResponse> getOrderBarcodes(int orderId) async {
    final response = await _apiServices.getApi("${AppUrl.orderBarcode}$orderId");
    return OrderBarcodeResponse.fromJson(response);
  }

}