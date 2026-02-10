import 'package:dmj_stock_manager/model/bills_model/create_bill_model.dart';
import 'package:dmj_stock_manager/model/order_models/create_order_response_model.dart';
import 'package:dmj_stock_manager/model/order_models/order_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/utils/barcode_utils.dart';
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
import '../../model/order_models/order_detail_adapter.dart';
import '../../model/order_models/order_detail_ui_model.dart';
import '../../model/product_models/product_model.dart';
import '../../model/order_models/return_order_history_model.dart';
import '../../model/product_models/scan_product_response_model.dart';
import '../../view/orders/order_create_bottom_sheet.dart';

class OrderController extends GetxController with BaseController {
  final OrderService orderService = OrderService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final BillingController billingController =
      Get.find<BillingController>();
  final StockController stockController = Get.find<StockController>();
  final Map<String, Uint8List> barcodeCache ={};


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
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  // Return Orders
  var returnOrders = <ReturnOrderHistory>[].obs;
  var selectedReason = "".obs;
  var selectedCondition = "".obs;

  var selectedMethod = "NET_BANKING".obs;
  var paymentDate = DateTime.now().obs;
  var paidStatus = "UNPAID".obs;
  var transactionId = "".obs;
  final billStatus = <CreateBillModel>[].obs;

  var filteredOrders = <OrderDetailModel>[].obs;
  RxString emailError = ''.obs;

  final orderDetailUI = Rxn<OrderDetailUIModel>();
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

  /// ✅ Clear form fields without disposing controllers
  /// ✅ Clear form fields WITHOUT disposing
  void clearForm() {
    selectedChannel.value = null;
    countryCode.value = "";
    phoneNumber.value = "";
    emailError.value = "";
    scannedSku.value = "";

    customerNameController.text = "";
    channelOrderId.text = "";
    emailController.text = "";
    remarkController.text = "";

    items.clear();

    if (formKey.currentState != null) {
      formKey.currentState!.reset();
    }

    debugPrint("✅ Form cleared successfully without dispose error");
  }

  /// ✅ Remove single item row WITHOUT disposing

  /// ✅ Remove single item row
  void removeItemRow(int index) {
    // final item = items[index];
    //
    // final qtyController = item["quantity"];
    // final priceController = item["unitPrice"];
    //
    // if (qtyController is TextEditingController) {
    //   qtyController.dispose();
    // }
    // if (priceController is TextEditingController) {
    //   priceController.dispose();
    // }
    items.removeAt(index);
  }

  /// ✅ Reset form - same as clearForm (for backward compatibility)
  void resetForm() {
    clearForm();
  }

  @override
  void onReady() {
    super.onReady();
    getOrderList();
  }

