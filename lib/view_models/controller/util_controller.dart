import 'package:dmj_stock_manager/model/scan_product_response_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../model/generate_barcode_model.dart';
import '../services/util_service.dart'; // ← Yeh import add karna

class UtilController extends GetxController {
  final UtilService utilService = UtilService();
  var isLoading = false.obs;
  var barcodeGenerationLoading = false.obs;
  // ← Yeh observables add kar do (optional but recommended)
  var scannedProduct = Rxn<ScanProductResponseModel>(); // Pura response
  var foundProduct = Rxn<ProductModel>(); // Sirf product
  var serialScanned = RxnInt(); // Serial number

  var generatedBarcodes = Rxn<BarcodeListResponseModel>();

  Future<ProductModel?> barcodeScanned(String barcode) async {
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
        Get.snackbar(
          "Product Found!",
          "${scanResponse.product!.name} • ${scanResponse.product!.size} • ${scanResponse.product!.color}",
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Not Found",
          "Product with barcode $barcode not found!",
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }

      print(
        "Barcode Scan Success: ${scanResponse.product?.name ?? 'Not found'}",
      );
    } on AppExceptions catch (e) {
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Barcode Scan Error: $e");
      Get.snackbar(
        "Scan Failed",
        "Something went wrong. Try again.",
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

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

      Get.snackbar(
        "Success!",
        "${result.barcodes?.length ?? 0} barcode(s) generated!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    } on AppExceptions catch (e) {
      Get.snackbar(
        "Error",
        e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        "Failed",
        "Generation failed!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      barcodeGenerationLoading.value = false;
    }
  }
}
