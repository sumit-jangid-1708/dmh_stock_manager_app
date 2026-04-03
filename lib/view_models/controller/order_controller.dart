import 'dart:math';

import 'package:dmj_stock_manager/model/bills_model/create_bill_model.dart';
import 'package:dmj_stock_manager/model/order_models/create_order_response_model.dart';
import 'package:dmj_stock_manager/model/order_models/order_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/utils/utils.dart';
import 'package:dmj_stock_manager/view/billings/billing_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/billing_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
import 'package:dmj_stock_manager/view_models/services/order_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dmj_stock_manager/model/channel_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/order_models/order_detail_model.dart';
import '../../model/product_models/product_model.dart';
import '../../model/order_models/return_order_history_model.dart';
import '../../model/product_models/scan_product_response_model.dart';
import '../../view/orders/order_create_bottom_sheet.dart';

class OrderController extends GetxController with BaseController {
  final OrderService orderService = OrderService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final BillingController billingController = Get.find<BillingController>();
  final StockController stockController = Get.find<StockController>();

  var orders = <OrderDetailModel>[].obs;
  var createOrderResponse = <CreateOrderResponseModel>[].obs;
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
  final TextEditingController packageExpenseController = TextEditingController();
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  // Return Orders
  var returnOrders = <ReturnOrderHistory>[].obs;
  var selectedReason = "".obs;
  var selectedCondition = "".obs;

  // ✅ Bill Creation Variables
  var selectedMethod = "NET_BANKING".obs;
  var paymentDate = DateTime.now().obs;
  var paidStatus = "UNPAID".obs;
  var transactionId = "".obs;
  var partialAmount = "".obs; // ✅ Added for partial payment amount
  final billStatus = <CreateBillModel>[].obs;

  var filteredOrders = <OrderDetailModel>[].obs;
  RxString emailError = ''.obs;

  final orderDetail = Rxn<OrderDetailsModel>();
  var isLoadingDetail = false.obs;

