// lib/view_models/controller/util_controller.dart

import 'package:dmj_stock_manager/model/product_models/scan_product_response_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/product_models/product_serial_stock_model.dart';
import '../../model/vendor_model/generate_barcode_model.dart';
import '../services/util_service.dart';
import 'order_controller.dart';

class UtilController extends GetxController with BaseController {
  late final OrderController orderController;

  @override
  void onReady() {
    super.onReady();
    if (!Get.isRegistered<OrderController>()) {
      throw Exception("OrderController not found. Wrong binding.");
    }
    orderController = Get.find<OrderController>();
  }

  final UtilService utilService = UtilService();
  var isLoading = false.obs;
  var barcodeGenerationLoading = false.obs;
  var scannedProduct = Rxn<ScanProductResponseModel>();
  var foundProduct = Rxn<ScanProductModel>();
  var serialScanned = RxnString();

  // ✅ Naya model use ho raha hai
  var generatedBarcodes = Rxn<ProductSerialStockModel>();

  RxBool isPrinting = false.obs;
  RxInt progress = 0.obs;
  RxString progressText = "Starting...".obs;

  Future<ScanProductModel?> barcodeScanned(String barcode) async {
    if (isLoading.value) return null;
    isLoading.value = true;
    scannedProduct.value = null;
    foundProduct.value = null;
    serialScanned.value = "";

    try {
      final response = await utilService.barcodeScan(barcode);
      final scanResponse = ScanProductResponseModel.fromJson(response);
      scannedProduct.value = scanResponse;
      foundProduct.value = scanResponse.product;
      serialScanned.value = scanResponse.serialScanned;

      if (scanResponse.product != null) {
        orderController.addScannedProductFromScan(scanResponse.product!);
        AppAlerts.success(
          "Product Found! ${scanResponse.product!.name} • ${scanResponse.product!.size} • ${scanResponse.product!.color}",
        );
      } else {
        AppAlerts.error("Product with barcode $barcode not found!");
      }
    } catch (e) {
      debugPrint("Barcode Scan Error: $e");
      handleError(e);
    } finally {
      isLoading.value = false;
    }
    return null;
  }

  /// ✅ Updated — naya ProductSerialStockModel parse karta hai
  Future<void> generateBarcode(int productId, int quantity) async {
    if (quantity <= 0) {
      AppAlerts.error("Invalid, Please enter Quantity");
      return;
    }
    if (barcodeGenerationLoading.value) return;
    barcodeGenerationLoading.value = true;
    generatedBarcodes.value = null;

    final data = {
      "product_id": productId,
      "quantity": quantity,
    };

    try {
      final response = await utilService.generateBarcode(data);

      // ✅ Error check — agar API "error" key bheje
      if (response is Map && response.containsKey('error')) {
        AppAlerts.error(response['error'].toString());
        return;
      }

      final result = ProductSerialStockModel.fromJson(response);
      generatedBarcodes.value = result;

      debugPrint("✅ Generated ${result.serials.length} serials for ${result.productName}");
      debugPrint("📦 Stock: available=${result.totalAvailable}, remaining=${result.remainingStock}");
    } catch (e) {
      debugPrint("❌ Barcode generation error: $e");
      handleError(e);
      rethrow;
    } finally {
      barcodeGenerationLoading.value = false;
    }
  }
}