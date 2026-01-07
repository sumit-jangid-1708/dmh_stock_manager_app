// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:typed_data';

import 'package:dmj_stock_manager/res/components/barcode_dialog.dart';
import 'package:dmj_stock_manager/res/components/widgets/iamge_share_dialog.dart';
import 'package:dmj_stock_manager/res/components/widgets/product_list_card_widget.dart';
import 'package:dmj_stock_manager/res/components/widgets/summary_card_widget.dart';
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
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          showProductSelectionDialog(
                            context,
                          ); // 👈 Dialog open hoga
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A4F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ), // Square shape
                          ),
                          padding: EdgeInsets.zero, // Taaki button square rahe
                        ),
                        child: const Icon(
                          Icons.print,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// PRODUCT LIST
              Expanded(
                child: Obx(() {
                  if (itemController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (itemController.filteredProducts.isEmpty) {
                    // ✅ use filtered list
                    return const Center(child: Text("No products found"));
                  }

                  return ListView.builder(
                    // reverse: true,
                    itemCount: itemController
                        .filteredProducts
                        .length, // ✅ use filtered list
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      // final reversedIndex = itemController.filteredProducts.length - 1 - index;
                      final product = itemController
                          .filteredProducts[index]; // ✅ use filtered list
                      return InkWell(
                        onTap: () {
                          handleInventoryAction(product);
                          // showAddInventoryDialog(product, (qty) {
                          //   stockController.addInventory(
                          //     productId: product.id,
                          //     quantity: qty,
                          //   );
                          // });
                        },
                        child: ProductCard(
                          count: index + 1,
                          product: product, // 👈 pass full ProductModel
                          onShare: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  ImageShareDialog(product: product),
                            );
                          },
                          onView: () {
                            showBarcodeDialog(
                              context,
                              product.barcode,
                              product.barcodeImage,
                            );
                          },
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
}

Future<void> showProductSelectionDialog(BuildContext context) async {
  final itemController = Get.find<ItemController>();
  final products =
      itemController.filteredProducts; // or itemController.products

  // local selection state inside the dialog
  final Set<int> selectedIds = <int>{};

  await showDialog(
    context: context,
    builder: (_) {
      bool selectAll = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      "Select Products",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        setState(() {
                          if (selectAll) {
                            selectedIds.clear();
                            selectAll = false;
                          } else {
                            selectedIds.clear();
                            for (var p in products) {
                              selectedIds.add(p.id);
                            }
                            selectAll = true;
                          }
                        });
                      },
                      child: Text(selectAll ? "Clear All" : "Select All"),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: products.isEmpty
                        ? const Center(child: Text("No products available"))
                        : ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final p = products[index];
                              final checked = selectedIds.contains(p.id);
                              return CheckboxListTile(
                                value: checked,
                                title: Text(p.name),
                                subtitle: Text(
                                  "${p.size ?? ''} • ${p.color ?? ''} • ${p.sku ?? ''}",
                                ),
                                onChanged: (v) => setState(() {
                                  if (v == true) {
                                    selectedIds.add(p.id);
                                  } else {
                                    selectedIds.remove(p.id);
                                  }
                                  selectAll =
                                      selectedIds.length == products.length;
                                }),
                              );
                            },
                          ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: const Text("Cancel"),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.print),
                          label: const Text(
                            "Print Barcodes",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A4F),
                          ),
                          onPressed: () async {
                            final selectedProducts = products
                                .where((p) => selectedIds.contains(p.id))
                                .toList();
                            if (selectedProducts.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Select at least one product to print.",
                                  ),
                                ),
                              );
                              return;
                            }
                            Get.back(); // close selection dialog
                            await _printSelectedProducts(
                              context,
                              selectedProducts,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              // width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Square shape
                  ),
                  padding: EdgeInsets.zero, // Taaki button square rahe
                ),
                onPressed: () async {
                  if (qtyController.text.isNotEmpty) {
                    int qty = int.tryParse(qtyController.text) ?? 0;
                    onAdd(qty);
                    Get.back();
                    await Get.to(StockScreen());
                  }
                },
                child: const Text("Add", style: TextStyle(color: Colors.white)),
              ),
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
              decoration: const InputDecoration(
                labelText: "Delta (use - for reduce)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            //Reason Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Reason",
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: "Note",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            //Submit Button
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
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

/// TOP ROW — Summary cards with space for circular icon button
// Padding(
//   padding: const EdgeInsets.symmetric(
//     horizontal: 15.0,
//     vertical: 12.0,
//   ),
//   child: Container(
//     width: double.infinity,
//     decoration: BoxDecoration(
//       color: const Color(0xFFF5F5F5),
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(
//         color: const Color(0xFFE0E0E0),
//         width: 1,
//       ),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// Top Row with arrow and action buttons
//         Padding(
//           padding: const EdgeInsets.only(
//             top: 12.0,
//             left: 12.0,
//             right: 12.0,
//             bottom: 12.0,
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1A1A4F),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.filter_alt,
//                   size: 18,
//                   color: Colors.white,
//                 ),
//               ),
//               // Spacer so scroll area gets more space
//               Expanded(child: SizedBox()),
//               // Action buttons (Download + Filter)
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: Color(0xFF1A1A4F),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.upload,
//                       size: 18,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   InkWell(
//                     onTap: () =>
//                         itemController.exportProductListToExcel(),
//                     child: Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         color: Color(0xFF1A1A4F),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Icon(
//                         Icons.download,
//                         size: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//
//         const SizedBox(height: 10),
//
//         /// Scrollable summary cards
//         ClipRRect(
//           borderRadius: BorderRadius.circular(
//             20,
//           ), // Match parent container
//           child: Container(
//             height: 100,
//             color: Color(
//               0xFFF5F5F5,
//             ), // Same background as outer container
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 12.0,
//               ),
//               children: const [
//                 SummaryCard(
//                   title: "Total Listed Item",
//                   count: "23",
//                 ),
//                 SizedBox(width: 12),
//                 SummaryCard(title: "Total Purchase", count: "23"),
//                 SizedBox(width: 12),
//                 SummaryCard(title: "Total sales ", count: "23"),
//                 SizedBox(width: 12),
//               ],
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 12), // Add bottom spacing
//       ],
//     ),
//   ),
// ),
