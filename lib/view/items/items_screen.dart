import 'dart:typed_data';

import 'package:dmj_stock_manager/res/components/barcode_dialog.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/res/components/widgets/iamge_share_dialog.dart';
import 'package:dmj_stock_manager/view/items/item_detail_screen.dart';
import 'package:dmj_stock_manager/view/stock/stock_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../model/product_model.dart';
import '../../utils/app_alerts.dart';

class ItemsScreen extends StatelessWidget {
  final ItemController itemController = Get.put(ItemController());
  final StockController stockController = Get.find<StockController>();
  ItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            itemController.getProducts();
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: Row(
                  children: [
                    // 🔍 Search Bar
                    Expanded(
                      child: TextFormField(
                        controller: itemController.searchBar,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            onPressed: () {
                              itemController.searchBar.clear();
                              itemController.filteredProducts.assignAll(
                                itemController.products,
                              );
                            },
                            icon: const Icon(Icons.close),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF1A1A4F),
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintText: "Search products...",
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),
                    // 🖨️ Print Button (Square)
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF1A1A4F).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: AppGradientButton(
                        onPressed: () {
                          showProductSelectionDialog(
                            context,
                          ); // 👈 Dialog open hoga
                        },
                        icon: Icons.print,
                      ),
                    ),
                  ],
                ),
              ),

              /// PRODUCT LIST - ✅ Simplified Card with only Image, Name, SKU
              Expanded(
                child: Obx(() {
                  if (itemController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (itemController.filteredProducts.isEmpty) {
                    return const Center(child: Text("No products found"));
                  }

                  return ListView.builder(
                    itemCount: itemController.filteredProducts.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final product = itemController.filteredProducts[index];
                      final imageList = product.productImageVariants;

                      // ✅ Simplified Product Card (Image, Name, SKU only)
                      return InkWell(
                        onTap: () => Get.to(() => ItemDetailScreen(product: product)),
                        child: Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 🖼️ Product Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: imageList.isNotEmpty
                                      ? Image.network(
                                    _getImageUrl(imageList.first),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                      : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                // 📝 Product Name & SKU
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Product Name
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A4F),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),

                                      // SKU
                                      Text(
                                        "SKU: ${product.sku}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Arrow Icon
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for image URL
  String _getImageUrl(dynamic imageItem) {
    if (imageItem is String) {
      return "https://traders.testwebs.in$imageItem";
    } else if (imageItem is Map<String, dynamic> &&
        imageItem.containsKey('image')) {
      return "https://traders.testwebs.in${imageItem['image']}";
    }
    return "https://via.placeholder.com/150"; // Fallback
  }
}

Future<void> showProductSelectionDialog(BuildContext context) async {
  final itemController = Get.find<ItemController>();
  // Local reactive list for selection
  final RxSet<int> selectedIds = <int>{}.obs;

  Get.bottomSheet(
    SizedBox(
      height: Get.height * 0.8, // 80% screen height
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            // Handle bar
            Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select Products", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F))),
                // Select All / Clear All Logic
                Obx(() => TextButton(
                  onPressed: () {
                    if (selectedIds.length == itemController.filteredProducts.length) {
                      selectedIds.clear();
                    } else {
                      selectedIds.addAll(itemController.filteredProducts.map((p) => p.id));
                    }
                  },
                  child: Text(selectedIds.length == itemController.filteredProducts.length ? "Clear All" : "Select All"),
                )),
              ],
            ),
            const Divider(),

            // List Area
            Expanded(
              child: Obx(() {
                if (itemController.filteredProducts.isEmpty) {
                  return const Center(child: Text("No products available"));
                }
                return ListView.builder(
                  itemCount: itemController.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final p = itemController.filteredProducts[index];
                    return Obx(() {
                      final isSelected = selectedIds.contains(p.id);
                      return ListTile(
                        onTap: () => isSelected ? selectedIds.remove(p.id) : selectedIds.add(p.id),
                        contentPadding: EdgeInsets.zero,
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Text("SKU: ${p.sku} | Size: ${p.size}", style: const TextStyle(fontSize: 12)),
                        trailing: Checkbox(
                          activeColor: const Color(0xFF1A1A4F),
                          value: isSelected,
                          onChanged: (v) => v! ? selectedIds.add(p.id) : selectedIds.remove(p.id),
                        ),
                      );
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 15),

            // Print Button
            Obx(() => AppGradientButton(
              width: double.infinity,
              height: 50,
              onPressed: selectedIds.isEmpty
                  ? null // Disable button if nothing selected
                  : () async {
                final selectedList = itemController.filteredProducts
                    .where((p) => selectedIds.contains(p.id))
                    .toList();
                Get.back(); // Close sheet
                // Make sure this function exists in your screen/controller
                await _printSelectedProducts(context, selectedList);
              },
              text: "Print ${selectedIds.length} Barcodes",
            )),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Future<void> _printSelectedProducts(
    BuildContext context,
    List<ProductModel> products,
    ) async {
  const baseUrl = "https://traders.testwebs.in";

  // loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // 1) fetch all barcode images as bytes
    final Map<int, Uint8List> imageBytes = {};
    for (final p in products) {
      try {
        final imagePath = p.barcodeImage ?? "";
        if (imagePath.isEmpty) continue;
        final url = Uri.parse(baseUrl + imagePath);
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          imageBytes[p.id] = Uint8List.fromList(resp.bodyBytes); // normalize
        }
      } catch (_) {}
    }

    // 2) build PDF with grid of barcode images
    final doc = pw.Document();

    final List<pw.Widget> itemWidgets = [];
    for (final p in products) {
      final bytes = imageBytes[p.id];
      if (bytes == null) continue;

      final pwWidget = pw.Container(
        width: 150, // barcode box width
        height: 80, // barcode box height
        padding: const pw.EdgeInsets.all(4),
        child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
      );
      itemWidgets.add(pwWidget);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          // Wrap = grid layout
          pw.Wrap(spacing: 10, runSpacing: 10, children: itemWidgets),
        ],
      ),
    );

    final pdfBytes = await doc.save();

    // 3) Print / Save dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  } catch (e) {
    debugPrint("Error building/printing barcode PDF: $e");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Printing failed: $e")));
  } finally {
    Get.back(); // close loader
  }
}

void showAddInventoryDialog(ProductModel product, Function(int qty) onAdd) {
  final TextEditingController qtyController = TextEditingController();

  Get.dialog(
    Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add to Inventory",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1A1A4F),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            AppGradientButton(
              width: double.infinity,
              height: 50,
              onPressed: () async {
                if (qtyController.text.isNotEmpty) {
                  int qty = int.tryParse(qtyController.text) ?? 0;
                  onAdd(qty);
                  Get.back();
                  await Get.to(StockScreen());
                }
              },
              text: "Add",
            ),
          ],
        ),
      ),
    ),
  );
}

void showAdjustInventoryDialog(String sku) {
  final TextEditingController deltaController = TextEditingController(
    text: "0",
  );
  final TextEditingController noteController = TextEditingController();
  String? selectedReason;

  final List<String> reason = ["ORDER", "DAMAGED", "RETURN", "OTHER"];

  Get.dialog(
    Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Adjust Inventory",
                  // "Adjust Inventory\n($sku)",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),

            //Delta Input
            TextField(
              controller: deltaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Delta (use - for reduce)",
                filled: false,
                fillColor: Colors.grey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1A1A4F),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),

            //Reason Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Reason",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: reason
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) => selectedReason = val,
            ),
            const SizedBox(height: 12),

            //Note Field
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: "Note",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            //Submit Button
            AppGradientButton(
              onPressed: () async {
                final delta = int.tryParse(deltaController.text) ?? 0;
                if (selectedReason == null) {
                  Get.snackbar("Error", "Please select a reason");
                  return;
                }
                Get.find<StockController>().adjustInventoryStock(
                  sku: sku,
                  delta: delta,
                  reason: selectedReason!,
                  note: noteController.text,
                );
                Get.back();
                await Get.to(StockScreen());
              },
              text: "Submit",
              width: double.infinity,
              height: 50,
            ),
          ],
        ),
      ),
    ),
  );
}

