import 'package:dmj_stock_manager/model/create_bill_model.dart';
import 'package:dmj_stock_manager/model/order_model.dart';
import 'package:dmj_stock_manager/view/billings/billing_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/billing_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/services/order_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dmj_stock_manager/model/channel_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/app_exceptions.dart';
import '../../model/product_model.dart';
import '../../model/return_order_history_model.dart';

class OrderController extends GetxController {
  final OrderService orderService = OrderService();
  final BillingController billingController = Get.find<BillingController>();

  var orders = <OrderDetailModel>[].obs;
  var isLoading = false.obs;
  var scannedSku = "".obs;
  // Form State Variables
  var countryCode = "".obs;
  var phoneNumber = "".obs;
  final Rx<ChannelModel?> selectedChannel = Rx<ChannelModel?>(null);
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController channelOrderId = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  // Return Orders
  var returnOrders = <ReturnOrderHistory>[].obs; // ✅ list of records
  var selectedReason = "".obs; // for dropdown filter
  var selectedCondition = "".obs; // for dropdown filter

  var selectedMethod = "NET_BANKING".obs;
  var paymentDate = DateTime.now().obs;
  var paidStatus = "UNPAID".obs;
  var transactionId = "".obs;
  final billStatus = <CreateBillModel>[].obs;

  var filteredOrders = <OrderDetailModel>[].obs;

  // Form Logic Methods
  void addItemRow() {
    items.add({
      "product": Rx<ProductModel?>(null), // ✅ reactive
      "quantity": TextEditingController(),
      "unitPrice": TextEditingController(),
    });
  }

  void clearForm() {
    selectedChannel.value = null;
    customerNameController.clear();
    channelOrderId.clear();
    remarkController.clear();
    items.clear();
  }

  void removeItemRow(int index) {
    if (items[index]["quantity"] is TextEditingController) {
      (items[index]["quantity"] as TextEditingController).dispose();
    }
    if (items[index]["unitPrice"] is TextEditingController) {
      (items[index]["unitPrice"] as TextEditingController).dispose();
    }
    items.removeAt(index);
  }

  void resetForm() {
    selectedChannel.value = null;
    customerNameController.clear();
    remarkController.clear();
    for (var item in items) {
      if (item["quantity"] is TextEditingController) {
        (item["quantity"] as TextEditingController).dispose();
      }
      if (item["unitPrice"] is TextEditingController) {
        (item["unitPrice"] as TextEditingController).dispose();
      }
    }
    items.clear();
  }

  @override
  void onInit() {
    super.onInit();
    getOrderList();
  }

  @override
  void onClose() {
    customerNameController.dispose();
    remarkController.dispose();
    super.onClose();
  }

