import 'package:dmj_stock_manager/model/channel_model.dart';
import 'package:dmj_stock_manager/view_models/services/home_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../model/stock_details_model.dart';

class HomeController extends GetxController {
  final HomeService _homeService = HomeService();
  var totalStock = 0.obs;
  var lowStock = 0.obs;
  var outOfStock = 0.obs;
  RxDouble totalStockValue = 0.0.obs;
  var isLoading = false.obs;
  var channels = <ChannelModel>[].obs;
  final TextEditingController nameController = TextEditingController();
  var stockResponseModel = <StockResponseModel>[].obs;
  var stockDetails = <StockDetail>[].obs;


  @override
  void onInit() {
    super.onInit();
    fetchStats();
    getChannels();
    getStockDetail();
  }

  void fetchStats() {
    // 🔗 Call your API service here
    totalStock.value = 54;
    lowStock.value = 2;
    outOfStock.value = 1;
  }

  Future<void> getChannels() async {
    try {
      isLoading.value = true;
      final response = await _homeService.getChannelApi();
      final List<dynamic> data = response;
      channels.value = data.map((item) => ChannelModel.fromJson(item)).toList();
    } on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error", e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }catch (e) {
      print("Error fetching Channels: $e");
      Get.snackbar(
        "Error",
        "Error fetching Channels ${e.toString().replaceAll(RegExp(r"<[^>]*>"), "")} ",
        backgroundColor: Colors.red,
      );
    }
  }

  /// 🟢 Helper: to get channel name by id
  String getChannelNameById(int id){
    final channel = channels.firstWhereOrNull((c)=> c.id == id);
    return channel?.name ?? "Unknown channel";
  }

  Future<void> addChannels() async {
    Map data = {"name": nameController.text};
    try {
      isLoading.value = true;
      final response = await _homeService.addChannelApi(data);
      // ✅ Check if response contains an error message
      if (response is Map && response.containsKey("name")) {
        String errorMessage = response["name"][0]; // take the first error
        Get.snackbar(
          "Error",
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // stop further execution
      }

      final channel = ChannelModel.fromJson(response);
      channels.add(channel);
      await getChannels(); // fetching the Channels
      nameController.clear();
      Get.snackbar(
        "Success",
        "Channel added successfully",
        backgroundColor: Colors.green,
      );
    } on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error", e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error",
        "Error in adding Channels",
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getStockDetail() async {
    try {
      isLoading.value = true;
      final response = await _homeService.stockDetailsApi();
      // response ek Map hai (not List)
      final stockResponse = StockResponseModel.fromJson(response);
      // yahan tumhari observable list me sirf stockDetail wali list save hogi
      stockDetails.value = stockResponse.data?.stockDetail ?? [];
      totalStock.value = stockResponse.data!.stockCount!;
      lowStock.value = stockResponse.data!.lowCount!;
      totalStockValue.value = stockResponse.data!.totalStockValue as double;

      print("🦄 Total Stock Count: ${stockResponse.data?.stockCount}");
      print("🦄 First Product: ${stockDetails.isNotEmpty ? stockDetails.first.name : 'No Data'}");

    }on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error", e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      print("Error fetching Stock details: $e");
      Get.snackbar(
        "Error",
        "Error fetching stock details",
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }



}
