import 'package:dmj_stock_manager/model/create_bill_model.dart';
import 'package:dmj_stock_manager/model/order_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/utils/utils.dart';
import 'package:dmj_stock_manager/view/billings/billing_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/billing_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/services/order_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dmj_stock_manager/model/channel_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../data/app_exceptions.dart';
import '../../model/product_model.dart';
import '../../model/return_order_history_model.dart';
import '../../model/scan_product_response_model.dart';
import '../../view/orders/order_create_bottom_sheet.dart';

class OrderController extends GetxController with BaseController{
  final OrderService orderService = OrderService();
  late final BillingController billingController =
      Get.find<BillingController>();

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
  RxString emailError = ''.obs;

  // Form Logic Methods
  void addItemRow() {
    items.add({
      "product": Rx<ProductModel?>(null), // ✅ reactive
      "quantity": TextEditingController(),
      "unitPrice": TextEditingController(),
    });
  }

  void validateEmail(String value) {
    if (value.isEmpty) {
      emailError.value = '';
    } else if (!Utils.isEmailValid(value)) {
      emailError.value = 'Please enter a valid Email Address';
    } else {
      emailError.value = '';
    }
  }

  bool get isEmailValid => emailError.value.isEmpty;

  void clearForm() {
    selectedChannel.value = null;
    customerNameController.clear();
    channelOrderId.clear();
    emailController.clear();
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
      handleError(e, onRetry: () => getOrderList());
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
        "customer_email": emailController.text,
        "channel_order_id": channelOrderId.text,
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
      AppAlerts.success("Order created successfully ✅");
      resetForm(); // clear form after saving
      getOrderList();
      if(Get.isBottomSheetOpen ?? false) Get.back();
    } catch (e) {
      handleError(e);
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
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
      AppAlerts.success("WPS return completed");
      getOrderList();
    } catch (e) {
      handleError(e);
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
      AppAlerts.success("Customer return completed");
      getOrderList();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
      handleError(e);
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
      AppAlerts.error("No product found for this SKU");
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
    } catch (e) {
      handleError(e, onRetry: ()=> getReturnOrderHistory(reason, condition));
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
      }
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
      if (Get.isDialogOpen ?? false) Get.back();
      AppAlerts.success(apiResponse.message.isEmpty ? "Bill Created" : apiResponse.message);
      debugPrint("✅ Snackbar shown");
      // ✅ Refresh order list
      await getOrderList();
      debugPrint("✅ Order list refreshed");
      Get.to(() => BillingScreen());
      billingController.refreshBills();
    } catch (e) {
      handleError(e);
      if (kDebugMode) print("❌ Unexpected Error: $e");
      if (kDebugMode) print("❌ Error Type: ${e.runtimeType}");
      // ✅ Close dialog first
      // if (Get.isDialogOpen ?? false) {
      //   Get.back();
      // }
      // await Future.delayed(const Duration(milliseconds: 300));
      // Get.snackbar(
      //   "Error",
      //   "Failed to create bill: ${e.toString()}",
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   duration: const Duration(seconds: 3),
      // );
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

  void openOrderBottomSheet() {
    Get.bottomSheet(
      OrderCreateBottomSheet(),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.white,
    );
  }

  void addScannedProduct(ProductModel product) {
    // Check if product already exists in items
    final existingIndex = items.indexWhere((item) {
      final p = (item["product"] as Rx<ProductModel?>).value;
      return p?.id == product.id;
    });

    if (existingIndex != -1) {
      // Product exists - increment quantity
      final qtyController =
          items[existingIndex]["quantity"] as TextEditingController;
      int currentQty = int.tryParse(qtyController.text) ?? 0;
      qtyController.text = (currentQty + 1).toString();


      Get.snackbar(
        "Updated",
        "${product.name} quantity increased to ${currentQty + 1}",
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } else {
      // Product doesn't exist - add new row
      items.add({
        "product": Rx<ProductModel?>(product),
        "quantity": TextEditingController(text: "1"),
        "unitPrice": TextEditingController(
          text: product.purchasePrice.toString() ?? "",
        ),
      });

      Get.snackbar(
        "Added",
        "${product.name} added to order",
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void addScannedProductFromScan(ScanProductModel scanProduct) {
    final itemController = Get.find<ItemController>();

    final product = itemController.products.firstWhereOrNull(
      (p) => p.sku == scanProduct.sku,
    );

    if (product == null) {
      Get.snackbar(
        "Not Found",
        "Scanned product not in product list",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    addScannedProduct(product);
  }
}
