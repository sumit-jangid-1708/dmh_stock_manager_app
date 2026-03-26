// lib/view_models/controller/item_controller.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dmj_stock_manager/model/product_models/hsn_model.dart';
import 'package:dmj_stock_manager/model/product_models/product_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/services/items_service%20.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/app_exceptions.dart';
import '../../model/product_models/product_delete_response_model.dart';
import '../../utils/app_lists.dart';

class ItemController extends GetxController with BaseController {
  final ItemService itemService = ItemService();
  final products = <ProductModel>[].obs;
  var isLoading = false.obs;
  final RxList<File> selectedImage = <File>[].obs;
  final ImagePicker picker = ImagePicker();

  final productName = TextEditingController().obs;
  final skuCode = TextEditingController().obs;
  var purchasePrice = TextEditingController().obs;
  var lowStockLimit = TextEditingController().obs;
  final hsnCode = TextEditingController().obs;
  final description = TextEditingController().obs;
  final weightBefore = TextEditingController().obs;
  final weightAfter = TextEditingController().obs;

  // store filtered vendors
  var filteredProducts = <ProductModel>[].obs;
  final searchBar = TextEditingController();
  var selectedProducts = <ProductModel>[].obs;

  final hsnList = <HsnGstModel>[].obs;
  Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);

  //image slider
  RxInt currentIndex = 0.obs;

  void updateIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    getProducts();
    getHsnList();
    filteredProducts.assignAll(products);

    // Search listener
    searchBar.addListener(() {
      final query = searchBar.text.toLowerCase();
      if (query.isEmpty) {
        filteredProducts.assignAll(products);
      } else {
        filteredProducts.assignAll(
          products.where(
                (product) =>
            product.name.toLowerCase().contains(query) ||
                product.sku.toLowerCase().contains(query),
          ),
        );
      }
    });
  }

  Future<void> pickFromCamera() async {
    if (selectedImage.length >= 6) return;
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      selectedImage.add(File(file.path));
    }
  }

  Future<void> pickFromGalleryMultiple() async {
    if (selectedImage.length >= 6) return;
    final List<XFile> files = await picker.pickMultiImage();
    if (files.isNotEmpty) {
      final remaining = 6 - selectedImage.length;
      selectedImage.addAll(files.take(remaining).map((e) => File(e.path)));
    }
  }

  void removeImage(int index) {
    selectedImage.removeAt(index);
  }

  void clearAll() {
    selectedImage.clear();
  }

  /// Print multiple different barcode images in a single PDF page
  Future<void> printMultipleBarcodes(List<Uint8List> barcodeImages) async {
    if (barcodeImages.isEmpty) {
      Get.snackbar(
        "Error",
        "No barcodes to print",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final pdf = pw.Document();

      final images =
      barcodeImages.map((bytes) => pw.MemoryImage(bytes)).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: images.map((image) {
                  return pw.Container(
                    width: 180,
                    height: 100,
                    alignment: pw.Alignment.center,
                    child: pw.Image(image, width: 150, height: 60),
                  );
                }).toList(),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      debugPrint("✅ Printed ${barcodeImages.length} barcodes successfully");
    } catch (e) {
      debugPrint("❌ Error printing barcodes: $e");
      rethrow;
    }
  }

  //--------------------------Show products api-------------------------------

  Future<void> getProducts() async {
    isLoading.value = true;
    try {
      final response = await itemService.showProducts();
      final List<dynamic> data = response;

      products.value = data
          .map<ProductModel>((item) => ProductModel.fromJson(item))
          .toList();

      products.sort((a, b) => b.id.compareTo(a.id));
      filteredProducts.assignAll(products);

      print("✅ Products fetched: ${products.length}");
    } catch (e) {
      print("🚩 Product Error $e");
      handleError(e, onRetry: () => getProducts());
    } finally {
      isLoading.value = false;
    }
  }

  /// Add product api
  Future<void> addProduct(
      String vendorId,
      String color,
      String size,
      String material,
      String purchasePrice,
      List<File> images,
      int? hsn,
      String? description,
      ) async {
    if (images.isEmpty) {
      AppAlerts.error("Please select at least one product image");
      return;
    }

    for (var image in images) {
      if (!await image.exists()) {
        AppAlerts.error(
            "Selected image no longer exists. Please select again.");
        return;
      }
    }

    Map<String, dynamic> fields = {
      "vendor": vendorId,
      "prefix_code": skuCode.value.text,
      "name": productName.value.text,
      "size": size,
      "color": color,
      "material": material,
      "unit_purchase_price": purchasePrice,
      "hsn": hsn,
      "desc": description,
      "weight_before": weightBefore.value.text.trim().isEmpty
          ? null
          : weightBefore.value.text.trim(),
      "weight_after": weightAfter.value.text.trim().isEmpty
          ? null
          : weightAfter.value.text.trim(),
    };

    try {
      isLoading.value = true;

      final response = await itemService.addProductApi(
        fields: fields,
        images: images,
      );

      final product = ProductModel.fromJson(response);
      await getProducts();
      AppAlerts.success("Product added successfully");

      clearAddProductForm();
    } catch (e, s) {
      if (kDebugMode) {
        print("🚩 Add product Error ❌ Exception Details: $e $s");
      }
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editProduct({
    required int productId,
    required int vendorId,
    required String prefixCode,
    required String color,
    required String size,
    required String material,
    required String purchasePrice,
    required List<File> images,
    int? hsnId,
    String? description,
  }) async {
    Map<String, dynamic> fields = {
      "vendor": vendorId,
      "prefix_code": prefixCode,
      "name": productName.value.text.trim(),
      "size": size,
      "color": color,
      "material": material,
      "unit_purchase_price": purchasePrice,
      "hsn": hsnId,
      "desc": description,
      "weight_before": weightBefore.value.text.trim().isEmpty
          ? null
          : weightBefore.value.text.trim(),
      "weight_after": weightAfter.value.text.trim().isEmpty
          ? null
          : weightAfter.value.text.trim(),
    };

    try {
      isLoading.value = true;

      final response = await itemService.editProduct(
        fields: fields,
        images: images,
        productId: productId,
      );

      if (kDebugMode) {
        print("✅ Product updated: ${response}");
      }

      await getProducts();

      AppAlerts.success("Product updated successfully");

      clearAddProductForm();
    } catch (e, s) {
      if (kDebugMode) {
        print("🚩 Edit product Error ❌: $e $s");
      }
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Delete Product Method
  Future<void> deleteProduct(int productId) async {
    try {
      isLoading.value = true;

      final response = await itemService.deleteProduct(productId);

      // Parse response
      final deleteResponse = ProductDeleteResponse.fromJson(response);

      // Remove from local list
      products.removeWhere((p) => p.id == productId);
      filteredProducts.removeWhere((p) => p.id == productId);

      AppAlerts.success(deleteResponse.message);

      if (kDebugMode) {
        print("✅ Product deleted: ID $productId");
      }
    } catch (e, s) {
      if (kDebugMode) {
        print("🚩 Delete product Error ❌: $e $s");
      }
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear form
  void clearAddProductForm() {
    productName.value.clear();
    skuCode.value.clear();
    purchasePrice.value.clear();
    lowStockLimit.value.clear();
    hsnCode.value.clear();
    description.value.clear();
    weightBefore.value.clear();
    weightAfter.value.clear();
    selectedImage.clear();

    if (kDebugMode) {
      print("✅ Add product form cleared");
    }
  }

  Future<void> exportProductListToExcel() async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        AppAlerts.error("Storage permission is required to export Excel");
        return;
      }
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      sheet.getRangeByName('A1').setText('ID');
      sheet.getRangeByName('B1').setText('Name');
      sheet.getRangeByName('C1').setText('Size');
      sheet.getRangeByName('D1').setText('Color');
      sheet.getRangeByName('E1').setText('Material');
      sheet.getRangeByName('F1').setText('SKU');

      for (int i = 0; i < products.length; i++) {
        final p = products[i];
        final row = i + 2;
        sheet.getRangeByName('A$row').setNumber(p.id.toDouble() ?? 0);
        sheet.getRangeByName('B$row').setText(p.name ?? "");
        sheet.getRangeByName('C$row').setText(p.size ?? "");
        sheet.getRangeByName('D$row').setText(p.color ?? "");
        sheet.getRangeByName('E$row').setText(p.material ?? "");
        sheet.getRangeByName('F$row').setText(p.sku ?? "");
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/products.xlsx";
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      await OpenFile.open(path);
      AppAlerts.success("Excel exported successfully!");
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception Details: $e");
      }
      handleError(e);
    }
  }

  void toggleProduct(ProductModel product) {
    if (selectedProducts.contains(product)) {
      selectedProducts.remove(product);
    } else {
      selectedProducts.add(product);
    }
  }

  void selectAll(List<ProductModel> products) {
    selectedProducts.assignAll(products);
  }

  void clearSelection() {
    selectedProducts.clear();
  }

  Future<void> getHsnList() async {
    try {
      isLoading.value = true;
      final response = await itemService.hsnCodeList();
      if (response is! List) {
        throw Exception("Invalid HSN response format");
      }
      hsnList.assignAll(
        response.map<HsnGstModel>((e) => HsnGstModel.fromJson(e)).toList(),
      );
      if (kDebugMode) {
        print("✅ HSN List fetched: ${hsnList.length}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ HSN Error: $e");
      }
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addHsn(String hsnCode, double gstPercentage) async {
    final alreadyExistsLocally = hsnList.any((e) => e.hsnCode == hsnCode);
    if (alreadyExistsLocally) {
      AppAlerts.error("This Hsn code is already exists");
      return;
    }
    Map<String, dynamic> data = {
      "hsn_code": hsnCode,
      "gst_percentage": gstPercentage,
    };
    try {
      isLoading.value = true;
      final response = await itemService.addHsn(data);
      final newHsn = HsnGstModel.fromJson(response);
      hsnList.add(newHsn);
      AppAlerts.success("Hsn added successfully");
      if (kDebugMode) {
        print("✅ HSN added: $hsnCode with GST: $gstPercentage%");
      }
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}