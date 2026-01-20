import 'package:dmj_stock_manager/model/bestselling_products_model.dart';
import 'package:dmj_stock_manager/model/channel_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/services/home_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../model/stock_details_model.dart';

class HomeController extends GetxController with BaseController{
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

  var bestSellingProducts = <BestSellingProductModel>[].obs;
  var selectedLowStockFilter = "all".obs;
  var bestSellingLimit = 5.obs;
  var selectedStockSource = "stock".obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
    getChannels();
    getStockDetail();
    getBestSellingProducts();
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
    // } on AppExceptions catch (e) {
    //   if (kDebugMode) {
    //     print("❌ Exception Details: $e"); // full stack ya raw details
    //   }
    //   Get.snackbar(
    //     "Error",
    //     e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
    //     duration: const Duration(seconds: 1),
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    } catch (e) {
      print("Error fetching Channels: $e");
      handleError(e, onRetry: ()=> getChannels());
    }
  }

  /// 🟢 Helper: to get channel name by id
  String getChannelNameById(int id) {
    final channel = channels.firstWhereOrNull((c) => c.id == id);
    return channel?.name ?? "Unknown channel";
  }

  Future<void> addChannels() async {
    // ❌ Empty validation
    if (nameController.text.trim().isEmpty) {
      AppAlerts.error("Please enter channel name");
      return;
    }
    // ✅ Payload
    Map data = {"name": nameController.text.trim()};
    try {
      isLoading.value = true;
      final response = await _homeService.addChannelApi(data);// ✅ API Call
      final channel = ChannelModel.fromJson(response);// ✅ Parse response
      channels.add(channel); // ✅ Update list
      nameController.clear();// ✅ Cleanup
      if (Get.isDialogOpen ?? false) Get.back();
      AppAlerts.success("Channel added successfully");
    // } on AppExceptions catch (e) {
    //   if (kDebugMode) {
    //     print("❌ Channel API Error: $e"); // ✅ Backend / API errors
    //   }
    //   Get.snackbar(
    //     "Error",
    //     e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
    //     duration: const Duration(seconds: 1),
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Channel Unexpected Error: $e");// ❌ Unexpected crash
      }
      handleError(e);
      // Get.snackbar(
      //   "Error",
      //   "Something went wrong",
      //   backgroundColor: Colors.redAccent,
      //   colorText: Colors.white,
      // );
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
      print(
        "🦄 First Product: ${stockDetails.isNotEmpty ? stockDetails.first.name : 'No Data'}",
      );
    // } on AppExceptions catch (e) {
    //   if (kDebugMode) {
    //     print("❌ Exception Details: $e"); // full stack ya raw details
    //   }
    //   Get.snackbar(
    //     "Error",
    //     e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
    //     duration: const Duration(seconds: 1),
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      print("Error fetching Stock details: $e");
      handleError(e, onRetry: ()=> getStockDetail());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getBestSellingProducts({int? limit}) async {
    try {
      isLoading.value = true;
      final response = await _homeService.bestSellingProductsApi(
        limit: limit ?? bestSellingLimit.value,
      );
      final result = BestSellingProductsResponseModel.fromJson(response);
      bestSellingProducts.value = result.results;
      // Update low stock count based on best selling products
      final lowStockCount = result.results
          .where((p) => p.quantity > 0 && p.quantity <= p.threshold)
          .length;

      final outOfStockCount = result.results
          .where((p) => p.quantity == 0)
          .length;

      lowStock.value = lowStockCount;
      outOfStock.value = outOfStockCount;

      if (kDebugMode) {
        print("✅ Best Selling Products Count: ${result.count}");
        print("✅ Low Stock: $lowStockCount, Out of Stock: $outOfStockCount");
      }
    // } on AppExceptions catch (e) {
    //   if (kDebugMode) {
    //     print("❌ Exception: $e");
    //   }
    //   Get.snackbar(
    //     "Error",
    //     "Failed to fetch best selling products",
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error: $e");
      }
      handleError(e, onRetry: ()=> getBestSellingProducts(limit: limit));
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ NEW: Change limit dynamically
  void changeBestSellingLimit(int newLimit) {
    bestSellingLimit.value = newLimit;
    getBestSellingProducts(limit: newLimit);
  }

  // ✅ NEW: Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([
      getChannels(),
      getStockDetail(),
      getBestSellingProducts(),
    ]);
    fetchStats();
  }
}
