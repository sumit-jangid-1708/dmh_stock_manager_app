import 'dart:io';
import 'dart:math';

import 'package:dmj_stock_manager/model/bills_model/create_bill_model.dart';
import 'package:dmj_stock_manager/model/order_models/create_order_response_model.dart';
import 'package:dmj_stock_manager/model/order_models/order_model.dart';
import 'package:dmj_stock_manager/model/order_models/order_status_log_model.dart'; // ✅ NEW
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/utils/utils.dart';
import 'package:dmj_stock_manager/view/billings/billing_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/billing_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
import 'package:dmj_stock_manager/view_models/services/items_service%20.dart';
import 'package:dmj_stock_manager/view_models/services/order_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dmj_stock_manager/model/channel_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/order_models/courier_partner_model.dart';
import '../../model/order_models/order_detail_model.dart';
import '../../model/order_models/order_with_shipment_model.dart';
import '../../model/order_models/shipment_model.dart';
import '../../model/product_models/product_model.dart';
import '../../model/order_models/return_order_history_model.dart';
import '../../model/product_models/scan_product_response_model.dart';
import '../../view/orders/order_create_bottom_sheet.dart';

class OrderController extends GetxController with BaseController {
  final OrderService orderService = OrderService();
  final ItemService itemService = ItemService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final BillingController billingController = Get.find<BillingController>();
  final StockController stockController = Get.find<StockController>();

  var orders = <OrderDetailModel>[].obs;
  var createOrderResponse = <CreateOrderResponseModel>[].obs;
  var isLoading = false.obs;
  var scannedSku = "".obs;

  var countryCode = "".obs;
  var phoneNumber = "".obs;
  final Rx<ChannelModel?> selectedChannel = Rx<ChannelModel?>(null);
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController channelOrderId = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController packageExpenseController = TextEditingController();
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  final RxList<CourierPartnerDetailModel> courierPartners =
      <CourierPartnerDetailModel>[].obs;
  final RxBool isLoadingCouriers = false.obs;
  final RxBool isCreatingCourier = false.obs;

  final RxBool isAddingRemark = false.obs;
  final RxBool isCancellingOrder = false.obs;

  var returnOrders = <ReturnOrderHistory>[].obs;
  var selectedReason = "".obs;
  var selectedCondition = "".obs;

  var selectedMethod = "NET_BANKING".obs;
  var paymentDate = DateTime.now().obs;
  var paidStatus = "UNPAID".obs;
  var transactionId = "".obs;
  var partialAmount = "".obs;
  final billStatus = <CreateBillModel>[].obs;

  var filteredOrders = <OrderDetailModel>[].obs;
  RxString emailError = ''.obs;

  final orderDetail = Rxn<OrderDetailsModel>();
  var isLoadingDetail = false.obs;

  var isCreatingShipment = false.obs;
  var shipments = <ShipmentModel>[].obs;
  var ordersWithShipments = <OrderWithShipmentModel>[].obs;
  var isLoadingShipmentsList = false.obs;

  final RxList<File> selectedPackageImages = <File>[].obs;
  final RxList<String> uploadedPackageImagePaths = <String>[].obs;
  final RxSet<int> uploadingPackageIndices = <int>{}.obs;
  bool get isAnyPackageImageUploading => uploadingPackageIndices.isNotEmpty;

  // ✅ NEW: Order status logs
  final RxList<OrderStatusLog> orderStatusLogs = <OrderStatusLog>[].obs;
  final RxBool isLoadingStatusLogs = false.obs;

  // ──────────────────────────────────────────────────────────────────────────
  // Unchanged methods below — only loadOrderDetail & updateOrderStatus modified
  // ──────────────────────────────────────────────────────────────────────────

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

  void clearBillForm() {
    selectedMethod.value = "NET_BANKING";
    paymentDate.value = DateTime.now();
    paidStatus.value = "UNPAID";
    transactionId.value = "";
    partialAmount.value = "";
  }

  void removeItemRow(int index) => items.removeAt(index);
  void resetForm() => clearForm();

