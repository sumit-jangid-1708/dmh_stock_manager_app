import 'dart:ui';
import 'package:dmj_stock_manager/model/courier_return/courier_return_list_model.dart';
import 'package:dmj_stock_manager/model/courier_return/courier_return_response.dart';
import 'package:dmj_stock_manager/model/customer_return/customer_return_list_model.dart';
import 'package:dmj_stock_manager/model/customer_return/customer_return_request.dart';
import 'package:dmj_stock_manager/model/customer_return/customer_return_response.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/services/return_service.dart';
import 'package:get/get.dart';

class ReturnController extends GetxController with BaseController {
  final ReturnService returnService = ReturnService();
  var isLoading = false.obs;
  final courierReturnList = <CourierReturnListModel>[].obs;
  final customerReturnList = <CustomerReturnListModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCourierReturnList();
    getCustomerReturnList();
  }

  /// ✅ Courier Return API
  Future<void> courierReturn({
    required Map<String, dynamic> body,
    VoidCallback? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      final CourierReturnResponse response = await returnService
          .courierReturnApi(body);
      // ✅ Close dialog
      Get.back();
      // ✅ Show success message
      AppAlerts.success(response.message);
      // ✅ Call onSuccess callback if provided
      onSuccess?.call();
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Customer Return API
  Future<void> customerReturn({
    required CustomerReturnRequest request,
    VoidCallback? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      final CustomerReturnResponse response = await returnService
          .customerReturnApi(request.toJson());
      // ✅ Close dialog
      Get.back();
      // ✅ Show success message
      AppAlerts.success(response.message);
      // ✅ Call onSuccess callback if provided
      onSuccess?.call();
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Get Courier Return List
  Future<void> getCourierReturnList({
    String? condition,
    String? claimStatus,
    String? claimResult,
  }) async {
    try {
      isLoading.value = true;
      final response = await returnService.courierReturnList(
        condition: condition,
        claimStatus: claimStatus,
        claimResult: claimResult,
      );
      courierReturnList.value = response
          .map((v) => CourierReturnListModel.fromJson(v))
          .toList();
    } catch (e) {
      handleError(e);
      print("👌👌👌👌 Courier Return Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Get Customer Return List
  Future<void> getCustomerReturnList({
    String? condition,
    String? refundStatus,
  }) async {
    try {
      isLoading.value = true;
      final response = await returnService.customerReturnList(
        condition: condition,
        refundStatus: refundStatus,
      );

      customerReturnList.value = response
          .map((e) => CustomerReturnListModel.fromJson(e))
          .toList();
    } catch (e) {
      handleError(e);
      print("🤖🤖🤖🤖 Customer Return Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearHistory() {
    courierReturnList.clear();
    customerReturnList.clear();
  }
}
