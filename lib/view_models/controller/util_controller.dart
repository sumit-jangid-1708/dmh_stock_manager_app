import 'package:dmj_stock_manager/model/scan_product_response_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../model/generate_barcode_model.dart';
import '../services/util_service.dart';
import 'order_controller.dart'; // ← Yeh import add karna

class UtilController extends GetxController with BaseController{
  final UtilService utilService = UtilService();
  var isLoading = false.obs;
  var barcodeGenerationLoading = false.obs;
  // ← Yeh observables add kar do (optional but recommended)
  var scannedProduct = Rxn<ScanProductResponseModel>(); // Pura response
  var foundProduct = Rxn<ScanProductModel>(); // Sirf product
  var serialScanned = RxnInt(); // Serial number
  var generatedBarcodes = Rxn<BarcodeListResponseModel>();
  final orderController = Get.find<OrderController>();


  Future<ScanProductModel?> barcodeScanned(String barcode) async {
    // Agar pehle se scan chal raha ho to double scan na ho
    if (isLoading.value) return null;

    isLoading.value = true;
    scannedProduct.value = null;
    foundProduct.value = null;
    serialScanned.value = 0;

    try {
      final response = await utilService.barcodeScan(barcode);

      // API response ko model mein convert karo
      final scanResponse = ScanProductResponseModel.fromJson(response);

      // Store kar do observables mein
      scannedProduct.value = scanResponse;
      foundProduct.value = scanResponse.product;
      serialScanned.value = scanResponse.serialScanned ?? 0;

      // Success message (optional)
      if (scanResponse.product != null) {
        orderController.addScannedProductFromScan(
          scanResponse.product!,
        );
        AppAlerts.success("Product Found! ${scanResponse.product!.name} • ${scanResponse.product!.size} • ${scanResponse.product!.color}");
      } else {
        AppAlerts.error("Product with barcode $barcode not found!");
      }
      print(
        "Barcode Scan Success: ${scanResponse.product?.name ?? 'Not found'}",
      );
    // } on AppExceptions catch (e) {
    //   Get.snackbar(
    //     "Error",
    //     e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
    //     duration: const Duration(seconds: 2),
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    } catch (e) {
      print("Barcode Scan Error: $e");
      handleError(e);
    } finally {
      isLoading.value = false;
    }
    return null;
  }

  // ✅ Updated generateBarcode method for UtilController

  Future<void> generateBarcode(int productId, int quantity) async {
    if (quantity <= 0) {
      Get.snackbar(
        "Invalid",
        "Quantity must be > 0",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (barcodeGenerationLoading.value) return;

    barcodeGenerationLoading.value = true;
    generatedBarcodes.value = null;

    final data = {"product_id": productId, "quantity": quantity};

    try {
      final response = await utilService.generateBarcode(data);
      final result = BarcodeListResponseModel.fromJson(response);

      generatedBarcodes.value = result;

      debugPrint("✅ Generated ${result.barcodes?.length ?? 0} barcodes");

      // ✅ No snackbar here - dialog will show success/error

    // } on AppExceptions catch (e) {
    //   debugPrint("❌ Barcode generation error: $e");
    //   Get.snackbar(
    //     "Error",
    //     e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //     snackPosition: SnackPosition.TOP,
    //   );
    //   rethrow; // ✅ Throw error so dialog can catch it
    } catch (e) {
      debugPrint("❌ Unexpected error: $e");
      handleError(e);
      rethrow; // ✅ Throw error so dialog can catch it
    } finally {
      barcodeGenerationLoading.value = false;
    }
  }
}
