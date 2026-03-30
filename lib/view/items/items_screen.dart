// lib/view/items/items_screen.dart

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

import '../../model/product_models/product_model.dart';
import '../../res/components/widgets/edit_item_form_bottom_sheet.dart';
import '../../utils/app_alerts.dart';

class ItemsScreen extends StatelessWidget {
  final ItemController itemController = Get.put(ItemController());
  final StockController stockController = Get.find<StockController>();
  final ScrollController _scrollController = ScrollController();
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
                          showProductSelectionDialog(context);
                        },
                        icon: Icons.print,
                      ),
                    ),
                  ],
                ),
              ),

              /// PRODUCT LIST - ✅ Enhanced Card with Edit & Delete Buttons
              Expanded(
                child: Obx(() {
                  if (itemController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (itemController.filteredProducts.isEmpty) {
                    return const Center(child: Text("No products found"));
                  }

                  return Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 6,
                    radius: const Radius.circular(10),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: itemController.filteredProducts.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final product = itemController.filteredProducts[index];
                        final imageList = product.productImageVariants;

                        return InkWell(
                          onTap: () =>
                              Get.to(() => ItemDetailScreen(product: product)),
                          child: Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
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
                                      errorBuilder: (_, __, ___) =>
                                          Container(
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
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
                                        Text(
                                          "SKU: ${product.baseSku}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ✅ Action Buttons Row
                                  Row(
                                    children: [
                                      // Edit Button
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF1A1A4F),
                                              Color(0xFF4A4ABF),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF1A1A4F)
                                                  .withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              Get.bottomSheet(
                                                EditItemFormBottomSheet(
                                                  product: product,
                                                ),
                                                isScrollControlled: true,
                                                backgroundColor:
                                                Colors.transparent,
                                              );
                                            },
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // ✅ Delete Button
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFE53935),
                                              Color(0xFFC62828),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFE53935)
                                                  .withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              _showDeleteConfirmationDialog(
                                                context,
                                                product,
                                              );
                                            },
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
    if (imageItem is ProductImageVariant) {
      return imageItem.url; // full URL already in model
    } else if (imageItem is String && imageItem.startsWith('http')) {
      return imageItem;
    } else if (imageItem is Map<String, dynamic> && imageItem.containsKey('url')) {
      return imageItem['url']?.toString() ?? '';
    }
    return "https://via.placeholder.com/150";
  }

  /// ✅ Delete Confirmation Dialog
  void _showDeleteConfirmationDialog(
      BuildContext context,
      ProductModel product,
      ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 35,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "Delete Product",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A4F),
                ),
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                "Are you sure you want to delete '${product.name}'?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 25),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: AppGradientButton(
                      text: "Cancel",
                      onPressed: () => Get.back(),
                      height: 45,
                      textColor: const Color(0xFF1A1A4F),
                      borderRadius: 12,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Delete Button
                  Expanded(
                    child: Obx(
                          () => Container(
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE53935),
                              Color(0xFFC62828),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppGradientButton(
                          text: "Delete",
                          onPressed: () async {
                            Get.back(); // Close dialog
                            await itemController.deleteProduct(product.id);
                          },
                          height: 45,
                          borderRadius: 12,
                          isLoading: itemController.isLoading.value,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... rest of your existing code (showProductSelectionDialog, etc.) ...

Future<void> showProductSelectionDialog(BuildContext context) async {
  final itemController = Get.find<ItemController>();
  final RxSet<int> selectedIds = <int>{}.obs;

  Get.bottomSheet(
    SizedBox(
      height: Get.height * 0.8,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Products",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A4F),
                  ),
                ),
                Obx(
                      () => TextButton(
                    onPressed: () {
                      if (selectedIds.length ==
                          itemController.filteredProducts.length) {
                        selectedIds.clear();
                      } else {
                        selectedIds.addAll(
                          itemController.filteredProducts.map((p) => p.id),
                        );
                      }
                    },
                    child: Text(
                      selectedIds.length ==
                          itemController.filteredProducts.length
                          ? "Clear All"
                          : "Select All",
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),

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
                        onTap: () => isSelected
                            ? selectedIds.remove(p.id)
                            : selectedIds.add(p.id),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          "SKU: ${p.sku} | Size: ${p.size}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Checkbox(
                          activeColor: const Color(0xFF1A1A4F),
                          value: isSelected,
                          onChanged: (v) => v!
                              ? selectedIds.add(p.id)
                              : selectedIds.remove(p.id),
                        ),
                      );
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 15),

            Obx(
                  () => AppGradientButton(
                width: double.infinity,
                height: 50,
                onPressed: selectedIds.isEmpty
                    ? null
                    : () async {
                  final selectedList = itemController.filteredProducts
                      .where((p) => selectedIds.contains(p.id))
                      .toList();
                  Get.back();
                  await _printSelectedProducts(context, selectedList);
                },
                text: "Print ${selectedIds.length} Barcodes",
              ),
            ),
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

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final Map<int, Uint8List> imageBytes = {};
    for (final p in products) {
      try {
        final imagePath = p.barcodeImage ?? "";
        if (imagePath.isEmpty) continue;
        final url = Uri.parse(baseUrl + imagePath);
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          imageBytes[p.id] = Uint8List.fromList(resp.bodyBytes);
        }
      } catch (_) {}
    }

    final doc = pw.Document();

    final List<pw.Widget> itemWidgets = [];
    for (final p in products) {
      final bytes = imageBytes[p.id];
      if (bytes == null) continue;

      final pwWidget = pw.Container(
        width: 150,
        height: 80,
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
          pw.Wrap(spacing: 10, runSpacing: 10, children: itemWidgets),
        ],
      ),
    );

    final pdfBytes = await doc.save();

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  } catch (e) {
    debugPrint("Error building/printing barcode PDF: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Printing failed: $e")),
    );
  } finally {
    Get.back();
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
    showAdjustInventoryDialog(product.sku);
  } else {
    showAddInventoryDialog(product, (qty) {
      stockController.addInventory(productId: product.id, quantity: qty);
    });
  }
}