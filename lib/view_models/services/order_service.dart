import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

import '../../model/courier_return/courier_return_response.dart';
import '../../model/customer_return/customer_return_response.dart';
import '../../model/order_models/courier_partner_model.dart';
import '../../model/order_models/order_detail_by_id_model.dart';
import '../../model/order_models/order_detail_model.dart';

class OrderService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> getOrderDetailApi() async {
    dynamic response = await _apiServices.getApi(AppUrl.orders);
    return response;
  }

  Future<dynamic> createOrderApi(data) async {
    dynamic response = await _apiServices.postApi(data, AppUrl.orders);
    return response;
  }

  Future<dynamic> returnOrderHistory(String reason, String condition) async {
    dynamic response = _apiServices.getApi(
      "${AppUrl.returnOrders}?reason=$reason&condition=$condition",
    );
    return response;
  }

  Future<dynamic> createBill(data, int id) async {
    dynamic response = _apiServices.postApi(data, "${AppUrl.createBill}/$id/");
    return response;
  }

  Future<OrderDetailsModel> getOrderDetailById(int orderId) async {
    final response = await _apiServices.getApi("${AppUrl.orders}$orderId");
    return OrderDetailsModel.fromJson(response);
  }

  /// ✅ Updated to use OrderBarcodeResponse
  Future<OrderBarcodeResponse> getOrderBarcodes(int orderId) async {
    final response = await _apiServices.getApi(
      "${AppUrl.orderBarcode}$orderId",
    );
    return OrderBarcodeResponse.fromJson(response);
  }

  // POST /api/orders/{orderId}/add-remark/
  Future<dynamic> addRemark(int orderId, String remark) async {
    final url = "${AppUrl.orders}$orderId/add-remark/";
    final response = await _apiServices.postApi({"remark": remark}, url);
    return response;
  }

  Future<dynamic> cancelOrder(int orderId) async {
    final url = "${AppUrl.cancelOrder}/$orderId/cancel/";
    final response = await _apiServices.postApi({}, url);
    return response;
  }

  Future<dynamic> softDeleteOrder(int orderId) async {
    final url = "${AppUrl.deleteOrder}/$orderId/soft-delete/";
    final response = await _apiServices.deleteApi(url);
    return response;
  }

  Future<dynamic> createCourierPartner(Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(
      data,
      AppUrl.createCourierPartner,
    ); // AppUrl me "api/courier/create/" add karna
    return response;
  }

  Future<List<CourierPartnerDetailModel>> getCourierPartners() async {
    final response = await _apiServices.getApi(AppUrl.courierList);
    final List<dynamic> data = response as List<dynamic>;
    return data.map((e) => CourierPartnerDetailModel.fromJson(e)).toList();
  }

  Future<dynamic>createShipment(Map<String, dynamic> data, int orderId) async{
    final response = await _apiServices.postApi(data, "${AppUrl.createShipment}/$orderId/create-shipment/");
    return response;
  }

  Future<List<dynamic>> getOrdersWithShipments() async {
    final response = await _apiServices.getApi(
      AppUrl.shipmentList,
    );
    return response;
  }
}