  Future<void> getOrderList() async {
    try {
      isLoading.value = true;
      final response = await orderService.getOrderDetailApi();
      final List<dynamic> data = response;
      orders.value = data
          .map((item) => OrderDetailModel.fromJson(item))
          .toList();

      filteredOrders.assignAll(orders);
    } on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error fetching order list $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Create Order Function
  Future<void> createOrder() async {
    try {
      isLoading.value = true;

      // Convert form items into API format
      List<Map<String, dynamic>> itemList = items.map((item) {
        final productRx = item["product"] as Rx<ProductModel?>?;
        final product = productRx?.value;
        final qtyController = item["quantity"] as TextEditingController;
        final priceController = item["unitPrice"] as TextEditingController;

        return {
          "product": product?.id, // product id is required
          "quantity": int.tryParse(qtyController.text) ?? 0,
          "unit_price": priceController.text,
        };
      }).toList();

      // Build request body
      Map<String, dynamic> data = {
        "channel": selectedChannel.value?.id,
        "customer_name": customerNameController.text,
        "remarks": remarkController.text,
        "items": itemList,
        "country_code": countryCode.value,
        "mobile": phoneNumber.value,
      };

      debugPrint("Create order request body: $data");
      final response = await orderService.createOrderApi(data);
      // Parse response
      final order = OrderDetailModel.fromJson(response);
      orders.add(order);
      Get.snackbar(
        'Success',
        'Order created successfully ✅',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      resetForm(); // clear form after saving
      getOrderList();
    } on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> wpsReturn({
    required int productId,
    required int quantity,
    required String condition,
    required int orderId,
    required int channelId,
  }) async {
    try {
      isLoading.value = true;
      final body = {
        "product_id": productId,
        "quantity": quantity,
        "condition": condition,
        "order_id": orderId,
        "channel_id": channelId,
      };
      final response = await orderService.wpsReturnApi(
        body,
      ); // create this in service
      Get.snackbar(
        "Success",
        "WPS return completed",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      getOrderList();
    } on AppExceptions catch (e) {
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceAll(RegExp(r"<[^>]*>"), ""));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> customerReturn({
    required int orderId,
    required int productId,
    required int quantity,
    required String condition,
    required int channelId,
  }) async {
    try {
      isLoading.value = true;
      final body = {
        "order_id": orderId,
        "product_id": productId,
        "quantity": quantity,
        "condition": condition,
        "channel_id": channelId,
      };
      final response = await orderService.customerReturnApi(body);
      Get.snackbar(
        "Success",
        "Customer return completed",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      getOrderList();
    } on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar("Error", e.toString().replaceAll(RegExp(r"<[^>]*>"), ""));
    } finally {
      isLoading.value = false;
    }
  }

  void setScannedSku(String sku) {
    final itemController = Get.find<ItemController>();
    final product = itemController.products.firstWhereOrNull(
      (p) => p.sku == sku,
    );

    if (product != null) {
      final existingIndex = items.indexWhere((item) {
        final p = item["product"] as ProductModel?;
        return p?.id == product.id;
      });

      if (existingIndex != -1) {
        final qtyController =
            items[existingIndex]["quantity"] as TextEditingController;
        int currentQty = int.tryParse(qtyController.text) ?? 0;
        qtyController.text = (currentQty + 1).toString();
      } else {
        addItemRowWithProduct(product);
      }
    } else {
      Get.snackbar(
        "Error",
        "No product found for this SKU",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void addItemRowWithProduct(ProductModel product) {
    items.add({
      "product": Rx<ProductModel?>(product), // ✅ reactive
      "quantity": TextEditingController(text: "1"),
      "unitPrice": TextEditingController(),
    });
  }

  Future<void> getReturnOrderHistory(String reason, String condition) async {
    try {
      isLoading.value = true;
      final response = await orderService.returnOrderHistory(reason, condition);
      // Parse response
      final returnOrderResponse = ReturnOrderHistoryResponse.fromJson(response);
      returnOrders.value = returnOrderResponse.data ?? [];
      print("📦 Return Orders fetched: ${returnOrders.length}");
    } on AppExceptions catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      Get.snackbar(
        "Error",
        "Unable to fetch return order history",
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createOrderBill(int orderId) async {
    // ✅ Convert DateTime to ISO 8601 string format (YYYY-MM-DD)
    String formattedDate = DateFormat('yyyy-MM-dd').format(paymentDate.value);
    Map<String, dynamic> data = {
      "payment_method": selectedMethod.value,
      "payment_date": formattedDate,
      "paid_status": paidStatus.value,
    };
    // ✅ Only add transaction_id if it's not empty
    if (transactionId.value.isNotEmpty) {
      data["transaction_id"] = transactionId.value;
    }

    try {
      isLoading.value = true;
      debugPrint("🚀 Starting API call for order: $orderId");
      final response = await orderService.createBill(data, orderId);
      debugPrint("✅ API Response received: $response");
      // ✅ Check if response is valid
      if (response == null) {
        throw Exception("Empty response from server");
      }
      // ✅ Response single object hai, list nahi
      final apiResponse = CreateBillModel.fromJson(response);
      debugPrint("✅ Parsed response: ${apiResponse.message}");
      // ✅ First close dialog, then show success
      if (Get.isDialogOpen ?? false) {
        Get.back();
        debugPrint("✅ Dialog closed");
      }
      // await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        "Success",
        apiResponse.message.isNotEmpty
            ? apiResponse.message
            : "Bill created successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        // duration: const Duration(seconds: 2),
      );
      debugPrint("✅ Snackbar shown");
      // ✅ Refresh order list
      await getOrderList();
      debugPrint("✅ Order list refreshed");
      Get.to(() => BillingScreen());
      billingController.refreshBills();
    } on AppExceptions catch (e) {
      if (kDebugMode) print("❌ API Error: $e");
      // ✅ Close dialog first
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      if (kDebugMode) print("❌ Unexpected Error: $e");
      if (kDebugMode) print("❌ Error Type: ${e.runtimeType}");
      // ✅ Close dialog first
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        "Error",
        "Failed to create bill: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterOrders(String query) {
    if (query.isEmpty) {
      filteredOrders.assignAll(orders);
    } else {
      filteredOrders.assignAll(
        orders.where((order) {
          final name = order.customerName.toLowerCase() ?? "";
          final id = order.id.toString();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || id.contains(searchLower);
        }).toList(),
      );
    }
  }
}
