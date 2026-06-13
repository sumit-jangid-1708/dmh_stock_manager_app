import 'package:dmj_stock_manager/model/product_models/bestselling_products_model.dart';
import 'package:dmj_stock_manager/model/channel_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/utils/response_list.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/services/home_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../model/stock_inventory_models/stock_details_model.dart';

class HomeController extends GetxController with BaseController {
  final HomeService _homeService = HomeService();

  var totalStock = 0.obs;
  var lowStock = 0.obs;
  var outOfStock = 0.obs;
  RxDouble totalStockValue = 0.0.obs;
  RxDouble totalSales = 0.0.obs;
  RxDouble totalPurchase = 0.0.obs;
  RxDouble inventoryValue = 0.0.obs;
  var ordersCount = 0.obs;
  var productsCount = 0.obs;
  var vendorsCount = 0.obs;
  var usersCount = 0.obs;
  var purchaseBillsCount = 0.obs;
  var channelsCount = 0.obs;
  var recentOrdersCount = 0.obs;
  var isLoading = false.obs;
  var isDashboardLoading = false.obs;
  var channels = <ChannelModel>[].obs;
  final TextEditingController nameController = TextEditingController();
  var stockResponseModel = <StockResponseModel>[].obs;
  var stockDetails = <StockDetail>[].obs;
  var appUsers = <Map<String, dynamic>>[].obs;
  var userSearchQuery = "".obs;

  var bestSellingProducts = <BestSellingProductModel>[].obs;
  var selectedLowStockFilter = "all".obs;
  var bestSellingLimit = 5.obs;
  var selectedStockSource = "stock".obs;

  @override
  void onInit() {
    super.onInit();
    getDashboardOverview();
    fetchStats();
    getChannels();
    getStockDetail();
    getBestSellingProducts();
  }

  void fetchStats() {
    // 🔗 Call your API service here
    totalStock.value = 0;
    lowStock.value = 0;
    outOfStock.value = 0;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> getDashboardOverview() async {
    try {
      isDashboardLoading.value = true;
      final response = await _homeService.appDashboardApi();
      if (response is! Map) return;

      final summary = response['summary'];
      if (summary is Map) {
        totalStock.value = _asInt(summary['total_stock']);
        lowStock.value = _asInt(summary['low_stock_count']);
        inventoryValue.value = _asDouble(summary['inventory_value']);
        totalStockValue.value = inventoryValue.value;
        totalSales.value = _asDouble(summary['total_sales']);
        totalPurchase.value = _asDouble(summary['total_purchase']);
        ordersCount.value = _asInt(summary['orders_count']);
        productsCount.value = _asInt(summary['products_count']);
        vendorsCount.value = _asInt(summary['vendors_count']);
        usersCount.value = _asInt(summary['users_count']);
        purchaseBillsCount.value = _asInt(summary['purchase_bills_count']);
      }

      final channelList = response['channels'];
      if (channelList is List) channelsCount.value = channelList.length;

      final recentOrders = response['recent_orders'];
      if (recentOrders is List) recentOrdersCount.value = recentOrders.length;
    } catch (e) {
      if (kDebugMode) {
        print("Dashboard overview error: $e");
      }
      handleError(e, onRetry: () => getDashboardOverview());
    } finally {
      isDashboardLoading.value = false;
    }
  }

  Future<void> getAppUsers({String search = ""}) async {
    try {
      isLoading.value = true;
      userSearchQuery.value = search;
      final response = await _homeService.appUsersApi(search: search);
      if (response is Map && response['data'] is List) {
        appUsers.value = List<Map<String, dynamic>>.from(
          (response['data'] as List)
              .map((item) => Map<String, dynamic>.from(item)),
        );
        usersCount.value = _asInt(response['count']);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Users error: $e");
      }
      handleError(e, onRetry: () => getAppUsers(search: search));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getChannels() async {
    try {
      isLoading.value = true;
      final response = await _homeService.getChannelApi();
      final data = responseList(response);
      channels.value = data.map((item) => ChannelModel.fromJson(item)).toList();
    } catch (e) {
      print("Error fetching Channels: $e");
      handleError(e, onRetry: () => getChannels());
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
      final response = await _homeService.addChannelApi(data); // ✅ API Call
      final channel = ChannelModel.fromJson(response); // ✅ Parse response
      channels.add(channel); // ✅ Update list
      nameController.clear(); // ✅ Cleanup
      if (Get.isDialogOpen ?? false) Get.back();
      AppAlerts.success("Channel added successfully");
    } catch (e) {
      if (kDebugMode) {
        print("❌ Channel Unexpected Error: $e"); // ❌ Unexpected crash
      }
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getStockDetail() async {
    try {
      isLoading.value = true;
      final response = await _homeService.stockDetailsApi();
      final stockResponse = StockResponseModel.fromJson(response);
      stockDetails.value = stockResponse.data?.stockDetail ?? [];
      totalStock.value = stockResponse.data!.stockCount!;
      lowStock.value = stockResponse.data!.lowCount!;
      totalStockValue.value = stockResponse.data!.totalStockValue as double;
      print("🦄 Total Stock Count: ${stockResponse.data?.stockCount}");
      print(
        "🦄 First Product: ${stockDetails.isNotEmpty ? stockDetails.first.name : 'No Data'}",
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      print("Error fetching Stock details: $e");
      handleError(e, onRetry: () => getStockDetail());
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
      outOfStock.value = result.results.where((p) => p.quantity == 0).length;

      if (kDebugMode) {
        print("✅ Best Selling Products Count: ${result.count}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error: $e");
      }
      handleError(e, onRetry: () => getBestSellingProducts(limit: limit));
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
      getDashboardOverview(),
      getChannels(),
      getStockDetail(),
      getBestSellingProducts(),
      getAppUsers(search: userSearchQuery.value),
    ]);
    fetchStats();
  }
}