  // Form Logic Methods
  void addItemRow() {
    items.add({
      "product": Rx<ProductModel?>(null),
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
    countryCode.value = "";
    phoneNumber.value = "";
    emailError.value = "";
    scannedSku.value = "";
    packageExpenseController.text = "";
    customerNameController.text = "";
    channelOrderId.text = "";
    emailController.text = "";
    remarkController.text = "";

    items.clear();

    if (formKey.currentState != null) {
      formKey.currentState!.reset();
    }
  }

  /// ✅ Clear Bill Form
  void clearBillForm() {
    selectedMethod.value = "NET_BANKING";
    paymentDate.value = DateTime.now();
    paidStatus.value = "UNPAID";
    transactionId.value = "";
    partialAmount.value = "";
  }

  void removeItemRow(int index) {
    items.removeAt(index);
  }

  void resetForm() => clearForm();

  @override
  void onReady() {
    super.onReady();
    getOrderList();
  }

  @override
  void onClose() {
    customerNameController.dispose();
    remarkController.dispose();
    emailController.dispose();
    channelOrderId.dispose();
    packageExpenseController.dispose();
    for (var item in items) {
      final qtyController = item["quantity"];
      final priceController = item["unitPrice"];
      if (qtyController is TextEditingController) qtyController.dispose();
      if (priceController is TextEditingController) priceController.dispose();
    }

    super.onClose();
  }

  Future<void> getOrderList() async {
    try {
      isLoading.value = true;
      final response = await orderService.getOrderDetailApi();
      final List<dynamic> data = response;
      orders.value = data.map((item) => OrderDetailModel.fromJson(item)).toList();
      filteredOrders.assignAll(orders);
    } catch (e) {
      handleError(e, onRetry: () => getOrderList());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createOrder() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (phoneNumber.value.isEmpty) {
      AppAlerts.error("Please enter phone number");
      return;
    }

    if (items.isEmpty) {
      AppAlerts.error("Please add at least one product");
      return;
    }

    try {
      isLoading.value = true;

      // ✅ Prepare Item List
      List<Map<String, dynamic>> itemList = items.map((item) {
        final productRx = item["product"] as Rx<ProductModel?>?;
        final product = productRx?.value;
        final qtyController = item["quantity"] as TextEditingController;
        final priceController = item["unitPrice"] as TextEditingController;

        return {
          "product": product?.id,
          "quantity": int.tryParse(qtyController.text) ?? 0,
          "unit_price": double.tryParse(priceController.text) ?? 0.0,
        };
      }).toList();

      // ✅ Calculate Total Amount
      // double totalAmount = 0.0;
      //
      // for (var item in itemList) {
      //   double price = item["unit_price"] ?? 0.0;
      //   int qty = item["quantity"] ?? 0;
      //   totalAmount += price * qty;
      // }

      // ❌ Safety check
      // if (totalAmount <= 0) {
      //   AppAlerts.error("Total amount must be greater than 0");
      //   return;
      // }

      // ✅ Final Payload
      final data = {
        "channel": selectedChannel.value?.id,
        "customer_name": customerNameController.text.trim(),
        "customer_email": emailController.text.trim(),
        "channel_order_id": channelOrderId.text.trim(),
        "remarks": remarkController.text.trim(),
        "items": itemList,
        "country_code": countryCode.value,
        "mobile": phoneNumber.value,
        "package_expence": double.tryParse(packageExpenseController.text.trim()) ?? 0.0,
        // "total_amount": totalAmount,
      };

      // ✅ API Call
      final response = await orderService.createOrderApi(data);

      print("🟢 RAW API RESPONSE: $response");

      // ✅ Proper Response Handling
      if (response is Map<String, dynamic>) {
        if (response.containsKey("error")) {
          AppAlerts.error(response["error"] ?? "Something went wrong");
          return;
        }

        final order = CreateOrderResponseModel.fromJson(response);
        createOrderResponse.add(order);
      } else {
        AppAlerts.error("Invalid server response");
        return;
      }

      if (Get.isBottomSheetOpen ?? false) Get.back();

      AppAlerts.success("Order created successfully ✅");

      clearForm();
      await getOrderList();
      stockController.fetchInventoryList();

    } catch (e) {
      handleError(e);
      print("❌ Create Order Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setScannedSku(String sku) {
    final itemController = Get.find<ItemController>();
    final product = itemController.products.firstWhereOrNull((p) => p.sku == sku);

    if (product != null) {
      final existingIndex = items.indexWhere((item) {
        final p = (item["product"] as Rx<ProductModel?>?)?.value;
        return p?.id == product.id;
      });

      if (existingIndex != -1) {
        final qtyController = items[existingIndex]["quantity"] as TextEditingController;
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
      "product": Rx<ProductModel?>(product),
      "quantity": TextEditingController(text: "1"),
      "unitPrice": TextEditingController(),
    });
  }

  Future<void> getReturnOrderHistory(String reason, String condition) async {
    try {
      isLoading.value = true;
      final response = await orderService.returnOrderHistory(reason, condition);
      final returnOrderResponse = ReturnOrderHistoryResponse.fromJson(response);
      returnOrders.value = returnOrderResponse.data ?? [];
    } catch (e) {
      handleError(e, onRetry: () => getReturnOrderHistory(reason, condition));
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Create Order Bill with Amount Calculation
  Future<void> createOrderBill(int orderId) async {
    // ✅ Calculate amount based on paid status
    double amount = 0.0;

    if (paidStatus.value == "PAID") {
      // PAID: Order ka total amount
      final order = orderDetail.value;
      if (order != null) {
        amount = order.items.fold(0.0, (sum, item) => sum + item.totalPrice);
      }
    } else if (paidStatus.value == "PARTIAL") {
      // PARTIAL: User entered amount
      amount = double.tryParse(partialAmount.value) ?? 0.0;

      // ✅ Validation: Partial amount cannot be 0 or empty
      if (amount <= 0) {
        AppAlerts.error("Please enter a valid partial amount");
        return;
      }
    } else if (paidStatus.value == "UNPAID") {
      // UNPAID: Amount = 0
      amount = 0.0;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(paymentDate.value);

    Map<String, dynamic> data = {
      "payment_method": selectedMethod.value,
      "payment_date": formattedDate,
      "paid_status": paidStatus.value,
      "amount": amount, // ✅ Added amount field
    };

    if (transactionId.value.isNotEmpty) {
      data["transaction_id"] = transactionId.value;
    }

    try {
      isLoading.value = true;
      final response = await orderService.createBill(data, orderId);

      if (response == null) throw Exception("Empty response from server");

      final apiResponse = CreateBillModel.fromJson(response);

      if (Get.isDialogOpen ?? false) Get.back();

      AppAlerts.success(
        apiResponse.message.isEmpty ? "Bill Created" : apiResponse.message,
      );

      // ✅ Clear bill form after success
      clearBillForm();

      await getOrderList();
      Get.to(() => BillingScreen());
      billingController.refreshBills();
    } catch (e) {
      handleError(e);
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
          final name = order.customerName.toLowerCase();
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
    final existingIndex = items.indexWhere((item) {
      final p = (item["product"] as Rx<ProductModel?>).value;
      return p?.id == product.id;
    });

    if (existingIndex != -1) {
      final qtyController = items[existingIndex]["quantity"] as TextEditingController;
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
      items.add({
        "product": Rx<ProductModel?>(product),
        "quantity": TextEditingController(text: "1"),
        "unitPrice": TextEditingController(text: product.unitPurchasePrice.toString()),
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
    final product = itemController.products.firstWhereOrNull((p) => p.sku == scanProduct.sku);
    if (product == null) {
      Get.snackbar("Not Found", "Scanned product not in product list",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    addScannedProduct(product);
  }

  Future<void> loadOrderDetail(int orderId) async {
    try {
      isLoadingDetail.value = true;
      orderDetail.value = await orderService.getOrderDetailById(orderId);
      debugPrint("✅ Order detail loaded: ${orderDetail.value?.orderId}");
    } catch (e, s) {
      handleError(e);
      debugPrint("❌ Error loading order detail: $e, $s");
    } finally {
      isLoadingDetail.value = false;
    }
  }
}