  @override
  void onClose() {
    // ✅ Dispose main form controllers
    customerNameController.dispose();
    remarkController.dispose();
    emailController.dispose();
    channelOrderId.dispose();

    // ✅ Dispose item controllers
    for (var item in items) {
      final qtyController = item["quantity"];
      final priceController = item["unitPrice"];

      if (qtyController is TextEditingController) {
        qtyController.dispose();
      }
      if (priceController is TextEditingController) {
        priceController.dispose();
      }
    }

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
    } catch (e) {
      handleError(e, onRetry: () => getOrderList());
      print("Error fetching order list $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Create Order Function with proper validation
  Future<void> createOrder() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (phoneNumber.value.isEmpty) {
      AppAlerts.error("Please enter phone number");
      return;
    }

    try {
      isLoading.value = true;

      print("🟡 createOrder() STARTED");

      List<Map<String, dynamic>> itemList = items.map((item) {
        final productRx = item["product"] as Rx<ProductModel?>?;
        final product = productRx?.value;
        final qtyController = item["quantity"] as TextEditingController;
        final priceController = item["unitPrice"] as TextEditingController;

        print("🟢 Item Debug → "
            "productId: ${product?.id}, "
            "qty: ${qtyController.text}, "
            "price: ${priceController.text}");

        return {
          "product": product?.id,
          "quantity": int.tryParse(qtyController.text) ?? 0,
          "unit_price": priceController.text,
        };
      }).toList();

      final data = {
        "channel": selectedChannel.value?.id,
        "customer_name": customerNameController.text,
        "customer_email": emailController.text,
        "channel_order_id": channelOrderId.text,
        "remarks": remarkController.text,
        "items": itemList,
        "country_code": countryCode.value,
        "mobile": phoneNumber.value,
      };

      print("🟣 CREATE ORDER PAYLOAD ↓↓↓");
      print(data);

      final response = await orderService.createOrderApi(data);

      print("🟣 CREATE ORDER API RESPONSE ↓↓↓");
      print(response);

      // 🔴 VERY IMPORTANT: before model parsing
      print("🔍 Checking response fields:");
      print("id: ${response['id']}");
      print("channel: ${response['channel']}");
      print("paid_status: ${response['paid_status']}");
      print("created_at: ${response['created_at']}");
      print("items: ${response['items']}");

      final order = CreateOrderResponseModel.fromJson(response);

      print("✅ Order parsed successfully → orderId: ${order.order.id}");

      createOrderResponse.add(order);

      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      AppAlerts.success("Order created successfully ✅");

      clearForm();
      getOrderList();
      stockController.fetchInventoryList();

    } catch (e, s) {
      print("❌ CREATE ORDER FAILED");
      print("Error: $e");
      print("StackTrace: $s");
      handleError(e);
    } finally {
      isLoading.value = false;
      print("🟡 createOrder() FINISHED");
    }
  }


  void setScannedSku(String sku) {
    final itemController = Get.find<ItemController>();
    final product = itemController.products.firstWhereOrNull(
      (p) => p.sku == sku,
    );

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
      print("📦 Return Orders fetched: ${returnOrders.length}");
    } catch (e) {
      handleError(e, onRetry: () => getReturnOrderHistory(reason, condition));
      if (kDebugMode) {
        print("❌ Exception Details: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createOrderBill(int orderId) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(paymentDate.value);
    Map<String, dynamic> data = {
      "payment_method": selectedMethod.value,
      "payment_date": formattedDate,
      "paid_status": paidStatus.value,
    };

    if (transactionId.value.isNotEmpty) {
      data["transaction_id"] = transactionId.value;
    }

    try {
      isLoading.value = true;
      debugPrint("🚀 Starting API call for order: $orderId");
      final response = await orderService.createBill(data, orderId);
      debugPrint("✅ API Response received: $response");

      if (response == null) {
        throw Exception("Empty response from server");
      }

      final apiResponse = CreateBillModel.fromJson(response);
      debugPrint("✅ Parsed response: ${apiResponse.message}");

      if (Get.isDialogOpen ?? false) {
        Get.back();
        debugPrint("✅ Dialog closed");
      }

      if (Get.isDialogOpen ?? false) Get.back();
      AppAlerts.success(
        apiResponse.message.isEmpty ? "Bill Created" : apiResponse.message,
      );
      debugPrint("✅ Snackbar shown");

      await getOrderList();
      debugPrint("✅ Order list refreshed");
      Get.to(() => BillingScreen());
      billingController.refreshBills();
    } catch (e) {
      handleError(e);
      if (kDebugMode) print("❌ Unexpected Error: $e");
      if (kDebugMode) print("❌ Error Type: ${e.runtimeType}");
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
          text: product.purchasePrice.toString(),
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

  // ✅ Add this method to your OrderController

  Future<void> loadOrderDetail(int orderId) async {
    try {
      isLoadingDetail.value = true;
      // 1️⃣ Get old order (from existing orders list or fetch)
      final oldOrder = orders.firstWhereOrNull((o) => o.id == orderId);
      if (oldOrder == null) {
        // Order not in list, fetch all orders
        final response = await orderService.getOrderDetailApi();
        final List<dynamic> data = response;
        final allOrders = data
            .map((item) => OrderDetailModel.fromJson(item))
            .toList();
        final fetchedOrder = allOrders.firstWhereOrNull((o) => o.id == orderId);

        if (fetchedOrder == null) {
          throw Exception("Order not found");
        }
        // 2️⃣ Get barcode data from NEW API
        final barcodeResponse = await orderService.getOrderBarcodes(orderId);
        // 3️⃣ MERGE both into UI Model
        orderDetailUI.value = OrderDetailAdapter.merge(
          fetchedOrder,
          barcodeResponse,
        );
      } else {
        // 2️⃣ Get barcode data from NEW API
        final barcodeResponse = await orderService.getOrderBarcodes(orderId);
        // 3️⃣ MERGE both into UI Model
        orderDetailUI.value = OrderDetailAdapter.merge(
          oldOrder,
          barcodeResponse,
        );
      }

      debugPrint("✅ Order detail loaded successfully");
    } catch (e) {
      handleError(e);
      debugPrint("❌ Error loading order detail: $e");
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<Uint8List> getBarcodeImage(String sku) async{
    if (barcodeCache.containsKey(sku)){
      return barcodeCache[sku]!;
    }

    final barcodeImage = await generateBarcodePng(sku);
    barcodeCache[sku] = barcodeImage;
    return barcodeImage;
  }

  void clearBarcodeCache(){
    barcodeCache.clear();
  }
  // Future<void> loadOrderDetail(int orderId) async {
  //   try {
  //     isLoadingDetail.value = true;
  //     final oldOrder = orders.firstWhereOrNull((o) => o.id == orderId);
  //
  //     if (oldOrder == null) {
  //       final response = await orderService.getOrderDetailApi();
  //       final List<dynamic> data = response;
  //       final allOrders = data.map((item) => OrderDetailModel.fromJson(item)).toList();
  //       final fetchedOrder = allOrders.firstWhereOrNull((o) => o.id == orderId);
  //
  //       if (fetchedOrder == null) {
  //         throw Exception("Order not found");
  //       }
  //       final newOrder = await orderService.getOrderDetailById(orderId);
  //       orderDetailUI.value = OrderDetailAdapter.merge(fetchedOrder, newOrder);
  //     } else {
  //       final newOrder = await orderService.getOrderDetailById(orderId);
  //       orderDetailUI.value = OrderDetailAdapter.merge(oldOrder, newOrder);
  //     }
  //     debugPrint("✅ Order detail loaded successfully");
  //   } catch (e) {
  //     handleError(e);
  //     debugPrint("❌ Error loading order detail: $e");
  //   } finally {
  //     isLoadingDetail.value = false;
  //   }
  // }
}