  @override
  void onReady() {
    super.onReady();
    getOrderList();
    fetchCourierPartners();
    getOrdersWithShipments();
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

  Future<void> fetchCourierPartners() async {
    try {
      isLoadingCouriers.value = true;
      final result = await orderService.getCourierPartners();
      courierPartners.assignAll(result);
    } catch (e) {
      handleError(e, onRetry: fetchCourierPartners);
    } finally {
      isLoadingCouriers.value = false;
    }
  }

  Future<void> getOrderList() async {
    try {
      isLoading.value = true;
      final response = await orderService.getOrderDetailApi();
      final List<dynamic> data = response;
      final allOrders =
      data.map((item) => OrderDetailModel.fromJson(item)).toList();
      orders.value = allOrders.where((o) => !o.isDeleted).toList();
      filteredOrders.assignAll(orders);
    } catch (e) {
      handleError(e, onRetry: () => getOrderList());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getOrdersWithShipments() async {
    try {
      isLoadingShipmentsList.value = true;
      final response = await orderService.getOrdersWithShipments();
      debugPrint("📦 Shipments API response length: ${response.length}");
      if (response is! List) {
        debugPrint("❌ Expected List but got: ${response.runtimeType}");
        return;
      }
      ordersWithShipments.value = response
          .map(
            (e) => OrderWithShipmentModel.fromJson(e as Map<String, dynamic>),
      )
          .toList();
      debugPrint(
          "✅ ordersWithShipments loaded: ${ordersWithShipments.length}");
    } catch (e, s) {
      debugPrint("❌ getOrdersWithShipments error: $e\n$s");
      handleError(e, onRetry: getOrdersWithShipments);
    } finally {
      isLoadingShipmentsList.value = false;
    }
  }

  // ✅ NEW: Fetch status logs for a specific order
  Future<void> fetchOrderStatusLogs(int orderId) async {
    try {
      isLoadingStatusLogs.value = true;
      final response = await orderService.getAllOrderStatus(orderId);
      final result = OrderStatusLogResponse.fromJson(
        response as Map<String, dynamic>,
      );
      orderStatusLogs.assignAll(result.data);
      debugPrint("✅ Status logs loaded: ${orderStatusLogs.length}");
    } catch (e) {
      // Non-critical — don't surface error to user; log silently
      debugPrint("❌ fetchOrderStatusLogs error: $e");
    } finally {
      isLoadingStatusLogs.value = false;
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

      final remarkText = remarkController.text.trim();

      final data = {
        "channel": selectedChannel.value?.id,
        "customer_name": customerNameController.text.trim(),
        "customer_email": emailController.text.trim(),
        "channel_order_id": channelOrderId.text.trim(),
        "remarks": remarkText.isNotEmpty ? [remarkText] : [],
        "items": itemList,
        "country_code": countryCode.value,
        "mobile": phoneNumber.value,
        "package_expence":
        double.tryParse(packageExpenseController.text.trim()) ?? 0.0,
      };

      final response = await orderService.createOrderApi(data);
      if (kDebugMode) print("🟢 RAW API RESPONSE: $response");

      if (response is! Map<String, dynamic>) {
        AppAlerts.error("Invalid server response");
        return;
      }

      final bool isSuccess = response.containsKey('order_id') ||
          response.containsKey('id') ||
          response.containsKey('order');
      if (!isSuccess) {
        final firstError = response.values.first;
        final errorMsg = firstError is List
            ? firstError.first.toString()
            : firstError.toString();
        AppAlerts.error(errorMsg);
        return;
      }

      final order = CreateOrderResponseModel.fromJson(response);
      createOrderResponse.add(order);

      if (Get.isBottomSheetOpen ?? false) Get.back();
      AppAlerts.success("Order created successfully ✅");
      clearForm();
      await getOrderList();
      stockController.fetchInventoryList();
    } catch (e) {
      handleError(e);
      if (kDebugMode) print("❌ Create Order Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addRemark(int orderId, String remark) async {
    if (remark.trim().isEmpty) {
      AppAlerts.error("Please enter a remark");
      return;
    }
    try {
      isAddingRemark.value = true;
      await orderService.addRemark(orderId, remark.trim());
      AppAlerts.success("Remark added successfully");
      await loadOrderDetail(orderId);
      await getOrderList();
    } catch (e) {
      handleError(e);
    } finally {
      isAddingRemark.value = false;
    }
  }

  Future<void> cancelOrder(int orderId) async {
    try {
      isCancellingOrder.value = true;
      await orderService.cancelOrder(orderId);
      await getOrderList();
      if (Get.isDialogOpen ?? false) Get.back();
      Get.back();
    } catch (e, s) {
      handleError(e);
      debugPrint("🤖🤖 order cancel error $s");
    } finally {
      isCancellingOrder.value = false;
    }
  }

  Future<void> deleteOrderFromList(int orderId) async {
    try {
      await orderService.softDeleteOrder(orderId);
      orders.removeWhere((o) => o.id == orderId);
      filteredOrders.removeWhere((o) => o.id == orderId);
    } catch (e) {
      handleError(e);
    }
  }

  void setScannedSku(String sku) {
    final itemController = Get.find<ItemController>();
    final product =
    itemController.products.firstWhereOrNull((p) => p.sku == sku);
    if (product != null) {
      final existingIndex = items.indexWhere((item) {
        final p = (item["product"] as Rx<ProductModel?>?)?.value;
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

  Future<void> createOrderBill(int orderId) async {
    double amount = 0.0;
    if (paidStatus.value == "PAID") {
      final order = orderDetail.value;
      if (order != null) {
        amount = order.items.fold(0.0, (sum, item) => sum + item.totalPrice);
      }
    } else if (paidStatus.value == "PARTIAL") {
      amount = double.tryParse(partialAmount.value) ?? 0.0;
      if (amount <= 0) {
        AppAlerts.error("Please enter a valid partial amount");
        return;
      }
    }

    String formattedDate =
    DateFormat('yyyy-MM-dd').format(paymentDate.value);
    Map<String, dynamic> data = {
      "payment_method": selectedMethod.value,
      "payment_date": formattedDate,
      "paid_status": paidStatus.value,
      "amount": amount,
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

  Future<void> createCourierPartner({
    required String title,
    required List<String> mediatorTitles,
    VoidCallback? onSuccess,
  }) async {
    if (title.trim().isEmpty) {
      AppAlerts.error("Please enter courier partner name");
      return;
    }
    try {
      isCreatingCourier.value = true;

      final data = {
        "title": title.trim(),
        "mediators": mediatorTitles
            .where((m) => m.trim().isNotEmpty)
            .map((m) => {"title": m.trim()})
            .toList(),
      };

      final response = await orderService.createCourierPartner(data);

      if (response != null && response["data"] != null) {
        final newCourier = CourierPartnerDetailModel.fromJson(
          response["data"] as Map<String, dynamic>,
        );
        courierPartners.add(newCourier);
        AppAlerts.success(
            response["message"] ?? "Courier created successfully ✅");
        onSuccess?.call();
      } else {
        AppAlerts.success("Courier created successfully ✅");
        onSuccess?.call();
        await fetchCourierPartners();
      }
    } catch (e) {
      handleError(e);
    } finally {
      isCreatingCourier.value = false;
    }
  }

  Future<void> createShipment({
    required int orderId,
    required int courierPartnerId,
    required int mediatorId,
    required String trackingId,
    required String shippingDate,
    required String trackingUrl,
    required double shippingExpense,
    required double otherExpense,
    String notes = "",
    VoidCallback? onSuccess,
  }) async {
    if (trackingId.trim().isEmpty) {
      AppAlerts.error("Please enter tracking ID");
      return;
    }
    try {
      isCreatingShipment.value = true;
      final data = {
        "courier_partner": courierPartnerId,
        "mediator": mediatorId,
        "tracking_id": trackingId.trim(),
        "shipping_date": shippingDate,
        "tracking_url": trackingUrl.trim(),
        "shipping_expense": shippingExpense,
        "other_expense": otherExpense,
        "notes": notes.trim(),
      };
      final response = await orderService.createShipment(data, orderId);
      if (response != null) {
        AppAlerts.success(
            response["message"] ?? "Shipment created successfully ✅");
        onSuccess?.call();
        await updateOrderStatus(
          orderId: orderId,
          status: 3,
          note: "Shipped",
        );
        await getOrdersWithShipments();
      } else {
        AppAlerts.error("Failed to create shipment");
      }
    } catch (e) {
      handleError(e);
    } finally {
      isCreatingShipment.value = false;
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
      items.add({
        "product": Rx<ProductModel?>(product),
        "quantity": TextEditingController(text: "1"),
        "unitPrice": TextEditingController(
          text: product.unitPurchasePrice.toString(),
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
    final product = itemController.products
        .firstWhereOrNull((p) => p.sku == scanProduct.sku);
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

  // ✅ UPDATED: Also fetches status logs + refreshes order list
  Future<void> loadOrderDetail(int orderId) async {
    try {
      isLoadingDetail.value = true;
      orderDetail.value = await orderService.getOrderDetailById(orderId);
      debugPrint("✅ Order detail loaded: ${orderDetail.value?.orderId}");
      // Fetch logs in parallel with detail — non-blocking if it fails
      await fetchOrderStatusLogs(orderId);
    } catch (e, s) {
      handleError(e);
      debugPrint("❌ Error loading order detail: $e, $s");
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> uploadPackageImageAtIndex(File image, int index) async {
    uploadingPackageIndices.add(index);
    try {
      final String path = await itemService.uploadImage(image);
      if (index < uploadedPackageImagePaths.length) {
        uploadedPackageImagePaths[index] = path;
      } else {
        while (uploadedPackageImagePaths.length < index) {
          uploadedPackageImagePaths.add('');
        }
        uploadedPackageImagePaths.add(path);
      }
    } catch (e) {
      Get.snackbar("Error", "Image upload failed");
      if (index < selectedPackageImages.length) {
        selectedPackageImages.removeAt(index);
      }
    } finally {
      uploadingPackageIndices.remove(index);
    }
  }

  // ✅ UPDATED: Refreshes order list after status change so cards reflect new status
  Future<void> updateOrderStatus({
    required int orderId,
    required int status,
    required String note,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final Map<String, dynamic> jsonPayload = {
        "note": note,
        "updated_by": "admin",
      };
      if (extraData != null) jsonPayload.addAll(extraData);

      final data = {
        "order_id": orderId,
        "status": status,
        "json": jsonPayload,
      };

      await orderService.updateOrderStatus(data);
      debugPrint(
          "✅ order status updated: orderId=$orderId, status=$status");

      // Refresh detail + logs
      await loadOrderDetail(orderId);
      // ✅ Refresh list so order card chip updates
      await getOrderList();
    } catch (e) {
      debugPrint("❌ updateOrderStatus error: $e");
      handleError("Something went wrong");
    }
  }
}