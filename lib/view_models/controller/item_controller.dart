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

  // ✅ Image upload state
  final RxList<String> uploadedImagePaths = <String>[].obs;
  final RxList<String> existingImageUrls = <String>[].obs;
  final RxSet<int> uploadingIndices = <int>{}.obs;

  // Form text controllers
  final productName = TextEditingController().obs;
  final skuCode = TextEditingController().obs;
  var purchasePrice = TextEditingController().obs;
  var lowStockLimit = TextEditingController().obs;
  final hsnCode = TextEditingController().obs;
  final description = TextEditingController().obs;
  final weightBefore = TextEditingController().obs;
  final weightAfter = TextEditingController().obs;

  // ✅ Multi-label size controllers
  final lengthController = TextEditingController().obs;
  final widthController = TextEditingController().obs;
  final heightController = TextEditingController().obs;

  var filteredProducts = <ProductModel>[].obs;
  final searchBar = TextEditingController();
  var selectedProducts = <ProductModel>[].obs;

  final hsnList = <HsnGstModel>[].obs;
  Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);

  RxInt currentIndex = 0.obs;
  // selected Mode State
  final RxBool isSelectedMode = false.obs;
  final RxSet<int> selectedProductIds = <int>{}.obs;

  void updateIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    getProducts();
    getHsnList();
    filteredProducts.assignAll(products);

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

  void enterSelectionMode(int productId){
    isSelectedMode.value = true;
    selectedProductIds.add(productId);
  }

  void exitSelectionMode() {
    isSelectedMode.value = false;
    selectedProductIds.clear();
  }

  void toggleSelection(int productId){
    if(selectedProductIds.contains(productId)){
      selectedProductIds.remove(productId);
      if (selectedProductIds.isEmpty) exitSelectionMode();
    }else{
      selectedProductIds.add(productId);
    }
  }

  List<ProductModel> get shareSelectedProducts =>
      products.where((p) => selectedProductIds.contains(p.id)).toList();
  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Existing image helpers (edit mode)
  // ─────────────────────────────────────────────────────────────────────────
  void setExistingImages(List<String> urls) {
    existingImageUrls.assignAll(urls.where((u) => u.isNotEmpty).toList());
    if (kDebugMode) print("📋 Existing images set: $existingImageUrls");
  }

  void removeExistingImage(int index) {
    if (index < existingImageUrls.length) {
      existingImageUrls.removeAt(index);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Image upload
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _uploadImageAtIndex(File image, int index) async {
    uploadingIndices.add(index);
    try {
      if (kDebugMode) print("📤 Uploading image at index $index: ${image.path}");
      final String path = await itemService.uploadImage(image);

      if (index < uploadedImagePaths.length) {
        uploadedImagePaths[index] = path;
      } else {
        while (uploadedImagePaths.length < index) {
          uploadedImagePaths.add('');
        }
        uploadedImagePaths.add(path);
      }
      if (kDebugMode) print("✅ Image $index uploaded → $path");
    } catch (e) {
      if (kDebugMode) print("❌ Upload failed for image $index: $e");
      AppAlerts.error("Image ${index + 1} upload failed. Please try again.");
      if (index < selectedImage.length) selectedImage.removeAt(index);
      if (index < uploadedImagePaths.length) uploadedImagePaths.removeAt(index);
    } finally {
      uploadingIndices.remove(index);
    }
  }

  Future<void> pickFromCamera() async {
    if (selectedImage.length >= 6) return;
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    final image = File(file.path);
    final int index = selectedImage.length;
    selectedImage.add(image);
    await _uploadImageAtIndex(image, index);
  }

  Future<void> pickFromGalleryMultiple() async {
    if (selectedImage.length >= 6) return;
    final List<XFile> files = await picker.pickMultiImage();
    if (files.isEmpty) return;
    final remaining = 6 - selectedImage.length;
    final pickedFiles = files.take(remaining).map((e) => File(e.path)).toList();
    for (final image in pickedFiles) {
      final int index = selectedImage.length;
      selectedImage.add(image);
      await _uploadImageAtIndex(image, index);
    }
  }

  void removeImage(int index) {
    selectedImage.removeAt(index);
    if (index < uploadedImagePaths.length) uploadedImagePaths.removeAt(index);
  }

  void clearAll() {
    selectedImage.clear();
    uploadedImagePaths.clear();
    uploadingIndices.clear();
    existingImageUrls.clear();
  }

  bool get isAnyImageUploading => uploadingIndices.isNotEmpty;

  // ─────────────────────────────────────────────────────────────────────────
  // Show products
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> getProducts() async {
    isLoading.value = true;
    try {
      final response = await itemService.showProducts();
      final List<dynamic> data = response;
      products.value = data.map<ProductModel>((item) => ProductModel.fromJson(item)).toList();
      products.sort((a, b) => b.id.compareTo(a.id));
      filteredProducts.assignAll(products);
      print("✅ Products fetched: ${products.length}");
    } catch (e, stackTrace) {
      print("🚩 Product Error: $e");
      print("📍 StackTrace: $stackTrace");
      handleError(e, onRetry: () => getProducts());
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Add product
  //    isMultiLabelSize: true → send unit/length/width/height + computed size
  //                     false → send size string from dropdown
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> addProduct(
      String vendorId,
      String color,
      String size, // used when isMultiLabelSize = false
      String material,
      String purchasePrice,
      int? hsn,
      String? description, {
        bool isMultiLabelSize = false,
        String? unit,
        String? length,
        String? width,
        String? height,
      }) async {
    if (isAnyImageUploading) {
      AppAlerts.error("Please wait, images are still uploading...");
      return;
    }

    final List<String> validPaths = uploadedImagePaths.where((p) => p.isNotEmpty).toList();
    if (validPaths.isEmpty) {
      AppAlerts.error("Please select at least one product image");
      return;
    }

    // ✅ Compute final size string for backend
    final String finalSize = isMultiLabelSize
        ? _buildSizeString(length, width, height, unit)
        : size;

    Map<String, dynamic> fields = {
      "vendor": vendorId,
      "prefix_code": skuCode.value.text,
      "name": productName.value.text,
      "size": finalSize,
      "color": color,
      "material": material,
      "unit_purchase_price": purchasePrice,
      "hsn": hsn,
      "desc": description,
      "weight_before": weightBefore.value.text.trim().isEmpty ? null : weightBefore.value.text.trim(),
      "weight_after": weightAfter.value.text.trim().isEmpty ? null : weightAfter.value.text.trim(),
    };

    // ✅ Send individual dimension fields only for multi-label
    if (isMultiLabelSize) {
      if (unit != null && unit.isNotEmpty) fields["unit"] = unit;
      if (length != null && length.isNotEmpty) fields["length"] = length;
      if (width != null && width.isNotEmpty) fields["width"] = width;
      if (height != null && height.isNotEmpty) fields["height"] = height;
    }

    try {
      isLoading.value = true;
      if (kDebugMode) {
        print("📦 Adding product with ${validPaths.length} image paths:");
        for (final p in validPaths) print("  → $p");
      }

      final response = await itemService.addProductApi(fields: fields, imagePaths: validPaths);
      ProductModel.fromJson(response);
      await getProducts();
      AppAlerts.success("Product added successfully");
      clearAddProductForm();
    } catch (e, s) {
      if (kDebugMode) print("🚩 Add product Error ❌: $e $s");
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Edit product — same multi-label logic
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> editProduct({
    required int productId,
    required int vendorId,
    required String prefixCode,
    required String color,
    required String size,
    required String material,
    required String purchasePrice,
    int? hsnId,
    String? description,
    bool isMultiLabelSize = false,
    String? unit,
    String? length,
    String? width,
    String? height,
  }) async {
    if (isAnyImageUploading) {
      AppAlerts.error("Please wait, images are still uploading...");
      return;
    }

    // ✅ Determine image paths to send
    final List<String> newPaths = uploadedImagePaths.where((p) => p.isNotEmpty).toList();
    final List<String> pathsToSend = newPaths.isNotEmpty ? newPaths : existingImageUrls.toList();

    // ✅ Compute final size
    final String finalSize = isMultiLabelSize
        ? _buildSizeString(length, width, height, unit)
        : size;

    Map<String, dynamic> fields = {
      "vendor": vendorId,
      "prefix_code": prefixCode,
      "name": productName.value.text.trim(),
      "size": finalSize,
      "color": color,
      "material": material,
      "unit_purchase_price": purchasePrice,
      "hsn": hsnId,
      "desc": description,
      "weight_before": weightBefore.value.text.trim().isEmpty ? null : weightBefore.value.text.trim(),
      "weight_after": weightAfter.value.text.trim().isEmpty ? null : weightAfter.value.text.trim(),
    };

    if (isMultiLabelSize) {
      if (unit != null && unit.isNotEmpty) fields["unit"] = unit;
      if (length != null && length.isNotEmpty) fields["length"] = length;
      if (width != null && width.isNotEmpty) fields["width"] = width;
      if (height != null && height.isNotEmpty) fields["height"] = height;
    }

    try {
      isLoading.value = true;
      if (kDebugMode) {
        print("========== EDIT PRODUCT DEBUG ==========");
        print("🆔 Product ID: $productId");
        print("📦 Fields: $fields");
        print("🖼 Paths to send (${pathsToSend.length}): $pathsToSend");
        print("========================================");
      }

      final response = await itemService.editProduct(
        fields: fields,
        imagePaths: pathsToSend,
        productId: productId,
      );

      if (kDebugMode) print("✅ Product updated: $response");
      await getProducts();
      AppAlerts.success("Product updated successfully");
      clearAddProductForm();
    } catch (e, s) {
      if (kDebugMode) {
        print("🚩 Edit product Error ❌: $e");
        print("📍 StackTrace: $s");
      }
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Build size string from dimensions: "10X5X3CM"
  String _buildSizeString(String? length, String? width, String? height, String? unit) {
    final parts = [length, width, height].where((v) => v != null && v.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final dims = parts.join('X');
    final u = (unit != null && unit.isNotEmpty) ? unit : '';
    return '$dims$u';
  }

  /// ✅ Delete Product
  Future<void> deleteProduct(int productId) async {
    try {
      isLoading.value = true;
      final response = await itemService.deleteProduct(productId);
      final deleteResponse = ProductDeleteResponse.fromJson(response);
      products.removeWhere((p) => p.id == productId);
      filteredProducts.removeWhere((p) => p.id == productId);
      AppAlerts.success(deleteResponse.message);
      if (kDebugMode) print("✅ Product deleted: ID $productId");
    } catch (e, s) {
      if (kDebugMode) print("🚩 Delete product Error ❌: $e $s");
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear form + all image + dimension state
  void clearAddProductForm() {
    productName.value.clear();
    skuCode.value.clear();
    purchasePrice.value.clear();
    lowStockLimit.value.clear();
    hsnCode.value.clear();
    description.value.clear();
    weightBefore.value.clear();
    weightAfter.value.clear();
    lengthController.value.clear();
    widthController.value.clear();
    heightController.value.clear();
    selectedImage.clear();
    uploadedImagePaths.clear();
    uploadingIndices.clear();
    existingImageUrls.clear();
    if (kDebugMode) print("✅ Form cleared");
  }

  Future<void> printMultipleBarcodes(List<Uint8List> barcodeImages) async {
    if (barcodeImages.isEmpty) {
      Get.snackbar("Error", "No barcodes to print", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    try {
      final pdf = pw.Document();
      final images = barcodeImages.map((bytes) => pw.MemoryImage(bytes)).toList();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => [
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: images.map((image) => pw.Container(
                width: 180, height: 100,
                alignment: pw.Alignment.center,
                child: pw.Image(image, width: 150, height: 60),
              )).toList(),
            ),
          ],
        ),
      );
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
      debugPrint("✅ Printed ${barcodeImages.length} barcodes successfully");
    } catch (e) {
      debugPrint("❌ Error printing barcodes: $e");
      rethrow;
    }
  }

  Future<void> exportProductListToExcel() async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) { AppAlerts.error("Storage permission required"); return; }
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
        sheet.getRangeByName('A$row').setNumber(p.id.toDouble());
        sheet.getRangeByName('B$row').setText(p.name);
        sheet.getRangeByName('C$row').setText(p.size);
        sheet.getRangeByName('D$row').setText(p.color);
        sheet.getRangeByName('E$row').setText(p.material);
        sheet.getRangeByName('F$row').setText(p.sku);
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
      if (kDebugMode) print("❌ Exception Details: $e");
      handleError(e);
    }
  }

  void toggleProduct(ProductModel product) {
    if (selectedProducts.contains(product)) { selectedProducts.remove(product); }
    else { selectedProducts.add(product); }
  }
  void selectAll(List<ProductModel> products) => selectedProducts.assignAll(products);
  void clearSelection() => selectedProducts.clear();

  Future<void> getHsnList() async {
    try {
      isLoading.value = true;
      final response = await itemService.hsnCodeList();
      if (response is! List) throw Exception("Invalid HSN response format");
      hsnList.assignAll(response.map<HsnGstModel>((e) => HsnGstModel.fromJson(e)).toList());
      if (kDebugMode) print("✅ HSN List fetched: ${hsnList.length}");
    } catch (e) {
      if (kDebugMode) print("❌ HSN Error: $e");
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addHsn(String hsnCode, double gstPercentage) async {
    final alreadyExistsLocally = hsnList.any((e) => e.hsnCode == hsnCode);
    if (alreadyExistsLocally) { AppAlerts.error("This Hsn code already exists"); return; }
    try {
      isLoading.value = true;
      final response = await itemService.addHsn({"hsn_code": hsnCode, "gst_percentage": gstPercentage});
      final newHsn = HsnGstModel.fromJson(response);
      hsnList.add(newHsn);
      AppAlerts.success("Hsn added successfully");
    } catch (e) { handleError(e); }
    finally { isLoading.value = false; }
  }
}