void handleInventoryAction(ProductModel product) {
  final stockController = Get.find<StockController>();
  final bool isInInventory = stockController.inventoryList.any(
        (item) => item.product == product.id,
  );

  if (isInInventory) {
    // Already exists -> Adjust dialog
    showAdjustInventoryDialog(product.sku);
  } else {
    //Not in Inventory -> Add dialog
    showAddInventoryDialog(product, (qty) {
      stockController.addInventory(productId: product.id, quantity: qty);
    });
  }
}




// import 'dart:typed_data';
//
// import 'package:dmj_stock_manager/res/components/barcode_dialog.dart';
// import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
// import 'package:dmj_stock_manager/res/components/widgets/iamge_share_dialog.dart';
// import 'package:dmj_stock_manager/res/components/widgets/product_list_card_widget.dart';
// import 'package:dmj_stock_manager/view/items/item_detail_screen.dart';
// import 'package:dmj_stock_manager/view/stock/stock_screen.dart';
// import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
// import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// import '../../model/product_model.dart';
// import '../../utils/app_alerts.dart';
//
// class ItemsScreen extends StatelessWidget {
//   final ItemController itemController = Get.put(ItemController());
//   final StockController stockController = Get.find<StockController>();
//   ItemsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             itemController.getProducts();
//           },
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 25,
//                 ),
//                 child: Row(
//                   children: [
//                     // 🔍 Search Bar
//                     Expanded(
//                       child: TextFormField(
//                         controller: itemController.searchBar,
//                         decoration: InputDecoration(
//                           prefixIcon: const Icon(Icons.search),
//                           suffixIcon: IconButton(
//                             onPressed: () {
//                               itemController.searchBar.clear();
//                               itemController.filteredProducts.assignAll(
//                                 itemController.products,
//                               );
//                             },
//                             icon: const Icon(Icons.close),
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey.withOpacity(0.1),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey.shade200),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF1A1A4F),
//                               width: 1,
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                           hintText: "Search products...",
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(width: 10),
//                     // 🖨️ Print Button (Square)
//                     Container(
//                       height: 48,
//                       width: 48,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
//                           begin: Alignment.centerLeft,
//                           end: Alignment.centerRight,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Color(0xFF1A1A4F).withOpacity(0.3),
//                             blurRadius: 8,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: AppGradientButton(
//                         onPressed: () {
//                           showProductSelectionDialog(
//                             context,
//                           ); // 👈 Dialog open hoga
//                         },
//                         icon: Icons.print,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               /// PRODUCT LIST
//               Expanded(
//                 child: Obx(() {
//                   if (itemController.isLoading.value) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (itemController.filteredProducts.isEmpty) {
//                     // ✅ use filtered list
//                     return const Center(child: Text("No products found"));
//                   }
//
//                   return ListView.builder(
//                     // reverse: true,
//                     itemCount: itemController
//                         .filteredProducts
//                         .length, // ✅ use filtered list
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     itemBuilder: (context, index) {
//                       // final reversedIndex = itemController.filteredProducts.length - 1 - index;
//                       final product = itemController
//                           .filteredProducts[index]; // ✅ use filtered list
//
//                       return InkWell(
//                         onTap: ()=>  Get.to(() => ItemDetailScreen(product: product)),
//                         child: ProductCard(
//                           count: index + 1,
//                           product: product,
//                           onShare: () {
//                             showDialog(
//                               context: context,
//                               builder: (_) => ImageShareDialog(product: product),
//                             );
//                           },
//                           onView: () {
//                             showBarcodeDialog(
//                               context,
//                               product.id,
//                               product.barcode,
//                               product.barcodeImage,
//                             );
//                           },
//                           // ✅ ADD button functionality - same as card tap
//                           onAdd: () {
//                             handleInventoryAction(product);
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// Future<void> showProductSelectionDialog(BuildContext context) async {
//   final itemController = Get.find<ItemController>();
//   // Local reactive list for selection
//   final RxSet<int> selectedIds = <int>{}.obs;
//
//   Get.bottomSheet(
//     SizedBox(
//       height: Get.height * 0.8, // 80% screen height
//       child: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//         ),
//         padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
//         child: Column(
//           children: [
//             // Handle bar
//             Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
//             const SizedBox(height: 15),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Select Products", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F))),
//                 // Select All / Clear All Logic
//                 Obx(() => TextButton(
//                   onPressed: () {
//                     if (selectedIds.length == itemController.filteredProducts.length) {
//                       selectedIds.clear();
//                     } else {
//                       selectedIds.addAll(itemController.filteredProducts.map((p) => p.id));
//                     }
//                   },
//                   child: Text(selectedIds.length == itemController.filteredProducts.length ? "Clear All" : "Select All"),
//                 )),
//               ],
//             ),
//             const Divider(),
//
//             // List Area
//             Expanded(
//               child: Obx(() {
//                 if (itemController.filteredProducts.isEmpty) {
//                   return const Center(child: Text("No products available"));
//                 }
//                 return ListView.builder(
//                   itemCount: itemController.filteredProducts.length,
//                   itemBuilder: (context, index) {
//                     final p = itemController.filteredProducts[index];
//                     return Obx(() {
//                       final isSelected = selectedIds.contains(p.id);
//                       return ListTile(
//                         onTap: () => isSelected ? selectedIds.remove(p.id) : selectedIds.add(p.id),
//                         contentPadding: EdgeInsets.zero,
//                         title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
//                         subtitle: Text("SKU: ${p.sku} | Size: ${p.size}", style: const TextStyle(fontSize: 12)),
//                         trailing: Checkbox(
//                           activeColor: const Color(0xFF1A1A4F),
//                           value: isSelected,
//                           onChanged: (v) => v! ? selectedIds.add(p.id) : selectedIds.remove(p.id),
//                         ),
//                       );
//                     });
//                   },
//                 );
//               }),
//             ),
//
//             const SizedBox(height: 15),
//
//             // Print Button
//             Obx(() => AppGradientButton(
//               width: double.infinity,
//               height: 50,
//               onPressed: selectedIds.isEmpty
//                   ? null // Disable button if nothing selected
//                   : () async {
//                 final selectedList = itemController.filteredProducts
//                     .where((p) => selectedIds.contains(p.id))
//                     .toList();
//                 Get.back(); // Close sheet
//                 // Make sure this function exists in your screen/controller
//                 await _printSelectedProducts(context, selectedList);
//               },
//               text: "Print ${selectedIds.length} Barcodes",
//             )),
//           ],
//         ),
//       ),
//     ),
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//   );
// }
// // Future<void> showProductSelectionDialog(BuildContext context) async {
// //   final itemController = Get.find<ItemController>();
// //   final products =
// //       itemController.filteredProducts; // or itemController.products
// //
// //   // local selection state inside the dialog
// //   final Set<int> selectedIds = <int>{};
// //
// //   await showDialog(
// //     context: context,
// //     builder: (_) {
// //       bool selectAll = false;
// //
// //       return StatefulBuilder(
// //         builder: (context, setState) {
// //           return Dialog(
// //             backgroundColor: Colors.white,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: SizedBox(
// //               width: double.maxFinite,
// //               height: MediaQuery.of(context).size.height * 0.7,
// //               child: Column(
// //                 children: [
// //                   ListTile(
// //                     title: const Text(
// //                       "Select Products",
// //                       style: TextStyle(fontWeight: FontWeight.bold),
// //                     ),
// //                     trailing: TextButton(
// //                       onPressed: () {
// //                         setState(() {
// //                           if (selectAll) {
// //                             selectedIds.clear();
// //                             selectAll = false;
// //                           } else {
// //                             selectedIds.clear();
// //                             for (var p in products) {
// //                               selectedIds.add(p.id);
// //                             }
// //                             selectAll = true;
// //                           }
// //                         });
// //                       },
// //                       child: Text(selectAll ? "Clear All" : "Select All"),
// //                     ),
// //                   ),
// //                   const Divider(height: 1),
// //                   Expanded(
// //                     child: products.isEmpty
// //                         ? const Center(child: Text("No products available"))
// //                         : ListView.builder(
// //                             itemCount: products.length,
// //                             itemBuilder: (context, index) {
// //                               final p = products[index];
// //                               final checked = selectedIds.contains(p.id);
// //                               return CheckboxListTile(
// //                                 value: checked,
// //                                 title: Text(p.name),
// //                                 subtitle: Text(
// //                                   "${p.size ?? ''} • ${p.color ?? ''} • ${p.sku ?? ''}",
// //                                 ),
// //                                 onChanged: (v) => setState(() {
// //                                   if (v == true) {
// //                                     selectedIds.add(p.id);
// //                                   } else {
// //                                     selectedIds.remove(p.id);
// //                                   }
// //                                   selectAll =
// //                                       selectedIds.length == products.length;
// //                                 }),
// //                               );
// //                             },
// //                           ),
// //                   ),
// //                   const Divider(height: 1),
// //                   Padding(
// //                     padding: const EdgeInsets.all(12.0),
// //                     child: Row(
// //                       children: [
// //                         TextButton(
// //                           onPressed: () {
// //                             Get.back();
// //                           },
// //                           child: const Text("Cancel"),
// //                         ),
// //                         const Spacer(),
// //                         ElevatedButton.icon(
// //                           icon: const Icon(Icons.print),
// //                           label: const Text(
// //                             "Print Barcodes",
// //                             style: TextStyle(color: Colors.white),
// //                           ),
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: const Color(0xFF1A1A4F),
// //                           ),
// //                           onPressed: () async {
// //                             final selectedProducts = products
// //                                 .where((p) => selectedIds.contains(p.id))
// //                                 .toList();
// //                             if (selectedProducts.isEmpty) {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 const SnackBar(
// //                                   content: Text(
// //                                     "Select at least one product to print.",
// //                                   ),
// //                                 ),
// //                               );
// //                               return;
// //                             }
// //                             Get.back(); // close selection dialog
// //                             await _printSelectedProducts(
// //                               context,
// //                               selectedProducts,
// //                             );
// //                           },
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         },
// //       );
// //     },
// //   );
// // }
//
// Future<void> _printSelectedProducts(
//   BuildContext context,
//   List<ProductModel> products,
// ) async {
//   const baseUrl = "https://traders.testwebs.in";
//
//   // loading indicator
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => const Center(child: CircularProgressIndicator()),
//   );
//
//   try {
//     // 1) fetch all barcode images as bytes
//     final Map<int, Uint8List> imageBytes = {};
//     for (final p in products) {
//       try {
//         final imagePath = p.barcodeImage ?? "";
//         if (imagePath.isEmpty) continue;
//         final url = Uri.parse(baseUrl + imagePath);
//         final resp = await http.get(url);
//         if (resp.statusCode == 200) {
//           imageBytes[p.id] = Uint8List.fromList(resp.bodyBytes); // normalize
//         }
//       } catch (_) {}
//     }
//
//     // 2) build PDF with grid of barcode images
//     final doc = pw.Document();
//
//     final List<pw.Widget> itemWidgets = [];
//     for (final p in products) {
//       final bytes = imageBytes[p.id];
//       if (bytes == null) continue;
//
//       final pwWidget = pw.Container(
//         width: 150, // barcode box width
//         height: 80, // barcode box height
//         padding: const pw.EdgeInsets.all(4),
//         child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
//       );
//       itemWidgets.add(pwWidget);
//     }
//
//     doc.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(20),
//         build: (context) => [
//           // Wrap = grid layout
//           pw.Wrap(spacing: 10, runSpacing: 10, children: itemWidgets),
//         ],
//       ),
//     );
//
//     final pdfBytes = await doc.save();
//
//     // 3) Print / Save dialog
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdfBytes,
//     );
//   } catch (e) {
//     debugPrint("Error building/printing barcode PDF: $e");
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text("Printing failed: $e")));
//   } finally {
//     Get.back(); // close loader
//   }
// }
//
// void showAddInventoryDialog(ProductModel product, Function(int qty) onAdd) {
//   final TextEditingController qtyController = TextEditingController();
//
//   Get.dialog(
//     Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Add to Inventory",
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Get.back(),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//
//             TextField(
//               controller: qtyController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: "Quantity",
//                 filled: true,
//                 fillColor: Colors.grey.shade50,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey.shade200),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Color(0xFF1A1A4F),
//                     width: 1,
//                   ),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             AppGradientButton(
//               width: double.infinity,
//               height: 50,
//               onPressed: () async {
//                 if (qtyController.text.isNotEmpty) {
//                   int qty = int.tryParse(qtyController.text) ?? 0;
//                   onAdd(qty);
//                   Get.back();
//                   await Get.to(StockScreen());
//                 }
//               },
//               text: "Add",
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// void showAdjustInventoryDialog(String sku) {
//   final TextEditingController deltaController = TextEditingController(
//     text: "0",
//   );
//   final TextEditingController noteController = TextEditingController();
//   String? selectedReason;
//
//   final List<String> reason = ["ORDER", "DAMAGED", "RETURN", "OTHER"];
//
//   Get.dialog(
//     Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Adjust Inventory",
//                   // "Adjust Inventory\n($sku)",
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Get.back(),
//                   icon: Icon(Icons.close),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             //Delta Input
//             TextField(
//               controller: deltaController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: "Delta (use - for reduce)",
//                 filled: false,
//                 fillColor: Colors.grey,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.grey),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: Color(0xFF1A1A4F),
//                     width: 1,
//                   ),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//
//             //Reason Dropdown
//             DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 labelText: "Reason",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               items: reason
//                   .map((r) => DropdownMenuItem(value: r, child: Text(r)))
//                   .toList(),
//               onChanged: (val) => selectedReason = val,
//             ),
//             const SizedBox(height: 12),
//
//             //Note Field
//             TextField(
//               controller: noteController,
//               decoration: InputDecoration(
//                 labelText: "Note",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             //Submit Button
//             AppGradientButton(
//               onPressed: () async {
//                 final delta = int.tryParse(deltaController.text) ?? 0;
//                 if (selectedReason == null) {
//                   Get.snackbar("Error", "Please select a reason");
//                   return;
//                 }
//                 Get.find<StockController>().adjustInventoryStock(
//                   sku: sku,
//                   delta: delta,
//                   reason: selectedReason!,
//                   note: noteController.text,
//                 );
//                 Get.back();
//                 await Get.to(StockScreen());
//               },
//               text: "Submit",
//               width: double.infinity,
//               height: 50,
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// void handleInventoryAction(ProductModel product) {
//   final stockController = Get.find<StockController>();
//   final bool isInInventory = stockController.inventoryList.any(
//     (item) => item.product == product.id,
//   );
//
//   if (isInInventory) {
//     // Already exists -> Adjust dialog
//     showAdjustInventoryDialog(product.sku);
//   } else {
//     //Not in Inventory -> Add dialog
//     showAddInventoryDialog(product, (qty) {
//       stockController.addInventory(productId: product.id, quantity: qty);
//     });
//   }
// }
