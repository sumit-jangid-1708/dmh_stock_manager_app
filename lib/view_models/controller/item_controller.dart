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
import '../../utils/app_lists.dart';

class ItemController extends GetxController with BaseController{
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

  // store filtered vendors
  var filteredProducts = <ProductModel>[].obs;
  final searchBar = TextEditingController();
  var selectedProducts = <ProductModel>[].obs;

  final hsnList = <HsnGstModel>[].obs;
  Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);

  //image slider
RxInt currentIndex = 0.obs;

void updateIndex(int index){
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
                product.name.toLowerCase().contains(query) || // product name
                product.sku.toLowerCase().contains(query), // SKU code
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

  // ✅ Add this method in ItemController - Print multiple different barcodes

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

      // Convert all byte arrays to MemoryImage
      final images = barcodeImages.map((bytes) => pw.MemoryImage(bytes)).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Wrap(
                spacing: 10, // horizontal spacing
                runSpacing: 10, // vertical spacing
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

      // Print the generated PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      debugPrint("✅ Printed ${barcodeImages.length} barcodes successfully");

    } catch (e) {
      debugPrint("❌ Error printing barcodes: $e");
      rethrow; // Let dialog handle the error
    }
  }

  //--------------------------Show products api-------------------------------

  Future<void> getProducts() async {
    isLoading.value = true;
    try {
      final response = await itemService.showProducts();
      final List<dynamic> data = response;
      // fill products
      products.value = data
          .map<ProductModel>((item) => ProductModel.fromJson(item))
          .toList();
      // ✅ Sort products by ID (latest first)
      products.sort((a, b) => b.id.compareTo(a.id));
      // ✅ make filteredProducts same as products initially
      filteredProducts.assignAll(products);
      print("✅ Products fetched: ${products.length}");
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
      print("🚩 Product Error $e");
      handleError(e, onRetry: ()=> getProducts());
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
    List<File> images, // ⬅️ accept List<File>
    String hsn,
  ) async {
    Map<String, String> fields = {
      "vendor": vendorId,
      "prefix_code": skuCode.value.text,
      "name": productName.value.text,
      "size": size,
      "color": color,
      "material": material,
      "unit_purchase_price": purchasePrice,
      "hsn": hsn,
    };

    try {
      isLoading.value = true;
      final response = await itemService.addProductApi(
        fields: fields,
        images: images, // ⬅️ use passed images instead of selectedImage
      );
      final product = ProductModel.fromJson(response);
      // products.add(product);
      await getProducts();
      AppAlerts.success("Product added successfully");

      clearAddProductForm();
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
      if (kDebugMode) {
        print("🚩 Add product Error ❌ Exception Details: $e",); // full stack ya raw details
      }
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Add this method in ItemController class
  void clearAddProductForm() {
    productName.value.clear();
    skuCode.value.clear();
    purchasePrice.value.clear();
    lowStockLimit.value.clear();
    hsnCode.value.clear();

    // Optional: अगर आप चाहते हो कि selected images भी clear हो जाएं
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
      // Get.snackbar(
      //   "Success",
      //   "Excel saved at $path",
      //   snackPosition: SnackPosition.TOP,
      //   duration: const Duration(seconds: 3),
      // );
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
      if (kDebugMode) {
        print("❌ Exception Details: $e"); // full stack ya raw details
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

  // void addMaterial(String newMaterial) {
  //   if (newMaterial.isNotEmpty && !materials.contains(newMaterial)) {
  //     materials.add(newMaterial);
  //   }
  // }

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
    // } on AppExceptions catch (e) {
    //   if (kDebugMode) {
    //     print("❌ HSN API Exception: $e");
    //   }
    //   Get.snackbar(
    //     "Error",
    //     e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //     duration: const Duration(seconds: 2),
    //   );
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
    // } on AppExceptions catch (e) {
    //   Get.snackbar(
    //     "Error",
    //     e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}

// Future<void> addProduct(
//   String vendorId,
//   String color,
//   String size,
//   String material,
// ) async {
//   Map data = {
//     "vendor": vendorId,
//     "prefix_code": skuCode.value.text,
//     "name": productName.value.text,
//     "size": size,
//     "color": color,
//     "material": material,
//   };
//
//   try {
//     isLoading.value = true;
//     final response = await itemService.addProductApi(data);
//     final product = ProductModel.fromJson(response);
//     products.add(product);
//     getProducts();
//
//     Get.snackbar("Success", "Product added successfully");
//   } catch (e) {
//     print("🚩product Error $e");
//     Get.snackbar('Error', 'Failed to add Product');
//   } finally {
//     isLoading.value = false;
//   }
// }
// Future<void> printBarcode(Uint8List imageBytes, ) async {
//   try {
//     final pdf = pw.Document();
//
//     final image = pw.MemoryImage(imageBytes);
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Center(
//             child: pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.center,
//               children: [
//                 pw.Text('Product Barcode', style: pw.TextStyle(fontSize: 20)),
//                 pw.SizedBox(height: 20),
//                 pw.Image(image, width: 230), // 👈 API Image
//               ],
//             ),
//           );
//         },
//       ),
//     );
//
//     // 🔹 Print / Save as PDF
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   } catch (e) {
//     print("Error printing barcode: $e");
//   }
// }
