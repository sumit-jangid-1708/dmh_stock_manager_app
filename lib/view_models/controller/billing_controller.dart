import 'package:dmj_stock_manager/view_models/services/billing_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../model/bill_response_model.dart';

class BillingController extends GetxController {
  final BillingService billingService = BillingService();

  // ✅ Bill list and pagination state
  final bills = <BillModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  var currentPage = 1.obs;
  var totalCount = 0.obs;

  // ✅ Search and filter
  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  // ✅ Scroll controller for pagination
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    getBillDetails();

    // ✅ Setup scroll listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value && hasMore.value) {
          loadMoreBills();
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // ✅ Initial load
  Future<void> getBillDetails({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        bills.clear();
        hasMore.value = true;
      }

      isLoading.value = true;
      final response = await billingService.getBills(page: currentPage.value);

      BillsResponseModel billResponse = BillsResponseModel.fromJson(response);

      totalCount.value = billResponse.count;

      if (refresh) {
        bills.value = billResponse.results;
      } else {
        bills.addAll(billResponse.results);
      }

      hasMore.value = billResponse.next != null;

      if (kDebugMode) {
        print("✅ Loaded ${billResponse.results.length} bills");
        print("✅ Total: ${billResponse.count}, Has more: ${hasMore.value}");
      }

    } on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e");
      }

      // ✅ Check if token expired
      if (e.toString().contains('Unauthorized') ||
          e.toString().contains('token_not_valid')) {
        Get.snackbar(
          "Session Expired",
          "Please login again",
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );

        // ✅ Clear stored data and redirect to login
        await Future.delayed(const Duration(seconds: 2));
        // Get.offAllNamed('/login'); // Uncomment if you have login route
        return;
      }

      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) print("🚩 Bill Error $e");
      Get.snackbar(
        'Error',
        'Failed to load Bills List: $e',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Load more for pagination
  Future<void> loadMoreBills() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await billingService.getBills(page: currentPage.value);
      BillsResponseModel billResponse = BillsResponseModel.fromJson(response);

      bills.addAll(billResponse.results);
      hasMore.value = billResponse.next != null;

      if (kDebugMode) {
        print("✅ Loaded more: ${billResponse.results.length} bills");
      }

    } catch (e) {
      if (kDebugMode) print("❌ Load more error: $e");
      currentPage.value--; // Rollback page number
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ✅ Search bills
  void searchBills(String query) {
    searchQuery.value = query;
    // TODO: Implement search API call if backend supports it
    // For now, local filtering
  }

  // ✅ Get filtered bills
  List<BillModel> get filteredBills {
    if (searchQuery.value.isEmpty) {
      return bills;
    }

    return bills.where((bill) {
      return bill.customerName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          bill.mobile.contains(searchQuery.value) ||
          bill.id.toString().contains(searchQuery.value);
    }).toList();
  }

  // ✅ Refresh bills
  Future<void> refreshBills() async {
    await getBillDetails(refresh: true);
  }
}